---
title: Using the Rust SDK
---

This tutorial describes how to develop a Sawtooth application with an
example transaction family, XO, using the Sawtooth Rust SDK.

{% set short_lang = \'python\' %} {% if language == \'JavaScript\' %} {%
set short_lang = \'js\' %} {% elif language == \'Go\' %} {% set
short_lang = \'go\' %} {% elif language == \'Rust\' %} {% set short_lang
= \'rust\' %} {% endif %}

{% set lowercase_lang = \'python\' %} {% if language == \'JavaScript\'
%} {% set lowercase_lang = \'javascript\' %} {% elif language == \'Go\'
%} {% set lowercase_lang = \'go\' %} {% elif language == \'Rust\' %} {%
set lowercase_lang = \'rust\' %} {% endif %}

# Overview

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

This tutorial shows how to use the Sawtooth {{ language }} SDK to
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

{% if language == \'Python\' %}

This tutorial also describes how a client can use the {{ language }} SDK
to create transactions and submit them as
`Sawtooth batches<batch>`{.interpreted-text role="term"}.

{% elif language == \'JavaScript\' %}

This tutorial also describes how a client can use the {{ language }} SDK
to create transactions and submit them as
`Sawtooth batches<batch>`{.interpreted-text role="term"}.

{% endif %}

::: note
::: title
Note
:::

This tutorial demonstrates the relevant concepts for a Sawtooth
transaction processor and client, but does not create a complete
implementation.
:::

{% if language == \'Rust\' %}

> For a full Rust implementation of the XO transaction family, see

\<\<\<\<\<\<\< HEAD:docs/core/1.1/\_templates/sdk_overview_tutorial.rst

:   `/{project}/sawtooth-core/sdk/examples/xo_{{ lowercase_lang }}/`.

=======

:   <https://github.com/hyperledger/sawtooth-sdk-rust/tree/master/examples/xo_rust>.

\>\>\>\>\>\>\>
core/1-2:docs/core/1.2/\_templates/sdk_overview_tutorial.rst

{% elif language == \'Go\' %}

> For a full Go implementation of the XO transaction family, see
> <https://github.com/hyperledger/sawtooth-sdk-go/tree/master/examples/xo_go>.

{% elif language == \'Java\' %}

> For a full Java implementation of the XO transaction family, see
> <https://github.com/hyperledger/sawtooth-sdk-java/tree/master/examples/xo_java>.

{% elif language == \'JavaScript\' %}

> For a full JavaScript implementation of the XO transaction family, see
> <https://github.com/hyperledger/sawtooth-sdk-javascript/tree/master/examples/xo>.

{% else %}

> For a full Python implementation of the XO transaction family, see

\<\<\<\<\<\<\< HEAD:docs/core/1.1/\_templates/sdk_overview_tutorial.rst

:   `/{project}/sawtooth-core/sdk/examples/xo_{{ lowercase_lang }}/`.

=======

:   <https://github.com/hyperledger/sawtooth-sdk-python/tree/master/examples/xo_python>.

\>\>\>\>\>\>\>
core/1-2:docs/core/1.2/\_templates/sdk_overview_tutorial.rst

{% endif %}

---
title: Prerequisites
---

This tutorial requires:

> -   A working Sawtooth development environment, as described in
>     `/app_developers_guide/installing_sawtooth`{.interpreted-text
>     role="doc"} or
>     `/app_developers_guide/creating_sawtooth_network`{.interpreted-text
>     role="doc"}
> -   Familiarity with the basic Sawtooth concepts that are introduced
>     in `/app_developers_guide/installing_sawtooth`{.interpreted-text
>     role="doc"}
> -   Understanding of the Sawtooth transaction and batch data
>     structures, as described in
>     `/architecture/transactions_and_batches`{.interpreted-text
>     role="doc"}

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

---
title: Importing the Rust SDK
---

::: note
::: title
Note
:::

The Sawtooth Rust SDK assumes that you have the latest version of Rust
and its package manager Cargo, which can be installed with
[rustup](https://rustup.rs/).
:::

Once you\'ve got a working version of Sawtooth, there are a few
additional steps you\'ll need to take to get started developing for
Sawtooth in Rust.

1.  Add Sawtooth to your `Cargo.toml` file. Add sawtooth-sdk with the
    appropriate version to the dependencies section. The Rust SDK is
    located in the Sawtooth SDK Rust repository
    <http://github.com/hyperledger/sawtooth-sdk-rust>.

``` ini
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

``` rust
extern crate sawtooth_sdk;

use sawtooth_sdk::processor::TransactionProcessor;

// --snip--
```

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

{% set short_lang = \'python\' %} {% if language == \'JavaScript\' %} {%
set short_lang = \'js\' %} {% elif language == \'Go\' %} {% set
short_lang = \'go\' %} {% elif language == \'Rust\' %} {% set short_lang
= \'rust\' %} {% endif %}

{% set lowercase_lang = \'python\' %} {% if language == \'JavaScript\'
%} {% set lowercase_lang = \'javascript\' %} {% elif language == \'Go\'
%} {% set lowercase_lang = \'go\' %} {% elif language == \'Rust\' %} {%
set short_lang = \'rust\' %} {% endif %}

# Transaction Processor: Creating a Transaction Handler

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

## Entry Point

Since a transaction processor is a long running process, it must have an
entry point.

In the entry point, the `TransactionProcessor` class is given the
address to connect with the validator and the handler class.

{% if language == \'JavaScript\' %}

``` javascript
const { TransactionProcessor } = require('sawtooth-sdk/processor')
const XOHandler = require('./xo_handler')

// In docker, the address would be the validator's container name
// with port 4004
const address = 'tcp://127.0.0.1:4004'
const transactionProcessor = new TransactionProcessor(address)

transactionProcessor.addHandler(new XOHandler())

transactionProcessor.start()
```

{% elif language == \'Go\' %}

``` go
import (
    "sawtooth_sdk/processor"
    xo "sawtooth_xo/handler"
    "syscall"
)

func main() {

    endpoint := "tcp://127.0.0.1:4004"
    // In docker, endpoint would be the validator's container name
    // with port 4004
    handler := &xo.XoHandler{}
    processor := processor.NewTransactionProcessor(endpoint)
    processor.AddHandler(handler)
    processor.ShutdownOnSignal(syscall.SIGINT, syscall.SIGTERM)

    processor.Start()
}
```

{% elif language == \'Rust\' %}

``` rust
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

::: note
::: title
Note
:::

If you\'re looking for a working implementation of an XO transaction
processor in Rust, check out the [xo_rust
example](https://github.com/hyperledger/sawtooth-sdk-rust/tree/master/examples/xo_rust)
in the Rust SDK repository.
:::

{% else %}

``` python
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

{% endif %}

Handlers get called in two ways: with an `apply` method and with various
\"metadata\" methods. The metadata is used to connect the handler to the
processor. The bulk of the handler, however, is made up of `apply` and
its helper functions.

{% if language == \'JavaScript\' %}

``` javascript
class XOHandler extends TransactionHandler {
  constructor () {
    super(XO_FAMILY, ['1.0'], [XO_NAMESPACE])
  }

  apply (transactionProcessRequest, context) {
    //
```

Note that the `XOHandler` class extends the `TransactionHandler` class
defined in the JavaScript SDK.

{% elif language == \'Go\' %}

``` go
type XoHandler struct {
}

func (self *XoHandler) FamilyName() string {
    return "xo"
}

func (self *XoHandler) FamilyVersions() []string {
    return []string{"1.0"}
}

func (self *XoHandler) Namespaces() []string {
    return []string{xo_state.Namespace}
}

func (self *XoHandler) Apply(request *processor_pb2.TpProcessRequest, context *processor.Context) error {
```

{% elif language == \'Rust\' %}

``` rust
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

{% else %}

``` python
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

{% endif %}

## The `apply` Method

{% if language == \'JavaScript\' %} `apply` gets called with two
arguments, `transactionProcessRequest` and `stateStore`.
`transactionProcessRequest` holds the command that is to be executed
(e.g. taking a space or creating a game), while `stateStore` stores
information about the current state of the game (e.g. the board layout
and whose turn it is).

The transaction contains payload bytes that are opaque to the validator
core, and transaction family specific. When implementing a transaction
handler the binary serialization protocol is up to the implementer.

{% elif language == \'Go\' %} `apply` gets called with two arguments,
`request` and `context`. `request` holds the command that is to be
executed (e.g. taking a space or creating a game), while `context`
stores information about the current state of the game (e.g. the board
layout and whose turn it is).

The transaction contains payload bytes that are opaque to the validator
core, and transaction family specific. When implementing a transaction
handler the binary serialization protocol is up to the implementer.

{% elif language == \'Rust\' %} `apply` gets called with two arguments,
`request` and `context`. `request` holds the command that is to be
executed (e.g. taking a space or creating a game), while `context`
contains information about the current state of the game (e.g. the board
layout and whose turn it is).

The transaction contains payload bytes that are opaque to the validator
core, and transaction family specific. When implementing a transaction
handler the binary serialization protocol is up to the implementer.

{% else %} `apply` gets called with two arguments, `transaction` and
`context`. The argument `transaction` is an instance of the class
Transaction that is created from the protobuf definition. Also,
`context` is an instance of the class Context from the python SDK.

`transaction` holds the command that is to be executed (e.g. taking a
space or creating a game), while `context` stores information about the
current state of the game (e.g. the board layout and whose turn it is).

The transaction contains payload bytes that are opaque to the validator
core, and transaction family specific. When implementing a transaction
handler the binary serialization protocol is up to the implementer. {%
endif %}

{% if language == \'Rust\' %} To separate details of state encoding and
payload handling from validation logic, the XO example has separate
`XoState` and `XoPayload` structs. The `XoPayload` has name, action, and
space fields, while the `XoState` contains information about a game (a
`Game` object). The `Game` struct holds a game name, a board, the
game\'s state, and the identities of both players.

{% else %} To separate details of state encoding and payload handling
from validation logic, the XO example has `XoState` and `XoPayload`
classes. The `XoPayload` has name, action, and space fields, while the
`XoState` contains information about the game name, board, state, and
which players are playing in the game. {% endif %}

Valid actions are: create a new game, take an unoccupied space, and
delete a game.

{% if language == \'JavaScript\' %}

``` javascript
apply (transactionProcessRequest, context) {
    let payload = XoPayload.fromBytes(transactionProcessRequest.payload)
    let xoState = new XoState(context)
    let header = transactionProcessRequest.header
    let player = header.signerPublicKey
    if (payload.action === 'create') {
        ...
    } else if (payload.action === 'take') {
        ...
    } else if (payload.action === 'delete') {
        ...
    } else {
        throw new InvalidTransaction(
            `Action must be create, delete, or take not ${payload.action}`
        )
    }
}
```

{% elif language == \'Go\' %}

``` go
func (self *XoHandler) Apply(request *processor_pb2.TpProcessRequest, context *processor.Context) error {
    // The xo player is defined as the signer of the transaction, so we unpack
    // the transaction header to obtain the signer's public key, which will be
    // used as the player's identity.
    header := request.GetHeader()
    player := header.GetSignerPublicKey()

    // The payload is sent to the transaction processor as bytes (just as it
    // appears in the transaction constructed by the transactor).  We unpack
    // the payload into an XoPayload struct so we can access its fields.
    payload, err := xo_payload.FromBytes(request.GetPayload())
    if err != nil {
        return err
    }

    xoState := xo_state.NewXoState(context)

    switch payload.Action {
    case "create":
        ...
    case "delete":
        ...
    case "take":
        ...
    default:
        return &processor.InvalidTransaction{
            Msg: fmt.Sprintf("Invalid Action : '%v'", payload.Action)}
    }
```

{% elif language == \'Rust\' %}

``` rust
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

{% else %}

{# Python code is the default #}

``` python
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

{% endif %}

For every new payload, the transaction processor validates rules
surrounding the action. If all of the rules validate, then state is
updated based on whether we are creating a game, deleting a game, or
updating the game by taking a space.

## Game Logic

The XO game logic is described in the XO transaction family
specification; see `xo-execution-label`{.interpreted-text role="ref"}.

The validation rules and state updates that are associated with the
`create`, `delete`, and `take` actions are shown below.

### Create

The `create` action has the following implementation: {% if language ==
\'JavaScript\' %}

``` javascript
if (payload.action === 'create') {
  return xoState.getGame(payload.name)
    .then((game) => {
      if (game !== undefined) {
        throw new InvalidTransaction('Invalid Action: Game already exists.')
      }

      let createdGame = {
        name: payload.name,
        board: '---------',
        state: 'P1-NEXT',
        player1: '',
        player2: ''
      }

      _display(`Player ${player.toString().substring(0, 6)} created game ${payload.name}`)

      return xoState.setGame(payload.name, createdGame)
    })
}
```

{% elif language == \'Go\' %}

``` go
case "create":
    err := validateCreate(xoState, payload.Name)
    if err != nil {
        return err
    }
    game := &xo_state.Game{
        Board:   "---------",
        State:   "P1-NEXT",
        Player1: "",
        Player2: "",
        Name:    payload.Name,
    }
    displayCreate(payload, player)
    return xoState.SetGame(payload.Name, game)
```

`validateCreate` is defined as follows:

``` go
func validateCreate(xoState *xo_state.XoState, name string) error {
    game, err := xoState.GetGame(name)
    if err != nil {
        return err
    }
    if game != nil {
        return &processor.InvalidTransactionError{Msg: "Game already exists"}
    }

    return nil
}
```

{% elif language == \'Rust\' %}

``` rust
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

{% else %}

``` python
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

{% endif %}

### Delete

The `delete` action has the following implementation: {% if language ==
\'JavaScript\' %}

``` javascript
if (payload.action === 'delete') {
  return xoState.getGame(payload.name)
    .then((game) => {
      if (game === undefined) {
        throw new InvalidTransaction(
          `No game exists with name ${payload.name}: unable to delete`)
      }
      return xoState.deleteGame(payload.name)
    })
} else {
  throw new InvalidTransaction(
    `Action must be create or take not ${payload.action}`
  )
}
```

{% elif language == \'Go\' %}

``` go
case "delete":
    err := validateDelete(xoState, payload.Name)
    if err != nil {
        return err
    }
    return xoState.DeleteGame(payload.Name)
```

`validateDelete` is defined as follows:

``` go
func validateDelete(xoState *xo_state.XoState, name string) error {
    game, err := xoState.GetGame(name)
    if err != nil {
        return err
    }
    if game == nil {
        return &processor.InvalidTransactionError{Msg: "Delete requires an existing game"}
    }
    return nil
}
```

{% elif language == \'Rust\' %}

``` rust
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

{% else %}

``` python
if xo_payload.action == 'delete':
    game = xo_state.get_game(xo_payload.name)

    if game is None:
        raise InvalidTransaction(
            'Invalid action: game does not exist')

    xo_state.delete_game(xo_payload.name)
```

{% endif %}

### Take

The `take` action has the following implementation:

{% if language == \'JavaScript\' %}

``` none
if (payload.action === 'take') {
  return xoState.getGame(payload.name)
    .then((game) => {
      try {
        parseInt(payload.space)
      } catch (err) {
        throw new InvalidTransaction('Space could not be converted as an integer.')
      }

      if (payload.space < 1 || payload.space > 9) {
        throw new InvalidTransaction('Invalid space ' + payload.space)
      }

      if (game === undefined) {
        throw new InvalidTransaction(
          'Invalid Action: Take requires an existing game.'
        )
      }
      if (['P1-WIN', 'P2-WIN', 'TIE'].includes(game.state)) {
        throw new InvalidTransaction('Invalid Action: Game has ended.')
      }

      if (game.player1 === '') {
        game.player1 = player
      } else if (game.player2 === '') {
        game.player2 = player
      }
      let boardList = game.board.split('')

      if (boardList[payload.space - 1] !== '-') {
        throw new InvalidTransaction('Invalid Action: Space already taken.')
      }

      if (game.state === 'P1-NEXT' && player === game.player1) {
        boardList[payload.space - 1] = 'X'
        game.state = 'P2-NEXT'
      } else if (
        game.state === 'P2-NEXT' &&
        player === game.player2
      ) {
        boardList[payload.space - 1] = 'O'
        game.state = 'P1-NEXT'
      } else {
        throw new InvalidTransaction(
          `Not this player's turn: ${player.toString().substring(0, 6)}`
        )
      }

      game.board = boardList.join('')

      if (_isWin(game.board, 'X')) {
        game.state = 'P1-WIN'
      } else if (_isWin(game.board, 'O')) {
        game.state = 'P2-WIN'
      } else if (game.board.search('-') === -1) {
        game.state = 'TIE'
      }

      let playerString = player.toString().substring(0, 6)

      _display(
        `Player ${playerString} takes space: ${payload.space}\n\n` +
          _gameToStr(
            game.board,
            game.state,
            game.player1,
            game.player2,
            payload.name
          )
      )

      return xoState.setGame(payload.name, game)
    })
}
```

{% elif language == \'Go\' %}

``` go
case "take":
    err := validateTake(xoState, payload, player)
    if err != nil {
        return err
    }
    game, err := xoState.GetGame(payload.Name)
    if err != nil {
        return err
    }
    // Assign players if new game
    if game.Player1 == "" {
        game.Player1 = player
    } else if game.Player2 == "" {
        game.Player2 = player
    }

    if game.State == "P1-NEXT" && player == game.Player1 {
        boardRunes := []rune(game.Board)
        boardRunes[payload.Space-1] = 'X'
        game.Board = string(boardRunes)
        game.State = "P2-NEXT"
    } else if game.State == "P2-NEXT" && player == game.Player2 {
        boardRunes := []rune(game.Board)
        boardRunes[payload.Space-1] = 'O'
        game.Board = string(boardRunes)
        game.State = "P1-NEXT"
    } else {
        return &processor.InvalidTransactionError{
            Msg: fmt.Sprintf("Not this player's turn: '%v'", player)}
    }

    if isWin(game.Board, 'X') {
        game.State = "P1-WIN"
    } else if isWin(game.Board, 'O') {
        game.State = "P2-WIN"
    } else if !strings.Contains(game.Board, "-") {
        game.State = "TIE"
    }
    displayTake(payload, player, game)
    return xoState.SetGame(payload.Name, game)
```

`validateTake` is defined as follows:

``` go
func validateTake(xoState *xo_state.XoState, payload *xo_payload.XoPayload, signer string) error {
    game, err := xoState.GetGame(payload.Name)
    if err != nil {
        return err
    }
    if game == nil {
        return &processor.InvalidTransactionError{Msg: "Take requires an existing game"}
    }
    if game.State == "P1-WIN" || game.State == "P2-WIN" || game.State == "TIE" {
        return &processor.InvalidTransactionError{Msg: "Game has ended"}
    }

    if game.State == "P1-WIN" || game.State == "P2-WIN" || game.State == "TIE" {
        return &processor.InvalidTransactionError{
            Msg: "Invalid Action: Game has ended"}
    }

    if game.Board[payload.Space-1] != '-' {
        return &processor.InvalidTransactionError{Msg: "Space already taken"}
    }
    return nil
}
```

{% elif language == \'Rust\' %}

``` rust
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

{% else %}

``` python
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

{% endif %}

## Payload

::: note
::: title
Note
:::

`/architecture/transactions_and_batches`{.interpreted-text role="doc"}
contains a detailed description of how transactions are structured and
used. Please read this document before proceeding, if you have not
reviewed it.
:::

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
    character `|`. If the action is [create]{.title-ref}, the new name
    must be unique.
-   `<action>` is the game action: [create]{.title-ref},
    [take]{.title-ref}, or [delete]{.title-ref}
-   `<space>` is the location on the board, as an integer between 1-9
    (inclusive), if the action is [take]{.title-ref}

{% if language == \'JavaScript\' %}

``` javascript
class XoPayload {
    constructor (name, action, space) {
        this.name = name
        this.action = action
        this.space = space
    }

    static fromBytes (payload) {
        payload = payload.toString().split(',')
        if (payload.length === 3) {
            let xoPayload = new XoPayload(payload[0], payload[1], payload[2])
            if (!xoPayload.name) {
                throw new InvalidTransaction('Name is required')
            }
            if (xoPayload.name.indexOf('|') !== -1) {
                throw new InvalidTransaction('Name cannot contain "|"')
            }

            if (!xoPayload.action) {
                throw new InvalidTransaction('Action is required')
            }
            return xoPayload
        } else {
        throw new InvalidTransaction('Invalid payload serialization')
        }
    }
}
```

{% elif language == \'Go\' %}

``` go
type XoPayload struct {
    Name   string
    Action string
    Space  int
}

func FromBytes(payloadData []byte) (*XoPayload, error) {
    if payloadData == nil {
        return nil, &processor.InvalidTransactionError{Msg: "Must contain payload"}
    }

    parts := strings.Split(string(payloadData), ",")
    if len(parts) != 3 {
        return nil, &processor.InvalidTransactionError{Msg: "Payload is malformed"}
    }

    payload := XoPayload{}
    payload.Name = parts[0]
    payload.Action = parts[1]

    if len(payload.Name) < 1 {
        return nil, &processor.InvalidTransactionError{Msg: "Name is required"}
    }

    if len(payload.Action) < 1 {
        return nil, &processor.InvalidTransactionError{Msg: "Action is required"}
    }

    if payload.Action == "take" {
        space, err := strconv.Atoi(parts[2])
        if err != nil {
            return nil, &processor.InvalidTransactionError{
                Msg: fmt.Sprintf("Invalid Space: '%v'", parts[2])}
        }
        payload.Space = space
    }

    if strings.Contains(payload.Name, "|") {
        return nil, &processor.InvalidTransactionError{
            Msg: fmt.Sprintf("Invalid Name (char '|' not allowed): '%v'", parts[2])}
    }

    return &payload, nil
}
```

{% elif language == \'Rust\' %}

``` rust
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

{% else %}

``` python
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

{% endif %}

## State

The XoState class turns game information into bytes and stores it in the
validator\'s Radix-Merkle tree, turns bytes stored in the validator\'s
Radix-Merkle tree into game information, and does these operations with
a state storage scheme that handles hash collisions.

An XO state entry consists of the UTF-8 encoding of a string with
exactly four commas formatted as follows:

`<name>,<board>,<game-state>,<player-key-1>,<player-key-2>`

where

-   \<name> is a nonempty string not containing [\|]{.title-ref},
-   \<board> is a string of length 9 containing only [O]{.title-ref},
    [X]{.title-ref}, or [-]{.title-ref},
-   \<game-state> is one of the following: [P1-NEXT]{.title-ref},
    [P2-NEXT]{.title-ref}, [P1-WIN]{.title-ref},
-   [P2-WIN]{.title-ref}, or [TIE]{.title-ref}, and
-   \<player-key-1> and \<player-key-2> are the (possibly empty) public
    keys
-   associated with the game\'s players.

In the event of a hash collision (i.e. two or more state entries sharing
the same address), the colliding state entries will stored as the UTF-8
encoding of the string `<a-entry>|<b-entry>|...`, where \<a-entry>,
\<b-entry>,\... are sorted alphabetically.

{% if language == \'JavaScript\' %}

``` javascript
class XoState {
    constructor (context) {
        this.context = context
        this.addressCache = new Map([])
        this.timeout = 500 // Timeout in milliseconds
    }

    getGame (name) {
        return this._loadGames(name).then((games) => games.get(name))
    }

    setGame (name, game) {
        let address = _makeXoAddress(name)

        return this._loadGames(name).then((games) => {
            games.set(name, game)
            return games
        }).then((games) => {
            let data = _serialize(games)

            this.addressCache.set(address, data)
            let entries = {
                [address]: data
            }
            return this.context.setState(entries, this.timeout)
        })
    }

    deleteGame (name) {
        let address = _makeXoAddress(name)
        return this._loadGames(name).then((games) => {
            games.delete(name)

            if (games.size === 0) {
                this.addressCache.set(address, null)
                return this.context.deleteState([address], this.timeout)
            } else {
                let data = _serialize(games)
                this.addressCache.set(address, data)
                let entries = {
                    [address]: data
                }
                    return this.context.setState(entries, this.timeout)
                }
            })
        }

    _loadGames (name) {
        let address = _makeXoAddress(name)
        if (this.addressCache.has(address)) {
            if (this.addressCache.get(address) === null) {
                return Promise.resolve(new Map([]))
            } else {
                return Promise.resolve(_deserialize(this.addressCache.get(address)))
            }
        } else {
            return this.context.getState([address], this.timeout)
                .then((addressValues) => {
                    if (!addressValues[address].toString()) {
                        this.addressCache.set(address, null)
                        return new Map([])
                    } else {
                        let data = addressValues[address].toString()
                        this.addressCache.set(address, data)
                        return _deserialize(data)
                    }
                })
            }
        }
    }

const _hash = (x) =>
    crypto.createHash('sha512').update(x).digest('hex').toLowerCase().substring(0, 64)

const XO_FAMILY = 'xo'

const XO_NAMESPACE = _hash(XO_FAMILY).substring(0, 6)

const _deserialize = (data) => {
    let gamesIterable = data.split('|').map(x => x.split(','))
        .map(x => [x[0], {name: x[0], board: x[1], state: x[2], player1: x[3], player2: x[4]}])
    return new Map(gamesIterable)
}

const _serialize = (games) => {
    let gameStrs = []
    for (let nameGame of games) {
        let name = nameGame[0]
        let game = nameGame[1]
        gameStrs.push([name, game.board, game.state, game.player1, game.player2].join(','))
    }

    gameStrs.sort()

    return Buffer.from(gameStrs.join('|'))
}
```

{% elif language == \'Go\' %}

``` go
var Namespace = hexdigest("xo")[:6]

type Game struct {
    Board   string
    State   string
    Player1 string
    Player2 string
    Name    string
}

// XoState handles addressing, serialization, deserialization,
// and holding an addressCache of data at the address.
type XoState struct {
    context      *processor.Context
    addressCache map[string][]byte
}

// NewXoState constructs a new XoState struct.
func NewXoState(context *processor.Context) *XoState {
    return &XoState{
        context:      context,
        addressCache: make(map[string][]byte),
    }
}

// GetGame returns a game by its name.
func (self *XoState) GetGame(name string) (*Game, error) {
    games, err := self.loadGames(name)
    if err != nil {
        return nil, err
    }
    game, ok := games[name]
    if ok {
        return game, nil
    }
    return nil, nil
}

// SetGame sets a game to its name
func (self *XoState) SetGame(name string, game *Game) error {
    games, err := self.loadGames(name)
    if err != nil {
        return err
    }

    games[name] = game

    return self.storeGames(name, games)
}

// DeleteGame deletes the game from state, handling
// hash collisions.
func (self *XoState) DeleteGame(name string) error {
    games, err := self.loadGames(name)
    if err != nil {
        return err
    }
    delete(games, name)
    if len(games) > 0 {
        return self.storeGames(name, games)
    } else {
        return self.deleteGames(name)
    }
}

func (self *XoState) loadGames(name string) (map[string]*Game, error) {
    address := makeAddress(name)

    data, ok := self.addressCache[address]
    if ok {
        if self.addressCache[address] != nil {
            return deserialize(data)
        }
        return make(map[string]*Game), nil

    }
    results, err := self.context.GetState([]string{address})
    if err != nil {
        return nil, err
    }
    if len(string(results[address])) > 0 {
        self.addressCache[address] = results[address]
        return deserialize(results[address])
    }
    self.addressCache[address] = nil
    games := make(map[string]*Game)
    return games, nil
}

func (self *XoState) storeGames(name string, games map[string]*Game) error {
    address := makeAddress(name)

    var names []string
    for name := range games {
        names = append(names, name)
    }
    sort.Strings(names)

    var g []*Game
    for _, name := range names {
        g = append(g, games[name])
    }

    data := serialize(g)

    self.addressCache[address] = data

    _, err := self.context.SetState(map[string][]byte{
        address: data,
    })
    return err
}

func (self *XoState) deleteGames(name string) error {
    address := makeAddress(name)

    _, err := self.context.DeleteState([]string{address})
    return err
}

func deserialize(data []byte) (map[string]*Game, error) {
    games := make(map[string]*Game)
    for _, str := range strings.Split(string(data), "|") {

        parts := strings.Split(string(str), ",")
        if len(parts) != 5 {
            return nil, &processor.InternalError{
                Msg: fmt.Sprintf("Malformed game data: '%v'", string(data))}
        }

        game := &Game{
            Name:    parts[0],
            Board:   parts[1],
            State:   parts[2],
            Player1: parts[3],
            Player2: parts[4],
        }
        games[parts[0]] = game
    }

    return games, nil
}

func serialize(games []*Game) []byte {
    var buffer bytes.Buffer
    for i, game := range games {

        buffer.WriteString(game.Name)
        buffer.WriteString(",")
        buffer.WriteString(game.Board)
        buffer.WriteString(",")
        buffer.WriteString(game.State)
        buffer.WriteString(",")
        buffer.WriteString(game.Player1)
        buffer.WriteString(",")
        buffer.WriteString(game.Player2)
        if i+1 != len(games) {
            buffer.WriteString("|")
        }
    }
    return buffer.Bytes()
}

func hexdigest(str string) string {
    hash := sha512.New()
    hash.Write([]byte(str))
    hashBytes := hash.Sum(nil)
    return strings.ToLower(hex.EncodeToString(hashBytes))
}
```

{% elif language == \'Rust\' %}

``` rust
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

{% else %}

``` python
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

{% endif %}

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

``` pycon
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

{% if language == \'JavaScript\' %}

``` javascript
const _makeXoAddress = (x) => XO_NAMESPACE + _hash(x)
```

{% elif language == \'Go\' %}

``` go
func makeAddress(name string) string {
    return Namespace + hexdigest(name)[:64]
}
```

{% elif language == \'Rust\' %}

``` rust
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

{% else %}

``` python
def _make_xo_address(name):
return XO_NAMESPACE + \
    hashlib.sha512(name.encode('utf-8')).hexdigest()[:64]
```

{% endif %}

---
title: "Client: Building and Submitting Transactions"
---

The process of encoding information to be submitted to a distributed
ledger is generally non-trivial. A series of cryptographic safeguards
are used to confirm identity and data validity. Hyperledger Sawtooth is
no different, but the {{ language }} SDK does provide client
functionality that abstracts away most of these details, and greatly
simplifies the process of making changes to the blockchain.

# Creating a Private Key and Signer

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

{% if language == \'JavaScript\' %}

``` javascript
const {createContext, CryptoFactory} = require('sawtooth-sdk/signing')

const context = createContext('secp256k1')
const privateKey = context.newRandomPrivateKey()
const signer = CryptoFactory(context).newSigner(privateKey)
```

{% elif language == \'Go\' %}

``` go
import "github.com/hyperledger/sawtooth-sdk-go/signing"

context := signing.NewSecp256k1Context()
privateKey := context.NewRandomPrivateKey()
signer := signing.NewCryptoFactory(context).NewSigner(privateKey)
```

{% elif language == \'Rust\' %}

``` rust
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

{% else %}

{# Python 3 code should be the default #}

``` python
from sawtooth_signing import create_context
from sawtooth_signing import CryptoFactory

context = create_context('secp256k1')
private_key = context.new_random_private_key()
signer = CryptoFactory(context).new_signer(private_key)
```

{% endif %}

::: note
::: title
Note
:::

This key is the **only** way to prove your identity on the blockchain.
Any person possessing it will be able to sign Transactions using your
identity, and there is no way to recover it if lost. It is very
important that any private key is kept secret and secure.
:::

---
title: Encoding Your Payload
---

Transaction payloads are composed of binary-encoded data that is opaque
to the validator. The logic for encoding and decoding them rests
entirely within the particular Transaction Processor itself. As a
result, there are many possible formats, and you will have to look to
the definition of the Transaction Processor itself for that information.
As an example, the *IntegerKey* Transaction Processor uses a payload of
three key/value pairs encoded as
[CBOR](https://en.wikipedia.org/wiki/CBOR). Creating one might look like
this:

{% if language == \'JavaScript\' %}

``` javascript
const cbor = require('cbor')

const payload = {
    Verb: 'set',
    Name: 'foo',
    Value: 42
}

const payloadBytes = cbor.encode(payload)
```

{% elif language == \'Go\' %}

``` go
import (
    cbor "github.com/brianolson/cbor_go"
)

payloadData := make(map[string]interface{})
payloadData["Verb"] = "set"
payloadData["Name"] = "foo"
payloadData["Value"] = 42

// check if err is nil before continuing
payloadBytes, err := cbor.Dumps(payloadData)
```

{% elif language == \'Rust\' %}

``` rust
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

{% else %}

``` python
import cbor

payload = {
    'Verb': 'set',
    'Name': 'foo',
    'Value': 42}

payload_bytes = cbor.dumps(payload)
```

{% endif %}

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

# Building the Transaction

*Transactions* are the basis for individual changes of state to the
Sawtooth blockchain. They are composed of a binary payload, a
binary-encoded *TransactionHeader* with some cryptographic safeguards
and metadata about how it should be handled, and a signature of that
header. It would be worthwhile to familiarize yourself with the
information in
`/architecture/transactions_and_batches`{.interpreted-text role="doc"},
particularly the definition of TransactionHeaders.

## 1. Create the Transaction Header

A TransactionHeader contains information for routing a transaction to
the correct transaction processor, what input and output state addresses
are involved, references to prior transactions it depends on, and the
public keys associated with the its signature. The header references the
payload through a SHA-512 hash of the payload bytes.

{% if language == \'JavaScript\' %}

``` javascript
const {createHash} = require('crypto')
const {protobuf} = require('sawtooth-sdk')

const transactionHeaderBytes = protobuf.TransactionHeader.encode({
    familyName: 'intkey',
    familyVersion: '1.0',
    inputs: ['1cf1266e282c41be5e4254d8820772c5518a2c5a8c0c7f7eda19594a7eb539453e1ed7'],
    outputs: ['1cf1266e282c41be5e4254d8820772c5518a2c5a8c0c7f7eda19594a7eb539453e1ed7'],
    signerPublicKey: signer.getPublicKey().asHex(),
    // In this example, we're signing the batch with the same private key,
    // but the batch can be signed by another party, in which case, the
    // public key will need to be associated with that key.
    batcherPublicKey: signer.getPublicKey().asHex(),
    // In this example, there are no dependencies.  This list should include
    // an previous transaction header signatures that must be applied for
    // this transaction to successfully commit.
    // For example,
    // dependencies: ['540a6803971d1880ec73a96cb97815a95d374cbad5d865925e5aa0432fcf1931539afe10310c122c5eaae15df61236079abbf4f258889359c4d175516934484a'],
    dependencies: [],
    payloadSha512: createHash('sha512').update(payloadBytes).digest('hex')
}).finish()
```

{% elif language == \'Go\' %}

``` go
import (
    "crypto/sha512"
    "encoding/hex"
    "github.com/golang/protobuf/proto"
    "github.com/hyperledger/sawtooth-sdk-go/protobuf/transaction_pb2"
    "strings"
)

hashHandler := sha512.New()
hashHandler.Write(payloadBytes)
payloadSha512 := strings.ToLower(hex.EncodeToString(hashHandler.Sum(nil)))

rawTransactionHeader := transaction_pb2.TransactionHeader{
    SignerPublicKey:  signer.GetPublicKey().AsHex(),
    FamilyName:       "intkey",
    FamilyVersion:    "1.0",
    // In this example, there are no dependencies.  This list should include
    // an previous transaction header signatures that must be applied for
    // this transaction to successfully commit.
    // For example,
    // dependencies:[]string{"540a6803971d1880ec73a96cb97815a95d374cbad5d865925e5aa0432fcf1931539afe10310c122c5eaae15df61236079abbf4f258889359c4d175516934484a"}
    Dependencies:     []string{},
    // In this example, we're signing the batch with the same private key,
    // but the batch can be signed by another party, in which case, the
    // public key will need to be associated with that key.
    BatcherPublicKey: signer.GetPublicKey().AsHex(),
    Inputs:           []string{"1cf1266e282c41be5e4254d8820772c5518a2c5a8c0c7f7eda19594a7eb539453e1ed7"},
    Outputs:          []string{"1cf1266e282c41be5e4254d8820772c5518a2c5a8c0c7f7eda19594a7eb539453e1ed7"},
    PayloadSha512:    payloadSha512,
}

// Check if err is nil before continuing
transactionHeaderBytes, err := proto.Marshal(&rawTransactionHeader)
```

{% elif language == \'Rust\' %}

``` rust
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

{% else %}

``` python
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

{% endif %}

::: note
::: title
Note
:::

Remember that a *batcher public_key* is the hex public key matching the
private key that will later be used to sign a Transaction\'s Batch, and
*dependencies* are the *header signatures* of Transactions that must be
committed before this one (see *TransactionHeaders* in
`/architecture/transactions_and_batches`{.interpreted-text role="doc"}).
:::

::: note
::: title
Note
:::

The *inputs* and *outputs* are the state addresses a Transaction is
allowed to read from or write to. With the Transaction above, we
referenced the specific address where the value of `'foo'` is stored.
Whenever possible, specific addresses should be used, as this will allow
the validator to schedule transaction processing more efficiently.

Note that the methods for assigning and validating addresses are
entirely up to the Transaction Processor. In the case of IntegerKey,
there are [specific rules to generate valid addresses
\<../transaction_family_specifications
/integerkey_transaction_family.html#addressing>](), which must be
followed or Transactions will be rejected. You will need to follow the
addressing rules for whichever Transaction Family you are working with.
:::

## 2. Create the Transaction

Once the TransactionHeader is constructed, its bytes are then used to
create a signature. This header signature also acts as the ID of the
transaction. The header bytes, the header signature, and the payload
bytes are all used to construct the complete Transaction.

{% if language == \'JavaScript\' %}

``` javascript
const signature = signer.sign(transactionHeaderBytes)

const transaction = protobuf.Transaction.create({
    header: transactionHeaderBytes,
    headerSignature: signature,
    payload: payloadBytes
})
```

{% elif language == \'Go\' %}

``` go
import (
    "encoding/hex"
    "github.com/hyperledger/sawtooth-sdk-go/protobuf/transaction_pb2"
)

signature := hex.EncodeToString(signer.Sign(transactionHeaderBytes))
transaction := transaction_pb2.Transaction{
    Header:          transactionHeaderBytes,
    HeaderSignature: signature,
    Payload:         payloadBytes,
}
```

{% elif language == \'Rust\' %}

``` rust
use sawtooth_sdk::messages::transaction::Transaction;

let signature = signer
    .sign(&txn_header_bytes)
    .expect("Error signing the transaction header");

let mut txn = Transaction::new();
txn.set_header(txn_header_bytes.to_vec());
txn.set_header_signature(signature);
txn.set_payload(payload_bytes);
```

{% else %}

``` python
from sawtooth_sdk.protobuf.transaction_pb2 import Transaction

signature = signer.sign(txn_header_bytes)

txn = Transaction(
    header=txn_header_bytes,
    header_signature=signature,
    payload=payload_bytes
)
```

{% endif %}

## 3. (optional) Encode the Transaction(s)

If the same machine is creating Transactions and Batches there is no
need to encode the Transaction instances. However, in the use case where
Transactions are being batched externally, they must be serialized
before being transmitted to the batcher. The {{ language }} SDK offers
two options for this. One or more Transactions can be combined into a
serialized *TransactionList* method, or can be serialized as a single
Transaction.

{% if language == \'JavaScript\' %}

``` javascript
const txnListBytes = protobuf.TransactionList.encode([
    transaction1,
    transaction2
]).finish()

const txnBytes2 = transaction.finish()
```

{% elif language == \'Go\' %}

``` go
import (
    "github.com/golang/protobuf/proto"
    "github.com/hyperledger/sawtooth-sdk-go/protobuf/transaction_pb2"
)

rawTransactionList := transaction_pb2.TransactionList{
    Transactions: []*transaction_pb2.Transaction{
        &transaction1,
        &transaction2,
    },
}
// Check if err is nil before continuing
transactionListBytes, err := proto.Marshal(&rawTransactionList)

// Check if err is nil before continuing
transactionBytes, err := proto.Marshal(&transaction)
```

{% elif language == \'Rust\' %}

``` rust
let txn_list_vec = vec![txn1, txn2];
let txn_list = TransactionList::new();
txn_list.set_transactions(RepeatedField::from_vec(txn_list_vec));

let txn_list_bytes = txn_list
    .write_to_bytes()
    .expect("Error converting Transaction List to bytes");
```

{% else %}

``` python
from sawtooth_sdk.protobuf.transaction_pb2 import TransactionList

txn_list_bytes = TransactionList(
    transactions=[txn1, txn2]
).SerializeToString()

txn_bytes = txn.SerializeToString()
```

{% endif %}

# Building the Batch

Once you have one or more Transaction instances ready, they must be
wrapped in a *Batch*. Batches are the atomic unit of change in
Sawtooth\'s state. When a Batch is submitted to a validator each
Transaction in it will be applied (in order), or *no* Transactions will
be applied. Even if your Transactions are not dependent on any others,
they cannot be submitted directly to the validator. They must all be
wrapped in a Batch.

## 1. Create the BatchHeader

Similar to the TransactionHeader, there is a *BatchHeader* for each
Batch. As Batches are much simpler than Transactions, a BatchHeader
needs only the public key of the signer and the list of Transaction IDs,
in the same order they are listed in the Batch.

{% if language == \'JavaScript\' %}

``` javascript
const transactions = [transaction]

const batchHeaderBytes = protobuf.BatchHeader.encode({
    signerPublicKey: signer.getPublicKey().asHex(),
    transactionIds: transactions.map((txn) => txn.headerSignature),
}).finish()
```

{% elif language == \'Go\' %}

``` go
import (
    "github.com/golang/protobuf/proto"
    "github.com/hyperledger/sawtooth-sdk-go/protobuf/batch_pb2"
)

transactionSignatures := []string{transaction.HeaderSignature}

rawBatchHeader := batch_pb2.BatchHeader{
    SignerPublicKey: signer.GetPublicKey().AsHex(),
    TransactionIds:  transactionSignatures,
}

// Check if err is nil before continuing
batchHeaderBytes, err := proto.Marshal(&rawBatchHeader)
```

{% elif language == \'Rust\' %}

``` rust
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

{% else %}

``` python
from sawtooth_sdk.protobuf.batch_pb2 import BatchHeader

txns = [txn]

batch_header_bytes = BatchHeader(
    signer_public_key=signer.get_public_key().as_hex(),
    transaction_ids=[txn.header_signature for txn in txns],
).SerializeToString()
```

{% endif %}

## 2. Create the Batch

Using the SDK, creating a Batch is similar to creating a transaction.
The header is signed, and the resulting signature acts as the Batch\'s
ID. The Batch is then constructed out of the header bytes, the header
signature, and the transactions that make up the batch.

{% if language == \'JavaScript\' %}

``` javascript
const signature = signer.sign(batchHeaderBytes)

const batch = protobuf.Batch.create({
    header: batchHeaderBytes,
    headerSignature: signature,
    transactions: transactions
})
```

{% elif language == \'Go\' %}

``` go
import (
    "encoding/hex"
    "github.com/hyperledger/sawtooth-sdk-go/protobuf/batch_pb2"
)

signature := hex.EncodeToString(signer.Sign(batchHeader))

batch := batch_pb2.Batch{
    Header:          batchHeaderBytes,
    Transactions:    transactions,
    HeaderSignature: signature,
}
```

{% elif language == \'Rust\' %}

``` rust
use sawtooth_sdk::messages::batch::Batch;

let signature = signer
    .sign(&batch_header_bytes)
    .expect("Error signing the batch header");

let mut batch = Batch::new();

batch.set_header(batch_header_bytes);
batch.set_header_signature(signature);
batch.set_transactions(RepeatedField::from_vec(vec![txn]));
```

{% else %}

``` python
from sawtooth_sdk.protobuf.batch_pb2 import Batch

signature = signer.sign(batch_header_bytes)

batch = Batch(
    header=batch_header_bytes,
    header_signature=signature,
    transactions=txns
)
```

{% endif %}

## 3. Encode the Batch(es) in a BatchList

In order to submit Batches to the validator, they must be collected into
a *BatchList*. Multiple batches can be submitted in one BatchList,
though the Batches themselves don\'t necessarily need to depend on each
other. Unlike Batches, a BatchList is not atomic. Batches from other
clients may be interleaved with yours.

{% if language == \'JavaScript\' %}

``` javascript
const batchListBytes = protobuf.BatchList.encode({
    batches: [batch]
}).finish()
```

{% elif language == \'Go\' %}

``` go
import (
    "github.com/golang/protobuf/proto"
    "github.com/hyperledger/sawtooth-sdk-go/protobuf/batch_pb2"
)

rawBatchList := batch_pb2.BatchList{
    Batches: []*batch_pb2.Batch{&batch},
}

// Check if err is nil before continuing
batchListBytes := proto.Marshal(&rawBatchList)
```

{% elif language == \'Rust\' %}

``` rust
use sawtooth_sdk::messages::batch::BatchList;

let mut batch_list = BatchList::new();
batch_list.set_batches(RepeatedField::from_vec(vec![batch]));
let batch_list_bytes = batch_list
    .write_to_bytes()
    .expect("Error converting batch list to bytes");
```

{% else %}

``` python
from sawtooth_sdk.protobuf.batch_pb2 import BatchList

batch_list_bytes = BatchList(batches=[batch]).SerializeToString()
```

{% endif %}

::: note
::: title
Note
:::

Note, if the transaction creator is using a different private key than
the batcher, the *batcher public_key* must have been specified for every
Transaction, and must have been generated from the private key being
used to sign the Batch, or validation will fail.
:::

---
title: Submitting Batches to the Validator
---

The prescribed way to submit Batches to the validator is via the REST
API. This is an independent process that runs alongside a validator,
allowing clients to communicate using HTTP/JSON standards. Simply send a
*POST* request to the */batches* endpoint, with a *\"Content-Type\"*
header of *\"application/octet-stream\"*, and the *body* as a serialized
*BatchList*.

There are a many ways to make an HTTP request, and hopefully the
submission process is fairly straightforward from here, but as an
example, this is what it might look if you sent the request from the
same {{ language }} process that prepared the BatchList:

{% if language == \'JavaScript\' %}

``` javascript
const request = require('request')

request.post({
    url: 'http://rest.api.domain/batches',
    body: batchListBytes,
    headers: {'Content-Type': 'application/octet-stream'}
}, (err, response) => {
    if (err) return console.log(err)
    console.log(response.body)
})
```

{% elif language == \'Go\' %}

``` go
import (
    "bytes"
    "net/http"
)

// Check if err is nil before continuing
response, err := http.Post(
    "http://rest.api.domain/batches",
    "application/octet-stream",
    bytes.NewBuffer(batchListBytes)
)
```

{% elif language == \'Rust\' %}

``` rust
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

{% else %}

``` python
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

{% endif %}

And here is what it would look like if you saved the binary to a file,
and then sent it from the command line with `curl`:

{% if language == \'JavaScript\' %}

``` javascript
const fs = require('fs')

const fileStream = fs.createWriteStream('intkey.batches')
fileStream.write(batchListBytes)
fileStream.end()
```

{% elif language == \'Go\' %}

``` go
import (
    "io/ioutil"
)

// Check if err is nil before continuing
err = ioutil.WriteFile("intkey.batches", batchListBytes, 0644)
```

{% elif language == \'Rust\' %}

``` rust
use std::fs::File;
use std::io::Write;

let mut file = File::create("intkey.batches").expect("Error creating file");
file.write_all(&batch_list_bytes)
    .expect("Error writing bytes");
```

{% else %}

``` python
output = open('intkey.batches', 'wb')
output.write(batch_list_bytes)
```

{% endif %}

``` bash
% curl --request POST \
    --header "Content-Type: application/octet-stream" \
    --data-binary @intkey.batches \
    "http://rest.api.domain/batches"
```

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
