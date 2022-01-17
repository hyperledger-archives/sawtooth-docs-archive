# Setting Up a Sawtooth Network

In this section, you will configure a network of Sawtooth nodes with
either Sawtooth PBFT consensus or PoET simulator consensus.

- [Sawtooth PBFT consensus]({% link docs/1.2/glossary.md %}) provides Byzantine
  fault tolerance for a network with restricted membership. PBFT requires at
  least four nodes.
- [PoET simulator consensus]({% link docs/1.2/glossary.md %}) is designed for a
  system without a Trusted Execution Environment (TEE). Sawtooth PoET requires a
  minimum of three nodes, but works best with at least four or five nodes.

For more information on the supported consensus types, or to learn how
to change the consensus later, see
[About Dynamic Consensus]({% link
docs/1.2/sysadmin_guide/about_dynamic_consensus.md %}).

> **Note**
>
> For the procedure to configure Sawtooth with PoET SGX consensus on a
> system with Intel ® Software Guard Extensions (SGX), see
> [Using Sawtooth with PoET-SGX]({% link docs/1.2/sysadmin_guide/configure_sgx.md %}).

Use this set of procedures to create the first Sawtooth node in a
network or to add a new node to an existing network. Note that some
procedures are performed only on the first node. Other procedures are
required on the minimum set of nodes in the initial network.

Each node in this Sawtooth network runs a validator, a REST API, and the
following transaction processors:

- [Settings]({% link
  docs/1.2/transaction_family_specifications/settings_transaction_family.md %})
  (`settings-tp`)
- [Identity]({% link
  docs/1.2/transaction_family_specifications/identity_transaction_family.md %})
  (`identity-tp`)
- [IntegerKey]({% link
  docs/1.2/transaction_family_specifications/integerkey_transaction_family.md
  %}) (`intkey-tp-python`) - optional, but used to test basic Sawtooth
  functionality
- (PoET only) [PoET Validator Registry]({% link
  docs/1.2/transaction_family_specifications/validator_registry_transaction_family.md
  %}) (`poet-validator-registry-tp`)

> **Important**
>
> Each node in a Sawtooth network must run the same set of transaction
> processors. If this node will join an existing Sawtooth network, make
> sure that you know the full list of required transaction processors, and
> that you install any custom transaction processors.


> **Note**
>
> These instructions have been tested on Ubuntu 18.04 (Bionic) only.

## Installing Hyperledger Sawtooth

This procedure describes how to install Hyperledger Sawtooth on a Ubuntu
system for proof-of-concept or production use in a Sawtooth network.

1.  Choose whether you want the stable version (recommended) or the most
    recent nightly build (for testing purposes only).

    -   (Release 1.2 and later) To add the stable repository, run these
        commands in a terminal window on your host system.

        ``` console
        $ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8AA7AF1F1091A5FD
        $ sudo add-apt-repository 'deb [arch=amd64] http://repo.sawtooth.me/ubuntu/chime/stable bionic universe'
        ```

        > **Note**
        >
        > The `chime` metapackage includes the Sawtooth core software and
        > associated items such as separate consensus software.

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

    1.  (PBFT only) Install the PBFT consensus engine package.

        ``` console
        $ sudo apt-get install -y sawtooth sawtooth-pbft-engine
        ```

    2.  (PoET only) Install the PoET consensus engine, transaction
        processor, and CLI packages.

        ``` console
        $ sudo apt-get install -y sawtooth \
        python3-sawtooth-poet-cli \
        python3-sawtooth-poet-engine \
        python3-sawtooth-poet-families
        ```

        > **Tip**
        >
        > Any time after installation, you can view the installed Sawtooth
        > packages with the following command:
        >
        > ``` console
        > $ dpkg -l '*sawtooth*'
        > ```

## Generating User and Validator Keys

> **Important**
>
> For PBFT, repeat this procedure on the other nodes in the initial
> network. When you create the genesis block on the first node, you will
> need the validator keys for at least three other nodes.

1.  Generate your user key for Sawtooth.

    ``` console
    $ sawtooth keygen my_key
    writing file: /home/yourname/.sawtooth/keys/my_key.priv
    writing file: /home/yourname/.sawtooth/keys/my_key.pub
    ```

    > **Note**
    >
    > This command specifies `my_key` as the base name for the key files,
    > to be consistent with the key name that is used in some example
    > Docker and Kubernetes files. By default (when no key name is
    > specified), the `sawtooth keygen` command uses your user name.

2.  Generate the key for the validator, which runs as root.

    ``` console
    $ sudo sawadm keygen
    writing file: /etc/sawtooth/keys/validator.priv
    writing file: /etc/sawtooth/keys/validator.pub
    ```

    > Note
    >
    > By default, this command stores the validator key files in
    > `/etc/sawtooth/keys/validator.priv` and
    > `/etc/sawtooth/keys/validator.pub`. However, settings in the path
    > configuration file could change this location; see
    > [Path Configuration File]({% link docs/1.2/sysadmin_guide/configuring_sawtooth.md %}#path_configuration_file).

Sawtooth also includes a network key pair that is used to encrypt
communication between the validators in a Sawtooth network. This
off-chain configuration setting is described in a later procedure.

## Creating the Genesis Block

**Prerequisites**:

-   For PBFT, the genesis block requires the validator keys for at least
    four nodes (or all nodes in the initial network, if known). Before
    continuing, ensure that three (or more) other nodes have installed
    Sawtooth and generated the keys. Gather these keys from
    `/etc/sawtooth/keys/validator.pub` on each node.

The first node in a new Sawtooth network must create the [genesis
block]{.title-ref} (the first block on the distributed ledger). When the
other nodes join the network, they use the on-chain settings that were
specified in the genesis block.

The genesis block specifies the consensus algorithm and the keys for
nodes (or users) who are authorized to change configuration settings.
For PBFT, the genesis block also includes the keys for the other nodes
in the initial network.

> **Important**
>
> Use this procedure **only** for the first node on a Sawtooth network.
> Skip this procedure for a node that will join an existing network.

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

    > **Note**
    >
    > You must use the same key for the `sawset proposal create` commands
    > in the following steps. In theory, some of these commands could use
    > a different key, but configuring multiple keys is a complicated
    > process that is not shown in this procedure. For more information,
    > see [Adding Authorized Users for Settings Proposals]({% link docs/1.2/sysadmin_guide/adding_authorized_users.md %}).

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

        > **Tip**
        >
        > The PBFT version number is in the file
        > `sawtooth-pbft/Cargo.toml` as
        > `version = "{major}.{minor}.{patch}"`. Use only the first two
        > digits (major and minor release numbers); omit the patch number.
        > For example, if the version is 1.0.3, use `1.0` for this
        > setting.

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

    > **Note**
    >
    > This is a complicated command. Here\'s an explanation of the options
    > and arguments:
    >
    > `--key $HOME/.sawtooth/keys/my_key.priv`
    >
    > :   Signs the proposal with your private key. Only this key can be
    >     used to change on-chain settings.
    >
    > `-o config-consensus.batch`
    >
    > :   Wraps the consensus proposal transaction in a batch named
    >     `config-consensus.batch`.
    >
    > `sawtooth.consensus.algorithm.name`
    >
    > :   Specifies the consensus algorithm for this network; this setting
    >     is required.
    >
    > `sawtooth.consensus.algorithm.version`
    >
    > :   Specifies the version of the consensus algorithm; this setting
    >     is required.
    >
    > (PBFT only) `sawtooth.consensus.pbft.members`
    >
    > :   Lists the member nodes on the initial network as a
    >     JSON-formatted string of the validators\' public keys, using the
    >     following format:
    >
    >     `'["<public-key-1>","<public-key-2>",...,"<public-key-n>"]'`
    >
    > (PoET only) `sawtooth.poet.report_public_key_pem="$(cat /etc/sawtooth/simulator_rk_pub.pem)"`
    >
    > :   Adds the public key for the PoET Validator Registry transaction
    >     processor to use for the PoET simulator consensus.
    >
    > (PoET only) `sawtooth.poet.valid_enclave_measurements=$(poet enclave measurement)`
    >
    > :   Adds a simulated enclave measurement to the blockchain. The PoET
    >     Validator Registry transaction processor uses this value to
    >     check signup information.
    >
    > (PoET only) `sawtooth.poet.valid_enclave_basenames=$(poet enclave basename)`
    >
    > :   Adds a simulated enclave basename to the blockchain. The PoET
    >     Validator Registry uses this value to check signup information.

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

        > **Note**
        >
        > This example shows the default PoET settings. For more
        > information, see the [Hyperledger Sawtooth Settings
        > FAQ](https://sawtooth.hyperledger.org/faq/settings/).

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

    > **Note**
    >
    > The `sawtooth.consensus.algorithm.name` and
    > `sawtooth.consensus.algorithm.version` settings are required;
    > `sawadm genesis` will fail if they are not present in one of the
    > batches unless the `--ignore-required-settings` flag is used.

When this command finishes, the genesis block is complete.

The settings in the genesis block will be available after the first node
has started and the genesis block has been committed.

## Changing Off-chain Settings with Configuration Files

This procedure explains how to create and use Sawtooth configuration
files to change the following Sawtooth settings:

-   Host and port values (bind endpoints) for the validator, REST API,
    and consensus API

-   Peering type and peer nodes on the network

    > **Important**
    >
    > For PBFT, all peer nodes must be specified with the `peers` setting
    > in the validator configuration file.

-   Network keys for secured communication between nodes (optional)

-   Scheduler type (optional)

It also explains how to configure a non-default REST API URL for the
Sawtooth commands.

See [About Sawtooth Configuration Files]({% link
docs/1.2/sysadmin_guide/configuring_sawtooth.md %}) for detailed information on
the settings in each configuration file.

> **Note**
>
> This procedure assumes that the configuration directory is
> `/etc/sawtooth/`. If your system uses a different location, change this
> path in the commands below. For more information, see
> [Path Configuration File]({% link docs/1.2/sysadmin_guide/configuring_sawtooth.md %}#path_configuration_file).

### Configure the Validator {#sysadm-configure-validator-label}

The following steps configure the validator\'s networking information so
that the validator advertises itself properly and knows where to search
for peers. Additional steps specify the peers for this node, change the
scheduler type (optional), and create a network key.

1.  Create the validator configuration file by copying the example file.

    ``` console
    $ sudo cp -a /etc/sawtooth/validator.toml.example /etc/sawtooth/validator.toml
    ```

2.  Use `sudo` to edit this file.

    ``` console
    $ sudo vi /etc/sawtooth/validator.toml
    ```

3.  Change the network settings for the validator.

    a.  Locate the `endpoint` setting, which specifies validator\'s
        external URL.

    Replace the default interface and port (`127.0.0.1:8800`) with
    the values for your node. You can use either the NAT values or
    the publicly addressable IP address and port.

    ``` ini
    endpoint = "tcp://{external_interface}:{port}"
    ```

    b.  Locate the `bind` settings. If necessary, change these values
        for your system. The default values are:

    ``` ini
    bind = [
      "network:tcp://127.0.0.1:8800",
      "component:tcp://127.0.0.1:4004",
      "consensus:tcp://127.0.0.1:5050"
    ]
    ```

    -   `network` specifies where the validator listens for
        communication from other nodes
    -   `component` specifies where the validator listens for
        communication from this validator\'s components, such as the
        REST API and transaction processors
    -   `consensus` specifies where the validator listens for
        communication from the consensus engine

    > **Tip**
    >
    > Make sure that all values in this setting are valid for your
    > network. If the bind interface doesn\'t exist, you might see a
    > ZMQ error in the `sawtooth-validator` systemd logs when
    > attempting to start the validator, as in this example:
    >
    > ``` console
    > Jun 02 14:50:37 ubuntu validator[15461]:   File "/usr/lib/python3.5/threading.py", line 862, in run
    > ...
    > Jun 02 14:50:37 ubuntu validator[15461]:   File "zmq/backend/cython/socket.pyx", line 487, in zmq.backend.cython.socket.Socket.bind (zmq/backend/cython/socket.c:5156)
    > Jun 02 14:50:37 ubuntu validator[15461]:   File "zmq/backend/cython/checkrc.pxd", line 25, in zmq.backend.cython.checkrc._check_rc (zmq/backend/cython/socket.c:7535)
    > Jun 02 14:50:37 ubuntu validator[15461]: zmq.error.ZMQError: No such device
    > Jun 02 14:50:37 ubuntu systemd[1]: sawtooth-validator.service: Main process exited, code=exited, status=1/FAILURE
    > Jun 02 14:50:37 ubuntu systemd[1]: sawtooth-validator.service: Unit entered failed state.
    > Jun 02 14:50:37 ubuntu systemd[1]: sawtooth-validator.service: Failed with result 'exit-code'.
    > ```

4.  Set the peering type and peer list (directly connected nodes) for
    this Sawtooth node.

    a.  Locate the `peering` setting, which specifies the type of
        peering approach the validator should take: static (the default)
        or dynamic.

    ``` ini
    peering = "static"
    ```

    This choice depends on the network type and consensus algorithm.
    For example, a public network using an open-membership consensus
    algorithm should use dynamic peering, while a consortium network
    or network using a fixed-membership consensus algorithm should
    use static peering. For more information, see [Validator Configuration
    File]({% link docs/1.2/sysadmin_guide/configuring_sawtooth.md
    %}#validator_configuration_file).

    > **Note**
    >
    > Static peering is recommended for PBFT consensus, because a PBFT
    > network must be fully peered.

    b.  Find the `peers` setting and enter the URLs for other validators
        on the network.

    -   If `peering` is `dynamic`, you can enter a partial list of
        URLs. Sawtooth will automatically discover the other nodes
        on the network.
    -   If `peering` is `static`, you must list the URLs of **all**
        peers that this node should connect to.

    Use the format `tcp://{hostname}:{port}` for each peer. Specify
    multiple peers in a comma-separated list. For example:

    ``` ini
    peers = ["tcp://node1:8800", "tcp://node2:8800", "tcp://node3:8800"]
    ```

    c.  (Dynamic peering only). Find the `seeds` setting, which
        specifies the peers to use for the initial connection to the
        Sawtooth network. This setting is ignored for static peering.

    Replace the default address and port (`host1:8800`) with the
    values for one or more nodes in your network. You can use either
    the NAT values or the publicly addressable IP address and port.

    Specify multiple nodes in a comma-separated list, as in this
    example:

    ``` ini
    seeds = ["tcp://{address1}:{port}",
             "tcp://{address2}:{port}"]
    ```

5.  (Optional) Set the scheduler type to either `parallel` (the default)
    or `serial`. For more information, see
    [Iterative Scheduling]({% link docs/1.2/architecture/scheduling.md
    %}#arch-iterative-sched-label) in the Architecture Guide.

    ``` ini
    scheduler = 'parallel'
    ```

6.  (Optional) Set the network key to specify secured network
    communication between nodes in the network. By default, the network
    is unsecured.

    > **Important**
    >
    > The example configuration file contains sample keys that are
    > publicly visible. You **must** change these keys in order to have
    > a secured network.

    a.  Locate the `network_public_key` and `network_private_key`
        settings. These items specify the curve ZMQ key pair used to
        create a secured network based on side-band sharing of a single
        network key pair to all participating nodes.

    b.  Generate your network keys.

    - This example shows how to use Python to generate these keys:

      ```python
      python3
       ...
      >>> import zmq
      >>> (public, secret) = zmq.curve_keypair()
      >>> print(public.decode('UTF-8'))
      wFMwoOt>yFqI/ek.G[tfMMILHWw#vXB[Sv}>l>i)
      >>> print(secret.decode('UTF-8'))
      r&oJ5aQDj4+V]p2:Lz70Eu0x#m%IwzBdP(}&hWM*
      ```

    - Or you could use the following steps to compile and run `curve_keygen` to
      generate the keys:

      ``` console
      $ sudo apt-get install g++ libzmq3-dev
       ...
      $ wget https://raw.githubusercontent.com/zeromq/libzmq/master/tools/curve_keygen.cpp
       ...
      $ g++ curve_keygen.cpp -o curve_keygen -lzmq

      $./curve_keygen
      == CURVE PUBLIC KEY ==
      -so<iWpS=5uINn*eV$=J)F%lEFd=@g:g@GqmL2C]
      == CURVE SECRET KEY ==
      G1.mNaJLnJxb6BWsY=P[K3D({+uww!T&LC3(Xq:B
      ```

    c. Replace the example values with your unique network keys.

       ``` ini
       network_public_key = '{nw-public-key}'
       network_private_key = '{nw-private-key}'
       ```

7.  After saving your changes, restrict the permissions on
    `validator.toml` to protect the network private key.

    ``` console
    $ sudo chown root:sawtooth /etc/sawtooth/validator.toml
    $ sudo chmod 640 /etc/sawtooth/validator.toml
    ```

8.  Finally, restart the validator to activate the configuration
    changes.

    ``` console
    $ sudo systemctl restart sawtooth-validator.service
    ```

> **Note**
>
> To learn how to use the `[role]` and `[permissions]` settings to control
> validator and user access to the network, see
> [Configuring Validator and Transactor Permissions]({% link docs/1.2/sysadmin_guide/configuring_permissions.md %})
>
> For information about the `opentsdb_` settings, see
> [Using Grafana to Display Sawtooth Metrics]({% link docs/1.2/sysadmin_guide/grafana_configuration.md %}).

### Configure the REST API {#rest-api-bind-address-label}

Use these steps to change the network settings for the REST API.

1.  Create the REST API configuration file by copying the example file.

    ``` console
    $ sudo cp -a /etc/sawtooth/rest_api.toml.example /etc/sawtooth/rest_api.toml
    ```

2.  Use `sudo` to edit this file.

    ``` console
    $ sudo vi /etc/sawtooth/rest_api.toml
    ```

3.  If necessary, change the `bind` setting to specify where the REST
    API listens for incoming communication.

    Be sure to remove the `#` comment character to activate this
    setting.

    ``` console
    bind = ["127.0.0.1:8008"]
    ```

4.  If necessary, change the `connect` setting, which specifies where
    the REST API can find this node\'s validator on the network.

    Be sure to remove the `#` comment character to activate this
    setting.

    ``` console
    connect = "tcp://localhost:4004"
    ```

5.  Finally, restart the REST API to activate the configuration changes.

    ``` console
    $ sudo systemctl restart sawtooth-rest-api.service
    ```

> **Note**
>
> To learn how to put the REST API behind a proxy server, see
> [Using a Proxy Server to Authorize the REST API]({% link docs/1.2/sysadmin_guide/rest_auth_proxy.md %}).

### Configure the Sawtooth Commands (Optional) {#config-sawtooth-cmds-label}

If the REST API on this node is not at the default location, you can set
the URL in the CLI configuration file. Otherwise, you would have to use
the `--url` option with each Sawtooth command.

For more information, see [Sawtooth CLI Configuration File]({% link
docs/1.2/sysadmin_guide/configuring_sawtooth.md %}#cli_configuration).

1.  Create the CLI configuration file by copying the example file.

    ``` console
    $ sudo cp -a /etc/sawtooth/cli.toml.example /etc/sawtooth/cli.toml
    ```

2.  Use `sudo` to edit this file.

    ``` console
    $ sudo vi /etc/sawtooth/cli.toml
    ```

3.  Change the `url` setting to the host and port for the REST API. This
    setting must match the `bind` value in the REST API configuration
    file.

    Be sure to remove the `#` comment character to activate this
    setting.

    ``` console
    url = "http://localhost:8008"
    ```

## Running Sawtooth as a Service

When you installed Sawtooth with `apt-get`, `systemd` units were added
for the Sawtooth components (validator, REST API, transaction
processors, and consensus engines). This procedure describes how to use
the `systemctl` command to start, stop, and restart Sawtooth components
as `systemd` services.

To learn more about `systemd` and the `systemctl` command, see the
[Digital Ocean systemctl
guide](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units).

> **Note**
>
> Each node in the Sawtooth network must run the same set of transaction
> processors. If this node will join an existing Sawtooth network, make
> sure that you know the full list of required transaction processors, and
> have installed any custom transaction processors.
>
> If necessary, add the additional transaction processors to all
> `systemctl` commands in this procedure.

### Start the Sawtooth Services

1.  Start the basic Sawtooth components as services: REST API,
    validator, and transaction processors.

    ``` console
    $ sudo systemctl start sawtooth-rest-api.service
    $ sudo systemctl start sawtooth-validator.service
    $ sudo systemctl start sawtooth-settings-tp.service
    $ sudo systemctl start sawtooth-identity-tp.service
    $ sudo systemctl start sawtooth-intkey-tp-python.service
    ```

    The transaction processors `sawtooth-settings-tp` (Settings) and
    `sawtooth-identity-tp` (Identity) are required.
    `sawtooth-intkey-tp-python` (IntegerKey) is used in a later
    procedure to test basic Sawtooth functionality.

2.  Start the consensus-related components as services.

    - For PBFT:

      ``` console
      $ sudo systemctl start sawtooth-pbft-engine.service
      ```

    - For PoET:

      ``` console
      $ sudo systemctl start sawtooth-poet-validator-registry-tp.service
      $ sudo systemctl start sawtooth-poet-engine.service
      ```

3.  Verify that all the Sawtooth services are running.

    - Check the basic services:

      ``` console
      $ sudo systemctl status sawtooth-rest-api.service
      $ sudo systemctl status sawtooth-validator.service
      $ sudo systemctl status sawtooth-settings-tp.service
      $ sudo systemctl status sawtooth-identity-tp.service
      $ sudo systemctl status sawtooth-intkey-tp-python.service
      ```

    - (PBFT only) Check the PBFT consensus service:

      ``` console
      $ sudo systemctl status sawtooth-pbft-engine.service
      ```

    - (PoET only) Check the PoET consensus services:

      ``` console
      $ sudo systemctl status sawtooth-poet-validator-registry-tp.service
      $ sudo systemctl status sawtooth-poet-engine.service
      ```

### View Sawtooth Logs

Use the following command to see the log output that would have been
displayed on the console if you ran the components manually.

- For PBFT:

  ``` console
  $ sudo journalctl -f \
  -u sawtooth-rest-api \
  -u sawtooth-validator \
  -u sawtooth-settings-tp \
  -u sawtooth-identity-tp \
  -u sawtooth-intkey-tp-python \
  -u sawtooth-pbft-engine
  ```

- For PoET:

  ``` console
  $ sudo journalctl -f \
  -u sawtooth-rest-api \
  -u sawtooth-validator \
  -u sawtooth-settings-tp \
  -u sawtooth-identity-tp \
  -u sawtooth-intkey-tp-python \
  -u sawtooth-poet-validator-registry-tp \
  -u sawtooth-poet-engine
  ```

Additional logging output can be found in `/var/log/sawtooth/`. For more
information, see [Log Configuration File]({% link
docs/1.2/sysadmin_guide/log_configuration.md %}).

### Stop or Restart the Sawtooth Services {#stop-restart-sawtooth-services-label}

If you need to stop or restart the Sawtooth services for any reason, use
the following procedures.

#### Stop Sawtooth Services

1. Stop the basic services.

   ``` console
   $ sudo systemctl stop sawtooth-rest-api.service
   $ sudo systemctl stop sawtooth-validator.service
   $ sudo systemctl stop sawtooth-settings-tp.service
   $ sudo systemctl stop sawtooth-identity-tp.service
   $ sudo systemctl stop sawtooth-intkey-tp-python.service
   ```

2. Stop the consensus services.

   - For PBFT:

     ``` console
     $ sudo systemctl stop sawtooth-pbft-engine.service
     ```

   - For PoET:

     ``` console
     $ sudo systemctl stop sawtooth-poet-validator-registry-tp.service
     $ sudo systemctl stop sawtooth-poet-engine.service
     ```

#### Restart Sawtooth Services

1. Restart the basic services.

   ``` console
   $ sudo systemctl restart sawtooth-rest-api.service
   $ sudo systemctl restart sawtooth-validator.service
   $ sudo systemctl restart sawtooth-settings-tp.service
   $ sudo systemctl restart sawtooth-identity-tp.service
   $ sudo systemctl restart sawtooth-intkey-tp-python.service
   ```

2. Restart the consensus services.

   - For PBFT:

     ``` console
     $ sudo systemctl restart sawtooth-pbft-engine.service
     ```

   - For PoET:

     ``` console
     $ sudo systemctl restart sawtooth-poet-validator-registry-tp.service
     $ sudo systemctl restart sawtooth-poet-engine.service
     ```

## Testing Sawtooth Functionality

### Test a single node

After [starting Sawtooth services](#testing-sawtooth-functionality) on one node,
you can use any or all of the following commands to test basic Sawtooth
functionality.

- Confirm that the REST API is reachable.

  ``` console
  $ curl http://localhost:8008/blocks
  ```

  > **Note**
  >
  > The Sawtooth environment described this guide runs a local REST API
  > on each node. For a node that is not running a local REST API,
  > replace `localhost:8008` with the externally advertised IP address
  > and port.

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

- Check the list of blocks on the blockchain.

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

  Block 0 is the [genesis block]({% link docs/1.2/glossary.md %}). The
  other two blocks contain the initial transactions for on-chain
  settings, such as setting the consensus algorithm.

- (PBFT only) Ensure that the on-chain setting
  `sawtooth.consensus.pbft.members` lists the validator public keys of
  all PBFT member nodes on the network.
  a. Connect to the first node (the one that created the genesis
     block).

  b. Display the on-chain settings.

     ``` console
     $ sawtooth settings list
     ```

  c. In the output, look for `sawtooth.consensus.pbft.members` and
     verify that it includes the public key for each node.

     ``` console
     sawtooth.consensus.pbft.members=["03e27504580fa15...
     ```

     > Tip
     >
     > You can use the `sawset proposal create` command to change this
     > setting. For more information, see
     > [Adding or Removing a PBFT Node]({% link docs/1.2/sysadmin_guide/pbft_adding_removing_node.md %}).

### Test the network

For the remaining steps, multiple nodes in the network must be running.
If this node is the first one in the network, wait until other nodes
have joined the network before continuing.

> -   PBFT requires at least four nodes.
> -   PoET requires at least three nodes.

1. To check whether peering has occurred on the network, submit a peers
   query to the REST API on this node.

   ``` console
   $ curl http://localhost:8008/peers
   ```

   > **Note**
   >
   > If this node is not running a local REST API, replace
   > `localhost:8008` with the externally advertised IP address and port
   > of the REST API.

   You should see a JSON response that includes the IP address and port
   for the validator and REST API, as in this example:

   ``` console
   {
       "data": [
       "tcp://validator-1:8800",
     ],
     "link": "http://rest-api:8008/peers"
   }
   ```

   If this query returns a 503 error, the node has not yet peered with
   the Sawtooth network. Repeat the query until you see the JSON
   response.

2. (Optional) You can run the following Sawtooth commands to show the
   other nodes on the network.

   - Run `sawtooth peer list` to show the peers of this node.
   - (Release 1.1 and later) Run `sawnet peers list` to display a
     complete graph of peers on the network.

   If there are problems, check the validator and REST API
   configuration files for errors in the IP addresses, ports, or peer
   settings. For more information, see [About Sawtooth Configuration Files]({%
   link docs/1.2/sysadmin_guide/configuring_sawtooth.md %}).

3. Make sure that new blocks of transactions are added to the
   blockchain.

   a. Use the IntegerKey transaction processor to submit a test
      transaction. The following command uses `intkey` (the
      command-line client for IntegerKey) to set a key named `MyKey`
      to the value 999.

      ``` console
      $ intkey set MyKey 999
      ```

   b. Next, check that this transaction appears on the blockchain.

      ``` console
      $ intkey show MyKey
      MyKey: 999
      ```

   c. Repeat the `block list` command to verify that there is now one
      more block on the blockchain, as in this example:

      ``` console
      $ sawtooth block list

      NUM  BLOCK_ID                                                                                                                          BATS  TXNS  SIGNER
      N    1b7f121a82e73ba0e7f73de3e8b46137a2e47b9a2d2e6566275b5ee45e00ee5a06395e11c8aef76ff0230cbac0c0f162bb7be626df38681b5b1064f9c18c76e5  3     3     02d87a...
      .
      .
      .
      2    f40b90d06b4a9074af2ab09e0187223da7466be75ec0f472f2edd5f22960d76e402e6c07c90b7816374891d698310dd25d9b88dce7dbcba8219d9f7c9cae1861  3     3     02e56e...
      1    4d7b3a2e6411e5462d94208a5bb83b6c7652fa6f4c2ada1aa98cabb0be34af9d28cf3da0f8ccf414aac2230179becade7cdabbd0976c4846990f29e1f96000d6  1     1     034aad...
      0    0fb3ebf6fdc5eef8af600eccc8d1aeb3d2488992e17c124b03083f3202e3e6b9182e78fef696f5a368844da2a81845df7c3ba4ad940cee5ca328e38a0f0e7aa0  3     11    034aad...
      ```

   If there is a problem, examine the logs for the validator, REST API,
   and transaction processors for possible clues. For more information,
   see [Log Configuration File]({% link
   docs/1.2/sysadmin_guide/log_configuration.md %}).

> **Tip**
>
> For help with problems, see the [Hyperledger Sawtooth
> FAQ]({% link faq/index.md %}) or ask a question on the
> Hyperledger Chat [#sawtooth
> channel](https://chat.hyperledger.org/channel/sawtooth).

After verifying that Sawtooth is running correctly, you can continue
with the optional configuration and customization steps that are
described in the following procedures.

## PBFT Only: Updating the PBFT Member List

If you are adding a new node to an existing PBFT network, you must
update the on-chain setting `sawtooth.consensus.pbft.members` after the
new node has been installed and configured. This setting takes effect
after the containing block has been committed.

See [Adding a PBFT Node]({% link
docs/1.2/sysadmin_guide/pbft_adding_removing_node.md %}#adding-a-pbft-node-label)
for this procedure.

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
