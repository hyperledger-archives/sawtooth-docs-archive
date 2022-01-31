# sawadm

The `sawadm` command is used for Sawtooth administration tasks. The
`sawadm` subcommands create validator keys during initial configuration
and help create the genesis block when initializing a validator.

``` console
usage: sawadm [-h] [-v] [-V] {genesis,keygen} ...

Provides subcommands to create validator keys and create the genesis block

optional arguments:
  -h, --help        show this help message and exit
  -v, --verbose     enable more verbose output
  -V, --version     display version information

subcommands:
  {genesis,keygen}
    genesis         Creates the genesis.batch file for initializing the
                    validator
    keygen          Generates keys for the validator to use when signing
                    blocks
```

## sawadm genesis

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

The `sawadm genesis` subcommand produces a file for use during the
initialization of a validator. A network requires an initial block
(known as the `genesis block`) whose signature will
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
`sawtooth_data`/`genesis.batch`, will trigger the genesis
process.

> **Note**
>
> The location of `sawtooth_data` depends on whether the
> environment variable `SAWTOOTH_HOME` is set. If it is, then
> `sawtooth_data` is located at `SAWTOOTH_HOME/data`. If it is
> not, then `sawtooth_data` is located at `/var/lib/sawtooth`.

When `sawadm genesis` runs, it displays the path and filename of the
target file where the serialized `GenesisData` is written. (Default:
`sawtooth_data`/`genesis.batch`.) For example:

``` console
$ sawadm genesis config.batch mktplace.batch
Generating /var/lib/sawtooth/genesis.batch
```

Use `--output` `filename` to specify a different name for
the target file.

``` console
usage: sawadm genesis [-h] [-v] [-V] [-o OUTPUT] [--ignore-required-settings]
                      [input_file [input_file ...]]

Generates the genesis.batch file for initializing the validator.

positional arguments:
  input_file            file or files containing batches to add to the
                        resulting GenesisData

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         enable more verbose output
  -V, --version         display version information
  -o OUTPUT, --output OUTPUT
                        choose the output file for GenesisData
  --ignore-required-settings
                        skip the check for settings that are required at
                        genesis (necessary if using a settings transaction
                        family other than sawtooth_settings)

This command generates a serialized GenesisData protobuf message and stores it
in the genesis.batch file. One or more input files contain serialized
BatchList protobuf messages to add to the GenesisData. The output shows the
location of this file. By default, the genesis.batch file is stored in
/var/lib/sawtooth. If $SAWTOOTH_HOME is set, the location is

SAWTOOTH_HOME/data/genesis.batch. Use the --output option to change the name
of the file. The following settings must be present in the input batches:
['sawtooth.consensus.algorithm.name', 'sawtooth.consensus.algorithm.version']
```

## sawadm keygen

The `sawadm keygen` subcommand generates keys that the validator uses to
sign blocks. This system-wide key must be created during Sawtooth
configuration.

Validator keys are stored in the directory `/etc/sawtooth/keys/`. By
default, the public-private key files are named `validator.priv` and
validator.pub. Use the \<key-name> argument to specify a different file
name.

``` console
usage: sawadm keygen [-h] [-v] [-V] [--force] [-q] [key_name]

Generates keys for the validator to use when signing blocks.

positional arguments:
  key_name       name of the key to create

optional arguments:
  -h, --help     show this help message and exit
  -v, --verbose  enable more verbose output
  -V, --version  display version information
  --force        overwrite files if they exist
  -q, --quiet    do not display output

The private and public key pair is stored in /etc/sawtooth/keys/<key-
name>.priv and /etc/sawtooth/keys/<key-name>.pub.

```
