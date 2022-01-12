# Setting Up a Sawtooth Node for Testing

Before you can start developing for the *Hyperledger Sawtooth* platform,
you'll need to set up a local Sawtooth node to test your application
against. Once the node is running, you will be able to submit new
transactions and fetch the resulting state and block data from the
blockchain using HTTP and the Sawtooth
[REST API]({% link docs/1.2/rest_api/index.md%}). The
methods explained in this section apply to the example transaction
processors, *IntegerKey* and *XO*, as well as any transaction processors
you might write yourself.

> Note
>
> To set up a multiple-node test environment, see [Creating a Sawtooth
> Network]({% link docs/1.2/app_developers_guide/creating_sawtooth_network.md%})


You can install and run a single-node Sawtooth application development
environment using prebuilt [Docker](https://www.docker.com/) containers,
a [Kubernetes](https://kubernetes.io) cluster inside a virtual machine
on your computer, or a native [Ubuntu](https://www.ubuntu.com/)
installation.

To get started, choose the guide for the platform of your choice.

* [Docker]({% link docs/1.2/app_developers_guide/docker.md%})
* [Kubernetes]({% link docs/1.2/app_developers_guide/kubernetes.md%})
* [Ubuntu]({% link docs/1.2/app_developers_guide/kubernetes.md%})

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
