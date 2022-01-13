---
title: Generating User and Validator Keys
---

::: note
::: title
Note
:::

These instructions have been tested on Ubuntu 18.04 (Bionic) only.
:::

::: important
::: title
Important
:::

For PBFT, repeat this procedure on the other nodes in the initial
network. When you create the genesis block on the first node, you will
need the validator keys for at least three other nodes.
:::

1.  Generate your user key for Sawtooth.

    ``` console
    $ sawtooth keygen my_key
    writing file: /home/yourname/.sawtooth/keys/my_key.priv
    writing file: /home/yourname/.sawtooth/keys/my_key.pub
    ```

    ::: note
    ::: title
    Note
    :::

    This command specifies `my_key` as the base name for the key files,
    to be consistent with the key name that is used in some example
    Docker and Kubernetes files. By default (when no key name is
    specified), the `sawtooth keygen` command uses your user name.
    :::

2.  Generate the key for the validator, which runs as root.

    ``` console
    $ sudo sawadm keygen
    writing file: /etc/sawtooth/keys/validator.priv
    writing file: /etc/sawtooth/keys/validator.pub
    ```

    ::: note
    ::: title
    Note
    :::

    By default, this command stores the validator key files in
    `/etc/sawtooth/keys/validator.priv` and
    `/etc/sawtooth/keys/validator.pub`. However, settings in the path
    configuration file could change this location; see
    `../sysadmin_guide/configuring_sawtooth/path_configuration_file`{.interpreted-text
    role="doc"}.
    :::

Sawtooth also includes a network key pair that is used to encrypt
communication between the validators in a Sawtooth network. This
off-chain configuration setting is described in a later procedure.

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
