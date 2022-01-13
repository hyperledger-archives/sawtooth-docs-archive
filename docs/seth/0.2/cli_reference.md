---
title: CLI Reference
---

# Seth Client Usage {#seth-cli-reference-label}

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
-->

## seth {#seth-client-usage}

    Usage:
      seth [OPTIONS] <command>

    Application Options:
      -v, --verbose  Set the log level

    Help Options:
      -h, --help     Show this help message

    Available commands:
      account      Manage seth accounts
      contract     Deploy and execute contracts
      init         Initialize seth to communicate with the given URL
      permissions  Manage permissions of accounts
      show         Show data associated with accounts and transactions

## seth init

    Usage:
      seth [OPTIONS] init [url]

    Application Options:
      -v, --verbose    Set the log level

    Help Options:
      -h, --help       Show this help message

## seth show

    Usage:
      seth [OPTIONS] show <account | events | receipt>

    Application Options:
      -v, --verbose   Set the log level

    Help Options:
      -h, --help      Show this help message

    Available commands:
      account  Show all data associated with a given account
      events   Show events associated with a given transaction ID
      receipt  Show receipt associated with a given transaction ID

## seth account

    Usage:
      seth [OPTIONS] account <create | import | list>

    Application Options:
      -v, --verbose   Set the log level

    Help Options:
      -h, --help      Show this help message

    Available commands:
      create  Create a new externally owned account
      import  Import the private and create an alias for later reference
      list    List all imported accounts as "alias: address"

## seth account import

    Usage:
      seth [OPTIONS] account import [import-OPTIONS] [key-file] [alias]

    Application Options:
      -v, --verbose       Set the log level

    Help Options:
      -h, --help          Show this help message

    [import command options]
          -f, --force     Overwrite key with the same alias if it exists

    [import command arguments]
      key-file:           Path to the file that contains the private key to import
      alias:              Alias to assign the private key

## seth account list

    Usage:
      seth [OPTIONS] account list

    Application Options:
      -v, --verbose   Set the log level

    Help Options:
      -h, --help      Show this help message

## seth account create

    Usage:
      seth [OPTIONS] account create [create-OPTIONS] [alias]

    Application Options:
      -v, --verbose          Set the log level

    Help Options:
      -h, --help             Show this help message

    [create command options]
          -m, --moderator=   Alias of another account to be used to create the
                            account
          -p, --permissions= Permissions for new account; see 'seth permissions -h'
                            for more info
          -n, --nonce=       Current nonce of the moderator account; if not passed,
                            the current value will be retrieved
          -w, --wait=        Number of seconds Seth client will wait for
                            transaction to be committed, if flag passed, default
                            is 60 seconds; if no flag passed, do not wait

    [create command arguments]
      alias:                 Alias of the imported key associated with the account
                            to be created

## seth contract

    Usage:
      seth [OPTIONS] contract <call | create | list>

    Application Options:
      -v, --verbose   Set the log level

    Help Options:
      -h, --help      Show this help message

    Available commands:
      call    Execute a deployed contract account
      create  Deploy a new contract account
      list    List the addresses of all contracts that could have been created based on the current nonce of the account owned by the private key with the given alias. Note that not all addresses may be valid, since the nonce increments whenever a transaction is sent from an account

## seth contract call

    Usage:
      seth [OPTIONS] contract call [call-OPTIONS] [alias] [address] [data]

    Application Options:
      -v, --verbose               Set the log level

    Help Options:
      -h, --help                  Show this help message

    [call command options]
          -g, --gas=              Gas limit for contract creation (default: 90000)
          -n, --nonce=            Current nonce of moderator account
          -w, --wait=             Number of seconds Seth client will wait for
                                  transaction to be committed; if flag passed,
                                  default is 60 seconds; if no flag passed, do not
                                  wait
          -c, --chaining-enabled  If true, enables contract chaining

    [call command arguments]
      alias:                      Alias of the imported key associated with the
                                  contract to be created
      address:                    Address of contract to call
      data:                       Input data to pass to contract when called; must
                                  conform to contract ABI

## seth contract create

    Usage:
      seth [OPTIONS] contract create [create-OPTIONS] [alias] [init]

    Application Options:
      -v, --verbose          Set the log level

    Help Options:
      -h, --help             Show this help message

    [create command options]
          -p, --permissions= Permissions for new account; see 'seth permissions -h'
                            for more info
          -g, --gas=         Gas limit for contract creation (default: 90000)
          -n, --nonce=       Current nonce of the moderator account; if not passed,
                            the current value will be retrieved
          -w, --wait=        Number of seconds Seth client will wait for
                            transaction to be committed; if flag passed, default
                            is 60 seconds; if no flag passed, do not wait

    [create command arguments]
      alias:                 Alias of the imported key associated with the
                            contract to be created
      init:                  Initialization code to be executed on deployment


## seth permissions

    Usage:
      seth [OPTIONS] permissions <set>

    Permissions can be set for individual EVM accounts. If a permission is not set,
    account permissions default to those set at the global permissions address. If
    no permissions are set at the global permissions address, all permissions are
    allowed.

    Supported permissions are:
    * root: Change permissions of accounts
    * send: Transfer value from an owned account to another account
    * call: Execute a deployed contract
    * contract: Deploy new contracts from an owned account
    * account: Create new externally owned accounts

    When a new account is created, its permissions are inherited from the creating
    account according to the following rules:
    - If the account is a new external account, its permissions are inherited from
    the global permissions address. If no permissions are set at the global
    permissions address, all permissions are enabled for the new account.
    - If the account is a new contract account, its permissions are inherited from
    the creating account, with the exception of the "root" permission, which is set
    to deny.

    To specify permissions on the command line, use a comma-separated list of
    "prefixed" permissions from the list above. Permissions must be prefixed with a
    plus ("+") or minus ("-") to indicated allowed and not allowed respectively.
    Permissions that are omitted from the list will be left unset and default to
    those set at the global permissions address.

    "all" may be used as a special keyword to refer to all permissions. Duplicates
    are allowed and items that come later in the list override earlier items.

    Examples:

    -all,+contract,+call      Disable all permissions except contract creation or
    calling
    +account,+send,-contract  Enable account creation and sending value; Disable
    contract creation
    +all,-root                Enable all permissions except setting permissions

    Application Options:
      -v, --verbose   Set the log level

    Help Options:
      -h, --help      Show this help message

    Available commands:
      set  Change the permissions of accounts

## seth permissions set

    Usage:
      seth [OPTIONS] permissions set [set-OPTIONS] [moderator]

    See 'seth permissions -h' for more info.

    Application Options:
      -v, --verbose          Set the log level

    Help Options:
      -h, --help             Show this help message

    [set command options]
          -a, --address=     Address of account whose permissions are being
                            changed; 'global' may be used to refer to the zero
                            address
          -p, --permissions= New permissions for the account
          -n, --nonce=       Current nonce of the moderator account; If not passed,
                            the current value will be retrieved
          -w, --wait=        Number of seconds Seth client will wait for
                            transaction to be committed; If flag passed, default
                            is 60 seconds; If no flag passed, do not wait

    [set command arguments]
      moderator:             Alias of key to be used for modifying permissions

# Seth Transaction Processor Usage {#seth-tp-reference-label}

## seth-tp

    Usage:
      seth-tp [OPTIONS]

    Application Options:
      -v, --verbose  Increase verbosity
      -C, --connect= Validator component endpoint to connect to (default:
                    tcp://localhost:4004)

    Help Options:
      -h, --help     Show this help message

# Seth RPC Usage {#seth-rpc-reference-label}

## seth-rpc

    seth-rpc 0.2.4
    Seth RPC Server

    USAGE:
        seth-rpc [FLAGS] [OPTIONS]

    FLAGS:
        -h, --help       Prints help information
        -V, --version    Prints version information
        -v               Increase the logging level.

    OPTIONS:
            --bind <bind>           The host and port the RPC server should bind to.
            --connect <connect>     Component endpoint of the validator to communicate with.
            --unlock <unlock>...    The aliases of the accounts to unlock.
