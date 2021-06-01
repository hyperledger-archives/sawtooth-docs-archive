---
title: Using Ubuntu for a Sawtooth Test Network
---

This procedure describes how to create a Sawtooth network for an
application development environment on a Ubuntu platform. Each host
system (physical computer or virtual machine) is a [Sawtooth
node]{.title-ref} that runs a validator and related Sawtooth components.

::: note
::: title
Note
:::

For a single-node environment, see `ubuntu`{.interpreted-text
role="doc"}.
:::

This procedure guides you through the following tasks:

> -   Installing Sawtooth
> -   Creating user and validator keys
> -   Creating the genesis block on the first node (includes specifying
>     either PBFT or PoET consensus)
> -   Starting Sawtooth on each node
> -   Confirming network functionality
> -   Configuring the allowed transaction types (optional)

For information on Sawtooth `dynamic consensus`{.interpreted-text
role="term"} or to learn how to change the consensus type, see
`/sysadmin_guide/about_dynamic_consensus`{.interpreted-text role="doc"}.

::: note
::: title
Note
:::

These instructions have been tested on Ubuntu 18.04 (Bionic) only.
:::

# About the Ubuntu Sawtooth Network Environment {#about-sawtooth-nw-env-label}

This test environment is a network of several Sawtooth nodes. The
following figure shows a network with five nodes.

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

Like the single-node environment, this environment uses parallel
transaction processing and static peering. However, it uses a different
consensus algorithm (Devmode consensus is not recommended for a
network).

This procedure explains how to configure either PBFT or PoET consensus.
The initial network must include the minimum number of nodes for the
chosen consensus:

> -   `PBFT consensus`{.interpreted-text role="term"} requires four or
>     more nodes. At least four nodes must be configured and running in
>     order for the network to start.
>
> -   `PoET consensus`{.interpreted-text role="term"} requires three or
>     more nodes. You can start the first node and test basic
>     functionality, then add the other nodes.
>
>     ::: note
>     ::: title
>     Note
>     :::
>
>     This procedure uses PoET simulator consensus (also called PoET CFT
>     because it is crash fault tolerant), which is a version of
>     PoET-SGX consensus that runs on any processor.
>     :::
>
> -   `Devmode consensus`{.interpreted-text role="term"} has no minimum
>     requirement, but it is not recommended for multiple-node test
>     networks or production networks. Devmode is a light-weight
>     consensus that is intended for short-term testing on a single node
>     or a very small network (two or three nodes). It is not crash
>     fault tolerant and does not handle forks efficiently.

::: note
::: title
Note
:::

For PBFT consensus, the network must be [fully peered]{.title-ref} (each
node must be connected to all other nodes).
:::

# Prerequisites {#prereqs-multi-ubuntu-label}

-   Remove data from an existing single node: To reuse the single test
    node described in `ubuntu`{.interpreted-text role="doc"}, stop
    Sawtooth and delete all blockchain data and logs from that node.
    1.  If the first node is running, stop the Sawtooth components
        (validator, REST API, consensus engine, and transaction
        processors), as described in
        `stop-sawtooth-ubuntu-label`{.interpreted-text role="ref"}.
    2.  Delete the existing blockchain data by removing all files from
        `/var/lib/sawtooth/`.
    3.  Delete the logs by removing all files from `/var/log/sawtooth/`.
    4.  You can reuse the existing user and validator keys. If you want
        to start with new keys, delete the `.priv` and `.pub` files from
        `/home/yourname/.sawtooth/keys/` and `/etc/sawtooth/keys/`.
-   Gather networking information: For each node that will be on your
    network, gather the following information.
    -   **Component bind string**: Where this validator will listen for
        incoming communication from this validator\'s components. You
        will set this value with `--bind component` when starting the
        validator. Default: `tcp://127.0.0.1:4004`.
    -   **Network bind string**: Where this validator will listen for
        incoming communication from other nodes (also called peers). You
        will set this value with `--bind network` when starting the
        validator. Default: `tcp://127.0.0.1:8800`.
    -   **Public endpoint string**: The address that other peers should
        use to find the validator on this node. You will set this value
        with `--endpoint` when starting the validator. You will also
        specify this value in the peers list when starting a validator
        on another node. Default: `tcp://127.0.0.1:8800`.
    -   **Consensus endpoint string**: Where this validator will listen
        for incoming communication from the
        `consensus engine`{.interpreted-text role="term"}. You will set
        this value with `--bind consensus` when starting the validator.
        Default: `tcp://127.0.0.1:5050`.
    -   **Peers list**: The addresses that this validator should use to
        connect to the other nodes (peers); that is, the public endpoint
        strings of those nodes. You will set this value with `--peers`
        when starting the validator. Default: none.

.. \_about-bind-strings-label:

## About component and network bind strings

For the network bind string and component bind string, you would
typically use a specific network interface that you want to bind to. The
`ifconfig` command provides an easy way to determine what this interface
should be. `ifconfig` displays the network interfaces on your host
system, along with additional information about the interfaces. For
example:

``` console
$ ifconfig
eth0      Link encap:Ethernet  HWaddr ...
          inet addr:...  Bcast:...  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:17964 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6134 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:26335425 (26.3 MB)  TX bytes:338394 (338.3 KB)
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

This example output shows that `eth0` is a network interface that has
access to the Internet. In this case, you could use one of the
following:

-   If you would like the validator to accept connections from other
    nodes on the network behind `eth0`, you could specify a network bind
    string such as `tcp://eth0:8800`.
-   If you would like the validator to accept only connections from
    local Sawtooth components, you could specify the component bind
    string `tcp://lo:4004`. Note that this is equivalent to
    `tcp://127.0.0.1:4004`.

For more information on how to specify the component and network bind
strings, see \"Assigning a local address to a socket\" in the [zmq-tcp
API Reference](http://api.zeromq.org/4-2:zmq-tcp).

## About the public endpoint string {#about-endpoint-string-label}

The correct value for your public endpoint string depends on your
network configuration.

-   If this network is for development purposes and all of the nodes
    will be on the same local network, the IP address returned by
    `ifconfig` should work as your public endpoint string.

-   If part of your network is behind a NAT or firewall, or if you want
    to start up a public network on the Internet, you must determine the
    correct routable values for all the nodes in your network.

    Determining these values for a distributed or production network is
    an advanced networking topic that is beyond the scope of this guide.
    Contact your network administrator for help with this task.

For information on how to specify the public endpoint string, see
\"Connecting a socket\" in the [zmq-tcp API
Reference](http://api.zeromq.org/4-2:zmq-tcp).

# Step 1: Install Sawtooth on All Nodes {#appdev-multinode-install-label}

Use these steps on each system to install Hyperledger Sawtooth.

::: note
::: title
Note
:::

-   For PBFT consensus, you must install Sawtooth and generate keys for
    all nodes before continuing to step 3 (creating the genesis block on
    the first node).
-   For PoET consensus, you can choose to install Sawtooth on the other
    nodes after configuring and starting the first node.
:::

1.  Choose whether you want the stable version (recommended) or the most
    recent nightly build (for testing purposes only).

    -   (Release 1.2 and later) To add the stable repository, run these
        commands in a terminal window on your host system.

        ``` console
        $ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8AA7AF1F1091A5FD
        $ sudo add-apt-repository 'deb [arch=amd64] http://repo.sawtooth.me/ubuntu/chime/stable bionic universe'
        ```

        ::: note
        ::: title
        Note
        :::

        The `chime` metapackage includes the Sawtooth core software and
        associated items such as separate consensus software.
        :::

    -   The latest version of Sawtooth is available in a repository of
        nightly builds. These builds may incorporate undocumented
        features and should be used for testing purposes only.

        To use the nightly repository, run the following commands in a
        terminal window on your host system.

        ``` console
        $ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 44FC67F19B2466EA
        $ sudo apt-add-repository 'deb [arch=amd64] http://repo.sawtooth.me/ubuntu/nightly bionic universe'
        ```

2.  Update your package lists.

    ``` console
    $ sudo apt-get update
    ```

3.  Install the Sawtooth packages. Sawtooth consists of several Ubuntu
    packages that can be installed together using the `sawtooth`
    meta-package. Run the following command:

    ``` console
    $ sudo apt-get install -y sawtooth
    ```

> 1.  (PBFT only) Install the PBFT consensus engine package.
>
>     ``` console
>     $ sudo apt-get install -y sawtooth sawtooth-pbft-engine
>     ```
>
> 2.  (PoET only) Install the PoET consensus engine, transaction
>     processor, and CLI packages.
>
>     ``` console
>     $ sudo apt-get install -y sawtooth \
>     python3-sawtooth-poet-cli \
>     python3-sawtooth-poet-engine \
>     python3-sawtooth-poet-families
>     ```
>
> > ::: tip
> > ::: title
> > Tip
> > :::
> >
> > Any time after installation, you can view the installed Sawtooth
> > packages with the following command:
> >
> > ``` console
> > $ dpkg -l '*sawtooth*'
> > ```
> > :::

# Step 2: Create User and Validator Keys {#appdev-multinode-keys-label}

::: note
::: title
Note
:::

Skip this step if you are reusing an existing node that already has user
and validator keys.
:::

::: important
::: title
Important
:::

For PBFT, repeat this procedure on the other nodes in the initial
network. When you create the genesis block on the first node, you will
need the validator keys for at least three other nodes.
:::

1.  Generate your user key for Sawtooth.

    ``` console
    $ sawtooth keygen my_key
    writing file: /home/yourname/.sawtooth/keys/my_key.priv
    writing file: /home/yourname/.sawtooth/keys/my_key.pub
    ```

    ::: note
    ::: title
    Note
    :::

    This command specifies `my_key` as the base name for the key files,
    to be consistent with the key name that is used in some example
    Docker and Kubernetes files. By default (when no key name is
    specified), the `sawtooth keygen` command uses your user name.
    :::

2.  Generate the key for the validator, which runs as root.

    ``` console
    $ sudo sawadm keygen
    writing file: /etc/sawtooth/keys/validator.priv
    writing file: /etc/sawtooth/keys/validator.pub
    ```

    ::: note
    ::: title
    Note
    :::

    By default, this command stores the validator key files in
    `/etc/sawtooth/keys/validator.priv` and
    `/etc/sawtooth/keys/validator.pub`. However, settings in the path
    configuration file could change this location; see
    `../sysadmin_guide/configuring_sawtooth/path_configuration_file`{.interpreted-text
    role="doc"}.
    :::

# Step 3: Create the Genesis Block on the First Node

The first node creates the genesis block, which specifies the initial
on-chain settings for the network configuration. Other nodes access
those settings when they join the network.

**Prerequisites**:

-   If you are reusing an existing node, make sure that you have deleted
    the blockchain data before continuing (as described in
    `the Ubuntu section's
    prerequisites <prereqs-multi-ubuntu-label>`{.interpreted-text
    role="ref"}).
-   For PBFT, the genesis block requires the validator keys for at least
    four nodes (or all nodes in the initial network, if known). If you
    have not installed Sawtooth and generated keys on the other nodes,
    perform `Step 1 <appdev-multinode-install-label>`{.interpreted-text
    role="ref"} and
    `Step 2 <appdev-multinode-keys-label>`{.interpreted-text role="ref"}
    on those nodes, then gather the public keys from
    `/etc/sawtooth/keys/validator.pub` on each node.

The first node in a new Sawtooth network must create the [genesis
block]{.title-ref} (the first block on the distributed ledger). When the
other nodes join the network, they use the on-chain settings that were
specified in the genesis block.

The genesis block specifies the consensus algorithm and the keys for
nodes (or users) who are authorized to change configuration settings.
For PBFT, the genesis block also includes the keys for the other nodes
in the initial network.

::: important
::: title
Important
:::

Use this procedure **only** for the first node on a Sawtooth network.
Skip this procedure for a node that will join an existing network.
:::

1.  Ensure that the required user and validator keys exist on this node:

    ``` console
    $ ls $HOME/.sawtooth/keys/
    my_key.priv    my_key.pub

    $ ls /etc/sawtooth/keys/
    validator.priv   validator.pub
    ```

    If these key files do not exist, create them as described in the
    previous step.

2.  Change to a writable directory such as `/tmp`.

    ``` console
    $ cd /tmp
    ```

3.  Create a batch with a settings proposal for the genesis block.

    ``` console
    $ sawset genesis --key $HOME/.sawtooth/keys/my_key.priv \
    -o config-genesis.batch
    ```

    This command authorizes you to set and change Sawtooth settings. The
    settings changes will take effect after the validator and Settings
    transaction processor have started.

    ::: note
    ::: title
    Note
    :::

    You must use the same key for the `sawset proposal create` commands
    in the following steps. In theory, some of these commands could use
    a different key, but configuring multiple keys is a complicated
    process that is not shown in this procedure. For more information,
    see `/sysadmin_guide/adding_authorized_users`{.interpreted-text
    role="doc"}.
    :::

4.  Create a batch to initialize the consensus settings.

    -   For PBFT:

        ``` console
        $ sawset proposal create --key $HOME/.sawtooth/keys/my_key.priv \
        -o config-consensus.batch \
        sawtooth.consensus.algorithm.name=pbft \
        sawtooth.consensus.algorithm.version=1.0 \
        sawtooth.consensus.pbft.members='["VAL1KEY","VAL2KEY",...,"VALnKEY"]'
        ```

        Replace `"VAL1KEY","VAL2KEY","VAL3KEY",...,"VALnKEY"` with the
        validator public keys of all the nodes (including this node).
        This information is in the file
        `/etc/sawtooth/keys/validator.pub` on each node. Be sure to use
        single quotes and double quotes correctly, as shown in the
        example.

        ::: tip
        ::: title
        Tip
        :::

        The PBFT version number is in the file
        `sawtooth-pbft/Cargo.toml` as
        `version = "{major}.{minor}.{patch}"`. Use only the first two
        digits (major and minor release numbers); omit the patch number.
        For example, if the version is 1.0.3, use `1.0` for this
        setting.
        :::

    -   For PoET:

        ``` console
        $ sawset proposal create --key $HOME/.sawtooth/keys/my_key.priv \
        -o config-consensus.batch \
        sawtooth.consensus.algorithm.name=PoET \
        sawtooth.consensus.algorithm.version=0.1 \
        sawtooth.poet.report_public_key_pem="$(cat /etc/sawtooth/simulator_rk_pub.pem)" \
        sawtooth.poet.valid_enclave_measurements=$(poet enclave measurement) \
        sawtooth.poet.valid_enclave_basenames=$(poet enclave basename)
        ```

    ::: note
    ::: title
    Note
    :::

    This is a complicated command. Here\'s an explanation of the options
    and arguments:

    `--key $HOME/.sawtooth/keys/my_key.priv`

    :   Signs the proposal with your private key. Only this key can be
        used to change on-chain settings.

    `-o config-consensus.batch`

    :   Wraps the consensus proposal transaction in a batch named
        `config-consensus.batch`.

    `sawtooth.consensus.algorithm.name`

    :   Specifies the consensus algorithm for this network; this setting
        is required.

    `sawtooth.consensus.algorithm.version`

    :   Specifies the version of the consensus algorithm; this setting
        is required.

    (PBFT only) `sawtooth.consensus.pbft.members`

    :   Lists the member nodes on the initial network as a
        JSON-formatted string of the validators\' public keys, using the
        following format:

        `'["<public-key-1>","<public-key-2>",...,"<public-key-n>"]'`

    (PoET only) `sawtooth.poet.report_public_key_pem="$(cat /etc/sawtooth/simulator_rk_pub.pem)"`

    :   Adds the public key for the PoET Validator Registry transaction
        processor to use for the PoET simulator consensus.

    (PoET only) `sawtooth.poet.valid_enclave_measurements=$(poet enclave measurement)`

    :   Adds a simulated enclave measurement to the blockchain. The PoET
        Validator Registry transaction processor uses this value to
        check signup information.

    (PoET only) `sawtooth.poet.valid_enclave_basenames=$(poet enclave basename)`

    :   Adds a simulated enclave basename to the blockchain. The PoET
        Validator Registry uses this value to check signup information.
    :::

5.  (PoET only) Create a batch to register the first Sawtooth node with
    the PoET Validator Registry transaction processor, using the
    validator\'s private key. Without this command, the validator would
    not be able to publish any blocks.

    ``` console
    $ poet registration create --key /etc/sawtooth/keys/validator.priv -o poet.batch
    ```

6.  (Optional) Create a batch to configure other consensus settings.

    -   For PBFT:

        ``` console
        $ sawset proposal create --key $HOME/.sawtooth/keys/my_key.priv \
        -o pbft-settings.batch \
        SETTING-NAME=VALUE \
        ... \
        SETTING-NAME=VALUE
        ```

        For the available settings and their default values, see
        \"On-Chain Settings\" in the [Sawtooth PBFT
        documentation](https://sawtooth.hyperledger.org/docs/#sawtooth-pbft).

    -   For PoET:

        ``` console
        $ sawset proposal create --key $HOME/.sawtooth/keys/my_key.priv \
        -o poet-settings.batch \
        sawtooth.poet.target_wait_time=5 \
        sawtooth.poet.initial_wait_time=25 \
        sawtooth.publisher.max_batches_per_block=100
        ```

        ::: note
        ::: title
        Note
        :::

        This example shows the default PoET settings. For more
        information, see the [Hyperledger Sawtooth Settings
        FAQ](https://sawtooth.hyperledger.org/faq/settings/).
        :::

7.  As the sawtooth user, combine the separate batches into a single
    genesis batch that will be committed in the genesis block.

    -   For PBFT:

        ``` console
        $ sudo -u sawtooth sawadm genesis \
        config-genesis.batch config-consensus.batch pbft-settings.batch
        ```

    -   For PoET:

        ``` console
        $ sudo -u sawtooth sawadm genesis \
        config-genesis.batch config-consensus.batch poet.batch poet-settings.batch
        ```

    You'll see some output indicating success:

    ``` console
    Processing config-genesis.batch...
    Processing config-consensus.batch...
    ...
    Generating /var/lib/sawtooth/genesis.batch
    ```

    ::: note
    ::: title
    Note
    :::

    The `sawtooth.consensus.algorithm.name` and
    `sawtooth.consensus.algorithm.version` settings are required;
    `sawadm genesis` will fail if they are not present in one of the
    batches unless the `--ignore-required-settings` flag is used.
    :::

When this command finishes, the genesis block is complete.

The settings in the genesis block will be available after the first node
has started and the genesis block has been committed.

# Step 4. (PBFT Only) Configure Peers in Off-Chain Settings

For PBFT, each node specify the peer nodes in the network, because a
PBFT network must be fully peered (all nodes must be directly
connected). This setting is in the off-chain
`validator configuration file <../sysadmin_guide/configuring_sawtooth/validator_configuration_file>`{.interpreted-text
role="doc"}.

1.  Create the validator configuration file by copying the example file.

    ``` console
    $ sudo cp -a /etc/sawtooth/validator.toml.example /etc/sawtooth/validator.toml
    ```

2.  Use `sudo` to edit this file.

    ``` console
    $ sudo vi /etc/sawtooth/validator.toml
    ```

3.  Locate the `peering` setting and make sure that it is set to
    `static` (the default).

4.  Find the `peers` setting and enter the URLs for other validators on
    the network.

    Use the format `tcp://{hostname}:{port}` for each peer. Specify
    multiple peers in a comma-separated list. For example:

    ``` ini
    peers = ["tcp://node1:8800", "tcp://node2:8800", "tcp://node3:8800"]
    ```

This setting will take effect when the validator starts.

::: note
::: title
Note
:::

For information about optional configuration settings, see
`../sysadmin_guide/off_chain_settings`{.interpreted-text role="doc"}.
:::

# Step 5. Start Sawtooth on the First Node {#start-sawtooth-first-node-label}

This step shows how to start all Sawtooth components: the validator,
REST API, transaction processors, and consensus engine. Use a separate
terminal window to start each component.

1.  Start the validator with the following command.

    Substitute your actual values for the component and network bind
    strings, public endpoint string, and peer list, as described in
    `prereqs-multi-ubuntu-label`{.interpreted-text role="ref"}.

    ``` console
    $ sudo -u sawtooth sawtooth-validator \
    --bind component:{component-bind-string} \
    --bind network:{network-bind-string} \
    --bind consensus:{consensus-bind-string} \
    --endpoint {public-endpoint-string} \
    --peers {peer-list}
    ```

    Specify multiple peers in a comma-separated list, as in this
    example:

    > ``` none
    > --peers tcp://203.0.113.0:8800,198.51.100.0:8800
    > ```

    ::: important
    ::: title
    Important
    :::

    For PBFT, specify all known peers in the initial network. (PBFT
    requires at least four nodes.) If you want to add another PBFT node
    later, see
    `../sysadmin_guide/pbft_adding_removing_node`{.interpreted-text
    role="doc"}.
    :::

    The following example uses these values:

    -   component bind address `127.0.0.1:4004` (the default value)

    -   network bind address and endpoint `192.0.2.0:8800` (a TEST-NET-1
        example address)

    -   consensus bind address and endpoint `192.0.2.0:5050`

    -   three peers at the public endpoints `203.0.113.0:8800`,
        `203.0.113.1:8800`, and `203.0.113.2:8800`.

        > ``` console
        > $ sudo -u sawtooth sawtooth-validator \
        > --bind component:tcp://127.0.0.1:4004 \
        > --bind network:tcp://192.0.2.0:8800 \
        > --bind consensus:tcp://192.0.2.0:5050 \
        > --endpoint tcp://192.0.2.0:8800 \
        > --peers tcp://203.0.113.0:8800,tcp://203.0.113.1:8800,tcp://203.0.113.2:8800
        > ```

    Leave this window open; the validator will continue to display
    logging output as it runs.

2.  Open a separate terminal window and start the REST API.

    ``` console
    $ sudo -u sawtooth sawtooth-rest-api -v
    ```

    If necessary, use the `--connect` option to specify a non-default
    value for the validator\'s component bind address and port, as
    described in `prereqs-multi-ubuntu-label`{.interpreted-text
    role="ref"}. The following example shows the default value:

    > ``` none
    > $ sudo -u sawtooth sawtooth-rest-api -v --connect 127.0.0.1:4004
    > ```

    For more information, see `start-rest-api-label`{.interpreted-text
    role="ref"}.

3.  Start the transaction processors. Open a separate terminal window to
    start each one.

    As with the previous command, use the `--connect` option for each
    command, if necessary, to specify a non-default value for
    validator\'s component bind address and port.

    ``` console
    $ sudo -u sawtooth settings-tp -v
    ```

    ``` console
    $ sudo -u sawtooth intkey-tp-python -v
    ```

    ``` console
    $ sudo -u sawtooth xo-tp-python -v
    ```

    ::: note
    ::: title
    Note
    :::

    The transaction processors for Integer Key (`intkey-tp-python`) and
    XO (`xo-tp-python`) are not required for a Sawtooth network, but are
    used for the other steps in this guide.
    :::

    For more information, see `start-tps-label`{.interpreted-text
    role="ref"}.

4.  (PoET only) Also start the PoET Validator Registry transaction
    processor in a separate terminal window.

    ``` console
    $ sudo -u sawtooth poet-validator-registry-tp -v
    ```

5.  Start the consensus engine in a separate terminal window.

    ::: note
    ::: title
    Note
    :::

    Change the `--connect` option, if necessary, to specify a
    non-default value for validator\'s consensus bind address and port.
    :::

    -   For PBFT:

        ``` console
        $ sudo -u sawtooth pbft-engine -vv --connect tcp://localhost:5050
        ```

    -   For PoET:

        ``` console
        $ sudo -u sawtooth poet-engine -vv --connect tcp://localhost:5050
        ```

    The terminal window displays log messages as the consensus engine
    connects to and registers with the validator. The output will be
    similar to this example:

    ``` console
    [2019-01-09 11:45:07.807 INFO     handlers] Consensus engine registered: ...

    DEBUG | {name:}:engine | Min: 0 -- Max: 0
    INFO  | {name:}:engine | Wait time: 0
    DEBUG | {name}::engine | Initializing block
    ```

# Step 6. Test the First Node

Although the Sawtooth network is not fully functional until other nodes
have joined the network, you can use any or all of the following
commands to verify the REST API and check that the genesis block has
been committed.

-   Confirm that the REST API is reachable.

    ``` console
    $ curl http://localhost:8008/blocks
    ```

    ::: note
    ::: title
    Note
    :::

    The Sawtooth environment described this guide runs a local REST API
    on each node. For a node that is not running a local REST API,
    replace `localhost:8008` with the externally advertised IP address
    and port.
    :::

    You should see a JSON response that is similar to this example:

    ``` console
    {
      "data": [
        {
          "batches": [
            {
              "header": {
                "signer_public_key": . . .
    ```

    If not, check the status of the REST API service and restart it, if
    necessary.

```{=html}
<!-- -->
```
-   Check the list of blocks on the blockchain.

    ``` console
    $ sawtooth block list
    ```

    For the first node on a network, this list will contain only a few
    blocks. If this node has joined an existing network, the block list
    could be quite long. In both cases, the list should end with output
    that resembles this example:

    ``` console
    NUM  BLOCK_ID                                                                                                                          BATS  TXNS  SIGNER
    .
    .
    .
    2    f40b90d06b4a9074af2ab09e0187223da7466be75ec0f472f2edd5f22960d76e402e6c07c90b7816374891d698310dd25d9b88dce7dbcba8219d9f7c9cae1861  3     3     02e56e...
    1    4d7b3a2e6411e5462d94208a5bb83b6c7652fa6f4c2ada1aa98cabb0be34af9d28cf3da0f8ccf414aac2230179becade7cdabbd0976c4846990f29e1f96000d6  1     1     034aad...
    0    0fb3ebf6fdc5eef8af600eccc8d1aeb3d2488992e17c124b03083f3202e3e6b9182e78fef696f5a368844da2a81845df7c3ba4ad940cee5ca328e38a0f0e7aa0  3     11    034aad...
    ```

    Block 0 is the `genesis block`{.interpreted-text role="term"}. The
    other two blocks contain the initial transactions for on-chain
    settings, such as setting the consensus algorithm.

```{=html}
<!-- -->
```
-   (PBFT only) Ensure that the on-chain setting
    `sawtooth.consensus.pbft.members` lists the validator public keys of
    all PBFT member nodes on the network.
    a.  Connect to the first node (the one that created the genesis
        block).

    b.  Display the on-chain settings.

        ``` console
        $ sawtooth settings list
        ```

    c.  In the output, look for `sawtooth.consensus.pbft.members` and
        verify that it includes the public key for each node.

        ``` console
        sawtooth.consensus.pbft.members=["03e27504580fa15...
        ```

        ::: tip
        ::: title
        Tip
        :::

        You can use the `sawset proposal create` command to change this
        setting. For more information, see
        `/sysadmin_guide/pbft_adding_removing_node`{.interpreted-text
        role="doc"}.
        :::

# Step 7: Start the Other Nodes {#install-second-val-ubuntu-label}

After confirming basic functionality on the first node, start Sawtooth
on all other nodes in the initial network.

Use the procedure in `start-sawtooth-first-node-label`{.interpreted-text
role="ref"}.

::: important
::: title
Important
:::

Be careful to specify the correct values for the component and network
bind address, endpoint, and peers settings. Incorrect values could cause
the network to fail.

Start the same transaction processors that are running on the first
node. For example, if you chose not to start `intkey-tp-python` and
`xo-tp-python` on the first node, do not start them on the other nodes.
:::

When each node\'s validator fully starts, it will peer with the other
running nodes.

# Step 8: Confirm Network Functionality {#confirm-nw-funct-ubuntu-label}

For the remaining steps, multiple nodes in the network must be running.

> -   PBFT requires at least four nodes.
> -   PoET requires at least three nodes.

1.  To check whether peering has occurred on the network, submit a peers
    query to the REST API on the first node.

    Open a terminal window on the first node and run the following
    command.

    > ``` console
    > $ curl http://localhost:8008/peers
    > ```

    ::: note
    ::: title
    Note
    :::

    This environment runs a local REST API on each node. For a node that
    is not running a local REST API, you must replace `localhost:8008`
    with the externally advertised IP address and port. (Non-default
    values are set with the `--bind` option when starting the REST API.)
    :::

    If this query returns a 503 error, the nodes have not yet peered
    with the Sawtooth network. Repeat the query until you see output
    that resembles the following example:

    > ``` console
    > {
    >     "data": [
    >     "tcp://validator-1:8800",
    >   ],
    >   "link": "http://rest-api:8008/peers"
    > }
    > ```

2.  Run the following Sawtooth commands on a node to show the other
    nodes on the network.

    a.  Run `sawtooth peer list` to show the peers of a particular node.
    b.  Run `sawnet peers list` to display a complete graph of peers on
        the network (available in Sawtooth release 1.1 and later).

3.  Verify that transactions are being processed correctly.

    a.  Submit a transaction to the REST API on the first node. This
        example sets a key named `MyKey` to the value 999.

        Run the following command in a terminal window on the first
        node.

        ``` console
        $ intkey set MyKey 999
        ```

    b.  Watch for this transaction to appear on the other node. The
        following command requests the value of `MyKey` from the REST
        API on the that node.

        Open a terminal window on another node to run the following
        command.

        ``` console
        $ intkey show MyKey
        MyKey: 999
        ```

# Step 9. (Optional) Configure the Allowed Transaction Types {#configure-txn-procs-ubuntu-label}

By default, a validator accepts transactions from any transaction
processor. However, Sawtooth allows you to limit the types of
transactions that can be submitted.

For this procedure, see
`../sysadmin_guide/setting_allowed_txns`{.interpreted-text role="doc"}
in the System Administrator\'s Guide.
