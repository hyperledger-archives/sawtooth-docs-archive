---
title: sawadm
---

The `sawadm` command is used for Sawtooth administration tasks. The
`sawadm` subcommands create validator keys during initial configuration
and help create the genesis block when initializing a validator.

::: literalinclude
output/sawadm_usage.out
:::

# sawadm genesis

The `sawadm genesis` subcommand produces a file for use during the
initialization of a validator. A network requires an initial block
(known as the [genesis block]{.title-ref}) whose signature will
determine the blockchain ID. This initial block is produced from a list
of batches, which will be applied at genesis time.

\<\<\<\<\<\<\< HEAD:docs/core/1.1/cli/sawadm.rst The optional argument
[input_file]{.title-ref} specifies one or more files containing
serialized `BatchList` protobuf messages to add to the genesis data.
(Use a space to separate multiple files.) If no input file is specified,
this command produces an empty genesis block. ======= The
[input_file]{.title-ref} argument specifies one or more files containing
serialized `BatchList` protobuf messages to add to the genesis data.
(Use a space to separate multiple files.) At least one input file must
be specified and it must contain the required settings, unless the
`--ignore-required-settings` argument is used (run
`sawadm genesis --help` for more info). \>\>\>\>\>\>\>
core/1-2:docs/core/1.2/cli/sawadm.rst

The output is a file containing a serialized `GenesisData` protobuf
message. This file, when placed at
[sawtooth_data]{.title-ref}/`genesis.batch`, will trigger the genesis
process.

::: note
::: title
Note
:::

The location of [sawtooth_data]{.title-ref} depends on whether the
environment variable `SAWTOOTH_HOME` is set. If it is, then
[sawtooth_data]{.title-ref} is located at `SAWTOOTH_HOME/data`. If it is
not, then [sawtooth_data]{.title-ref} is located at `/var/lib/sawtooth`.
:::

When `sawadm genesis` runs, it displays the path and filename of the
target file where the serialized `GenesisData` is written. (Default:
[sawtooth_data]{.title-ref}/`genesis.batch`.) For example:

``` console
$ sawadm genesis config.batch mktplace.batch
Generating /var/lib/sawtooth/genesis.batch
```

Use `--output` [filename]{.title-ref} to specify a different name for
the target file.

::: literalinclude
output/sawadm_genesis_usage.out
:::

# sawadm keygen

The `sawadm keygen` subcommand generates keys that the validator uses to
sign blocks. This system-wide key must be created during Sawtooth
configuration.

Validator keys are stored in the directory `/etc/sawtooth/keys/`. By
default, the public-private key files are named `validator.priv` and
validator.pub. Use the \<key-name> argument to specify a different file
name.

::: literalinclude
output/sawadm_keygen_usage.out
:::
