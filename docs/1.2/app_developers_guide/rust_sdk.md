# Using the Rust SDK

This tutorial describes how to develop a Sawtooth application with an
example transaction family, XO, using the Sawtooth Rust SDK.

## Overview

This tutorial shows how to use the Sawtooth Rust SDK to
develop a simple application (also called a transaction family). A
transaction family includes these components:

-   A **transaction processor** to define the business logic for your
    application. The transaction processor is responsible for
    registering with the validator, handling transaction payloads and
    associated metadata, and getting/setting state as needed.
-   A **data model** to record and store data.
-   A **client** to handle the client logic for your application. The
    client is responsible for creating and signing transactions,
    combining those transactions into batches, and submitting them to
    the validator. The client can post batches through the REST API or
    connect directly to the validator via [ZeroMQ](http://zeromq.org).

The client and transaction processor must use the same data model,
serialization/encoding method, and addressing scheme.

In this tutorial, you will construct a transaction handler that
implements XO, a distributed version of the two-player game
[tic-tac-toe](https://en.wikipedia.org/wiki/Tic-tac-toe).

> **Note**
>
> This tutorial demonstrates the relevant concepts for a Sawtooth
> transaction processor and client, but does not create a complete
> implementation.


For a full Rust implementation see the [XO transaction
family](https://github.com/hyperledger/sawtooth-sdk-rust/tree/master/examples/xo_rust)


## Prerequisites

This tutorial requires:

 -  A working Sawtooth development environment, as described in [Installing
    Sawtooth]({% link docs/1.2/app_developers_guide/installing_sawtooth.md %})
    or [Creating a Sawtooth
    Network]({% link docs/1.2/app_developers_guide/creating_sawtooth_network.md %})
 -  Familiarity with the basic Sawtooth concepts that are introduced
    in [Installing
    Sawtooth]({% link docs/1.2/app_developers_guide/installing_sawtooth.md %})
 -  Understanding of the Sawtooth transaction and batch data
    structures, as described in [Transaction and
    Batches]({% link docs/1.2/architecture/transactions_and_batches.md %})

## Importing the Rust SDK

> **Note**
>
> The Sawtooth Rust SDK assumes that you have the latest version of Rust
> and its package manager Cargo, which can be installed with
> [rustup](https://rustup.rs/).

Once you\'ve got a working version of Sawtooth, there are a few
additional steps you\'ll need to take to get started developing for
Sawtooth in Rust.

1.  Add Sawtooth to your `Cargo.toml` file. Add sawtooth-sdk with the
    appropriate version to the dependencies section. The Rust SDK is
    located in the Sawtooth SDK Rust repository
    <http://github.com/hyperledger/sawtooth-sdk-rust>.

```ini
[package]
name = "package_name"
version = "0.1.0"
authors = ["..."]

[dependencies]
sawtooth-sdk = "0.2"
// --snip--
```

2.  Import the SDK into your Rust files. At the top of your files,
    specify `extern crate sawtooth_sdk;` and then `use` the packages you
    need from the Sawtooth SDK. For example:

```rust
extern crate sawtooth_sdk;

use sawtooth_sdk::processor::TransactionProcessor;

// --snip--
```

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Transaction Processor: Creating a Transaction Handler

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

A transaction processor has two top-level components:

-   Processor class. The SDK provides a general-purpose processor class.
-   Handler class. The handler class is application-dependent. It
    contains the business logic for a particular family of transactions.
    Multiple handlers can be connected to an instance of the processor
    class.

### Entry Point

Since a transaction processor is a long running process, it must have an
entry point.

In the entry point, the `TransactionProcessor` class is given the
address to connect with the validator and the handler class.

```rust
extern crate sawtooth_sdk;

use sawtooth_sdk::processor::TransactionProcessor;
use handler::XoTransactionHandler;

fn main() {
    let endpoint = "tcp://localhost:4004";

    let handler = XoTransactionHandler::new();
    let mut processor = TransactionProcessor::new(endpoint);

    processor.add_handler(&handler);
    processor.start();
}
```

>  **Note**
>
> If you\'re looking for a working implementation of an XO transaction
> processor in Rust, check out the [xo_rust
> example](https://github.com/hyperledger/sawtooth-sdk-rust/tree/master/examples/xo_rust)
> in the Rust SDK repository.


Handlers get called in two ways: with an `apply` method and with various
\"metadata\" methods. The metadata is used to connect the handler to the
processor. The bulk of the handler, however, is made up of `apply` and
its helper functions.

```rust
use sawtooth_sdk::messages::processor::TpProcessRequest;
use sawtooth_sdk::processor::handler::ApplyError;
use sawtooth_sdk::processor::handler::TransactionContext;
use sawtooth_sdk::processor::handler::TransactionHandler;

pub fn get_xo_prefix() -> String {
    let mut sha = Sha512::new();
    sha.input_str("xo");
    sha.result_str()[..6].to_string()
}

pub struct XoTransactionHandler {
    family_name: String,
    family_versions: Vec<String>,
    namespaces: Vec<String>,
}

impl XoTransactionHandler {
    pub fn new() -> XoTransactionHandler {
        XoTransactionHandler {
            family_name: String::from("xo"),
            family_versions: vec![String::from("1.0")],
            namespaces: vec![String::from(get_xo_prefix().to_string())],
        }
    }
}

impl TransactionHandler for XoTransactionHandler {
    fn family_name(&self) -> String {
        self.family_name.clone()
    }

    fn family_versions(&self) -> Vec<String> {
        self.family_versions.clone()
    }

    fn namespaces(&self) -> Vec<String> {
        self.namespaces.clone()
    }

    fn apply(
        &self,
        request: &TpProcessRequest,
        context: &mut TransactionContext,
    ) -> Result<(), ApplyError> {
        // --snip--
    }
}
```

Note that the `apply` method is inside of the
`impl TransactionHandler for XoTransactionHandler`, which is where most
of the handler\'s work is done.

### The `apply` Method

`apply` gets called with two arguments, `request` and `context`. `request` holds
the command that is to be executed (e.g. taking a space or creating a game),
while `context` contains information about the current state of the game (e.g.
the board layout and whose turn it is).

The transaction contains payload bytes that are opaque to the validator
core, and transaction family specific. When implementing a transaction
handler the binary serialization protocol is up to the implementer.

To separate details of state encoding and
payload handling from validation logic, the XO example has separate
`XoState` and `XoPayload` structs. The `XoPayload` has name, action, and
space fields, while the `XoState` contains information about a game (a
`Game` object). The `Game` struct holds a game name, a board, the
game\'s state, and the identities of both players.

```rust
fn apply(
    &self,
    request: &TpProcessRequest,
    context: &mut TransactionContext,
) -> Result<(), ApplyError> {
    let header = &request.header;
    let signer = match &header.as_ref() {
        Some(s) => &s.signer_public_key,
        None => {
            return Err(ApplyError::InvalidTransaction(String::from(
                "Invalid header",
            )))
        }
    };

    let payload = XoPayload::new(&request.payload)?;

    let mut state = XoState::new(context);

    let game = state.get_game(payload.get_name().as_str())?;

    match payload.get_action().as_str() {
        "delete" => {
            // --snip--
        }
        "create" => {
            // --snip--
        }
        "take" => {
            // --snip--
            }
    }
}
```

For every new payload, the transaction processor validates rules
surrounding the action. If all of the rules validate, then state is
updated based on whether we are creating a game, deleting a game, or
updating the game by taking a space.

### Game Logic

The XO game logic is described in the XO transaction family
specification; see see [XO Transaction
Family]({% link docs/1.2/transaction_family_specifications/xo_transaction_family.md%}#execution)

The validation rules and state updates that are associated with the
`create`, `delete`, and `take` actions are shown below.

#### Create

The `create` action has the following implementation:

```rust
// --snip--
"create" => {
    if game.is_none() {
        let game = Game::new(payload.get_name());
        state.set_game(payload.get_name().as_str(), game)?;
        info!("Created game: {}", payload.get_name().as_str());
    } else {
        return Err(ApplyError::InvalidTransaction(String::from(
            "Invalid action: Game already exists",
        )));
    }
}
// --snip--
```

#### Delete

The `delete` action has the following implementation:

```rust
// --snip--
"delete" => {
    if game.is_none() {
        return Err(ApplyError::InvalidTransaction(String::from(
            "Invalid action: game does not exist",
        )));
    }
    state.delete_game(payload.get_name().as_str())?;
}
// --snip--
```

#### Take

The `take` action has the following implementation:

```rust
// --snip--
"take" => {
        if let Some(mut g) = game {
            match g.get_state().as_str() {
                "P1-WIN" | "P2-WIN" | "TIE" => {
                    return Err(ApplyError::InvalidTransaction(String::from(
                        "Invalid action: Game has ended",
                    )))
                }
                "P1-NEXT" => {
                    let p1 = g.get_player1();
                    if !p1.is_empty() && p1.as_str() != signer {
                        return Err(ApplyError::InvalidTransaction(String::from(
                            "Not player 2's turn",
                        )));
                    }
                }
                "P2-NEXT" => {
                    let p2 = g.get_player2();
                    if !p2.is_empty() && p2.as_str() != signer {
                        return Err(ApplyError::InvalidTransaction(String::from(
                            "Not player 1's turn",
                        )));
                    }
                }
                _ => {
                    return Err(ApplyError::InvalidTransaction(String::from(
                        "Invalid state",
                    )))
                }
            }

            let board_chars: Vec<char> = g.get_board().chars().collect();
            if board_chars[payload.get_space() - 1] != '-' {
                return Err(ApplyError::InvalidTransaction(String::from(
                    format!("Space {} is already taken", payload.get_space()).as_str(),
                )));
            }

            if g.get_player1().is_empty() {
                g.set_player1(signer);
            } else if g.get_player2().is_empty() {
                g.set_player2(signer)
            }

            g.mark_space(payload.get_space())?;
            g.update_state()?;

            g.display();

            state.set_game(payload.get_name().as_str(), g)?;
        } else {
            return Err(ApplyError::InvalidTransaction(String::from(
                "Invalid action: Take requires an existing game",
            )));
        }
    }
    other_action => {
        return Err(ApplyError::InvalidTransaction(String::from(format!(
            "Invalid action: '{}'",
            other_action
        ))));
    }
}
// --snip--
```

### Payload

> **Note**
>
> [Transaction and Batches]({% link docs/1.2/architecture/transactions_and_batches.md%})
> contains a detailed description of how transactions are structured and
> used. Please read this document before proceeding, if you have not
> reviewed it.

So how do we get data out of the transaction? The transaction consists
of a header and a payload. The header contains the \"signer\", which is
used to identify the current player. The payload will contain an
encoding of the game name, the action (`create` a game, `delete` a game,
`take` a space), and the space (which will be an empty string if the
action isn\'t `take`).

An XO transaction request payload consists of the UTF-8 encoding of a
string with exactly two commas, which is formatted as follows:

`<name>,<action>,<space>`

-   `<name>` is the game name as a non-empty string not containing the
    character `|`. If the action is create, the new name
    must be unique.
-   `<action>` is the game action: create,
    take, or delete
-   `<space>` is the location on the board, as an integer between 1-9
    (inclusive), if the action is take.

```rust
use sawtooth_sdk::processor::handler::ApplyError;

pub struct XoPayload {
    name: String,
    action: String,
    space: usize,
}

impl XoPayload {
    // payload_data is a utf-8 encoded string
    pub fn new(payload_data: &[u8]) -> Result<XoPayload, ApplyError> {
        let payload_string = match ::std::str::from_utf8(&payload_data) {
            Ok(s) => s,
            Err(_) => {
                return Err(ApplyError::InvalidTransaction(String::from(
                    "Invalid payload serialization",
                )))
            }
        };

        let items: Vec<&str> = payload_string.split(",").collect();

        if items.len() != 3 {
            return Err(ApplyError::InvalidTransaction(String::from(
                "Payload must have exactly 2 commas",
            )));
        }

        let (name, action, space) = (items[0], items[1], items[2]);

        if name.is_empty() {
            return Err(ApplyError::InvalidTransaction(String::from(
                "Name is required",
            )));
        }

        if action.is_empty() {
            return Err(ApplyError::InvalidTransaction(String::from(
                "Action is required",
            )));
        }

        if name.contains("|") {
            return Err(ApplyError::InvalidTransaction(String::from(
                "Name cannot contain |",
            )));
        }
        match action {
            "create" | "take" | "delete" => (),
            _ => {
                return Err(ApplyError::InvalidTransaction(String::from(
                    format!("Invalid action: {}", action).as_str(),
                )));
            }
        };

        let mut space_parsed: usize = 0; // Default, invalid value
        if action == "take" {
            if space.is_empty() {
                return Err(ApplyError::InvalidTransaction(String::from(
                    "Space is required with action `take`",
                )));
            }
            space_parsed = match space.parse() {
                Ok(num) => num,
                Err(_) => {
                    return Err(ApplyError::InvalidTransaction(String::from(
                        "Space must be an integer",
                    )))
                }
            };
            if space_parsed < 1 || space_parsed > 9 {
                return Err(ApplyError::InvalidTransaction(String::from(
                    "Space must be an integer from 1 to 9",
                )));
            }
        }

        Ok(XoPayload {
            name: name.to_string(),
            action: action.to_string(),
            space: space_parsed,
        })
    }

    // Getters/setters
    // --snip--
}
```

### State

The XoState class turns game information into bytes and stores it in the
validator\'s Radix-Merkle tree, turns bytes stored in the validator\'s
Radix-Merkle tree into game information, and does these operations with
a state storage scheme that handles hash collisions.

An XO state entry consists of the UTF-8 encoding of a string with
exactly four commas formatted as follows:

`<name>,<board>,<game-state>,<player-key-1>,<player-key-2>`

where

-   \<name> is a nonempty string not containing |
-   \<board> is a string of length 9 containing only O,
    X, or -,
-   \<game-state> is one of the following: P1-NEXT,
    P2-NEXT, P1-WIN, P2-WIN, or TIE, and
-   \<player-key-1> and \<player-key-2> are  the (possibly empty) public keys
    associated with the game\'s players.

In the event of a hash collision (i.e. two or more state entries sharing
the same address), the colliding state entries will stored as the UTF-8
encoding of the string `<a-entry>|<b-entry>|...`, where \<a-entry>,
\<b-entry>,\... are sorted alphabetically.

```rust
// Use statements
// --snip--

pub struct XoState<'a> {
    context: &'a mut TransactionContext,
    address_map: HashMap<String, Option<String>>,
}

impl<'a> XoState<'a> {
    pub fn new(context: &'a mut TransactionContext) -> XoState {
        XoState {
            context: context,
            address_map: HashMap::new(),
        }
    }

    pub fn delete_game(&mut self, game_name: &str) -> Result<(), ApplyError> {
        let mut games = self._load_games(game_name)?;
        games.remove(game_name);
        if games.is_empty() {
            self._delete_game(game_name)?;
        } else {
            self._store_game(game_name, games)?;
        }
        Ok(())
    }

    pub fn set_game(&mut self, game_name: &str, g: Game) -> Result<(), ApplyError> {
        let mut games = self._load_games(game_name)?;
        games.insert(game_name.to_string(), g);
        self._store_game(game_name, games)?;
        Ok(())
    }

    pub fn get_game(&mut self, game_name: &str) -> Result<Option<Game>, ApplyError> {
        let games = self._load_games(game_name)?;
        if games.contains_key(game_name) {
            Ok(Some(games[game_name].clone()))
        } else {
            Ok(None)
        }
    }

    fn _store_game(
        &mut self,
        game_name: &str,
        games: HashMap<String, Game>,
    ) -> Result<(), ApplyError> {
        let address = XoState::calculate_address(game_name);
        let state_string = Game::serialize_games(games);
        self.address_map
            .insert(address.clone(), Some(state_string.clone()));
        self.context
            .set_state(&address, &state_string.into_bytes())?;
        Ok(())
    }

    fn _delete_game(&mut self, game_name: &str) -> Result<(), ApplyError> {
        let address = XoState::calculate_address(game_name);
        if self.address_map.contains_key(&address) {
            self.address_map.insert(address.clone(), None);
        }
        self.context.delete_state(vec![address])?;
        Ok(())
    }

    fn _load_games(&mut self, game_name: &str) -> Result<HashMap<String, Game>, ApplyError> {
        let address = XoState::calculate_address(game_name);
        let mut games = HashMap::new();

        if self.address_map.contains_key(&address) {
            if let Some(ref serialized_games) = self.address_map[&address] {
                let t = Game::deserialize_games((*serialized_games).clone());
                match t {
                    Some(g) => games = g,
                    None => {
                        return Err(ApplyError::InvalidTransaction(String::from(
                            "Invalid serialization of game state",
                        )))
                    }
                }
            }
        } else {
            if let Some(state_bytes) = self.context.get_state(&address)? {
                let state_string = match ::std::str::from_utf8(&state_bytes) {
                    Ok(s) => s,
                    Err(_) => {
                        return Err(ApplyError::InvalidTransaction(String::from(
                            "Invalid serialization of game state",
                        )))
                    }
                };
                self.address_map
                    .insert(address, Some(state_string.to_string()));
                let t = Game::deserialize_games(state_string.to_string());
                match t {
                    Some(g) => games = g,
                    None => {
                        return Err(ApplyError::InvalidTransaction(String::from(
                            "Invalid serialization of game state",
                        )))
                    }
                }
            } else {
                self.address_map.insert(address, None);
            }
        }
        Ok(games)
    }
}
```

#### Addressing

By convention, we\'ll store game data at an address obtained from
hashing the game name prepended with some constant.

XO data is stored in state using addresses generated from the XO family
name and the name of the game being stored. In particular, an XO address
consists of the first 6 characters of the SHA-512 hash of the UTF-8
encoding of the string \"xo\" (which is \"5b7349\") plus the first 64
characters of the SHA-512 hash of the UTF-8 encoding of the game name.

For example, the XO address for a game called \"my-game\" could be
generated as follows (in Python):

```console
>>> XO_NAMESPACE = hashlib.sha512('xo'.encode('utf-8')).hexdigest()[:6]
>>> XO_NAMESPACE
'5b7349'
>>> y = hashlib.sha512('my-game'.encode('utf-8')).hexdigest()[:64]
>>> y
'4d4cffe9cf3fb4e41def5114a323e292af9b0e07925cca6299d671ce7fc7ec37'
>>> XO_NAMESPACE+y
'5b73494d4cffe9cf3fb4e41def5114a323e292af9b0e07925cca6299d671ce7fc7ec37'
```

Addressing is implemented as follows:

```rust
use crypto::sha2::Sha512;

pub fn get_xo_prefix() -> String {
    let mut sha = Sha512::new();
    sha.input_str("xo");
    sha.result_str()[..6].to_string()
}

pub fn calculate_address(name: &str) -> String {
    let mut sha = Sha512::new();
    sha.input_str(name);
    get_xo_prefix() + &sha.result_str()[..64].to_string()
}
```

## Client: Building and Submitting Transactions

The process of encoding information to be submitted to a distributed
ledger is generally non-trivial. A series of cryptographic safeguards
are used to confirm identity and data validity. Hyperledger Sawtooth is
no different, but the Rust SDK does provide client
functionality that abstracts away most of these details, and greatly
simplifies the process of making changes to the blockchain.

## Creating a Private Key and Signer

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

In order to confirm your identity and sign the information you send to
the validator, you will need a 256-bit key. Sawtooth uses the secp256k1
ECDSA standard for signing, which means that almost any set of 32 bytes
is a valid key. It is fairly simple to generate a valid key using the
SDK\'s *signing* module.

A *Signer* wraps a private key and provides some convenient methods for
signing bytes and getting the private key\'s associated public key.

```rust
use sawtooth_sdk::signing::CryptoFactory;
use sawtooth_sdk::signing::create_context;

let context = create_context("secp256k1")
    .expect("Error creating the right context");
let private_key = context
    .new_random_private_key()
    .expect("Error generating a new Private Key");
let crypto_factory = CryptoFactory::new(context.as_ref());
let signer = crypto_factory.new_signer(private_key.as_ref());
```

> **Note**
>
> This key is the **only** way to prove your identity on the blockchain.
> Any person possessing it will be able to sign Transactions using your
> identity, and there is no way to recover it if lost. It is very
> important that any private key is kept secret and secure.

## Encoding Your Payload

Transaction payloads are composed of binary-encoded data that is opaque
to the validator. The logic for encoding and decoding them rests
entirely within the particular Transaction Processor itself. As a
result, there are many possible formats, and you will have to look to
the definition of the Transaction Processor itself for that information.
As an example, the *IntegerKey* Transaction Processor uses a payload of
three key/value pairs encoded as
[CBOR](https://en.wikipedia.org/wiki/CBOR). Creating one might look like
this:

```rust
extern crate serde;
extern crate serde_cbor;

use serde::{Serialize, Deserialize};

// Using serde to create a serializable struct
#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "PascalCase")]
struct Payload {
    verb: String,
    name: String,
    value: u32,
}

// --snip--
let payload = Payload{  verb : String::from("set"),
                        name : String::from("foo"),
                        value : 42 };

let payload_bytes = serde_cbor::to_vec(&payload).expect("upsi");
```

## Building the Transaction

*Transactions* are the basis for individual changes of state to the
Sawtooth blockchain. They are composed of a binary payload, a
binary-encoded *TransactionHeader* with some cryptographic safeguards
and metadata about how it should be handled, and a signature of that
header. It would be worthwhile to familiarize yourself with the
information in [Transactions and
Batches]({% link docs/1.2/architecture/transactions_and_batches.md%}),
particularly the definition of TransactionHeaders.

### 1. Create the Transaction Header

A TransactionHeader contains information for routing a transaction to
the correct transaction processor, what input and output state addresses
are involved, references to prior transactions it depends on, and the
public keys associated with the its signature. The header references the
payload through a SHA-512 hash of the payload bytes.

```rust
extern crate protobuf;
extern crate openssl;
extern crate rand;

use rand::{thread_rng, Rng};

use protobuf::Message
use protobuf::RepeatedField;

use openssl::sha::sha512;
use sawtooth_sdk::messages::transaction::TransactionHeader;

let mut txn_header = TransactionHeader::new();
txn_header.set_family_name(String::from("intkey"));
txn_header.set_family_version(String::from("1.0"));

// Generate a random 128 bit number to use as a nonce
let mut nonce = [0u8; 16];
thread_rng()
    .try_fill(&mut nonce[..])
    .expect("Error generating random nonce");
txn_header.set_nonce(to_hex_string(&nonce.to_vec()));

let input_vec: Vec<String> = vec![String::from(
    "1cf1266e282c41be5e4254d8820772c5518a2c5a8c0c7f7eda19594a7eb539453e1ed7",
)];
let output_vec: Vec<String> = vec![String::from(
    "1cf1266e282c41be5e4254d8820772c5518a2c5a8c0c7f7eda19594a7eb539453e1ed7",
)];

txn_header.set_inputs(RepeatedField::from_vec(input_vec));
txn_header.set_outputs(RepeatedField::from_vec(output_vec));
txn_header.set_signer_public_key(
    signer
        .get_public_key()
        .expect("Error retrieving Public Key")
        .as_hex(),
);
txn_header.set_batcher_public_key(
    signer
        .get_public_key()
        .expect("Error retrieving Public Key")
        .as_hex(),
);

txn_header.set_payload_sha512(to_hex_string(&sha512(&payload_bytes).to_vec()));

let txn_header_bytes = txn_header
    .write_to_bytes()
    .expect("Error converting transaction header to bytes");

// --snip--

// To properly format the Sha512 String
pub fn to_hex_string(bytes: &Vec<u8>) -> String {
    let strs: Vec<String> = bytes.iter()
        .map(|b| format!("{:02x}", b))
        .collect();
    strs.join("")
}
```

> **Note**
>
> Remember that a *batcher public_key* is the hex public key matching the
> private key that will later be used to sign a Transaction\'s Batch, and
> *dependencies* are the *header signatures* of Transactions that must be
> committed before this one
> (see [`TransactionHeader`]({% link docs/1.2/architecture/transactions_and_batches.md%})).

> **Note**
>
> The *inputs* and *outputs* are the state addresses a Transaction is
> allowed to read from or write to. With the Transaction above, we
> referenced the specific address where the value of `'foo'` is stored.
> Whenever possible, specific addresses should be used, as this will allow
> the validator to schedule transaction processing more efficiently.

> **Note**
>
> The methods for assigning and validating addresses are
> entirely up to the Transaction Processor. In the case of IntegerKey,
> there are specific rules to generate valid addresses in [Transactions and
> Batches]({% link docs/1.2/architecture/transactions_and_batches.md%}), which
> must be followed or Transactions will be rejected. You will need to follow the
> addressing rules for whichever Transaction Family you are working with.

### 2. Create the Transaction

Once the TransactionHeader is constructed, its bytes are then used to
create a signature. This header signature also acts as the ID of the
transaction. The header bytes, the header signature, and the payload
bytes are all used to construct the complete Transaction.

```rust
use sawtooth_sdk::messages::transaction::Transaction;

let signature = signer
    .sign(&txn_header_bytes)
    .expect("Error signing the transaction header");

let mut txn = Transaction::new();
txn.set_header(txn_header_bytes.to_vec());
txn.set_header_signature(signature);
txn.set_payload(payload_bytes);
```

### 3. (optional) Encode the Transaction(s)

If the same machine is creating Transactions and Batches there is no
need to encode the Transaction instances. However, in the use case where
Transactions are being batched externally, they must be serialized
before being transmitted to the batcher. The Rust SDK offers
two options for this. One or more Transactions can be combined into a
serialized *TransactionList* method, or can be serialized as a single
Transaction.

```rust
let txn_list_vec = vec![txn1, txn2];
let txn_list = TransactionList::new();
txn_list.set_transactions(RepeatedField::from_vec(txn_list_vec));

let txn_list_bytes = txn_list
    .write_to_bytes()
    .expect("Error converting Transaction List to bytes");
```

## Building the Batch

Once you have one or more Transaction instances ready, they must be
wrapped in a *Batch*. Batches are the atomic unit of change in
Sawtooth\'s state. When a Batch is submitted to a validator each
Transaction in it will be applied (in order), or *no* Transactions will
be applied. Even if your Transactions are not dependent on any others,
they cannot be submitted directly to the validator. They must all be
wrapped in a Batch.

### 1. Create the BatchHeader

Similar to the TransactionHeader, there is a *BatchHeader* for each
Batch. As Batches are much simpler than Transactions, a BatchHeader
needs only the public key of the signer and the list of Transaction IDs,
in the same order they are listed in the Batch.


```rust
use sawtooth_sdk::messages::batch::BatchHeader;

let mut batch_header = BatchHeader::new();

batch_header.set_signer_public_key(
    signer
        .get_public_key()
        .expect("Error retrieving Public Key")
        .as_hex(),
);

let transaction_ids = vec![txn.clone()]
    .iter()
    .map(|trans| String::from(trans.get_header_signature()))
    .collect();

batch_header.set_transaction_ids(RepeatedField::from_vec(transaction_ids));

let batch_header_bytes = batch_header
    .write_to_bytes()
    .expect("Error converting batch header to bytes");
```


### 2. Create the Batch

Using the SDK, creating a Batch is similar to creating a transaction.
The header is signed, and the resulting signature acts as the Batch\'s
ID. The Batch is then constructed out of the header bytes, the header
signature, and the transactions that make up the batch.

```rust
use sawtooth_sdk::messages::batch::Batch;

let signature = signer
    .sign(&batch_header_bytes)
    .expect("Error signing the batch header");

let mut batch = Batch::new();

batch.set_header(batch_header_bytes);
batch.set_header_signature(signature);
batch.set_transactions(RepeatedField::from_vec(vec![txn]));
```

### 3. Encode the Batch(es) in a BatchList

In order to submit Batches to the validator, they must be collected into
a *BatchList*. Multiple batches can be submitted in one BatchList,
though the Batches themselves don\'t necessarily need to depend on each
other. Unlike Batches, a BatchList is not atomic. Batches from other
clients may be interleaved with yours.

```rust
use sawtooth_sdk::messages::batch::BatchList;

let mut batch_list = BatchList::new();
batch_list.set_batches(RepeatedField::from_vec(vec![batch]));
let batch_list_bytes = batch_list
    .write_to_bytes()
    .expect("Error converting batch list to bytes");
```

> **Note**
>
> Note, if the transaction creator is using a different private key than
> the batcher, the *batcher public_key* must have been specified for every
> Transaction, and must have been generated from the private key being
> used to sign the Batch, or validation will fail.

## Submitting Batches to the Validator

The prescribed way to submit Batches to the validator is via the REST
API. This is an independent process that runs alongside a validator,
allowing clients to communicate using HTTP/JSON standards. Simply send a
*POST* request to the */batches* endpoint, with a *\"Content-Type\"*
header of *\"application/octet-stream\"*, and the *body* as a serialized
*BatchList*.

There are many ways to make an HTTP request, and hopefully the
submission process is fairly straightforward from here, but as an
example, this is what it might look if you sent the request from the
same Rust process that prepared the BatchList:

```rust
// When using an external crate don't forget to add it to your dependencies
// in the Cargo.toml file, just like with the sdk itself
extern crate reqwest;

let client = reqwest::Client::new();
let res = client
    .post("http://localhost:8008/batches")
    .header("Content-Type", "application/octet-stream")
    .body(
        batch_list_bytes,
    )
    .send()
```

And here is what it would look like if you saved the binary to a file,
and then sent it from the command line with `curl`:

```rust
use std::fs::File;
use std::io::Write;

let mut file = File::create("intkey.batches").expect("Error creating file");
file.write_all(&batch_list_bytes)
    .expect("Error writing bytes");
```

```bash
% curl --request POST \
    --header "Content-Type: application/octet-stream" \
    --data-binary @intkey.batches \
    "http://rest.api.domain/batches"
```
