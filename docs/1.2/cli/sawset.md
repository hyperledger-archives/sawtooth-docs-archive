# sawset

The `sawset` command is used to work with settings proposals.

Sawtooth supports storing settings on-chain. The `sawset` subcommands
can be used to view the current proposals, create proposals, vote on
existing proposals, and produce setting values that will be set in the
genesis block.

```console
usage: sawset [-h] [-v] [-V] {genesis,proposal} ...

Provides subcommands to change genesis block settings and to view, create, and
vote on settings proposals.

optional arguments:
  -h, --help          show this help message and exit
  -v, --verbose       enable more verbose output
  -V, --version       display version information

subcommands:
  {genesis,proposal}
    genesis           Creates a genesis batch file of settings transactions
    proposal          Views, creates, or votes on settings change proposals
```

## sawset genesis

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

The `sawset genesis` subcommand creates a Batch of settings proposals
that can be consumed by `sawadm genesis` and used during genesis block
construction.

```console
usage: sawset genesis [-h] [-k KEY] [-o OUTPUT] [-T APPROVAL_THRESHOLD]
                      [-A AUTHORIZED_KEY]

Creates a Batch of settings proposals that can be consumed by "sawadm genesis"
and used during genesis block construction.

optional arguments:
  -h, --help            show this help message and exit
  -k KEY, --key KEY     specify signing key for resulting batches and initial
                        authorized key
  -o OUTPUT, --output OUTPUT
                        specify the output file for the resulting batches
  -T APPROVAL_THRESHOLD, --approval-threshold APPROVAL_THRESHOLD
                        set the number of votes required to enable a setting
                        change
  -A AUTHORIZED_KEY, --authorized-key AUTHORIZED_KEY
                        specify a public key for the user authorized to submit
                        config transactions

```

## sawset proposal

The Settings transaction family supports a simple voting mechanism for
applying changes to on-change settings. The `sawset proposal`
subcommands provide tools to view, create and vote on proposed settings.

```console
usage: sawset proposal [-h] {create,list,vote} ...

Provides subcommands to view, create, or vote on proposed settings

optional arguments:
  -h, --help          show this help message and exit

subcommands:
  {create,list,vote}
    create            Creates proposals for setting changes
    list              Lists the currently proposed (not active) settings
    vote              Votes for specific setting change proposals

```

## sawset proposal create

The `sawset proposal create` subcommand creates proposals for settings
changes. The change may be applied immediately or after a series of
votes, depending on the vote threshold setting.

```console
usage: sawset proposal create [-h] [-k KEY]
                              [-o OUTPUT | --url URL | --sabre-output SABRE_OUTPUT]
                              setting [setting ...]

Create proposals for settings changes. The change may be applied immediately
or after a series of votes, depending on the vote threshold setting.

positional arguments:
  setting               configuration setting as key/value pair with the
                        format <key>=<value>

optional arguments:
  -h, --help            show this help message and exit
  -k KEY, --key KEY     specify a signing key for the resulting batches
  -o OUTPUT, --output OUTPUT
                        specify the output file for the resulting batches
  --url URL             identify the URL of a validator's REST API
  --sabre-output SABRE_OUTPUT
                        specify an output file to write the settings payload
                        to for the sabre cli
```

## sawset proposal list

The `sawset proposal list` subcommand displays the currently proposed
settings that are not yet active. This list of proposals can be used to
find proposals to vote on.

```console
usage: sawset proposal list [-h] [--url URL] [--public-key PUBLIC_KEY]
                            [--filter FILTER]
                            [--format {default,csv,json,yaml}]

Lists the currently proposed (not active) settings. Use this list of proposals
to find proposals to vote on.

optional arguments:
  -h, --help            show this help message and exit
  --url URL             identify the URL of a validator's REST API
  --public-key PUBLIC_KEY
                        filter proposals from a particular public key
  --filter FILTER       filter keys that begin with this value
  --format {default,csv,json,yaml}
                        choose the output format
```

## sawset proposal vote

The `sawset proposal vote` subcommand votes for a specific
settings-change proposal. Use `sawset proposal list` to find the
proposal id.

```console
usage: sawset proposal vote [-h] [--url URL] [-k KEY]
                            proposal_id {accept,reject}

Votes for a specific settings change proposal. Use "sawset proposal list" to
find the proposal id.

positional arguments:
  proposal_id        identify the proposal to vote on
  {accept,reject}    specify the value of the vote

optional arguments:
  -h, --help         show this help message and exit
  --url URL          identify the URL of a validator's REST API
  -k KEY, --key KEY  specify a signing key for the resulting transaction batch

```
