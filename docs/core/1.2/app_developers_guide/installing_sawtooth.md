---
title: Setting Up a Sawtooth Node for Testing
---

Before you can start developing for the *Hyperledger Sawtooth* platform,
you\'ll need to set up a local Sawtooth node to test your application
against. Once the node is running, you will be able to submit new
transactions and fetch the resulting state and block data from the
blockchain using HTTP and the Sawtooth
`REST API <../architecture/rest_api>`{.interpreted-text role="doc"}. The
methods explained in this section apply to the example transaction
processors, *IntegerKey* and *XO*, as well as any transaction processors
you might write yourself.

::: note
::: title
Note
:::

To set up a multiple-node test environment, see
`creating_sawtooth_network`{.interpreted-text role="doc"}.
:::

You can install and run a single-node Sawtooth application development
environment using prebuilt [Docker](https://www.docker.com/) containers,
a [Kubernetes](https://kubernetes.io) cluster inside a virtual machine
on your computer, or a native [Ubuntu](https://www.ubuntu.com/)
installation.

To get started, choose the guide for the platform of your choice.

::: toctree
docker.rst kubernetes.rst ubuntu.rst
:::
