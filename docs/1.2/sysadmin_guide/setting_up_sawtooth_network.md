---
title: Setting Up a Sawtooth Network
---

In this section, you will configure a network of Sawtooth nodes with
either Sawtooth PBFT consensus or PoET simulator consensus.

-   `Sawtooth PBFT consensus <PBFT consensus>`{.interpreted-text
    role="term"} provides Byzantine fault tolerance for a network with
    restricted membership. PBFT requires at least four nodes.
-   `PoET simulator consensus <PoET consensus>`{.interpreted-text
    role="term"} is designed for a system without a Trusted Execution
    Environment (TEE). Sawtooth PoET requires a minimum of three nodes,
    but works best with at least four or five nodes.

For more information on the supported consensus types, or to learn how
to change the consensus later, see
`about_dynamic_consensus`{.interpreted-text role="doc"}.

> ::: note
> ::: title
> Note
> :::
>
> For the procedure to configure Sawtooth with PoET SGX consensus on a
> system with Intel ® Software Guard Extensions (SGX), see
> `configure_sgx`{.interpreted-text role="doc"}.
> :::

Use this set of procedures to create the first Sawtooth node in a
network or to add a new node to an existing network. Note that some
procedures are performed only on the first node. Other procedures are
required on the minimum set of nodes in the initial network.

Each node in this Sawtooth network runs a validator, a REST API, and the
following transaction processors:

-   `Settings <../transaction_family_specifications/settings_transaction_family>`{.interpreted-text
    role="doc"} (`settings-tp`)
-   `Identity <../transaction_family_specifications/identity_transaction_family>`{.interpreted-text
    role="doc"} (`identity-tp`)
-   `IntegerKey <../transaction_family_specifications/integerkey_transaction_family>`{.interpreted-text
    role="doc"} (`intkey-tp-python`) \-- optional, but used to test
    basic Sawtooth functionality
-   (PoET only)
    `PoET Validator Registry <../transaction_family_specifications/validator_registry_transaction_family>`{.interpreted-text
    role="doc"} (`poet-validator-registry-tp`)

::: important
::: title
Important
:::

Each node in a Sawtooth network must run the same set of transaction
processors. If this node will join an existing Sawtooth network, make
sure that you know the full list of required transaction processors, and
that you install any custom transaction processors.
:::

::: toctree
installation.rst generating_keys.rst creating_genesis_block.rst
off_chain_settings.rst systemd.rst testing_sawtooth.rst
pbft_updating_member_list.rst
:::

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
