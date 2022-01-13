# Playing with the XO Transaction Family

XO is an example transaction family that implements the game
[tic-tac-toe](https://en.wikipedia.org/wiki/Tic-tac-toe), also known as
*Noughts and Crosses* or *X\'s and O\'s*. We chose XO as an example
transaction family for Sawtooth because of its simplicity, global player
base, and straightforward implementation as a computer program. This
transaction family demonstrates the functionality of Sawtooth; in
addition, the code that implements it serves as a reference for building
other transaction processors.

This section introduces the concepts of a Sawtooth transaction family
with XO, summarizes XO game rules, and describes how use the `xo` client
application to play a game of tic-tac-toe on the blockchain.

## About the XO Transaction Family

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

The XO transaction family defines the data model and business logic for
playing tic-tac-toe on the blockchain by submitting transactions for
[create]{.title-ref}, [take]{.title-ref}, and [delete]{.title-ref}
actions. For more information, see [XO Transaction
Family]({% link docs/1.2/transaction_family_specifications/xo_transaction_family.md%})

The XO transaction family includes:

> -   Transaction processors in several languages, including Go
>     (`xo-tp-go`),
>     [JavaScript](https://github.com/hyperledger/sawtooth-sdk-javascript/blob/master/examples/xo/),
>     and Python (`xo-tp-python`). These transaction processors
>     implement the business logic of XO game play.
> -   An `xo` client: A set of commands that provide a command-line
>     interface for playing XO. The `xo` client handles the construction
>     and submission of transactions. For more information, see [XO
>     CLI]({% link docs/1.2/cli/xo.md%})

## Game Rules

In tic-tac-toe, two players take turns marking spaces on a 3x3 grid.

-   The first player (player 1) marks spaces with an X. Player 1 always
    makes the first move.
-   The second player (player 2) marks spaces with an O.
-   A player wins the game by marking three adjoining spaces in a
    horizontal, vertical, or diagonal row.
-   The game is a tie if all nine spaces on the grid have been marked,
    but no player has won.

See [Wikipedia](https://en.wikipedia.org/wiki/Tic-tac-toe) for more
information on playing tic-tac-toe. For the detailed business logic of
game play, see \"Execution\" in [XO Transaction
Family]({% link docs/1.2/transaction_family_specifications/xo_transaction_family.md%})

## Playing XO with the xo Client

This procedure introduces you to the XO transaction family by playing a
game with the `xo` client. Each `xo` command is a transaction that the
client submits to the validator via the REST API.

### Prerequisites

-   A working Sawtooth node, as described in [Installing
    Sawtooth]({% link docs/1.2/app_developers_guide/installing_sawtooth.md%})
    This node must be running a validator, a REST API, a
    consensus engine, and the Settings transaction processor. (The
    IntegerKey transaction processor is not used in this procedure.)
-   This procedure also requires the XO transaction processor. The
    Docker and Kubernetes procedures start it automatically. For Ubuntu,
    this procedure shows how to start the XO transaction processor if
    necessary.

### Step 1: Connect to the Sawtooth Node

To connect to the Sawtooth node, use the steps for your platform:

-   Docker: See [Log Into the Docker Client
    Container]({% link docs/1.2/app_developers_guide/docker.md%}#log-into-the-docker-client-container)
-   Kubernetes: See [Connect to the Kubernetes Shell
    Container]({% link docs/1.2/app_developers_guide/kubernetes.md%}#connect-to-the-kubernetes-shell-container)
-   Ubuntu: Open a client terminal window on the host system running
    Sawtooth

### Step 2: Confirm Connectivity to the REST API

Verify that you can connect to the REST API. The step will help
determine if The REST API is at the default location
(`http://localhost:8008`).

The `xo` client sends requests to update and query the blockchain to the
URL of the REST API (by default, `http://127.0.0.1:8008`). If the REST
API\'s URL is not `http://127.0.0.1:8008`, you must add the `--url`
argument to each `xo` command in this procedure.

-   Docker: See [Confirm Connectivity to the REST API]({% link docs/1.2/app_developers_guide/docker.md%}#confirm-connectivity-to-the-rest-api)

    > Important
    >
    >
    > In the Docker environment, the REST API is at
    > `http://rest-api:8008`. You must add `--url http://rest-api:8008` to
    > all `xo` commands in this procedure. For example:
    >
    > ``` console
    > $ xo create my-game --username jack --url http://rest-api:8008
    > ```

-   Kubernetes: See [Confirm Connectivity to the REST API (for
    Kubernetes)]({% link docs/1.2/app_developers_guide/kubernetes.md %}#confirm-connectivity-to-the-rest-api-for-kubernetes)

-   Ubuntu: See [Use Sawtooth Commands as a
    Client]({% link docs/1.2/app_developers_guide/ubuntu.md %}#use-sawtooth-commands-as-a-client)

### Step 3. Ubuntu only: Start the XO Transaction Processor

For Ubuntu: If the XO transaction processor is not running on your
Sawtooth node, start it now.

1.  Open a new terminal window (the xo window).

2.  Check whether the XO transaction processor is running.

    ``` console
    user@xo$ ps aux | grep [x]o-tp
    root      1546  0.0  0.1  52700  3776 pts/2    S+   19:15   0:00 sudo -u sawtooth xo-tp-python -v
    sawtooth  1547  0.0  1.5 277784 31192 pts/2    Sl+  19:15   0:00 /usr/bin/python3 /usr/bin/xo-tp-python -v
    ```

3.  If the output does not show that `/usr/bin/xo-tp-python` is running,
    start the XO transaction processor with the following command:

    ``` console
    user@xo$ sudo -u sawtooth xo-tp-python -v
    ```

For more information, see [Start the Transaction
Processors]({% link docs/1.2/app_developers_guide/ubuntu.md %}#start-the-transaction-precessors)

### Step 4. Create Players

Create keys for two players to play the game:

``` console
$ sawtooth keygen jack
writing file: /home/ubuntu/.sawtooth/keys/jack.priv
writing file: /home/ubuntu/.sawtooth/keys/jack.addr

$ sawtooth keygen jill
writing file: /home/ubuntu/.sawtooth/keys/jill.priv
writing file: /home/ubuntu/.sawtooth/keys/jill.addr
```


> Note
>
> The output may differ slightly from this example.

### Step 5. Create a Game

Create a game named `my-game` with the following command:

``` console
$ xo create my-game --username jack
```


> Note
>
> The `--username` argument is required for `xo create` and `xo take` so
> that a single player (you) can play as two players. By default,
> `<username>` is the Linux user name of the person playing the game.

Verify that the `create` transaction was committed by displaying the
list of existing games:

``` console
$ xo list
GAME            PLAYER 1        PLAYER 2        BOARD     STATE
my-game                                         --------- P1-NEXT
```

> Note
>
>
> The `xo list` command is a wrapper that provides a quick way to show
> game state rather than using `curl` with the REST API\'s URL to request
> state.

### Step 6. Take a Space as Player 1

> Note
>
> The first player to issue an `xo take` command to a newly created game
> is recorded as `PLAYER 1` . The second player to issue a `take` command
> is recorded by username as `PLAYER 2`.
>
> The `--username` argument determines where the `xo` client should look
> for the player\'s key to sign the transaction. By default, if you\'re
> logged in as `root`, `xo` would look for the key file named
> `~/.sawtooth/keys/root.priv`. Instead, the following command specifies
> that `xo` should use the key file `~/.sawtooth/keys/jack.priv`.
>

Start playing tic-tac-toe by taking a space as the first player, Jack.
In this example, Jack takes space 5:

``` console
$ xo take my-game 5 --username jack
```

This diagram shows the number of each space.

``` console
 1 | 2 | 3
---|---|---
 4 | 5 | 6
---|---|---
 7 | 8 | 9
```

**What Happens During a Game Move?**

Each `xo` command is a transaction. A successful transaction updates
global state with the game name, board state, game state, and player
keys, using this format:

``` none
<game-name>,<board-state>,<game-state>,<player1-key>,<player2-key>
```

Each time a player attempts to take a space, the transaction processor
will verify that their username matches the name of the player whose
turn it is. This ensures that no player is able to mark a space out of
turn.

After each turn, the XO transaction processor scans the board state for
a win or tie. If either condition occurs, no more `take` actions are
allowed on the finished game.

### Step 7. Take a Space as Player 2

Next, take a space on the board as player 2, Jill. In this example, Jill
takes space 1:

``` console
$ xo take my-game 1 --username jill
```

### Step 8. Show the Current Game Board

Whenever you want to see the current state of the game board, enter the
following command:

``` console
$ xo show my-game
```

The output includes the game name, the first six characters of each
player\'s public key, the game state, and the current board state. This
example shows the game state `P1-NEXT` (player 1 has the next turn) and
a board with Jack\'s X in space 5 and Jill\'s O in space 1.

``` console
GAME:     : my-game
PLAYER 1  : 02403a
PLAYER 2  : 03729b
STATE     : P1-NEXT

  O |   |
 ---|---|---
    | X |
 ---|---|---
    |   |
```

This `xo` client formats the global state data so that it\'s easier to
read than the state returned to the transaction processor:

``` none
my-game,O---X----,P1-NEXT,02403a...,03729b...
```

### Step 9. Continue the Game

Players take turns using `xo take my-game <space>` to mark spaces on the
grid.

You can continue the game until one of the players wins or the game ends
in a tie, as in this example:

``` console
$ xo show my-game
GAME:     : my-game
PLAYER 1  : 02403a
PLAYER 2  : 03729b
STATE     : TIE

  O | X | O
 ---|---|---
  X | X | O
 ---|---|---
  X | O | X
```

### Step 10. Delete the Game

Either player can use the `xo delete` command to remove the game data
from global state.

``` console
$ xo delete my-game
```

## Using Authentication with the xo Client

The XO client supports optional authentication. If the REST API is
connected to an authentication proxy, you can point the XO client at it
with the `--url` argument. You must also specify your authentication
information using the `--auth-user [user]` and
`--auth-password [password]` options for each `xo` command.

Note that the value of the `--auth-user` argument is **not** the same
username that is entered with the `--username` argument.
