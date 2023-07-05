# intkey

The `intkey` command starts the IntegerKey transaction processor, which
provides functions that can be used to test deployed ledgers.

The `intkey` command provides subcommands to set, increment, and
decrement the value of entries stored in a state dictionary.

```
usage: intkey [-h] [-v] [-V]
              {set,inc,dec,show,list,generate,load,populate,create_batch,workload}
              ...

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         enable more verbose output
  -V, --version         display version information

subcommands:
  {set,inc,dec,show,list,generate,load,populate,create_batch,workload}
    set                 Sets an intkey value
    inc                 Increments an intkey value
    dec                 Decrements an intkey value
    show                Displays the specified intkey value
    list                Displays all intkey values
```

## intkey set

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

The `intkey set` subcommand sets a key (**name**) to the
specified value. This transaction will fail if the value is less than 0
or greater than 2^32 - 1.

```
usage: intkey set [-h] [-v] [-V] [--url URL] [--keyfile KEYFILE]
                  [--wait [WAIT]]
                  name value

Sends an intkey transaction to set <name> to <value>.

positional arguments:
  name               name of key to set
  value              amount to set

optional arguments:
  -h, --help         show this help message and exit
  -v, --verbose      enable more verbose output
  -V, --version      display version information
  --url URL          specify URL of REST API
  --keyfile KEYFILE  identify file containing user's private key
  --wait [WAIT]      set time, in seconds, to wait for transaction to commit
```

## intkey inc

The `intkey inc` subcommand increments a key (**name**) by the
specified value. This transaction will fail if the key is not set or if
the resulting value would exceed 2^32 - 1.

```
usage: intkey inc [-h] [-v] [-V] [--url URL] [--keyfile KEYFILE]
                  [--wait [WAIT]]
                  name value

Sends an intkey transaction to increment <name> by <value>.

positional arguments:
  name               identify name of key to increment
  value              specify amount to increment

optional arguments:
  -h, --help         show this help message and exit
  -v, --verbose      enable more verbose output
  -V, --version      display version information
  --url URL          specify URL of REST API
  --keyfile KEYFILE  identify file containing user's private key
  --wait [WAIT]      set time, in seconds, to wait for transaction to commit
```

## intkey dec

The `intkey dec` subcommand decrements a key (**name**) by the
specified value. This transaction will fail if the key is not set or if
the resulting value would be less than 0.

```
usage: intkey dec [-h] [-v] [-V] [--url URL] [--keyfile KEYFILE]
                  [--wait [WAIT]]
                  name value

Sends an intkey transaction to decrement <name> by <value>.

positional arguments:
  name               identify name of key to decrement
  value              amount to decrement

optional arguments:
  -h, --help         show this help message and exit
  -v, --verbose      enable more verbose output
  -V, --version      display version information
  --url URL          specify URL of REST API
  --keyfile KEYFILE  identify file containing user's private key
  --wait [WAIT]      set time, in seconds, to wait for transaction to commit

```

## intkey show

The `intkey show` subcommand displays the value of the specified key
(**name**).

```
usage: intkey show [-h] [-v] [-V] [--url URL] name

Shows the value of the key <name>.

positional arguments:
  name           name of key to show

optional arguments:
  -h, --help     show this help message and exit
  -v, --verbose  enable more verbose output
  -V, --version  display version information
  --url URL      specify URL of REST API
```

## intkey list

The `intkey list` subcommand displays the value of all keys.

```
usage: intkey list [-h] [-v] [-V] [--url URL]

Shows the values of all keys in intkey state.

optional arguments:
  -h, --help     show this help message and exit
  -v, --verbose  enable more verbose output
  -V, --version  display version information
  --url URL      specify URL of REST API
```
