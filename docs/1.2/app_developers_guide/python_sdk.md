# Using the Python SDK

This tutorial describes how to develop a Sawtooth application with an
example transaction family, XO, using the Sawtooth Python SDK.

## Overview

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

This tutorial shows how to use the Sawtooth Python SDK to
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


This tutorial also describes how a client can use the Python SDK
to create transactions and submit them as
Sawtooth batches.

> **Note**
>
> This tutorial demonstrates the relevant concepts for a Sawtooth
> transaction processor and client, but does not create a complete
> implementation.

For a full Python implementation see,  the [XO transaction
family](https://github.com/hyperledger/sawtooth-sdk-python/tree/master/examples/xo_python)

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

## Importing the Python SDK

> **Note**
>
>
> The Sawtooth Python SDK requires Python version 3.5 or higher

The Python SDK is installed automatically in the demo development
environment, as described by [Installing
Sawtooth]({% link docs/1.2/app_developers_guide/installing_sawtooth.md %}).
This SDK is available through the standard Python import system.

You can use the Python REPL to import the SDK into your Python
environment, then verify the import by viewing the SDK\'s docstring.

```console
$ python3
>>> import sawtooth_sdk
>>> help(sawtooth_sdk)
Help on package sawtooth_sdk:

NAME
    sawtooth_sdk

DESCRIPTION
    # Copyright 2016 Intel Corporation
    #
    # Licensed under the Apache License, Version 2.0 (the "License");
    # you may not use this file except in compliance with the License.
    # You may obtain a copy of the License at
    #
    #     http://www.apache.org/licenses/LICENSE-2.0
    #
    # Unless required by applicable law or agreed to in writing, software
    # distributed under the License is distributed on an "AS IS" BASIS,
    # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    # See the License for the specific language governing permissions and
    # limitations under the License.
    # ------------------------------------------------------------------------------

PACKAGE CONTENTS
    client (package)
    processor (package)
    protobuf (package)
    workload (package)

DATA
    __all__ = ['client', 'processor']

FILE
    /usr/lib/python3/dist-packages/sawtooth_sdk/__init__.py
```


### Transaction Processor: Creating a Transaction Handler

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

```python
from sawtooth_sdk.processor.core import TransactionProcessor
from sawtooth_xo.processor.handler import XoTransactionHandler

def main():
    # In docker, the url would be the validator's container name with
    # port 4004
    processor = TransactionProcessor(url='tcp://127.0.0.1:4004')

    handler = XoTransactionHandler()

    processor.add_handler(handler)

    processor.start()
```

Handlers get called in two ways: with an `apply` method and with various
\"metadata\" methods. The metadata is used to connect the handler to the
processor. The bulk of the handler, however, is made up of `apply` and
its helper functions.

```python
class XoTransactionHandler(TransactionHandler):
    def __init__(self, namespace_prefix):
        self._namespace_prefix = namespace_prefix

    @property
    def family_name(self):
        return 'xo'

    @property
    def family_versions(self):
        return ['1.0']

    @property
    def namespaces(self):
        return [self._namespace_prefix]

    def apply(self, transaction, context):
        # ...
```

Note that the `XoTransactionHandler` extends the `TransactionHandler`
defined in the Python SDK.


### The `apply` Method

`apply` gets called with two arguments, `transaction` and
`context`. The argument `transaction` is an instance of the class
Transaction that is created from the protobuf definition. Also,
`context` is an instance of the class Context from the python SDK.

`transaction` holds the command that is to be executed (e.g. taking a
space or creating a game), while `context` stores information about the
current state of the game (e.g. the board layout and whose turn it is).

The transaction contains payload bytes that are opaque to the validator
core, and transaction family specific. When implementing a transaction
handler the binary serialization protocol is up to the implementer.

To separate details of state encoding and payload handling
from validation logic, the XO example has `XoState` and `XoPayload`
classes. The `XoPayload` has name, action, and space fields, while the
`XoState` contains information about the game name, board, state, and
which players are playing in the game.

Valid actions are: create a new game, take an unoccupied space, and
delete a game.

```python
def apply(self, transaction, context):

    header = transaction.header
    signer = header.signer_public_key

    xo_payload = XoPayload.from_bytes(transaction.payload)

    xo_state = XoState(context)

    if xo_payload.action == 'delete':
        ...
    elif xo.payload.action == 'create':
        ...
    elif xo.payload.action == 'take':
        ...
    else:
        raise InvalidTransaction('Unhandled action: {}'.format(
            xo_payload.action))
```

For every new payload, the transaction processor validates rules
surrounding the action. If all of the rules validate, then state is
updated based on whether we are creating a game, deleting a game, or
updating the game by taking a space.

### Game Logic

The XO game logic is described in the XO transaction family
specification; see [XO Transaction
Family]({% link docs/1.2/transaction_family_specifications/xo_transaction_family.md%}#execution)

The validation rules and state updates that are associated with the
`create`, `delete`, and `take` actions are shown below.

#### Create

The `create` action has the following implementation:

```python
elif xo_payload.action == 'create':

    if xo_state.get_game(xo_payload.name) is not None:
        raise InvalidTransaction(
            'Invalid action: Game already exists: {}'.format(
                xo_payload.name))

    game = Game(name=xo_payload.name,
                board="-" * 9,
                state="P1-NEXT",
                player1="",
                player2="")

    xo_state.set_game(xo_payload.name, game)
    _display("Player {} created a game.".format(signer[:6]))
```

#### Delete

The `delete` action has the following implementation:

```python
if xo_payload.action == 'delete':
    game = xo_state.get_game(xo_payload.name)

    if game is None:
        raise InvalidTransaction(
            'Invalid action: game does not exist')

    xo_state.delete_game(xo_payload.name)
```


#### Take

The `take` action has the following implementation:

```python
elif xo_payload.action == 'take':
    game = xo_state.get_game(xo_payload.name)

    if game is None:
        raise InvalidTransaction(
            'Invalid action: Take requires an existing game')

    if game.state in ('P1-WIN', 'P2-WIN', 'TIE'):
        raise InvalidTransaction('Invalid Action: Game has ended')

    if (game.player1 and game.state == 'P1-NEXT' and
        game.player1 != signer) or \
            (game.player2 and game.state == 'P2-NEXT' and
                game.player2 != signer):
        raise InvalidTransaction(
            "Not this player's turn: {}".format(signer[:6]))

    if game.board[xo_payload.space - 1] != '-':
        raise InvalidTransaction(
            'Invalid Action: space {} already taken'.format(
                xo_payload))

    if game.player1 == '':
        game.player1 = signer

    elif game.player2 == '':
        game.player2 = signer

    upd_board = _update_board(game.board,
                                xo_payload.space,
                                game.state)

    upd_game_state = _update_game_state(game.state, upd_board)

    game.board = upd_board
    game.state = upd_game_state

    xo_state.set_game(xo_payload.name, game)
    _display(
        "Player {} takes space: {}\n\n".format(
            signer[:6],
            xo_payload.space) +
        _game_data_to_str(
            game.board,
            game.state,
            game.player1,
            game.player2,
            xo_payload.name))
```

### Payload

> **Note**
>
> [Transaction and
> Batches]({% link docs/1.2/architecture/transactions_and_batches.md %})
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

```python
class XoPayload:

    def __init__(self, payload):
        try:
            # The payload is csv utf-8 encoded string
            name, action, space = payload.decode().split(",")
        except ValueError:
            raise InvalidTransaction("Invalid payload serialization")

        if not name:
            raise InvalidTransaction('Name is required')

        if '|' in name:
            raise InvalidTransaction('Name cannot contain "|"')

        if not action:
            raise InvalidTransaction('Action is required')

        if action not in ('create', 'take', 'delete'):
            raise InvalidTransaction('Invalid action: {}'.format(action))

        if action == 'take':
            try:

                if int(space) not in range(1, 10):
                    raise InvalidTransaction(
                        "Space must be an integer from 1 to 9")
            except ValueError:
                raise InvalidTransaction(
                    'Space must be an integer from 1 to 9')

        if action == 'take':
            space = int(space)

        self._name = name
        self._action = action
        self._space = space

    @staticmethod
    def from_bytes(payload):
        return XoPayload(payload=payload)

    @property
    def name(self):
        return self._name

    @property
    def action(self):
        return self._action

    @property
    def space(self):
        return self._space
```

## State

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

```python
XO_NAMESPACE = hashlib.sha512('xo'.encode("utf-8")).hexdigest()[0:6]


class Game:
    def __init__(self, name, board, state, player1, player2):
        self.name = name
        self.board = board
        self.state = state
        self.player1 = player1
        self.player2 = player2


class XoState:

    TIMEOUT = 3

    def __init__(self, context):
        """Constructor.
        Args:
            context (sawtooth_sdk.processor.context.Context): Access to
                validator state from within the transaction processor.
        """

        self._context = context
        self._address_cache = {}

    def delete_game(self, game_name):
        """Delete the Game named game_name from state.
        Args:
            game_name (str): The name.
        Raises:
            KeyError: The Game with game_name does not exist.
        """

        games = self._load_games(game_name=game_name)

        del games[game_name]
        if games:
            self._store_game(game_name, games=games)
        else:
            self._delete_game(game_name)

    def set_game(self, game_name, game):
        """Store the game in the validator state.
        Args:
            game_name (str): The name.
            game (Game): The information specifying the current game.
        """

        games = self._load_games(game_name=game_name)

        games[game_name] = game

        self._store_game(game_name, games=games)

    def get_game(self, game_name):
        """Get the game associated with game_name.
        Args:
            game_name (str): The name.
        Returns:
            (Game): All the information specifying a game.
        """

        return self._load_games(game_name=game_name).get(game_name)

    def _store_game(self, game_name, games):
        address = _make_xo_address(game_name)

        state_data = self._serialize(games)

        self._address_cache[address] = state_data

        self._context.set_state(
            {address: state_data},
            timeout=self.TIMEOUT)

    def _delete_game(self, game_name):
        address = _make_xo_address(game_name)

        self._context.delete_state(
            [address],
            timeout=self.TIMEOUT)

        self._address_cache[address] = None

    def _load_games(self, game_name):
        address = _make_xo_address(game_name)

        if address in self._address_cache:
            if self._address_cache[address]:
                serialized_games = self._address_cache[address]
                games = self._deserialize(serialized_games)
            else:
                games = {}
        else:
            state_entries = self._context.get_state(
                [address],
                timeout=self.TIMEOUT)
            if state_entries:

                self._address_cache[address] = state_entries[0].data

                games = self._deserialize(data=state_entries[0].data)

            else:
                self._address_cache[address] = None
                games = {}

        return games

    def _deserialize(self, data):
        """Take bytes stored in state and deserialize them into Python
        Game objects.
        Args:
            data (bytes): The UTF-8 encoded string stored in state.
        Returns:
            (dict): game name (str) keys, Game values.
        """

        games = {}
        try:
            for game in data.decode().split("|"):
                name, board, state, player1, player2 = game.split(",")

                games[name] = Game(name, board, state, player1, player2)
        except ValueError:
            raise InternalError("Failed to deserialize game data")

        return games

    def _serialize(self, games):
        """Takes a dict of game objects and serializes them into bytes.
        Args:
            games (dict): game name (str) keys, Game values.
        Returns:
            (bytes): The UTF-8 encoded string stored in state.
        """

        game_strs = []
        for name, g in games.items():
            game_str = ",".join(
                [name, g.board, g.state, g.player1, g.player2])
            game_strs.append(game_str)

        return "|".join(sorted(game_strs)).encode()
```


### Addressing

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

```python
def _make_xo_address(name):
return XO_NAMESPACE + \
    hashlib.sha512(name.encode('utf-8')).hexdigest()[:64]
```

## Client: Building and Submitting Transactions

The process of encoding information to be submitted to a distributed
ledger is generally non-trivial. A series of cryptographic safeguards
are used to confirm identity and data validity. Hyperledger Sawtooth is
no different, but the Python SDK does provide client
functionality that abstracts away most of these details, and greatly
simplifies the process of making changes to the blockchain.

### Creating a Private Key and Signer

In order to confirm your identity and sign the information you send to
the validator, you will need a 256-bit key. Sawtooth uses the secp256k1
ECDSA standard for signing, which means that almost any set of 32 bytes
is a valid key. It is fairly simple to generate a valid key using the
SDK\'s *signing* module.

A *Signer* wraps a private key and provides some convenient methods for
signing bytes and getting the private key\'s associated public key.

```python
from sawtooth_signing import create_context
from sawtooth_signing import CryptoFactory

context = create_context('secp256k1')
private_key = context.new_random_private_key()
signer = CryptoFactory(context).new_signer(private_key)
```

> **Note**
>
> This key is the **only** way to prove your identity on the blockchain.
> Any person possessing it will be able to sign Transactions using your
> identity, and there is no way to recover it if lost. It is very
> important that any private key is kept secret and secure.

### Encoding Your Payload

Transaction payloads are composed of binary-encoded data that is opaque
to the validator. The logic for encoding and decoding them rests
entirely within the particular Transaction Processor itself. As a
result, there are many possible formats, and you will have to look to
the definition of the Transaction Processor itself for that information.
As an example, the *IntegerKey* Transaction Processor uses a payload of
three key/value pairs encoded as
[CBOR](https://en.wikipedia.org/wiki/CBOR). Creating one might look like
this:


```python
import cbor

payload = {
    'Verb': 'set',
    'Name': 'foo',
    'Value': 42}

payload_bytes = cbor.dumps(payload)
```


## Building the Transaction

*Transactions* are the basis for individual changes of state to the
Sawtooth blockchain. They are composed of a binary payload, a
binary-encoded *TransactionHeader* with some cryptographic safeguards
and metadata about how it should be handled, and a signature of that
header. It would be worthwhile to familiarize yourself with the
information in [Transactions and
Batches]({% link docs/1.2/architecture/transactions_and_batches.md%})
particularly the definition of TransactionHeaders.

### 1. Create the Transaction Header

A TransactionHeader contains information for routing a transaction to
the correct transaction processor, what input and output state addresses
are involved, references to prior transactions it depends on, and the
public keys associated with the its signature. The header references the
payload through a SHA-512 hash of the payload bytes.


```python
from hashlib import sha512
from sawtooth_sdk.protobuf.transaction_pb2 import TransactionHeader

txn_header_bytes = TransactionHeader(
    family_name='intkey',
    family_version='1.0',
    inputs=['1cf1266e282c41be5e4254d8820772c5518a2c5a8c0c7f7eda19594a7eb539453e1ed7'],
    outputs=['1cf1266e282c41be5e4254d8820772c5518a2c5a8c0c7f7eda19594a7eb539453e1ed7'],
    signer_public_key=signer.get_public_key().as_hex(),
    # In this example, we're signing the batch with the same private key,
    # but the batch can be signed by another party, in which case, the
    # public key will need to be associated with that key.
    batcher_public_key=signer.get_public_key().as_hex(),
    # In this example, there are no dependencies.  This list should include
    # an previous transaction header signatures that must be applied for
    # this transaction to successfully commit.
    # For example,
    # dependencies=['540a6803971d1880ec73a96cb97815a95d374cbad5d865925e5aa0432fcf1931539afe10310c122c5eaae15df61236079abbf4f258889359c4d175516934484a'],
    dependencies=[],
    payload_sha512=sha512(payload_bytes).hexdigest()
).SerializeToString()
```

> **Note**
>
> Remember that a *batcher public_key* is the hex public key matching the
> private key that will later be used to sign a Transaction\'s Batch, and
> *dependencies* are the *header signatures* of Transactions that must be
> committed before this one (see *TransactionHeaders* in [Transactions and
>Batches]({% link docs/1.2/architecture/transactions_and_batches.md%}) ).

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
> there are specific rules to generate valid addresses
> [IntegerKey Family]({% link docs/1.2/transaction_family_specifications/integerkey_transaction_family.md%}#addressing),
> which must be
> followed or Transactions will be rejected. You will need to follow the
> addressing rules for whichever Transaction Family you are working with.

### 2. Create the Transaction

Once the TransactionHeader is constructed, its bytes are then used to
create a signature. This header signature also acts as the ID of the
transaction. The header bytes, the header signature, and the payload
bytes are all used to construct the complete Transaction.

```python
from sawtooth_sdk.protobuf.transaction_pb2 import Transaction

signature = signer.sign(txn_header_bytes)

txn = Transaction(
    header=txn_header_bytes,
    header_signature=signature,
    payload=payload_bytes
)
```

### 3. (optional) Encode the Transaction(s)

If the same machine is creating Transactions and Batches there is no
need to encode the Transaction instances. However, in the use case where
Transactions are being batched externally, they must be serialized
before being transmitted to the batcher. The Python SDK offers
two options for this. One or more Transactions can be combined into a
serialized *TransactionList* method, or can be serialized as a single
Transaction.

```python
from sawtooth_sdk.protobuf.transaction_pb2 import TransactionList

txn_list_bytes = TransactionList(
    transactions=[txn1, txn2]
).SerializeToString()

txn_bytes = txn.SerializeToString()
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

```python
from sawtooth_sdk.protobuf.batch_pb2 import BatchHeader

txns = [txn]

batch_header_bytes = BatchHeader(
    signer_public_key=signer.get_public_key().as_hex(),
    transaction_ids=[txn.header_signature for txn in txns],
).SerializeToString()
```

### 2. Create the Batch

Using the SDK, creating a Batch is similar to creating a transaction.
The header is signed, and the resulting signature acts as the Batch\'s
ID. The Batch is then constructed out of the header bytes, the header
signature, and the transactions that make up the batch.

```python
from sawtooth_sdk.protobuf.batch_pb2 import Batch

signature = signer.sign(batch_header_bytes)

batch = Batch(
    header=batch_header_bytes,
    header_signature=signature,
    transactions=txns
)
```

### 3. Encode the Batch(es) in a BatchList

In order to submit Batches to the validator, they must be collected into
a *BatchList*. Multiple batches can be submitted in one BatchList,
though the Batches themselves don\'t necessarily need to depend on each
other. Unlike Batches, a BatchList is not atomic. Batches from other
clients may be interleaved with yours.

```python
from sawtooth_sdk.protobuf.batch_pb2 import BatchList

batch_list_bytes = BatchList(batches=[batch]).SerializeToString()
```

> **Note**
>
> Note, if the transaction creator is using a different private key than
> the batcher, the *batcher public_key* must have been specified for every
> Transaction, and must have been generated from the private key being
> used to sign the Batch, or validation will fail.

### Submitting Batches to the Validator
---

The prescribed way to submit Batches to the validator is via the REST
API. This is an independent process that runs alongside a validator,
allowing clients to communicate using HTTP/JSON standards. Simply send a
*POST* request to the */batches* endpoint, with a *\"Content-Type\"*
header of *\"application/octet-stream\"*, and the *body* as a serialized
*BatchList*.

There are many ways to make an HTTP request, and hopefully the
submission process is fairly straightforward from here, but as an
example, this is what it might look if you sent the request from the
same Pythno  process that prepared the BatchList:

```python
import urllib.request
from urllib.error import HTTPError

try:
    request = urllib.request.Request(
        'http://rest.api.domain/batches',
        batch_list_bytes,
        method='POST',
        headers={'Content-Type': 'application/octet-stream'})
    response = urllib.request.urlopen(request)

except HTTPError as e:
    response = e.file
```

And here is what it would look like if you saved the binary to a file,
and then sent it from the command line with `curl`:


```python
output = open('intkey.batches', 'wb')
output.write(batch_list_bytes)
```

```bash
% curl --request POST \
    --header "Content-Type: application/octet-stream" \
    --data-binary @intkey.batches \
    "http://rest.api.domain/batches"
```
