# sawtooth

The `sawtooth` command is the usual way to interact with Sawtooth
validators and networks.

This command has a multi-level structure. It starts with the base call
to `sawtooth`. Next is a top-level subcommand such as `block` or
`state`. Each top-level subcommand has additional subcommands that
specify the operation to perform, such as `list` or `create`. The
subcommands have options and arguments that control their behavior. For
example:

```console
$ sawtooth state list --format csv
```

```console
usage: sawtooth [-h] [-v] [-V]
                {batch,block,identity,keygen,peer,status,settings,state,transaction}
                ...

Provides subcommands to configure, manage, and use Sawtooth components.

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         enable more verbose output
  -V, --version         display version information

subcommands:
  {batch,block,identity,keygen,peer,status,settings,state,transaction}
    batch               Displays information about batches and submit new
                        batches
    block               Displays information on blocks in the current
                        blockchain
    identity            Works with optional roles, policies, and permissions
    keygen              Creates user signing keys
    peer                Displays information about validator peers
    status              Displays information about validator status
    settings            Displays on-chain settings
    state               Displays information on the entries in state
    transaction         Shows information on transactions in the current chain
```

## sawtooth batch

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

The `sawtooth batch` subcommands display information about the Batches
in the current blockchain and submit Batches to the validator via the
REST API. A Batch is a group of interdependent transactions that is the
atomic unit of change in Sawtooth. For more information, see
[Transactions and Batches](../architecture/transactions_and_batches).

```console
usage: sawtooth batch [-h] {list,show,status,submit} ...

Provides subcommands to display Batch information and submit Batches to the
validator via the REST API.

optional arguments:
  -h, --help            show this help message and exit

subcommands:
  {list,show,status,submit}
```

## sawtooth batch list

The `sawtooth batch list` subcommand queries the specified Sawtooth REST
API (default: `http://localhost:8008`) for a list of Batches in the
current blockchain. It returns the id of each Batch, the public key of
each signer, and the number of transactions in each Batch.

By default, this information is displayed as a white-space delimited
table intended for display, but other plain-text formats (CSV, JSON, and
YAML) are available and can be piped into a file for further processing.

```console
usage: sawtooth batch list [-h] [--url URL] [-u USERNAME[:PASSWORD]]
                           [-F {csv,json,yaml,default}]

Displays all information about all committed Batches for the specified validator, including the Batch id, public keys of all signers, and number of transactions in each Batch.

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of the validator's REST API (default:
                        http://localhost:8008)
  -u USERNAME[:PASSWORD], --user USERNAME[:PASSWORD]
                        specify the user to authorize request
  -F {csv,json,yaml,default}, --format {csv,json,yaml,default}
                        choose the output format
```

## sawtooth batch show

The `sawtooth batch show` subcommand queries the Sawtooth REST API for a
specific batch in the current blockchain. It returns complete
information for this batch in either YAML (default) or JSON format. Use
the `--key` option to narrow the returned information to just the value
of a single key, either from the batch or its header.

This subcommand requires the URL of the REST API (default:
`http://localhost:8008`), and can specify a
`username`:`password` combination when the REST API is
behind a Basic Auth proxy.

```console
usage: sawtooth batch show [-h] [--url URL] [-u USERNAME[:PASSWORD]] [-k KEY]
                           [-F {yaml,json}]
                           batch_id

Displays information for the specified Batch.

positional arguments:
  batch_id              id (header_signature) of the batch

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of the validator's REST API (default:
                        http://localhost:8008)
  -u USERNAME[:PASSWORD], --user USERNAME[:PASSWORD]
                        specify the user to authorize request
  -k KEY, --key KEY     show a single property from the block or header
  -F {yaml,json}, --format {yaml,json}
                        choose the output format (default: yaml)

```

## sawtooth batch status

The `sawtooth batch status` subcommand queries the Sawtooth REST API for
the committed status of one or more batches, which are specified as a
list of comma-separated Batch ids. The output is in either YAML
(default) or JSON format, and includes the ids of any invalid
transactions with an error message explaining why they are invalid. The
`--wait` option indicates that results should not be returned until
processing is complete, with an optional timeout value specified in
seconds.

This subcommand requires the URL of the REST API (default:
`http://localhost:8008`), and can specify a
`username`:`password` combination when the REST API is
behind a Basic Auth proxy.

```console
usage: sawtooth batch status [-h] [--url URL] [-u USERNAME[:PASSWORD]]
                             [--wait [WAIT]] [-F {yaml,json}]
                             batch_ids

Displays the status of the specified Batch id or ids.

positional arguments:
  batch_ids             single batch id or comma-separated list of batch ids

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of the validator's REST API (default:
                        http://localhost:8008)
  -u USERNAME[:PASSWORD], --user USERNAME[:PASSWORD]
                        specify the user to authorize request
  --wait [WAIT]         set time, in seconds, to wait for commit
  -F {yaml,json}, --format {yaml,json}
                        choose the output format (default: yaml)

```

## sawtooth batch submit

The `sawtooth batch submit` subcommand sends one or more Batches to the
Sawtooth REST API to be submitted to the validator. The input is a
binary file with a binary-encoded `BatchList` protobuf, which can
contain one or more batches with any number of transactions. The
`--wait` option indicates that results should not be returned until
processing is complete, with an optional timeout specified in seconds.

This subcommand requires the URL of the REST API (default:
`http://localhost:8008`), and can specify a
`username`:`password` combination when the REST API is
behind a Basic Auth proxy.

```console
usage: sawtooth batch submit [-h] [--url URL] [-u USERNAME[:PASSWORD]] [-v]
                             [-V] [--wait [WAIT]] [-f FILENAME]
                             [--batch-size-limit BATCH_SIZE_LIMIT]

Sends Batches to the REST API to be submitted to the validator. The input must
be a binary file containing a binary-encoded BatchList of one or more batches
with any number of transactions.

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of the validator's REST API (default:
                        http://localhost:8008)
  -u USERNAME[:PASSWORD], --user USERNAME[:PASSWORD]
                        specify the user to authorize request
  -v, --verbose         enable more verbose output
  -V, --version         display version information
  --wait [WAIT]         set time, in seconds, to wait for batches to commit
  -f FILENAME, --filename FILENAME
                        specify location of input file
  --batch-size-limit BATCH_SIZE_LIMIT
                        set maximum batch size; batches are split for
                        processing if they exceed this size

```

## sawtooth block

The `sawtooth block` subcommands display information about the blocks in
the current blockchain.

```console
usage: sawtooth block [-h] {list,show} ...

Provides subcommands to display information about the blocks in the current
blockchain.

optional arguments:
  -h, --help   show this help message and exit

subcommands:
  {list,show}
    list       Displays information for all blocks on the current blockchain
    show       Displays information about the specified block on the current
               blockchain
```

## sawtooth block list {#sawtooth-block-list-label}

The `sawtooth block list` subcommand queries the Sawtooth REST API
(default: `http://localhost:8008`) for a list of blocks in the current
chain. Using the `--count` option, the number of blocks returned can be
configured. It returns the id and number of each block, the public key
of each signer, and the number of transactions and batches in each.

By default, this information is displayed as a white-space delimited
table intended for display, but other plain-text formats (CSV, JSON, and
YAML) are available and can be piped into a file for further processing.

```console
usage: sawtooth block list [-h] [--url URL] [-u USERNAME[:PASSWORD]]
                           [-F {csv,json,yaml,default}] [-n COUNT]

Displays information for all blocks on the current blockchain, including the block id and number, public keys all of allsigners, and number of transactions and batches.

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of the validator's REST API (default:
                        http://localhost:8008)
  -u USERNAME[:PASSWORD], --user USERNAME[:PASSWORD]
                        specify the user to authorize request
  -F {csv,json,yaml,default}, --format {csv,json,yaml,default}
                        choose the output format
  -n COUNT, --count COUNT
                        the number of blocks to list

```

## sawtooth block show

The `sawtooth block show` subcommand queries the Sawtooth REST API for a
specific block in the current blockchain. It returns complete
information for this block in either YAML (default) or JSON format.
Using the `--key` option, it is possible to narrow the returned
information to just the value of a single key, either from the block, or
its header.

This subcommand requires the URL of the REST API (default:
`http://localhost:8008`), and can specify a
`username`:`password` combination when the REST API is
behind a Basic Auth proxy.

```console
usage: sawtooth block show [-h] [--url URL] [-u USERNAME[:PASSWORD]] [-k KEY]
                           [-F {yaml,json}]
                           block_id

Displays information about the specified block on the current blockchain.

positional arguments:
  block_id              id (header_signature) of the block

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of the validator's REST API (default:
                        http://localhost:8008)
  -u USERNAME[:PASSWORD], --user USERNAME[:PASSWORD]
                        specify the user to authorize request
  -k KEY, --key KEY     show a single property from the block or header
  -F {yaml,json}, --format {yaml,json}
                        choose the output format (default: yaml)

```

## sawtooth identity

Sawtooth supports an identity system that provides an extensible
role-and policy-based system for defining permissions in a way which can
be used by other pieces of the architecture. This includes the existing
permissioning components for transactor key and validator key; in the
future, this feature may also be used by transaction family
implementations. The `sawtooth identity` subcommands can be used to view
the current roles and policy set in state, create new roles, and new
policies.

Note that only the public keys stored in the setting
`sawtooth.identity.allowed_keys` are allowed to submit identity
transactions. Use the `sawset` commands to change this setting.

```console
usage: sawtooth identity [-h] {policy,role} ...

Provides subcommands to work with roles and policies.

optional arguments:
  -h, --help     show this help message and exit

subcommands:
  {policy,role}
    policy       Provides subcommands to display existing policies and create
                 new policies
    role         Provides subcommands to display existing roles and create new
                 roles

```

## sawtooth identity policy

The `sawtooth identity policy` subcommands are used to display the
current policies stored in state and to create new policies.

```console
usage: sawtooth identity policy [-h] {create,list} ...

Provides subcommands to list the current policies stored in state and to
create new policies.

optional arguments:
  -h, --help     show this help message and exit

policy:
  {create,list}
    create       Creates batches of sawtooth-identity transactions for setting
                 a policy
    list         Lists the current policies

```

## sawtooth identity policy create

The `sawtooth identity policy create` subcommand creates a new policy
that can then be set to a role. The policy should contain at least one
"rule" (`PERMIT_KEY` or `DENY_KEY`). Note that all policies have an
assumed last rule to deny all. This subcommand can also be used to
change the policy that is already set to a role without having to also
reset the role.

```console
usage: sawtooth identity policy create [-h] [-k KEY] [-o OUTPUT | --url URL]
                                       [--wait WAIT]
                                       name rule [rule ...]

Creates a policy that can be set to a role or changes a policy without
resetting the role.

positional arguments:
  name                  name of the new policy
  rule                  rule with the format "PERMIT_KEY <key>" or "DENY_KEY
                        <key> (multiple "rule" arguments can be specified)

optional arguments:
  -h, --help            show this help message and exit
  -k KEY, --key KEY     specify the signing key for the resulting batches
  -o OUTPUT, --output OUTPUT
                        specify the output filename for the resulting batches
  --url URL             identify the URL of a validator's REST API
  --wait WAIT           set time, in seconds, to wait for the policy to commit
                        when submitting to the REST API.
```

## sawtooth identity policy list

The `sawtooth identity policy list` subcommand lists the policies that
are currently set in state. This list can be used to figure out which
policy name should be set for a new role.

```console
usage: sawtooth identity policy list [-h] [--url URL]
                                     [--format {default,csv,json,yaml}]

Lists the policies that are currently set in state.

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of a validator's REST API
  --format {default,csv,json,yaml}
                        choose the output format
```

## sawtooth identity role

The `sawtooth identity role` subcommands are used to list the current
roles stored in state and to create new roles.

```console
usage: sawtooth identity role [-h] {create,list} ...

Provides subcommands to list the current roles stored in state and to create
new roles.

optional arguments:
  -h, --help     show this help message and exit

role:
  {create,list}
    create       Creates a new role that can be used to enforce permissions
    list         Lists the current keys and values of roles

```

## sawtooth identity role create

The `sawtooth identity role create` subcommand creates a new role that
can be used to enforce permissions. The policy argument identifies the
policy that the role is restricted to. This policy must already exist
and be stored in state. Use `sawtooth identity policy list` to display
the existing policies. The role name should reference an action that can
be taken on the network. For example, the role named
`transactor.transaction_signer` controls who is allowed to sign
transactions.

```console
usage: sawtooth identity role create [-h] [-k KEY] [--wait WAIT]
                                     [-o OUTPUT | --url URL]
                                     name policy

Creates a new role that can be used to enforce permissions.

positional arguments:
  name                  name of the role
  policy                identify policy that role will be restricted to

optional arguments:
  -h, --help            show this help message and exit
  -k KEY, --key KEY     specify the signing key for the resulting batches
  --wait WAIT           set time, in seconds, to wait for a role to commit
                        when submitting to the REST API.
  -o OUTPUT, --output OUTPUT
                        specify the output filename for the resulting batches
  --url URL             the URL of a validator's REST API
```

## sawtooth identity role list

The `sawtooth identity role list` subcommand displays the roles that are
currently set in state. This list can be used to determine which
permissions are being enforced on the network. The output includes which
policy the roles are set to.

By default, this information is displayed as a white-space delimited
table intended for display, but other plain-text formats (CSV, JSON, and
YAML) are available and can be piped into a file for further processing.

```console
usage: sawtooth identity role list [-h] [--url URL]
                                   [--format {default,csv,json,yaml}]

Displays the roles that are currently set in state.

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of a validator's REST API
  --format {default,csv,json,yaml}
                        choose the output format
```

## sawtooth keygen

The `sawtooth keygen` subcommand generates a private key file and a
public key file so that users can sign Sawtooth transactions and
batches. These files are stored in the `<key-dir>` directory in
`<key_name>.priv` and `<key_dir>/<key_name>.pub`. By default,
`<key_dir>` is `~/.sawtooth` and `<key_name>` is `$USER`.

```console
usage: sawtooth keygen [-h] [-v] [-V] [--key-dir KEY_DIR] [--force] [-q]
                       [key_name]

Generates keys with which the user can sign transactions and batches.

positional arguments:
  key_name           specify the name of the key to create

optional arguments:
  -h, --help         show this help message and exit
  -v, --verbose      enable more verbose output
  -V, --version      display version information
  --key-dir KEY_DIR  specify the directory for the key files
  --force            overwrite files if they exist
  -q, --quiet        do not display output

The private and public key files are stored in <key-dir>/<key-name>.priv and
<key-dir>/<key-name>.pub. <key-dir> defaults to ~/.sawtooth and <key-name>
defaults to $USER.
```

## sawtooth peer

The `sawtooth peer` subcommand displays the addresses of a specified
validator\'s peers.

```console
usage: sawtooth peer [-h] {list} ...

Provides a subcommand to list a validator's peers

optional arguments:
  -h, --help  show this help message and exit

subcommands:
  {list}
```

## sawtooth peer list

The `sawtooth peer list` subcommand displays the addresses of a
specified validator\'s peers.

This subcommand requires the URL of the REST API (default:
`http://localhost:8008`), and can specify a
`username`:`password` combination when the REST API is
behind a Basic Auth proxy.

```console
usage: sawtooth peer list [-h] [--url URL] [-u USERNAME[:PASSWORD]]
                          [-F {csv,json,yaml,default}]

Displays the addresses of the validators with which a specified validator is
peered.

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of the validator's REST API (default:
                        http://localhost:8008)
  -u USERNAME[:PASSWORD], --user USERNAME[:PASSWORD]
                        specify the user to authorize request
  -F {csv,json,yaml,default}, --format {csv,json,yaml,default}
                        choose the output format
```

## sawtooth settings

The `sawtooth settings` subcommand displays the values of currently
active on-chain settings.

```console
usage: sawtooth settings [-h] {list} ...

Displays the values of currently active on-chain settings.

optional arguments:
  -h, --help  show this help message and exit

settings:
  {list}
    list      Lists the current keys and values of on-chain settings
```

## sawtooth settings list

The `sawtooth settings list` subcommand displays the current keys and
values of on-chain settings.

```console
usage: sawtooth settings list [-h] [--url URL] [--filter FILTER]
                              [--format {default,csv,json,yaml}]

List the current keys and values of on-chain settings. The content can be
exported to various formats for external consumption.

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of a validator's REST API
  --filter FILTER       filters keys that begin with this value
  --format {default,csv,json,yaml}
                        choose the output format
```

## sawtooth state

The `sawtooth state` subcommands display information about the entries
in the current blockchain state.

```console
usage: sawtooth state [-h] {list,show} ...

Provides subcommands to display information about the state entries in the
current blockchain state.

optional arguments:
  -h, --help   show this help message and exit

subcommands:
  {list,show}
```

## sawtooth state list

The `sawtooth state list` subcommand queries the Sawtooth REST API for a
list of all state entries in the current blockchain state. This
subcommand returns the address of each entry, its size in bytes, and the
byte-encoded data it contains. It also returns the head block for which
this data is valid.

To control the state that is returned, use the `subtree` argument to
specify an address prefix as a filter or a block id to use as the chain
head.

By default, this information is displayed as a white-space delimited
table intended for display, but other plain-text formats (CSV, JSON, and
YAML) are available and can be piped into a file for further processing.

This subcommand requires the URL of the REST API (default:
`http://localhost:8008`), and can specify a
`username`:`password` combination when the REST API is
behind a Basic Auth proxy.

```console
usage: sawtooth state list [-h] [--url URL] [-u USERNAME[:PASSWORD]]
                           [-F {csv,json,yaml,default}] [--head HEAD]
                           [subtree]

Lists all state entries in the current blockchain.

positional arguments:
  subtree               address of a subtree to filter the list by

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of the validator's REST API (default:
                        http://localhost:8008)
  -u USERNAME[:PASSWORD], --user USERNAME[:PASSWORD]
                        specify the user to authorize request
  -F {csv,json,yaml,default}, --format {csv,json,yaml,default}
                        choose the output format
  --head HEAD           specify the id of the block to set as the chain head

```

## sawtooth state show

The `sawtooth state show` subcommand queries the Sawtooth REST API for a
specific state entry (address) in the current blockchain state. It
returns the data stored at this state address and the id of the chain
head for which this data is valid. This data is byte-encoded per the
logic of the transaction family that created it, and must be decoded
using that same logic.

This subcommand requires the URL of the REST API (default:
`http://localhost:8008`), and can specify a
`username`:`password` combination when the REST API is
behind a Basic Auth proxy.

```console
usage: sawtooth state show [-h] [--url URL] [-u USERNAME[:PASSWORD]]
                           [--head HEAD]
                           address

Displays information for the specified state address in the current blockchain.

positional arguments:
  address               address of the leaf

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of the validator's REST API (default:
                        http://localhost:8008)
  -u USERNAME[:PASSWORD], --user USERNAME[:PASSWORD]
                        specify the user to authorize request
  --head HEAD           specify the id of the block to set as the chain head
```

## sawtooth status

The `sawtooth status` subcommands display information related to a
validator\'s status.

```console
usage: sawtooth status [-h] {show} ...

Provides a subcommand to show a validator's status

optional arguments:
  -h, --help  show this help message and exit

subcommands:
  {show}
```

## sawtooth status show

The `sawtooth status` subcommand displays information related to a
validator\'s current status, including its public network endpoint and
its peers.

This subcommand requires the URL of the REST API (default:
`http://localhost:8008`), and can specify a
`username`:`password` combination when the REST API is
behind a Basic Auth proxy.

By default, the status is displayed as a CSV string, but other
plain-text formats (JSON, and YAML) are available and can be piped into
a file for further processing.

```console
usage: sawtooth status show [-h] [--url URL] [-u USERNAME[:PASSWORD]]
                            [-F {csv,json,yaml,default}]

Displays information about the status of a validator.

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of the validator's REST API (default:
                        http://localhost:8008)
  -u USERNAME[:PASSWORD], --user USERNAME[:PASSWORD]
                        specify the user to authorize request
  -F {csv,json,yaml,default}, --format {csv,json,yaml,default}
                        choose the output format

```

## sawtooth transaction

The `sawtooth transaction` subcommands display information about the
transactions in the current blockchain.

```console
usage: sawtooth transaction [-h] {list,show} ...

Provides subcommands to display information about the transactions in the
current blockchain.

optional arguments:
  -h, --help   show this help message and exit

subcommands:
  {list,show}
```

## sawtooth transaction list

The `sawtooth transaction list` subcommand queries the Sawtooth REST API
(default: `http://localhost:8008`) for a list of transactions in the
current blockchain. It returns the id of each transaction, its family
and version, the size of its payload, and the data in the payload
itself.

By default, this information is displayed as a white-space delimited
table intended for display, but other plain-text formats (CSV, JSON, and
YAML) are available and can be piped into a file for further processing.

```console
usage: sawtooth transaction list [-h] [--url URL] [-u USERNAME[:PASSWORD]]
                                 [-F {csv,json,yaml,default}]

Lists all transactions in the current blockchain.

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of the validator's REST API (default:
                        http://localhost:8008)
  -u USERNAME[:PASSWORD], --user USERNAME[:PASSWORD]
                        specify the user to authorize request
  -F {csv,json,yaml,default}, --format {csv,json,yaml,default}
                        choose the output format

```

## sawtooth transaction show

The `sawtooth transaction show` subcommand queries the Sawtooth REST API
for a specific transaction in the current blockchain. It returns
complete information for this transaction in either YAML (default) or
JSON format. Use the `--key` option to narrow the returned information
to just the value of a single key, either from the transaction or its
header.

This subcommand requires the URL of the REST API (default:
`http://localhost:8008`), and can specify a
`username`:`password` combination when the REST API is
behind a Basic Auth proxy.

```console
usage: sawtooth transaction show [-h] [--url URL] [-u USERNAME[:PASSWORD]]
                                 [-k KEY] [-F {yaml,json}]
                                 transaction_id

Displays information for the specified transaction.

positional arguments:
  transaction_id        id (header_signature) of the transaction

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of the validator's REST API (default:
                        http://localhost:8008)
  -u USERNAME[:PASSWORD], --user USERNAME[:PASSWORD]
                        specify the user to authorize request
  -k KEY, --key KEY     show a single property from the block or header
  -F {yaml,json}, --format {yaml,json}
                        choose the output format (default: yaml)

```
