# About Sawtooth Configuration Files

Each Sawtooth component, such as the validator or the REST API, has an
optional configuration file that controls the component's behavior.
These configuration files provide an alternative to specifying Sawtooth
command options when starting a component.

> **Note**
>
> Using configuration files is an example of *off-chain configuration*. Changes
> are made on the local system only.  For more information, see
> [Configuring Validator and Transactor Permissions]({% link docs/1.2/sysadmin_guide/configuring_permissions.md %}).

When a Sawtooth component starts, it looks for a
[TOML-format](https://github.com/toml-lang/toml) configuration file in
the config directory, `/etc/sawtooth/` (by default).

By default (when Sawtooth is installed), no configuration files are
created. However, Sawtooth includes example configuration files that can
be customized for your system. See
[Changing Off-chain Settings with Configuration Files]({% link
docs/1.2/sysadmin_guide/setting_up_sawtooth_network.md
%}#changing-off-chain-settings-with-configuration-files) for this procedure.

> **Important**
>
> After changing a configuration file for a component, you must restart
> that component in order to load the changes.

Sawtooth also supports several non-component configuration files:

- The [Log Configuration File](#log-configuration-file) allows you to
  configure the log output for each component.
- The [Path Configuration File](#path_configuration_file) controls the
  location of Sawtooth directories, such as the configuration directory
  (`config_dir`) and log directory (`log_dir`). This file also lets you set an
  optional `$SAWTOOTH_HOME` environment variable to change the base location
  of Sawtooth files and directories.

## Validator Configuration File

The validator configuration file specifies network information that
allows the validator to advertise itself properly and search for peers.
This file also contains settings for optional authorization roles and
transactor permissions.

If the config directory contains a file named `validator.toml`, the
configuration settings are applied when the validator starts. Specifying
an option on the command line overrides the setting in the configuration
file.

An example configuration file is in
`/sawtooth-core/packaging/validator.toml.example`.

> **Note**
>
> By default, the config directory is `/etc/sawtooth/`.
> See [Path Configuration File](#path-configuration-file) for more
> information.


To create a validator configuration file, copy the example file to the
config directory and name it `validator.toml`. Important: Copy with
`cp -a` to preserve the file's ownership and permissions (or change
after copying to owner `root`, group `sawtooth`, and permissions `640`).
Then edit the file to change the example configuration options as
necessary for your system.

> **Note**
>
> For the procedures that show how to change configuration settings in
> this file, see [Off-chain Settings with Configuration Files]({% link docs/1.2/sysadmin_guide/setting_up_sawtooth_network.md %}#changing-off-chain-settings-with-configuration-files)
> and [Using Sawtooth with PoET-SGX]({% link docs/1.2/sysadmin_guide/configure_sgx.md %}).

The `validator.toml` configuration file has the following options:

- `bind = [ "network:{endpoint}", "component:{endpoint}", "consensus:{endpoint}", ]`

  Sets the network, component, and consensus endpoints. The default
  values are:

  ```toml
  bind = [
    "network:tcp://127.0.0.1:8800",
    "component:tcp://127.0.0.1:4004",
    "consensus:tcp://127.0.0.1:5050"
  ]
  ```

- `peering = "{static,dynamic}"`

  Specifies the type of peering the validator should use: static or
  dynamic. Default: `static`.

  Static peering attempts to peer only with the candidates provided
  with the peers option. For example:

  ```toml
  peering = "static"
  ```

  Dynamic peering first processes any static peers, starts topology
  buildouts, then uses the URLs specified by the seeds option for the
  initial connection to the Sawtooth network.

  ```toml
  peering = "dynamic"
  ```

- `endpoint = "URL"`

  Sets the advertised network endpoint URL. Default:
  tcp://127.0.0.1:8800. Replace the external interface and port values
  with either the publicly addressable IP address and port or with the
  NAT values for your validator. For example:

  ```toml
  endpoint = "tcp://127.0.0.1:8800"
  ```

- `seeds` = [`URI`]

  (Dynamic peering only.) Specifies the URI or URIs for the initial
  connection to the Sawtooth network. Specify multiple URIs in a
  comma-separated list; each URI must be enclosed in double quotes.
  Default: none.

  Note that this option is not needed in static peering mode.

  Replace the seed address and port values with either the publicly
  addressable IP address and port or with the NAT values for the other
  nodes in your network. For example:

  ```toml
  seeds = ["tcp://127.0.0.1:8801"]
  ```

- `peers` = ["*URL*"]

  Specifies a static list of peers to attempt to connect to. Default:
  none.

  ```toml
  peers = ["tcp://127.0.0.1:8801"]
  ```

- `scheduler` = "*type*"

  Determines the type of scheduler to use: serial or parallel.
  Default: `parallel`. For example:

  ```toml
  scheduler = 'parallel'
  ```

- `network_public_key` and `network_private_key`

  Specifies the curve ZMQ key pair used to create a secured network
  based on side-band sharing of a single network key pair to all
  participating nodes. Default: none.

  Enclose the key in single quotes; for example:

  ```toml
  network_public_key = 'wFMwoOt>yFqI/ek.G[tfMMILHWw#vXB[Sv}>l>i)'
  network_private_key = 'r&oJ5aQDj4+V]p2:Lz70Eu0x#m%IwzBdP(}&hWM*'
  ```

  > **Important**
  >
  > If these options are not set or the configuration file does not
  > exist, the network will default to being insecure.

- `opentsdb_url` = "*value*"

  Sets the host and port for an Open TSDB database (used for metrics).
  Default: none.

  For example of using the `opentsdb_` settings, see
  [Using Grafana to Display Sawtooth Metrics]({% link
  docs/1.2/sysadmin_guide/grafana_configuration.md %}).

- `opentsdb_db` = "*name*"

  Sets the name of the Open TSDB database. Default: none.

- `opentsdb_username` = *username*

  Sets the username for the Open TSDB database. Default: none.

- `opentsdb_password` = *password*

  Sets the password for the Open TSDB database. Default: none.

- `network = "{trust,challenge}"`

  Specifies the type of authorization that must be performed for the
  different type of authorization roles on the network: trust or
  challenge. Default: trust.

  This option must be in the `[roles]` section of the file. For
  example:

  ```toml
  [roles]
  network = "trust"
  ```

  For more information, see [Authorization Types]({% link
  docs/1.2/architecture/validator_network.md %}#authorization-types).

- "*role*" = "*policy*"

  Sets the off-chain transactor permissions for the role or roles that
  specify which transactors are allowed to sign batches on the system.
  Multiple roles can be defined, using one "*role*" = "*policy*" entry per line.
  Default: none.

  The role names specified in this config file must match the roles
  stored in state for transactor permissioning. For example:

  - `transactor`
  - `transactor.transaction_signer`
  - `transactor.transaction_signer.{tp_name}`
  - `transactor.batch_signer`

  For *policy*, specify a policy file in `policy_dir` (by
  default, `/etc/sawtooth/`). Each policy file contains permit and
  deny rules for the transactors; see
  [Off-chain Transactor Permissioning]({% link
  docs/1.2/sysadmin_guide/configuring_permissions.md
  %}#off-chain-transactor-permissioning).

  Because transactor roles and policy files can have a period in the
  name, use double-quotes so that TOML can process these settings. For
  example:

  ```toml
  [permissions]
  "transactor" = "policy.example"
  "transactor.transaction_signer" = "policy.example"
  ```

  > **Note**
  >
  > The `default` role cannot be set in the configuration file. Use the
  > `sawtooth identity` command to change this on-chain-only setting.

  See [Configuring Validator and Transactor Permissions]({% link
  docs/1.2/sysadmin_guide/configuring_permissions.md %}) for more information on
  roles and permissions.

- `minimum_peer_connectivity` = *min*

  The minimum number of peers required before stopping peer search.
  Default: 3 For example:

  ```toml
  minimum_peer_connectivity = 3
  ```

- `maximum_peer_connectivity` = *max*

  The maximum number of peers that will be accepted. Default: 10. For
  example:

  ```toml
  maximum_peer_connectivity = 10
  ```

## REST API Configuration File

The REST API configuration file specifies network connection settings
and an optional timeout value.

If the config directory contains a file named `rest_api.toml`, the
configuration settings are applied when the REST API starts. Specifying
a command-line option will override the setting in the configuration
file.

> **Note**
>
> By default, the config directory is `/etc/sawtooth/`.
> See [Path Configuration File](#path-configuration_file) for more information.

An example configuration file is in the `sawtooth-core` repository at
`/sawtooth-core/rest_api/packaging/rest_api.toml.example`. To create a
REST API configuration file, download this example file to the config
directory and name it `rest_api.toml`. Set the ownership and permissions
to owner `root`, group `sawtooth`, and permissions `640`. Then edit the
file to change the example configuration options as necessary for your
system.

The `rest_api.toml` configuration file has the following options:

- `bind` = ["*HOST:PORT*"]

  Sets the port and host for the REST API to run on. Default:
  `127.0.0.1:8008`. For example:

  ```toml
  bind = ["127.0.0.1:8008"]
  ```

- `connect` = "*URL*"

  Identifies the URL of a running validator. Default:
  `tcp://localhost:4004`. For example:

  ```toml
  connect = "tcp://localhost:4004"
  ```

- `timeout` = *value*

  Specifies the time, in seconds, to wait for a validator response.
  Default: 300. For example:

  ```toml
  timeout = 900
  ```

- `client_max_size` = *value*

  Specifies the size, in bytes, that the REST API will accept for the
  body of requests. If the body is larger a
  `413: Request Entity Too Large` will be returned Default: 10485760
  (or 10 MB). For example:

  ```toml
  client_max_size = 10485760
  ```

- `opentsdb_url` = "*value*"

  Sets the host and port for Open TSDB database (used for metrics).

- `opentsdb_db` = "*name*"

  Sets the name of the Open TSDB database. Default: none.

- `opentsdb_username` = *username*

  Sets the username for the Open TSDB database. Default: none.

- `opentsdb_password` = *password*

  Sets the password for the Open TSDB database. Default: none.

## Sawtooth CLI Configuration File

The Sawtooth CLI configuration file specifies arguments to be used by
the `sawtooth` command and its subcommands. For example, you can use
this file to set the URL of the REST API once, rather than entering the
`--url` option for each subcommand.

If the config directory contains a file named `cli.toml`, the
configuration settings are applied when the `sawtooth` command is run.
Specifying command-line options will override the settings in the
configuration file.

> **Note**
>
> By default, the config directory is `/etc/sawtooth/`.
> See [Path Configuration File](#path-configuration_file) for more information.

An example configuration file is in the `sawtooth-core` repository at
`/sawtooth-core/cli/cli.toml.example`. To create a CLI configuration
file, download this example file to the config directory and name it
`cli.toml`. Set the ownership and permissions to owner `root`, group
`sawtooth`, and permissions `640`.

The example file shows the format of the `url` option. To use it,
uncomment the line and replace the default value with the actual URL for
the REST API.

```toml
# The REST API URL

# url = "http://localhost:8008"
```

## PoET SGX Enclave Configuration File

This configuration file specifies configuration settings for a PoET SGX
enclave.

If the config directory contains a file named `poet_enclave_sgx.toml`,
the configuration settings are applied when the component starts.
Specifying a command-line option will override the setting in the
configuration file.

> **Note**
>
> By default, the config directory is `/etc/sawtooth/`.
> See [Path Configuration File](#path-configuration_file) for more information.

An example configuration file is in the `sawtooth-core` repository at
`/sawtooth-core/consensus/poet/sgx/packaging/poet_enclave_sgx.toml.example`.
To create a PoET SGX enclave configuration file, download this example
file to the config directory and name it `poet_enclave_sgx.toml`. Set
the ownership and permissions to owner `root`, group `sawtooth`, and
permissions `640`. Then edit the file to change the example
configuration options as necessary for your system.

> **Note**
>
> See [Using Sawtooth with PoET SGX]({% link docs/1.2/sysadmin_guide/configure_sgx.md %})
> for an example of changing settings in `poet_enclave_sgx.toml` when
> configuring Sawtooth with the SGX implementation of PoET.

The `poet_enclave_sgx.toml` configuration file has the following
options:

- `spid` = '*string*'

  Specifies the Service Provider ID (SPID), which is linked to the key
  pair used to authenticate with the attestation service. Default:
  none. The SPID value is a 32-digit hex string tied to the enclave
  implementation; for example:

  ```toml
  spid = 'DEADBEEF00000000DEADBEEF00000000'
  ```

- `ias_url` = '*URL*'

  Specifies the URL of the Intel Attestation Service (IAS) server.
  Default: none. Note that the URL shown in
  `poet_enclave_sgx.toml.example` is an example server for debug
  enclaves only:

  ```toml
  ias_url = 'https://test-as.sgx.trustedservices.intel.com:443'
  ```

- `spid_cert_file` = '*/full/path/to/certificate.pem*'

  Identifies the PEM-encoded certificate file that was submitted to
  Intel in order to obtain a SPID. Default: none. Specify the full
  path to the certificate file. This pem file can be created from
  `cert.crt` and `cert.key` files with this command:

  ``` console
  $ cat cert.crt cert.key > cert.pem
  ```

  Or from `cert.pfx` file with following command:

  ``` console
  $ openssl pkcs12 -in cert.pfx -out cert.pem -nodes
    ```

## Identity Transaction Processor Configuration File

The Identity transaction processor configuration file specifies the
validator endpoint connection to use.

If the config directory contains a file named `identity.toml`, the
configuration settings are applied when the transaction processor
starts. Specifying a command-line option will override the setting in
the configuration file.

> **Note**
>
> By default, the config directory is `/etc/sawtooth/`.
> See [Path Configuration File](#path-configuration_file) for more information.

An example configuration file is in the `sawtooth-core` repository at
`/sawtooth-core/families/identity/sawtooth_identity/packaging/identity.toml.example`.
To create an Identity transaction processor configuration file, download
this example file to the config directory and name it `identity.toml`.
Set the ownership and permissions to owner `root`, group `sawtooth`, and
permissions `640`. Then edit the file to change the example
configuration options as necessary for your system.

The `identity.toml` configuration file has the following option:

- `connect` = "*URL*"

  Identifies the URL of a running validator. Default:
  `tcp://localhost:4004`. For example:

  ``` toml
  connect = "tcp://localhost:4004"
  ```

## Settings Transaction Processor Configuration File

The Settings transaction processor configuration file specifies the
validator endpoint connection to use.

If the config directory contains a file named `settings.toml`, the
configuration settings are applied when the transaction processor
starts. Specifying a command-line option will override the setting in
the configuration file.

> **Note**
>
> By default, the config directory is `/etc/sawtooth/`.
> See [Path Configuration File](#path-configuration_file) for more information.

An example configuration file is in the `sawtooth-core` repository at
`/sawtooth-core/families/settings/packaging/settings.toml.example`. To
create a Settings transaction processor configuration file, download
this example file to the config directory and name it `settings.toml`.
Set the ownership and permissions to owner `root`, group `sawtooth`, and
permissions `640`. Then edit the file to change the example
configuration options as necessary for your system.

The `settings.toml` configuration file has the following option:

- `connect` = "*URL*"

  Identifies the URL of a running validator. Default:
  `tcp://localhost:4004`. For example:

  ``` toml
  connect = "tcp://localhost:4004"
  ```

## XO Transaction Processor Configuration File

The XO transaction processor configuration file specifies the validator
endpoint connection to use.

If the config directory contains a file named `xo.toml`, the
configuration settings are applied when the transaction processor
starts. Specifying a command-line option will override the setting in
the configuration file.

> **Note**
>
> By default, the config directory is `/etc/sawtooth/`.
> See [Path Configuration File](#path-configuration_file) for more information.

An example configuration file is in the `sawtooth-sdk-python` repository
at
`https://github.com/hyperledger/sawtooth-sdk-python/blob/master/examples/xo_python/packaging/xo.toml.example`.
To create a XO transaction processor configuration file, download this
example file to the config directory and name it `xo.toml`. Set the
ownership and permissions to owner `root`, group `sawtooth`, and
permissions `640`. Then edit the file to change the example
configuration options as necessary for your system.

The `xo.toml` configuration file has the following option:

- `connect` = "*URL*"

  Identifies the URL of a running validator. Default:
  `tcp://localhost:4004`. For example:

  ``` toml
  connect = "tcp://localhost:4004"
  ```

::: toctree
configuring_sawtooth/path_configuration_file
:::

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
