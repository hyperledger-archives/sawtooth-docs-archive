# sawnet

The `sawnet` command is used to interact with an entire network of
Sawtooth nodes.

```console
usage: sawnet [-h] [-v] [-V] {compare-chains,list-blocks,peers} ...

Inspect status of a sawtooth network

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         enable more verbose output
  -V, --version         display version information

subcommands:
  {compare-chains,list-blocks,peers}
    compare-chains      Compare chains from different nodes.
    list-blocks         List blocks from different nodes.
    peers               Shows the peering arrangment of a network
```

## sawnet compare-chains

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
-->

The `sawnet compare-chains` subcommand compares chains across the
specified nodes.

```console
usage: sawnet compare-chains [-h] [-v] [-V] [--users USERNAME[:PASSWORD]]
                             [-l LIMIT] [--table] [--tree]
                             urls [urls ...]

Compute and display information about how the chains at different nodes differ.

positional arguments:
  urls                  The URLs of the validator's REST APIs of interest,
                        separated by commas or spaces. (no default)

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         enable more verbose output
  -V, --version         display version information
  --users USERNAME[:PASSWORD]
                        Specify the users to authorize requests, in the same
                        order as the URLs, separate by commas. Passing empty
                        strings between commas is supported.
  -l LIMIT, --limit LIMIT
                        the number of blocks to request at a time
  --table               Print out a fork table for all nodes since the common
                        ancestor.
  --tree                Print out a fork tree for all nodes since the common
                        ancestor.

By default, prints a table of summary data and a table of per-node data with
the following fields. Pass --tree for a fork graph.

COMMON ANCESTOR
    The most recent block that all chains have in common.

COMMON HEIGHT
    Let min_height := the minimum height of any chain across all nodes passed
    in. COMMON HEIGHT = min_height.

HEAD
    The block id of the most recent block on a given chain.

HEIGHT
    The block number of the most recent block on a given chain.

LAG
    Let max_height := the maximum height of any chain across all nodes passed
    in. LAG = max_height - HEIGHT for a given chain.

DIVERG
    Let common_ancestor_height := the height of the COMMON ANCESTOR.
    DIVERG = HEIGHT - common_ancestor_height
```

## sawnet peers

```console
usage: sawnet peers [-h] {list,graph} ...

Shows the peering arrangment of a network.

optional arguments:
  -h, --help    show this help message and exit

subcommands:
  {list,graph}
    list        Lists peers for validators with given URLs
    graph       Generates a file to graph a network's peering arrangement
```

## sawnet peers list

The `sawnet peers list` subcommand displays the peers of the specified
nodes.

```console
usage: sawnet peers list [-h] [-v] [-V] [--users USERNAME[:PASSWORD]]
                         [--pretty]
                         urls [urls ...]

Lists peers for validators with given URLs.

positional arguments:
  urls                  The URLs of the validator's REST APIs of interest,
                        separated by commas or spaces. (no default)

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         enable more verbose output
  -V, --version         display version information
  --users USERNAME[:PASSWORD]
                        Specify the users to authorize requests, in the same
                        order as the URLs, separate by commas. Passing empty
                        strings between commas is supported.
  --pretty, -p          Pretty-print the results

```

## sawnet peers graph

The `sawnet peers graph` subcommand creates a file called `peers.dot`
that describes the peering arrangement of the specified nodes. The
[Graphviz documentation](https://www.graphviz.org/documentation/) describes
the file format and how to transform it into a diagram.

```console
usage: sawnet peers graph [-h] [-v] [-V] [--users USERNAME[:PASSWORD]]
                          [-o OUTPUT] [--force]
                          urls [urls ...]

Generates a file to graph a network's peering arrangement.

positional arguments:
  urls                  The URLs of the validator's REST APIs of interest,
                        separated by commas or spaces. (no default)

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         enable more verbose output
  -V, --version         display version information
  --users USERNAME[:PASSWORD]
                        Specify the users to authorize requests, in the same
                        order as the URLs, separate by commas. Passing empty
                        strings between commas is supported.
  -o OUTPUT, --output OUTPUT
                        The path of the dot file to be produced (defaults to
                        peers.dot)
  --force               TODO
```
