# Sabre CLI Reference

The Sabre CLI provides a way to upload and execute Sabre smart contracts
from the command line. It also provides the ability to manage namespace
registries and their permissions.

## sabre

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

`sabre` is the top level command for Sabre. It contains the following
subcommands: `cr`, `upload`, `ns`, `perm`, and `exec`. The subcommands
have options and arguments that control their behavior. All subcommands
include `-key`, the name of the signing key, and `--url`, the url to the
Sawtooth REST API.

```
sabre-cli 0.5.2
Sawtooth Sabre CLI

USAGE:
    sabre <SUBCOMMAND>

FLAGS:
    -h, --help       Prints help information
    -V, --version    Prints version information

SUBCOMMANDS:
    cr        create, update, or delete a Sabre contract registry
    exec      execute a Sabre contract
    help      Prints this message or the help of the given subcommand(s)
    ns        create, update, or delete a Sabre namespace
    perm      set or delete a Sabre namespace permission
    sp        Create, update or delete smart permissions
    upload    upload a Sabre contract
```

## sabre cr

The `sabre cr` subcommand submits a Sabre transaction that can create,
update or delete a contract registry.

```
sabre-cr
create, update, or delete a Sabre contract registry

USAGE:
    sabre cr [FLAGS] [OPTIONS] <name>

FLAGS:
    -c, --create     Create the contract registry
    -d, --delete     Delete the contract registry
    -h, --help       Prints help information
    -u, --update     Update the contract registry
    -V, --version    Prints version information

OPTIONS:
    -k, --key <key>           Signing key name
    -O, --owner <owner>...    Owner of this contract registry
    -U, --url <url>           URL to the Sawtooth REST API
        --wait <wait>         A time in seconds to wait for batches to be committed

ARGS:
    <name>    Name of the contracts in the registry
```

A contract registry can only be created by an administrator. An
administrator has their public key stored in the setting
`sawtooth.swa.administrators`. At least one `--owner` is required. An
owner is identified by their public key and is allowed to update and
delete contract registries and stored contract versions.

Only an owner or an administrator is allowed to update owners of a
contract registry or delete a contract registry.

## sabre upload

The `sabre upload` subcommand submits a Sabre transaction that adds a
new contract.

```
sabre-upload
upload a Sabre contract

USAGE:
    sabre upload [OPTIONS] --filename <filename>

FLAGS:
    -h, --help       Prints help information
    -V, --version    Prints version information

OPTIONS:
    -f, --filename <filename>    Path to Sabre contract definition (*.yaml)
    -k, --key <key>              Signing key name
        --url <url>              URL to the Sawtooth REST API
        --wait <wait>            A time in seconds to wait for batches to be committed
    -w, --wasm <wasm>            Path to compiled smart contract (*.wasm)
```

The command requires that a path to a contract definition is provided to
`--filename`. The contract definition should be a yaml file with the
following information:

```yaml
name: <contract name>
version: <contract version>
wasm: <path to compiled wasm file>
inputs:
  - <input addresses>
outputs:
  - <output addresses>
```

Only an owner of the associated contract registry is allowed to upload a
new version of a contract.

## sabre ns

The `sabre ns` subcommand submits a Sabre transaction that can create,
update or delete a namespace registry.

```
sabre-ns
create, update, or delete a Sabre namespace

USAGE:
    sabre ns [FLAGS] [OPTIONS] <namespace>

FLAGS:
    -c, --create     Create the namespace
    -d, --delete     Delete the namespace
    -h, --help       Prints help information
    -u, --update     Update the namespace
    -V, --version    Prints version information

OPTIONS:
    -k, --key <key>           Signing key name
    -O, --owner <owner>...    Owner of this namespace
    -U, --url <url>           URL to the Sawtooth REST API
        --wait <wait>         A time in seconds to wait for batches to be committed

ARGS:
    <namespace>    A global state address prefix (namespace)
```

A namespace registry can only be created by an administrator. An
administrator has their public key stored in the setting
`sawtooth.swa.administrators`. At least one `--owner` is required. An
owner is the public key of those whose who are allowed to update and
delete namespaces.

Only an owner or an administrator is allowed to update owners of a
namespace registry or delete a namespace registry.

A namespace must be at least 6 characters long.

## sabre perm

The `sabre perm` subcommand submits a Sabre transaction that can create
or delete a namespace registry permissions.

```
sabre-perm
set or delete a Sabre namespace permission

USAGE:
    sabre perm [FLAGS] [OPTIONS] <namespace> <contract>

FLAGS:
    -d, --delete     Remove all permissions
    -h, --help       Prints help information
    -r, --read       Set read permission
    -V, --version    Prints version information
    -w, --write      Set write permission

OPTIONS:
    -k, --key <key>      Signing key name
    -U, --url <url>      URL to the Sawtooth REST API
        --wait <wait>    A time in seconds to wait for batches to be committed

ARGS:
    <namespace>    A global state address prefix (namespace)
    <contract>     Name of the contract
```

A namespace registry permissions can only be created by an administrator
or an owner of the namespace registry. Include `--read` if the contract
is allowed to read from the namespace and `--write` if the contract is
allowed to write to the namespace.

Using `--delete` will remove all permissions for the provided contract
name. Again a permission can only be deleted by an owner or an
administrator.

## sabre exec

The `sabre exec` subcommand submits a Sabre transaction that execute the
provided payload against an uploaded contract.

```
sabre-exec
execute a Sabre contract

USAGE:
    sabre exec [OPTIONS] --contract <contract> --payload <payload>

FLAGS:
    -h, --help       Prints help information
    -V, --version    Prints version information

OPTIONS:
    -C, --contract <contract>     Name:Version of a Sabre contract
        --inputs <inputs>...      Input addresses used by the contract
    -k, --key <key>               Signing key name
        --outputs <outputs>...    Output addresses used by the contract
    -p, --payload <payload>       Path to Sabre contract payload
        --url <url>               URL to the Sawtooth REST API
        --wait <wait>             A time in seconds to wait for batches to be committed
```

The `--contract` should be \<contract_name:version_number>. The
`--inputs` and `--outputs` should include any namespaces or addresses
that the contract needs to have access to. Finally the `--payload`
should be a path to the file that contains the Sabre contract bytes.

## sabre sp

The `sabre sp` subbcommand submits a Sabre transaction that can create,
update, or delete smart permissions

```
sabre-sp
Create, update or delete smart permissions

USAGE:
    sabre sp [OPTIONS] [SUBCOMMAND]

FLAGS:
    -h, --help       Prints help information
    -V, --version    Prints version information

OPTIONS:
    -U, --url <url>      URL to the Sawtooth REST API
        --wait <wait>    A time in seconds to wait for batches to be committed

SUBCOMMANDS:
    create
    delete
    help      Prints this message or the help of the given subcommand(s)
    update
```

The `--filename` should be the path to a compiled WebAssembly file. The
`--org_id` is the unique identifier for an organization that has been
created and registered with the Pike transaction processor.
