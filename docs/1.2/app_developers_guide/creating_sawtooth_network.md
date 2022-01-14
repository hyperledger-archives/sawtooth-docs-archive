# Creating a Sawtooth Test Network

This section describes how to create a Sawtooth network for an
application development environment. Each node is similar to the
single-node environment described earlier in this guide in [Installing
Sawtooth]({% link docs/1.2/app_developers_guide/installing_sawtooth.md %}),
but the network uses a consensus algorithm that is
appropriate for a Sawtooth network (instead of Devmode consensus). For
more information, see [About Sawtooth Networks](#about-sawtooth-networks)

> **Note**
>
> For a single-node test environment, see
> [Installing
> Sawtooth]({% link docs/1.2/app_developers_guide/installing_sawtooth.md %})

Use the procedures in this section to create a Sawtooth test network
using prebuilt [Docker](https://www.docker.com/) containers, a
[Kubernetes](https://kubernetes.io) cluster inside a virtual machine on
your computer, or a native [Ubuntu](https://www.ubuntu.com/)
installation.

To get started, read [About Sawtooth
Networks](#about-sawtooth-networks),
then choose the guide for the platform of your choice.

##  About Sawtooth Networks

In a Sawtooth network, each host system (physical computer, virtual
machine, set of Docker containers, or Kubernetes pod) is a Sawtooth node
that runs one validator, an optional REST API, a consensus engine, and a
set of transaction processors.

The first node creates the genesis block, which specifies the initial on-chain
settings for the network. The other nodes access those settings when they join
the network.

> **Note**
>
> The example environment includes the Sawtooth REST API on all validator
> nodes. However, an application could provide a custom REST API (or no
> REST API). See [Sawtooth Supply
> Chain](https://github.com/hyperledger/sawtooth-supply-chain) for an
> example of a custom REST API.
>
> This environment also runs a consensus engine on each node. The
> consensus engine could run on a separate system, as long as it is
> reachable from the Sawtooth node. This guide does not describe how to
> set up a consensus engine on a different system.

A Sawtooth network has the following requirements:

-   Each node must run the same consensus engine.
    The procedures in this guide show you how to configure
    PBFT or PoET consensus. For more information, see [About Dynamic
    Consensus]({% link docs/1.2/sysadmin_guide/about_dynamic_consensus.md%}).
-   Each node must run the same set of transaction processors as all
    other nodes in the network.
-   Each node must advertise a routable address. The Docker and
    Kubernetes platforms provide preconfigured settings. For the Ubuntu
    platform, you must configure network settings before starting the
    validator.
-   The authorization type must be the same on all nodes: either `trust`
    (default) or `challenge`. This application development environment
    uses `trust` authorization.
-   The first node on the network must create the genesis block, which includes
    the on-chain configuration settings that will be available to the other
    nodes when they join the network.

> **Note**
>
> The first Sawtooth node on the network has no special meaning, other
> than being the node that created the genesis block. Sawtooth has no
> concept of a \"head node\" or \"master node\". Once multiple nodes are
> up and running, each node has the same genesis block and treats all
> other nodes as peers.

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

* [Docker Test
Network]({% link docs/1.2/app_developers_guide/docker_test_network.md %})
* [Kubernetes Test
 Network]({% link docs/1.2/app_developers_guide/kubernetes_test_network.md %})
* [Ubuntu Test
Network]({% link docs/1.2/app_developers_guide/ubuntu_test_network.md %})

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
