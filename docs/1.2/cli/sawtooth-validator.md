# sawtooth-validator

The `sawtooth-validator` command controls the behavior of the validator.

A validator is the component ultimately responsible for validating
batches of transactions, combining them into blocks, maintaining
consensus with the network, and coordinating communication between
clients, other validators, and transaction processors. Much of the
actual validation is delegated to other components, such as transaction
processors and the active consensus module.

Note the following options, which provide several ways to configure the
validator.

-   Use the `--peering` option to set the peering type to `dynamic` or
    `static`.
    -   If set to `static`, use the `--peers` option to list the URLs of
        all peers that the validator should connect to, using the format
        `tcp`://`hostname`:`port`. Specify multiple peer
        URLs in a comma-separated list.
    -   If set to `dynamic`, any static peers will be processed first,
        before starting the topology buildout starting, then the URLs
        specified by `--seeds` will be used for the initial connection
        to the Sawtooth network.
-   Use `--scheduler` to set the scheduler type to `serial` or
    `parallel`. Note that both scheduler types result in the same
    deterministic results and are completely interchangeable. However,
    parallel processing of transactions provides a performance
    improvement even for fast transaction workloads by reducing the
    overall latency effects that occur when transactions are processed
    serially.
-   Use `--network-auth` to specify the required authorization procedure
    (`trust` or `challenge`) that validator connections must go through
    before they are allowed to participate on the network. To use
    network permissions, specify `challenge`, which requires connections
    to sign a challenge so their identity can be proved.

```console
sawtooth-validator 1.2.6
Configures and starts a Sawtooth validator.

USAGE:
    sawtooth-validator [FLAGS] [OPTIONS]

FLAGS:
    -h, --help       Prints help information
    -V, --version    Prints version information
    -v, --verbose    enable more verbose output to stderr

OPTIONS:
    -B, --bind <bind>...
            set the URL for the network or validator component service endpoints with the format network:<endpoint>,
            component:<endpoint>, or consensus:<endpoint>. Use multiple --bind options to specify all endpoints.
        --config-dir <config_dir>                                  specify the configuration directory
    -E, --endpoint <endpoint>                                      specifies the advertised network endpoint URL
        --fork-cache-keep-time <fork_cache_keep_time>              set the time in seconds to keep uncommitted forks.
        --maximum-peer-connectivity <maximum_peer_connectivity>    set the maximum number of peers to accept
        --minimum-peer-connectivity <minimum_peer_connectivity>
            set the minimum number of peers required before stopping peer search

        --network-auth <network_auth>
            identify type of authorization required to join validator network. [possible values: trust, challenge]

        --opentsdb-db <opentsdb-db>                                specify name of database used for storing metrics
        --opentsdb-url <opentsdb-url>
            specify host and port for Open TSDB database used for metrics

    -P, --peering <peering>
            determine peering type for the validator: 'static' (must use --peers to list peers) or 'dynamic' (processes
            any static peers first, then starts topology buildout). [possible values: static, dynamic]
    -p, --peers <peers>...
            list static peers to attempt to connect to in the format tcp://<hostname>:<port>. Specify multiple peers in
            a comma-separated list. Repeating the --peers option is also accepted.
        --scheduler <scheduler>
            set scheduler type: serial or parallel [possible values: serial, parallel]

    -s, --seeds <seeds>...
            provide URI(s) for the initial connection to the validator network, in the format tcp://<hostname>:<port>.
            Specify multiple URIs in a comma-separated list. Repeating the --seeds option is also accepted.
        --state-pruning-block-depth <state_pruning_block_depth>
            set the block depth below which state roots are pruned from the global state database.
```

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
