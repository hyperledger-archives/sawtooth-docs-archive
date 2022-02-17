# System Administrator\'s Guide

This guide explains how to install, configure, and run Hyperledger
Sawtooth on a Ubuntu system for proof-of-concept or production use in a
Sawtooth network.

-   See `sysadmin_guide/setting_up_sawtooth_network`{.interpreted-text
    role="doc"} to configure and run a Sawtooth node with either
    `PBFT <PBFT consensus>`{.interpreted-text role="term"} or
    `PoET simulator consensus <PoET consensus>`{.interpreted-text
    role="term"}.
-   See `sysadmin_guide/configure_sgx`{.interpreted-text role="doc"} to
    configure and run a Sawtooth node with PoET consensus on a system
    with Intel ® Software Guard Extensions (SGX).

This guide also includes optional administration procedures, such as how
to
`restrict transaction types <sysadmin_guide/setting_allowed_txns>`{.interpreted-text
role="doc"}; `configure user, client, and validator permissions
<sysadmin_guide/configuring_permissions>`{.interpreted-text role="doc"};
and
`display Sawtooth metrics with Grafana <sysadmin_guide/grafana_configuration>`{.interpreted-text
role="doc"}.

Other sections in this guide summarize
`dynamic consensus settings <sysadmin_guide/about_dynamic_consensus>`{.interpreted-text
role="doc"} and explain how to
`use Sawtooth configuration files <sysadmin_guide/configuring_sawtooth>`{.interpreted-text
role="doc"}.

::: toctree
sysadmin_guide/setting_up_sawtooth_network sysadmin_guide/configure_sgx
sysadmin_guide/setting_allowed_txns
sysadmin_guide/adding_authorized_users sysadmin_guide/rest_auth_proxy
sysadmin_guide/configuring_permissions
sysadmin_guide/grafana_configuration
sysadmin_guide/about_dynamic_consensus
sysadmin_guide/pbft_adding_removing_node.rst
sysadmin_guide/configuring_sawtooth
:::

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
