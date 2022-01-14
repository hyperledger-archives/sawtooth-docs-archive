# Creating a Sawtooth Test Network

This section describes how to create a Sawtooth network for an
application development environment. Each node is similar to the
single-node environment described earlier in this guide in [Installing
Sawtooth]({% link docs/1.2/app_developers_guide/installing_sawtooth.md %}),
but the network uses a consensus algorithm that is
appropriate for a Sawtooth network (instead of Devmode consensus). For
more information, see [About Sawtooth Networks](#about-sawtooth-networks)

> **Note**
>
> For a single-node test environment, see
> [Installing
> Sawtooth]({% link docs/1.2/app_developers_guide/installing_sawtooth.md %})

Use the procedures in this section to create a Sawtooth test network
using prebuilt [Docker](https://www.docker.com/) containers, a
[Kubernetes](https://kubernetes.io) cluster inside a virtual machine on
your computer, or a native [Ubuntu](https://www.ubuntu.com/)
installation.

To get started, read [About Sawtooth
Networks](#about-sawtooth-networks),
then choose the guide for the platform of your choice.

##  About Sawtooth Networks

In a Sawtooth network, each host system (physical computer, virtual
machine, set of Docker containers, or Kubernetes pod) is a Sawtooth node
that runs one validator, an optional REST API, a consensus engine, and a
set of transaction processors.

The first node creates the genesis block, which specifies the initial on-chain
settings for the network. The other nodes access those settings when they join
the network.

> **Note**
>
> The example environment includes the Sawtooth REST API on all validator
> nodes. However, an application could provide a custom REST API (or no
> REST API). See [Sawtooth Supply
> Chain](https://github.com/hyperledger/sawtooth-supply-chain) for an
> example of a custom REST API.
>
> This environment also runs a consensus engine on each node. The
> consensus engine could run on a separate system, as long as it is
> reachable from the Sawtooth node. This guide does not describe how to
> set up a consensus engine on a different system.

A Sawtooth network has the following requirements:

-   Each node must run the same consensus engine.
    The procedures in this guide show you how to configure
    PBFT or PoET consensus. For more information, see [About Dynamic
    Consensus]({% link docs/1.2/sysadmin_guide/about_dynamic_consensus.md%}).
-   Each node must run the same set of transaction processors as all
    other nodes in the network.
-   Each node must advertise a routable address. The Docker and
    Kubernetes platforms provide preconfigured settings. For the Ubuntu
    platform, you must configure network settings before starting the
    validator.
-   The authorization type must be the same on all nodes: either `trust`
    (default) or `challenge`. This application development environment
    uses `trust` authorization.
-   The first node on the network must create the genesis block, which includes
    the on-chain configuration settings that will be available to the other
    nodes when they join the network.

> **Note**
>
> The first Sawtooth node on the network has no special meaning, other
> than being the node that created the genesis block. Sawtooth has no
> concept of a \"head node\" or \"master node\". Once multiple nodes are
> up and running, each node has the same genesis block and treats all
> other nodes as peers.

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

---
title: Using Docker for a Sawtooth Test Network
---

This procedure describes how to use Docker to create a network of five
Sawtooth nodes for an application development environment. Each node is
a set of Docker containers that runs a validator and related Sawtooth
components.

::: note
::: title
Note
:::

For a single-node environment, see `docker`{.interpreted-text
role="doc"}.
:::

This procedure guides you through the following tasks:

> -   Downloading the Sawtooth Docker Compose file
> -   Starting the Sawtooth network with [docker-compose]{.title-ref}
> -   Checking process status
> -   Configuring the allowed transaction types (optional)
> -   Connecting to the Sawtooth shell container and confirming network
>     functionality
> -   Stopping Sawtooth and resetting the Docker environment

# About the Docker Sawtooth Network Environment {#about-sawtooth-nw-env-docker-label}

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

This test environment is a network of five Sawtooth nodes.

![](../images/appdev-environment-multi-node.*){.align-center
width="100.0%"}

Each node in this Sawtooth network runs a `validator`{.interpreted-text
role="term"}, a `REST API`{.interpreted-text role="term"}, a consensus
engine, and the following
`transaction processors<transaction processor>`{.interpreted-text
role="term"}:

-   `Settings <../transaction_family_specifications/settings_transaction_family>`{.interpreted-text
    role="doc"} (`settings-tp`): Handles Sawtooth\'s on-chain
    configuration settings. The Settings transaction processor (or an
    equivalent) is required for all Sawtooth networks.
-   `IntegerKey <../transaction_family_specifications/integerkey_transaction_family>`{.interpreted-text
    role="doc"} (`intkey-tp-python`): Demonstrates basic Sawtooth
    functionality. The associated `intkey` client includes shell
    commands to perform integer-based transactions.
-   `XO <../transaction_family_specifications/xo_transaction_family>`{.interpreted-text
    role="doc"} (`sawtooth-xo-tp-python`: Simple application for playing
    a game of tic-tac-toe on the blockchain. The assocated `xo` client
    provides shell commands to define players and play a game. XO is
    described in a later section,
    `intro_xo_transaction_family`{.interpreted-text role="doc"}.
-   (PoET only)
    `PoET Validator Registry <../transaction_family_specifications/validator_registry_transaction_family>`{.interpreted-text
    role="doc"} (`poet-validator-registry-tp`): Configures PoET
    consensus and handles a network with multiple nodes.

::: important
::: title
Important
:::

Each node in a Sawtooth network must run the same set of transaction
processors.
:::

Like the `single-node test environment <docker>`{.interpreted-text
role="doc"}, this environment uses parallel transaction processing and
static peering. However, it uses a different consensus algorithm
(Devmode consensus is not recommended for a network). You can choose
either PBFT or PoET consensus.

-   `PBFT consensus`{.interpreted-text role="term"} provides a
    voting-based consensus algorithm with Byzantine fault tolerance
    (BFT) that has finality (does not fork).

-   `PoET consensus`{.interpreted-text role="term"} provides a
    leader-election lottery system that can fork. This network uses PoET
    simulator consensus, which is also called [PoET CFT]{.title-ref}
    because it is crash fault tolerant.

    ::: note
    ::: title
    Note
    :::

    The other type of PoET consensus, PoET-SGX, relies on Intel Software
    Guard Extensions (SGX) that is Byzantine fault tolerant (BFT). PoET
    CFT provides the same consensus algorithm on an SGX simulator.
    :::

The first node creates the [genesis block]{.title-ref}, which specifies
the on-chain settings for the network configuration. The other nodes
access those settings when they join the network.

# Prerequisites {#prereqs-multi-docker-label}

-   This application development environment requires Docker Engine and
    Docker Compose.
    -   Windows: Install the latest version of [Docker Engine for
        Windows](https://docs.docker.com/docker-for-windows/install/)
        (also installs Docker Compose).
    -   macOS: Install the latest version of [Docker Engine for
        macOS](https://docs.docker.com/docker-for-mac/install/) (also
        installs Docker Compose).
    -   Linux: Install the latest versions of [Docker
        Engine](https://docs.docker.com/engine/installation/linux/ubuntu)
        and [Docker
        Compose](https://docs.docker.com/compose/install/#install-compose).
        Then follow [Post-Install
        steps](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user).
-   If you created a
    `single-node Docker environment <docker>`{.interpreted-text
    role="doc"} that is still running, shut it down and delete the
    existing blockchain data and logs. For more information, see
    `stop-sawtooth-docker-label`{.interpreted-text role="ref"}.

# Step 1: Download the Docker Compose File

Download the Docker Compose file for a multiple-node network.

-   For PBFT, download
    [sawtooth-default-pbft.yaml](./sawtooth-default-pbft.yaml)
-   For PoET, download
    [sawtooth-default-poet.yaml](./sawtooth-default-poet.yaml)

# Step 2: Start the Sawtooth Network

::: note
::: title
Note
:::

The Docker Compose file for Sawtooth handles environment setup steps
such as generating keys and creating a genesis block. To learn how the
typical network startup process works, see
`ubuntu_test_network`{.interpreted-text role="doc"}.
:::

1.  Open a terminal window.

2.  Change to the directory where you saved the Docker Compose file.

3.  Start the Sawtooth network.

    -   For PBFT:

        ``` console
        user@host$ docker-compose -f sawtooth-default-pbft.yaml up
        ```

    -   For PoET:

        ``` console
        user@host$ docker-compose -f sawtooth-default-poet.yaml up
        ```

4.  This Compose file creates five Sawtooth nodes named `validator-#`
    (numbered from 0 to 4). Note the container names for the Sawtooth
    components on each node:

    `validator-0`:

    > -   `sawtooth-validator-default-0`
    > -   `sawtooth-rest-api-default-0`
    > -   `sawtooth-pbft-engine-default-0` or `sawtooth-poet-engine-0`
    > -   `sawtooth-settings-tp-default-0`
    > -   `sawtooth-intkey-tp-python-default-0`
    > -   `sawtooth-xo-tp-python-default-0`
    > -   (PoET only) `sawtooth-poet-validator-registry-tp-0`

    `validator-1`:

    > -   `sawtooth-validator-default-1`
    > -   `sawtooth-rest-api-default-1`
    > -   `sawtooth-pbft-engine-default-1` or `sawtooth-poet-engine-1`
    > -   `sawtooth-settings-tp-default-1`
    > -   `sawtooth-intkey-tp-python-default-1`
    > -   `sawtooth-xo-tp-python-default-1`
    > -   (PoET only) `sawtooth-poet-validator-registry-tp-1`

    \... and so on.

5.  Note that there is only one shell container for this Docker
    environment:

    > -   `sawtooth-shell-default`

# Step 3: Check the REST API Process

Use these commands on one or more nodes to confirm that the REST API is
running.

1.  Connect to the REST API container on a node, such as
    `sawtooth-poet-rest-api-default-0`.

    ``` console
    user@host$ docker exec -it sawtooth-rest-api-default-0 bash
    root@b1adcfe0#
    ```

2.  Use the following command to verify that this component is running.

    ``` console
    root@b1adcfe0# ps --pid 1 fw
    PID TTY      STAT   TIME COMMAND
      1 ?        Ssl    0:00 /usr/bin/python3 /usr/bin/sawtooth-rest-api
      --connect tcp://validator-0:4004 --bind rest-api-0:8008
    ```

# Step 4: Confirm Network Functionality {#confirm-nw-funct-docker-label}

1.  Connect to the shell container.

    > ``` console
    > user@host$ docker exec -it sawtooth-shell-default bash
    > root@0e0fdc1ab#
    > ```

2.  To check whether peering has occurred on the network, submit a peers
    query to the REST API on the first node. This command specifies the
    container name and port for the first node\'s REST API.

    > ``` console
    > root@0e0fdc1ab# curl http://sawtooth-rest-api-default-0:8008/peers
    > ```

    If this query returns a 503 error, the nodes have not yet peered
    with the Sawtooth network. Repeat the query until you see output
    that resembles the following example:

    > ``` console
    > {
    >   "data": [
    >     "tcp://validator-4:8800",
    >     "tcp://validator-3:8800",
    >     ...
    >     "tcp://validator-2:8800",
    >     "tcp://validator-1:8800"
    >   ],
    >   "link": "http://sawtooth-rest-api-default-0:8008/peers"
    > ```

3.  (Optional) You can run the following Sawtooth commands to show the
    other nodes on the network.

    a.  Run `sawtooth peer list` to show the peers of a particular node.
        For example, the following command specifies the REST API on the
        first node, so it displays the first node\'s peers.

        ``` console
        root@0e0fdc1ab# sawtooth peer list --url http://sawtooth-rest-api-default-0:8008
        tcp://validator-1:8800,tcp://validator-1:8800,tcp://validator-2:8800,tcp://validator-3:8800
        ```

    b.  Run `sawnet peers list` to display a complete graph of peers on
        the network (available in Sawtooth release 1.1 and later).

        ``` console
        root@0e0fdc1ab# sawnet peers list http://sawtooth-rest-api-default-0:8008
        {
        "tcp://validator-0:8800": [
        "tcp://validator-1:8800",
        "tcp://validator-1:8800",
        "tcp://validator-2:8800",
        "tcp://validator-3:8800"
        ]
        }
        ```

4.  Submit a transaction to the REST API on the first node. This example
    sets a key named `MyKey` to the value 999.

    > ``` console
    > root@0e0fdc1ab# intkey set --url http://sawtooth-rest-api-default-0:8008 MyKey 999
    > ```
    >
    > The output should resemble this example:
    >
    > ``` console
    > {
    >   "link": "http://sawtooth-rest-api-default-0:8008/batch_statuses?id=dacefc7c9fe2c8510803f8340...
    > }
    > ```

5.  Watch for this transaction to appear on a different node. The
    following command requests the value of `MyKey` from the REST API on
    the second node.

    You can run this command from the first node\'s shell container by
    specifying the URL of the other node\'s REST API, as in this
    example.

    > ``` console
    > root@0e0fdc1ab# intkey show --url http://sawtooth-rest-api-default-1:8008 MyKey
    > ```
    >
    > The output should show the key name and current value:
    >
    > ``` console
    > MyKey: 999
    > ```

# Step 5. Configure the Allowed Transaction Types (Optional) {#configure-txn-procs-docker-label}

By default, a validator accepts transactions from any transaction
processor. However, Sawtooth allows you to limit the types of
transactions that can be submitted.

In this step, you will configure the Sawtooth network to accept
transactions only from the transaction processors running in the example
environment. Transaction-type restrictions are an on-chain setting, so
this configuration change is made on one node, then applied to all other
nodes.

The `Settings transaction processor
<../transaction_family_specifications/settings_transaction_family>`{.interpreted-text
role="doc"} handles on-chain configuration settings. You will use the
`sawset` command to create and submit a batch of transactions containing
the configuration change.

::: important
::: title
Important
:::

You **must** run this procedure from the first validator container,
because the example Docker Compose file uses the first validator\'s key
to create and sign the genesis block. (At this point, only the key used
to create the genesis block can change on-chain settings.) For more
information, see
`/sysadmin_guide/adding_authorized_users`{.interpreted-text role="doc"}.
:::

1.  Connect to the first validator container
    (`sawtooth-validator-default-0`). The next command requires the
    validator key that was generated in that container.

    ``` console
    user@host$ docker exec -it sawtooth-validator-default-0 bash
    root@c0c0ab33#
    ```

2.  Run the following command from the validator container to specify
    the allowed transaction families.

    -   For PBFT:

        ``` console
        root@c0c0ab33# sawset proposal create --url http://sawtooth-rest-api-default-0:8008 --key /etc/sawtooth/keys/validator.priv \
        sawtooth.validator.transaction_families='[{"family": "intkey", "version": "1.0"}, {"family":"sawtooth_settings", "version":"1.0"}, {"family":"xo", "version":"1.0"}]'
        ```

    -   For PoET:

        ``` console
        root@c0c0ab33# sawset proposal create --url http://sawtooth-rest-api-default-0:8008 --key /etc/sawtooth/keys/validator.priv \
        sawtooth.validator.transaction_families='[{"family": "intkey", "version": "1.0"}, {"family":"sawtooth_settings", "version":"1.0"}, {"family":"xo", "version":"1.0"}, {"family":"sawtooth_validator_registry", "version":"1.0"}]'
        ```

    This command sets `sawtooth.validator.transaction_families` to a
    JSON array that specifies the family name and version of each
    allowed transaction processor (defined in the transaction header of
    each family\'s
    `transaction family specification <../transaction_family_specifications>`{.interpreted-text
    role="doc"}).

3.  After this command runs, a `TP_PROCESS_REQUEST` message appears in
    the docker-compose output.

    ``` console
    .
    .
    .
    sawtooth-settings-tp-default-0  | INFO  | settings_tp::handler | Setting "sawtooth.validator.transaction_families" changed to "[{\"family\": \"intkey\", \"version\": \"1.0\"}, {\"family\":\"sawtooth_settings\", \"version\":\"1.0\"}, {\"family\":\"xo\", \"version\":\"1.0\"}, {\"family\":\"sawtooth_validator_registry\", \"version\":\"1.0\"}]"
    sawtooth-settings-tp-default-0  | INFO  | sawtooth_sdk::proces | TP_PROCESS_REQUEST sending TpProcessResponse: OK
    ```

4.  Run the following command to check the setting change on the shell
    container or any validator container. You can specify any REST API
    on the network; this example uses the REST API on the first node.

    ``` console
    root@0e0fdc1ab# sawtooth settings list --url http://sawtooth-rest-api-default-0:8008
    ```

    The output should be similar to this example:

    ``` console
    sawtooth.consensus.algorithm.name: {name}
    sawtooth.consensus.algorithm.version: {version}
    ...
    sawtooth.publisher.max_batches_per_block=1200
    sawtooth.settings.vote.authorized_keys: 0242fcde86373d0aa376...
    sawtooth.validator.transaction_families: [{"family": "intkey...
    ```

# Step 6: Stop the Sawtooth Network (Optional)

Use this procedure to stop or reset the multiple-node Sawtooth
environment.

1.  Exit from all open containers (such as the shell, REST-API,
    validator, and settings containers used in this procedure).
2.  Enter CTRL-c in the window where you ran `docker-compose up`.
3.  After all containers have shut down, you can reset the environment
    (remove all containers and data) with the following command:
    -   For PBFT:

        ``` console
        user@host$ docker-compose -f sawtooth-default-pbft.yaml down
        ```

    -   For PoET:

        ``` console
        user@host$ docker-compose -f sawtooth-default-poet.yaml down
        ```

* [Kubernetes Test
 Network]({% link docs/1.2/app_developers_guide/kubernetes_test_network.md %})
* [Ubuntu Test
Network]({% link docs/1.2/app_developers_guide/ubuntu_test_network.md %})

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
