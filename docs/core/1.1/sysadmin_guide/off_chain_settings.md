# Changing Off-chain Settings with Configuration Files

Each Sawtooth component, such as the validator or the REST API, can have
an optional configuration file that controls the component\'s behavior.
By default, Sawtooth does not install any configuration files. However,
Sawtooth provides example configuration files that can be customized for
your system.

This procedure explains how to create and use Sawtooth configuration
files to change the following Sawtooth settings:

-   Host and port values (bind endpoints) for the validator, REST API,
    and consensus API
-   Peering type and peer nodes on the network
-   Network keys for secured communication between nodes (optional)
-   Scheduler type (optional)

It also explains how to configure a non-default REST API URL for the
Sawtooth commands.

See `configuring_sawtooth`{.interpreted-text role="doc"} for detailed
information on all the settings in each configuration file.

::: note
::: title
Note
:::

This procedure assumes that the configuration directory is
`/etc/sawtooth/`. If your system uses a different location, change this
path in the commands below. For more information, see
`configuring_sawtooth/path_configuration_file`{.interpreted-text
role="doc"}.
:::

# Configure the Validator

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

The following steps configure the validator\'s networking information so
that the validator advertises itself properly and knows where to search
for peers. Additional steps specify the peers for this node, change the
scheduler type (optional), and create a network key.

1.  Create the validator configuration file by copying the example file.

    ``` console
    $ sudo cp /etc/sawtooth/validator.toml.example /etc/sawtooth/validator.toml
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

        > ``` ini
        > bind = [
        >   "network:tcp://127.0.0.1:8800",
        >   "component:tcp://127.0.0.1:4004",
        >   "consensus:tcp://127.0.0.1:5050"
        > ]
        > ```

        -   `network` specifies where the validator listens for
            communication from other nodes
        -   `component` specifies where the validator listens for
            communication from this validator\'s components, such as the
            REST API and transaction processors
        -   `consensus` specifies where the validator listens for
            communication from consensus engines

        ::: tip
        ::: title
        Tip
        :::

        Make sure that all values in this setting are valid for your
        network. If the bind interface doesn\'t exist, you might see a
        ZMQ error in the `sawtooth-validator` systemd logs when
        attempting to start the validator, as in this example:

        ``` console
        Jun 02 14:50:37 ubuntu validator[15461]:   File "/usr/lib/python3.5/threading.py", line 862, in run
        ...
        Jun 02 14:50:37 ubuntu validator[15461]:   File "zmq/backend/cython/socket.pyx", line 487, in zmq.backend.cython.socket.Socket.bind (zmq/backend/cython/socket.c:5156)
        Jun 02 14:50:37 ubuntu validator[15461]:   File "zmq/backend/cython/checkrc.pxd", line 25, in zmq.backend.cython.checkrc._check_rc (zmq/backend/cython/socket.c:7535)
        Jun 02 14:50:37 ubuntu validator[15461]: zmq.error.ZMQError: No such device
        Jun 02 14:50:37 ubuntu systemd[1]: sawtooth-validator.service: Main process exited, code=exited, status=1/FAILURE
        Jun 02 14:50:37 ubuntu systemd[1]: sawtooth-validator.service: Unit entered failed state.
        Jun 02 14:50:37 ubuntu systemd[1]: sawtooth-validator.service: Failed with result 'exit-code'.
        ```
        :::

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
        use static peering. For more information, see
        `configuring_sawtooth/validator_configuration_file`{.interpreted-text
        role="doc"}.

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
        validator network. This setting is ignored for static peering.

        Replace the default address and port (`host1:8800`) with the
        values for one or more nodes in your network. You can use either
        the NAT values or the publicly addressable IP address and port.

        Specify multiple nodes in a comma-separated list, as in this
        example:

        ``` ini
        seeds = ["tcp://{address1}:{port}",
                 "tcp://{address2}:{port}"]
        ```

5.  (Optional) Set the scheduler type to either `serial` (the default)
    or `parallel`. For more information, see
    `arch-iterative-sched-label`{.interpreted-text role="ref"} in the
    Architecture Guide.

    ``` ini
    scheduler = 'parallel'
    ```

6.  (Optional) Set the network key to specify secured network
    communication between nodes in the network. By default, the network
    is unsecured.

    > ::: important
    > ::: title
    > Important
    > :::
    >
    > The example configuration file contains sample keys that are
    > publicly visible. You **must** change these keys in order to have
    > a secured network.
    > :::

    a.  Locate the `network_public_key` and `network_private_key`
        settings. These items specify the curve ZMQ key pair used to
        create a secured network based on side-band sharing of a single
        network key pair to all participating nodes.

    b.  Generate your network keys.

        -   This example shows how to use Python to generate these keys:

            > ``` python
            > python
            >  ...
            > >>> import zmq
            > >>> (public, secret) = zmq.curve_keypair()
            > >>> print public
            > wFMwoOt>yFqI/ek.G[tfMMILHWw#vXB[Sv}>l>i)
            > >>> print secret
            > r&oJ5aQDj4+V]p2:Lz70Eu0x#m%IwzBdP(}&hWM*
            > ```

        -   Or you could use the following steps to compile and run
            `curve_keygen` to generate the keys:

            > ``` console
            > $ sudo apt-get install g++ libzmq3-dev
            >  ...
            > $ wget https://raw.githubusercontent.com/zeromq/libzmq/master/tools/curve_keygen.cpp
            >  ...
            > $ g++ curve_keygen.cpp -o curve_keygen -lzmq
            >
            > $./curve_keygen
            > == CURVE PUBLIC KEY ==
            > -so<iWpS=5uINn*eV$=J)F%lEFd=@g:g@GqmL2C]
            > == CURVE SECRET KEY ==
            > G1.mNaJLnJxb6BWsY=P[K3D({+uww!T&LC3(Xq:B
            > ```

    c.  Replace the example values with your unique network keys.

        ``` ini
        network_public_key = '{nw-public-key}'
        network_private_key = '{nw-private-key}'
        ```

7.  After saving your changes, restrict the permissions on
    `validator.toml` to protect the network private key.

    ``` console
    $ sudo chown root:sawtooth /etc/sawtooth/validator.toml
    $ sudo chown 640 /etc/sawtooth/validator.toml
    ```

8.  Finally, restart the validator to activate the configuration
    changes.

    ``` console
    $ sudo systemctl restart sawtooth-validator.service
    ```

::: note
::: title
Note
:::

To learn how to use the `[role]` and `[permissions]` settings to control
validator and user access to the network, see
`configuring_permissions`{.interpreted-text role="doc"}.

For information about the `opentsdb_` settings, see
`grafana_configuration`{.interpreted-text role="doc"}.
:::

# Configure the REST API {#rest-api-bind-address-label}

Use these steps to change the network settings for the REST API.

1.  Create the REST API configuration file by copying the example file.

    ``` console
    $ sudo cp /etc/sawtooth/rest_api.toml.example /etc/sawtooth/rest_api.toml
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

::: note
::: title
Note
:::

To learn how to put the REST API behind a proxy server, see
`rest_auth_proxy`{.interpreted-text role="doc"}.
:::

# Configure the Sawtooth Commands (Optional)

If the REST API on this node is not at the default location, you can set
the URL in the CLI configuration file. Otherwise, you would have to use
the `--url` option with each Sawtooth command.

For more information, see
`configuring_sawtooth/cli_configuration`{.interpreted-text role="doc"}.

1.  Create the CLI configuration file by copying the example file.

    ``` console
    $ sudo cp /etc/sawtooth/cli.toml.example /etc/sawtooth/cli.toml
    ```

2.  Use `sudo` to edit this file.

    ``` console
    $ sudo vi /etc/sawtooth/cli.toml
    ```

3.  Change the `url` setting to the host and port for the REST API. This
    setting must match the `bind` value in the REST API configuration
    file (see `rest-api-bind-address-label`{.interpreted-text
    role="ref"}).

    Be sure to remove the `#` comment character to activate this
    setting.

    ``` console
    url = "http://localhost:8008"
    ```
