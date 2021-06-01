---
title: Creating a Sawtooth Test Network
---

This section describes how to create a Sawtooth network for an
application development environment. Each node is similar to the
single-node environment described
`earlier in this guide <installing_sawtooth>`{.interpreted-text
role="doc"}, but the network uses a consensus algorithm that is
appropriate for a Sawtooth network (instead of Devmode consensus). For
more information, see `about_sawtooth_networks`{.interpreted-text
role="doc"}.

::: note
::: title
Note
:::

For a single-node test environment, see
`installing_sawtooth`{.interpreted-text role="doc"}.
:::

Use the procedures in this section to create a Sawtooth test network
using prebuilt [Docker](https://www.docker.com/) containers, a
[Kubernetes](https://kubernetes.io) cluster inside a virtual machine on
your computer, or a native [Ubuntu](https://www.ubuntu.com/)
installation.

To get started, read `about_sawtooth_networks`{.interpreted-text
role="doc"}, then choose the guide for the platform of your choice.

::: toctree
about_sawtooth_networks docker_test_network kubernetes_test_network
ubuntu_test_network
:::
