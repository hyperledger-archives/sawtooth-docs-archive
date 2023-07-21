<!--
     Copyright 2017 Intel Corporation

     Licensed under the Apache License, Version 2.0 (the "License");
     you may not use this file except in compliance with the License.
     You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

     Unless required by applicable law or agreed to in writing, software
     distributed under the License is distributed on an "AS IS" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     See the License for the specific language governing permissions and
     limitations under the License.

  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

# xo

The `xo` command starts the XO transaction processor.

This command demonstrates an example client that uses the XO transaction
family to play a simple game of Tic-tac-toe (also known as Noughts and
Crosses, or X\'s and O\'s). This command handles the construction and
submission of transactions to a running validator via the URL of the
validator\'s REST API.

Before playing a game, you must start a validator, the XO transaction
processor, and the REST API. The XO client sends requests to update and
query the blockchain to the URL of the REST API (by default,
`http://127.0.0.1:8008`).

For more information on requirements and game rules, see
[Playing with the XO Transaction Family]({% link
docs/1.2/app_developers_guide/intro_xo_transaction_family.md %}).

The `xo` command provides subcommands for playing XO on the command
line.

```
usage: xo [-h] [-v] [-V] {create,list,show,take,delete} ...

Provides subcommands to play tic-tac-toe (also known as Noughts and Crosses)
by sending XO transactions.

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         enable more verbose output
  -V, --version         display version information

subcommands:
  {create,list,show,take,delete}
    create              Creates a new xo game
    list                Displays information for all xo games
    show                Displays information about an xo game
    take                Takes a space in an xo game

```

## xo create

The `xo create` subcommand starts an XO game with the specified name.

```
usage: xo create [-h] [-v] [-V] [--url URL] [--username USERNAME]
                 [--key-dir KEY_DIR] [--auth-user AUTH_USER]
                 [--auth-password AUTH_PASSWORD] [--disable-client-validation]
                 [--wait [WAIT]]
                 name

Sends a transaction to start an xo game with the identifier <name>. This
transaction will fail if the specified game already exists.

positional arguments:
  name                  unique identifier for the new game

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         enable more verbose output
  -V, --version         display version information
  --url URL             specify URL of REST API
  --username USERNAME   identify name of user's private key file
  --key-dir KEY_DIR     identify directory of user's private key file
  --auth-user AUTH_USER
                        specify username for authentication if REST API is
                        using Basic Auth
  --auth-password AUTH_PASSWORD
                        specify password for authentication if REST API is
                        using Basic Auth
  --disable-client-validation
                        disable client validation
  --wait [WAIT]         set time, in seconds, to wait for game to commit

```

## xo list

The `xo list` subcommand displays information for all XO games in state.

```
usage: xo list [-h] [-v] [-V] [--url URL] [--username USERNAME]
               [--key-dir KEY_DIR] [--auth-user AUTH_USER]
               [--auth-password AUTH_PASSWORD]

Displays information for all xo games in state, showing the players, the game
state, and the board for each game.

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         enable more verbose output
  -V, --version         display version information
  --url URL             specify URL of REST API
  --username USERNAME   identify name of user's private key file
  --key-dir KEY_DIR     identify directory of user's private key file
  --auth-user AUTH_USER
                        specify username for authentication if REST API is
                        using Basic Auth
  --auth-password AUTH_PASSWORD
                        specify password for authentication if REST API is
                        using Basic Auth
```

## xo show

The `xo show` subcommand displays information about the specified XO
game.

```
usage: xo show [-h] [-v] [-V] [--url URL] [--username USERNAME]
               [--key-dir KEY_DIR] [--auth-user AUTH_USER]
               [--auth-password AUTH_PASSWORD]
               name

Displays the xo game <name>, showing the players, the game state, and the
board

positional arguments:
  name                  identifier for the game

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         enable more verbose output
  -V, --version         display version information
  --url URL             specify URL of REST API
  --username USERNAME   identify name of user's private key file
  --key-dir KEY_DIR     identify directory of user's private key file
  --auth-user AUTH_USER
                        specify username for authentication if REST API is
                        using Basic Auth
  --auth-password AUTH_PASSWORD
                        specify password for authentication if REST API is
                        using Basic Auth
```

## xo take

The `xo take` subcommand makes a move in an XO game by sending a
transaction to take the identified space. This transaction will fail if
the game **name** does not exist, if it is not the sender's
turn, or if **space** is already taken.

```
usage: xo take [-h] [-v] [-V] [--url URL] [--username USERNAME]
               [--key-dir KEY_DIR] [--auth-user AUTH_USER]
               [--auth-password AUTH_PASSWORD] [--wait [WAIT]]
               name space

Sends a transaction to take a square in the xo game with the identifier
<name>. This transaction will fail if the specified game does not exist.

positional arguments:
  name                  identifier for the game
  space                 number of the square to take (1-9); the upper-left
                        space is 1, and the lower-right space is 9

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         enable more verbose output
  -V, --version         display version information
  --url URL             specify URL of REST API
  --username USERNAME   identify name of user's private key file
  --key-dir KEY_DIR     identify directory of user's private key file
  --auth-user AUTH_USER
                        specify username for authentication if REST API is
                        using Basic Auth
  --auth-password AUTH_PASSWORD
                        specify password for authentication if REST API is
                        using Basic Auth
  --wait [WAIT]         set time, in seconds, to wait for take transaction to
                        commit
```

## xo delete

The `xo delete` subcommand deletes an existing xo game.

```
usage: xo delete [-h] [-v] [-V] [--url URL] [--username USERNAME]
                 [--key-dir KEY_DIR] [--auth-user AUTH_USER]
                 [--auth-password AUTH_PASSWORD] [--wait [WAIT]]
                 name

positional arguments:
  name                  name of the game to be deleted

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         enable more verbose output
  -V, --version         display version information
  --url URL             specify URL of REST API
  --username USERNAME   identify name of user's private key file
  --key-dir KEY_DIR     identify directory of user's private key file
  --auth-user AUTH_USER
                        specify username for authentication if REST API is
                        using Basic Auth
  --auth-password AUTH_PASSWORD
                        specify password for authentication if REST API is
                        using Basic Auth
  --wait [WAIT]         set time, in seconds, to wait for delete transaction
                        to commit
```
