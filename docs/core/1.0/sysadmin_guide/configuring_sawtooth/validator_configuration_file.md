# Validator Configuration File

The validator configuration file specifies network information that
allows the validator to advertise itself properly and search for peers.
This file also contains settings for optional authorization roles and
transactor permissions.

If the config directory contains a file named `validator.toml`, the
configuration settings are applied when the validator starts. (By
default, the config directory is `/etc/sawtooth/`; see
`path_configuration_file`{.interpreted-text role="doc"} for more
information.) Specifying an option on the command line overrides the
setting in the configuration file.

An example configuration file is in
`/sawtooth-core/packaging/validator.toml.example`. To create a validator
configuration file, copy the example file to the config directory and
name it `validator.toml`. Then edit the file to change the example
configuration options as necessary for your system.

::: note
::: title
Note
:::

See `../configure_sgx`{.interpreted-text role="doc"} for an example of
changing the settings in `validator.toml` when configuring Sawtooth with
the SGX implementation of PoET.
:::

The `validator.toml` configuration file has the following options:

-   `bind` = \[ \"`endpoint`\", \"`endpoint`\" \]

    Sets the network and component endpoints. Default network bind
    interface: `tcp://127.0.0.1:8800`. Default component bind interface:
    `tcp://127.0.0.1:4004`.

    Each string has the format `{option}:{endpoint}`, where `{option}`
    is either `network` or `component`. For example:

    ``` none
    bind = [
      "network:tcp://127.0.0.1:8800",
      "component:tcp://127.0.0.1:4004"
    ]
    ```

-   `peering = "{static,dynamic}"`

    Specifies the type of peering approach the validator should take:
    static or dynamic. Default: `static`.

    Static peering attempts to peer only with the candidates provided
    with the peers option. For example:

    ``` none
    peering = "static"
    ```

    Dynamic peering first processes any static peers, starts topology
    buildouts, then uses the URLs specified by the seeds option for the
    initial connection to the validator network.

    ``` none
    peering = "dynamic"
    ```

-   `endpoint = "URL"`

    Sets the advertised network endpoint URL. Default:
    tcp://127.0.0.1:8800. Replace the external interface and port values
    with either the publicly addressable IP address and port or with the
    NAT values for your validator. For example:

    ``` none
    endpoint = "tcp://127.0.0.1:8800"
    ```

-   `seeds` = \[`URI`\]

    (Dynamic peering only.) Specifies the URI or URIs for the initial
    connection to the validator network. Specify multiple URIs in a
    comma-separated list; each URI must be enclosed in double quotes.
    Default: none.

    Note that this option is not needed in static peering mode.

    Replace the seed address and port values with either the publicly
    addressable IP address and port or with the NAT values for the other
    nodes in your network. For example:

    ``` none
    seeds = ["tcp://127.0.0.1:8801"]
    ```

-   `peers` = \[\"[URL]{.title-ref}\"\]

    Specifies a static list of peers to attempt to connect to. Default:
    none.

    ``` none
    peers = ["tcp://127.0.0.1:8801"]
    ```

-   `scheduler` = \'[type]{.title-ref}\'

    Determines the type of scheduler to use: serial or parallel.
    Default: `serial`. For example:

    ``` none
    scheduler = 'serial'
    ```

-   `network_public_key` and `network_private_key`

    Specifies the curve ZMQ key pair used to create a secured network
    based on side-band sharing of a single network key pair to all
    participating nodes. Default: none.

    Enclose the key in single quotes; for example:

    ``` none
    network_public_key = 'wFMwoOt>yFqI/ek.G[tfMMILHWw#vXB[Sv}>l>i)'
    network_private_key = 'r&oJ5aQDj4+V]p2:Lz70Eu0x#m%IwzBdP(}&hWM*'
    ```

    ::: important
    ::: title
    Important
    :::

    If these options are not set or the configuration file does not
    exist, the network will default to being insecure.
    :::

-   `opentsdb_url` = \"[value]{.title-ref}\"

    Sets the host and port for Open TSDB database (used for metrics).
    Default: none.

-   `opentsdb_db` = \"[name]{.title-ref}\"

    Sets the name of the Open TSDB database. Default: none.

-   `opentsdb_username` = [username]{.title-ref}

    Sets the username for the Open TSDB database. Default: none.

-   `opentsdb_password` = [password]{.title-ref}

    Sets the password for the Open TSDB database. Default: none.

-   `network = "{trust,challenge}"`

    Specifies the type of authorization that must be performed for the
    different type of authorization roles on the network: trust or
    challenge. Default: trust.

    This option must be in the `[roles]` section of the file. For
    example:

    ``` none
    [roles]
    network = "trust"
    ```

    For more information, see `Authorization_Types`{.interpreted-text
    role="ref"}.

-   \"[role]{.title-ref}\" = \"[policy]{.title-ref}\"

    Sets the off-chain transactor permissions for the role or roles that
    specify which transactors are allowed to sign batches on the system.
    Multiple roles can be defined, using one \"[role]{.title-ref}\" =
    \"[policy]{.title-ref}\" entry per line. Default: none.

    The role names specified in this config file must match the roles
    stored in state for transactor permissioning. For example:

    -   `transactor`
    -   `transactor.transaction_signer`
    -   `transactor.transaction_signer.{tp_name}`
    -   `transactor.batch_signer`

    For [policy]{.title-ref}, specify a policy file in `policy_dir` (by
    default, `/etc/sawtooth/`). Each policy file contains permit and
    deny rules for the transactors; see
    `Off-Chain_Transactor_Permissioning`{.interpreted-text role="ref"}.

    Because transactor roles and policy files can have a period in the
    name, use double-quotes so that TOML can process these settings. For
    example:

    ``` none
    [permissions]
    "transactor" = "policy.example"
    "transactor.transaction_signer" = "policy.example"
    ```

    ::: note
    ::: title
    Note
    :::

    The `default` role cannot be set in the configuration file. Use the
    `sawtooth identity` command to change this on-chain-only setting.
    :::

    See `../configuring_permissions`{.interpreted-text role="doc"} for
    more information on roles and permissions.

-   `minimum_peer_connectivity` = [min]{.title-ref}

    The minimum number of peers required before stopping peer search.
    Default: 3 For example:

    ``` none
    minimum_peer_connectivity = 3
    ```

-   `maximum_peer_connectivity` = [max]{.title-ref}

    The maximum number of peers that will be accepted. Default: 10. For
    example:

    ``` none
    maximum_peer_connectivity = 10
    ```

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
