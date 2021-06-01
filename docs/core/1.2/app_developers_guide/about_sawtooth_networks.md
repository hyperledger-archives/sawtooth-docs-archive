---
title: About Sawtooth Networks
---

::: {#about-sawtooth-networks-start_DO-NOT-REMOVE}
In a Sawtooth network, each host system (physical computer, virtual
machine, set of Docker containers, or Kubernetes pod) is a Sawtooth node
that runs one validator, an optional REST API, a consensus engine, and a
set of transaction processors.
:::

The first node creates the `genesis block`{.interpreted-text
role="term"}, which specifies the initial on-chain settings for the
network. The other nodes access those settings when they join the
network.

::: note
::: title
Note
:::

The example environment includes the Sawtooth REST API on all validator
nodes. However, an application could provide a custom REST API (or no
REST API). See [Sawtooth Supply
Chain](https://github.com/hyperledger/sawtooth-supply-chain) for an
example of a custom REST API.

This environment also runs a consensus engine on each node. The
consensus engine could run on a separate system, as long as it is
reachable from the Sawtooth node. This guide does not describe how to
set up a consensus engine on a different system.
:::

A Sawtooth network has the following requirements:

-   Each node must run the same `consensus engine`{.interpreted-text
    role="term"}. The procedures in this guide show you how to configure
    `PBFT <PBFT consensus>`{.interpreted-text role="term"} or
    `PoET <PoET consensus>`{.interpreted-text role="term"} consensus.
    For more information, see
    `/sysadmin_guide/about_dynamic_consensus`{.interpreted-text
    role="doc"}.
-   Each node must run the same set of transaction processors as all
    other nodes in the network.
-   Each node must advertise a routable address. The Docker and
    Kubernetes platforms provide preconfigured settings. For the Ubuntu
    platform, you must configure network settings before starting the
    validator.
-   The authorization type must be the same on all nodes: either `trust`
    (default) or `challenge`. This application development environment
    uses `trust` authorization.
-   The first node on the network must create the
    `genesis block`{.interpreted-text role="term"}, which includes the
    on-chain configuration settings that will be available to the other
    nodes when they join the network.

::: note
::: title
Note
:::

The first Sawtooth node on the network has no special meaning, other
than being the node that created the genesis block. Sawtooth has no
concept of a \"head node\" or \"master node\". Once multiple nodes are
up and running, each node has the same genesis block and treats all
other nodes as peers.
:::

::: {#about-sawtooth-networks-end-NOT-REMOVE}
:::
