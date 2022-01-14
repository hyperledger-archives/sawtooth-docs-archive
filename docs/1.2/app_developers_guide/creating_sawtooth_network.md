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

## Using Docker for a Sawtooth Test Network

This procedure describes how to use Docker to create a network of five
Sawtooth nodes for an application development environment. Each node is
a set of Docker containers that runs a validator and related Sawtooth
components.

> **Note**
>
> For a single-node environment, see [Installing
> Sawtooth]({% link docs/1.2/app_developers_guide/installing_sawtooth.md %}#docker)

This procedure guides you through the following tasks:

> -   Downloading the Sawtooth Docker Compose file
> -   Starting the Sawtooth network with docker-compose
> -   Checking process status
> -   Configuring the allowed transaction types (optional)
> -   Connecting to the Sawtooth shell container and confirming network
>     functionality
> -   Stopping Sawtooth and resetting the Docker environment

# About the Docker Sawtooth Network Environment {#about-sawtooth-nw-env-docker-label}

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

This test environment is a network of five Sawtooth nodes.

<img alt="Appdev Environment Multi-Node" src="/images/1.2/appdev-environment-multi-node.svg">

Each node in this Sawtooth network runs a validator, a REST API, a consensus
engine, and the following transaction processors:

-   [Settings]({%link docs/1.2/transaction_family_specifications/settings_transaction_family.md%}) (`settings-tp`): Handles Sawtooth\'s on-chain
    configuration settings. The Settings transaction processor (or an
    equivalent) is required for all Sawtooth networks.
-   [IntegerKey]({%link docs/1.2/transaction_family_specifications/integerkey_transaction_family.md%}) (`intkey-tp-python`): Demonstrates basic
    Sawtooth functionality. The associated `intkey` client includes shell
    commands to perform integer-based transactions.
-   [XO]({%link docs/1.2/transaction_family_specifications/xo_transaction_family.md%}) (`sawtooth-xo-tp-python`): Simple application for playing
    a game of tic-tac-toe on the blockchain. The associated `xo` client
    provides shell commands to define players and play a game. XO is
    described in a later section,
    [Intro XO Transaction
    Family]({%link docs/1.2/app_developers_guide/intro_xo_transaction_family.md%})
-   (PoET only)
    [PoET Validator Registry]{%link docs/1.2/transaction_family_specifications/validator_registry_transaction_family.md%})
     (`poet-validator-registry-tp`): Configures PoET consensus and handles a
     network with multiple nodes.


> **Important**
>
> Each node in a Sawtooth network must run the same set of transaction
> processors.

Like the [single-node test environment
docker]({% link docs/1.2/app_developers_guide/installing_sawtooth.md %}#docker),
this environment uses parallel transaction processing and
static peering. However, it uses a different consensus algorithm
(Devmode consensus is not recommended for a network). You can choose
either PBFT or PoET consensus.

-   PBFT consensus provides a voting-based consensus algorithm with Byzantine
    fault tolerance (BFT) that has finality (does not fork).

-   PoET consensus provides a leader-election lottery system that can fork. This
    network uses PoET simulator consensus, which is also called PoET CFT]
    because it is crash fault tolerant.


    > **Note**
    >
    > The other type of PoET consensus, PoET-SGX, relies on Intel Software
    > Guard Extensions (SGX) that is Byzantine fault tolerant (BFT). PoET
    > CFT provides the same consensus algorithm on an SGX simulator.

The first node creates the genesis block, which specifies
the on-chain settings for the network configuration. The other nodes
access those settings when they join the network.

### Prerequisites {#prereqs-multi-docker-label}

-   This application development environment requires Docker Engine and
    Docker Compose.
    -   Windows: Install the latest version of [Docker Engine for
        Windows](https://docs.docker.com/docker-for-windows/install/)
        (also installs Docker Compose).
    -   macOS: Install the latest version of [Docker Engine for
        macOS](https://docs.docker.com/docker-for-mac/install/) (also
        installs Docker Compose).
    -   Linux: Install the latest versions of [Docker
        Engine](https://docs.docker.com/engine/installation/linux/ubuntu)
        and [Docker
        Compose](https://docs.docker.com/compose/install/#install-compose).
        Then follow [Post-Install
        steps](https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user).
-   If you created a
    [single-node Docker environment docker]({% link docs/1.2/app_developers_guide/installing_sawtooth.md %}#docker),
    that is still running, shut it down and delete the
    existing blockchain data and logs. For more information, see [Stop the
    Sawtooth Docker Environment]({% link docs/1.2/app_developers_guide/installing_sawtooth.md %}#stop-the-sawtooth-docker-environment)

### Step 1: Download the Docker Compose File

Download the Docker Compose file for a multiple-node network.

-   For PBFT, download
    [sawtooth-default-pbft.yaml](https://github.com/hyperledger/sawtooth-core/blob/main/docker/compose/sawtooth-default-pbft.yaml)
-   For PoET, download
    [sawtooth-default-poet.yaml](https://github.com/hyperledger/sawtooth-core/blob/main/docker/compose/sawtooth-default-poet.yaml)

### Step 2: Start the Sawtooth Network

> **Note**
>
> The Docker Compose file for Sawtooth handles environment setup steps
> such as generating keys and creating a genesis block. To learn how the
> typical network startup process works, see [Using Ubuntu for a
> Sawtooth Test Network](#using-ubuntu-for-a-sawtooth-test-network)

1.  Open a terminal window.

2.  Change to the directory where you saved the Docker Compose file.

3.  Start the Sawtooth network.

    -   For PBFT:

        ``` console
        user@host$ docker-compose -f sawtooth-default-pbft.yaml up
        ```

    -   For PoET:

        ``` console
        user@host$ docker-compose -f sawtooth-default-poet.yaml up
        ```

4.  This Compose file creates five Sawtooth nodes named `validator-#`
    (numbered from 0 to 4). Note the container names for the Sawtooth
    components on each node:

    `validator-0`:

    > -   `sawtooth-validator-default-0`
    > -   `sawtooth-rest-api-default-0`
    > -   `sawtooth-pbft-engine-default-0` or `sawtooth-poet-engine-0`
    > -   `sawtooth-settings-tp-default-0`
    > -   `sawtooth-intkey-tp-python-default-0`
    > -   `sawtooth-xo-tp-python-default-0`
    > -   (PoET only) `sawtooth-poet-validator-registry-tp-0`

    `validator-1`:

    > -   `sawtooth-validator-default-1`
    > -   `sawtooth-rest-api-default-1`
    > -   `sawtooth-pbft-engine-default-1` or `sawtooth-poet-engine-1`
    > -   `sawtooth-settings-tp-default-1`
    > -   `sawtooth-intkey-tp-python-default-1`
    > -   `sawtooth-xo-tp-python-default-1`
    > -   (PoET only) `sawtooth-poet-validator-registry-tp-1`

    \... and so on.

5.  Note that there is only one shell container for this Docker
    environment:

    > -   `sawtooth-shell-default`

### Step 3: Check the REST API Process

Use these commands on one or more nodes to confirm that the REST API is
running.

1.  Connect to the REST API container on a node, such as
    `sawtooth-poet-rest-api-default-0`.

    ``` console
    user@host$ docker exec -it sawtooth-rest-api-default-0 bash
    root@b1adcfe0#
    ```

2.  Use the following command to verify that this component is running.

    ``` console
    root@b1adcfe0# ps --pid 1 fw
    PID TTY      STAT   TIME COMMAND
      1 ?        Ssl    0:00 /usr/bin/python3 /usr/bin/sawtooth-rest-api
      --connect tcp://validator-0:4004 --bind rest-api-0:8008
    ```

### Step 4: Confirm Network Functionality {#confirm-nw-funct-docker-label}

1.  Connect to the shell container.

    > ``` console
    > user@host$ docker exec -it sawtooth-shell-default bash
    > root@0e0fdc1ab#
    > ```

2.  To check whether peering has occurred on the network, submit a peers
    query to the REST API on the first node. This command specifies the
    container name and port for the first node\'s REST API.

    > ``` console
    > root@0e0fdc1ab# curl http://sawtooth-rest-api-default-0:8008/peers
    > ```

    If this query returns a 503 error, the nodes have not yet peered
    with the Sawtooth network. Repeat the query until you see output
    that resembles the following example:

    > ``` console
    > {
    >   "data": [
    >     "tcp://validator-4:8800",
    >     "tcp://validator-3:8800",
    >     ...
    >     "tcp://validator-2:8800",
    >     "tcp://validator-1:8800"
    >   ],
    >   "link": "http://sawtooth-rest-api-default-0:8008/peers"
    > ```

3.  (Optional) You can run the following Sawtooth commands to show the
    other nodes on the network.

    a.  Run `sawtooth peer list` to show the peers of a particular node.
        For example, the following command specifies the REST API on the
        first node, so it displays the first node\'s peers.

        ``` console
        root@0e0fdc1ab# sawtooth peer list --url http://sawtooth-rest-api-default-0:8008
        tcp://validator-1:8800,tcp://validator-1:8800,tcp://validator-2:8800,tcp://validator-3:8800
        ```

    b.  Run `sawnet peers list` to display a complete graph of peers on
        the network (available in Sawtooth release 1.1 and later).

        ``` console
        root@0e0fdc1ab# sawnet peers list http://sawtooth-rest-api-default-0:8008
        {
        "tcp://validator-0:8800": [
        "tcp://validator-1:8800",
        "tcp://validator-1:8800",
        "tcp://validator-2:8800",
        "tcp://validator-3:8800"
        ]
        }
        ```

4.  Submit a transaction to the REST API on the first node. This example
    sets a key named `MyKey` to the value 999.

    > ``` console
    > root@0e0fdc1ab# intkey set --url http://sawtooth-rest-api-default-0:8008 MyKey 999
    > ```
    >
    > The output should resemble this example:
    >
    > ``` console
    > {
    >   "link": "http://sawtooth-rest-api-default-0:8008/batch_statuses?id=dacefc7c9fe2c8510803f8340...
    > }
    > ```

5.  Watch for this transaction to appear on a different node. The
    following command requests the value of `MyKey` from the REST API on
    the second node.

    You can run this command from the first node\'s shell container by
    specifying the URL of the other node\'s REST API, as in this
    example.

    > ``` console
    > root@0e0fdc1ab# intkey show --url http://sawtooth-rest-api-default-1:8008 MyKey
    > ```
    >
    > The output should show the key name and current value:
    >
    > ``` console
    > MyKey: 999
    > ```

### Step 5. Configure the Allowed Transaction Types (Optional) {#configure-txn-procs-docker-label}

By default, a validator accepts transactions from any transaction
processor. However, Sawtooth allows you to limit the types of
transactions that can be submitted.

In this step, you will configure the Sawtooth network to accept
transactions only from the transaction processors running in the example
environment. Transaction-type restrictions are an on-chain setting, so
this configuration change is made on one node, then applied to all other
nodes.

The [Settings transaction processor]({%link docs/1.2/transaction_family_specifications/settings_transaction_family.md%})
handles on-chain configuration settings. You will use the
`sawset` command to create and submit a batch of transactions containing
the configuration change.


> Important
>
> You **must** run this procedure from the first validator container,
> because the example Docker Compose file uses the first validator\'s key
> to create and sign the genesis block. (At this point, only the key used
> to create the genesis block can change on-chain settings.) For more
> information, see [Add Authorized
> Users]({% link docs/1.2/sysadmin_guide/adding_authorized_users.md%})

1.  Connect to the first validator container
    (`sawtooth-validator-default-0`). The next command requires the
    validator key that was generated in that container.

    ``` console
    user@host$ docker exec -it sawtooth-validator-default-0 bash
    root@c0c0ab33#
    ```

2.  Run the following command from the validator container to specify
    the allowed transaction families.

    -   For PBFT:

        ``` console
        root@c0c0ab33# sawset proposal create --url http://sawtooth-rest-api-default-0:8008 --key /etc/sawtooth/keys/validator.priv \
        sawtooth.validator.transaction_families='[{"family": "intkey", "version": "1.0"}, {"family":"sawtooth_settings", "version":"1.0"}, {"family":"xo", "version":"1.0"}]'
        ```

    -   For PoET:

        ``` console
        root@c0c0ab33# sawset proposal create --url http://sawtooth-rest-api-default-0:8008 --key /etc/sawtooth/keys/validator.priv \
        sawtooth.validator.transaction_families='[{"family": "intkey", "version": "1.0"}, {"family":"sawtooth_settings", "version":"1.0"}, {"family":"xo", "version":"1.0"}, {"family":"sawtooth_validator_registry", "version":"1.0"}]'
        ```

    This command sets `sawtooth.validator.transaction_families` to a
    JSON array that specifies the family name and version of each
    allowed transaction processor (defined in the transaction header of
    each family\'s [transaction family
    specification]({%link docs/1.2/transaction_family_specifications/index.md%})).

3.  After this command runs, a `TP_PROCESS_REQUEST` message appears in
    the docker-compose output.

    ``` console
    .
    .
    .
    sawtooth-settings-tp-default-0  | INFO  | settings_tp::handler | Setting "sawtooth.validator.transaction_families" changed to "[{\"family\": \"intkey\", \"version\": \"1.0\"}, {\"family\":\"sawtooth_settings\", \"version\":\"1.0\"}, {\"family\":\"xo\", \"version\":\"1.0\"}, {\"family\":\"sawtooth_validator_registry\", \"version\":\"1.0\"}]"
    sawtooth-settings-tp-default-0  | INFO  | sawtooth_sdk::proces | TP_PROCESS_REQUEST sending TpProcessResponse: OK
    ```

4.  Run the following command to check the setting change on the shell
    container or any validator container. You can specify any REST API
    on the network; this example uses the REST API on the first node.

    ``` console
    root@0e0fdc1ab# sawtooth settings list --url http://sawtooth-rest-api-default-0:8008
    ```

    The output should be similar to this example:

    ``` console
    sawtooth.consensus.algorithm.name: {name}
    sawtooth.consensus.algorithm.version: {version}
    ...
    sawtooth.publisher.max_batches_per_block=1200
    sawtooth.settings.vote.authorized_keys: 0242fcde86373d0aa376...
    sawtooth.validator.transaction_families: [{"family": "intkey...
    ```

### Step 6: Stop the Sawtooth Network (Optional)

Use this procedure to stop or reset the multiple-node Sawtooth
environment.

1.  Exit from all open containers (such as the shell, REST-API,
    validator, and settings containers used in this procedure).
2.  Enter CTRL-c in the window where you ran `docker-compose up`.
3.  After all containers have shut down, you can reset the environment
    (remove all containers and data) with the following command:
    -   For PBFT:

        ``` console
        user@host$ docker-compose -f sawtooth-default-pbft.yaml down
        ```

    -   For PoET:

        ``` console
        user@host$ docker-compose -f sawtooth-default-poet.yaml down
        ```

---
title: Using Kubernetes for a Sawtooth Test Network
---

This procedure describes how to use [Kubernetes](https://kubernetes.io/)
to create a network of five Sawtooth nodes for an application
development environment. Each node is a Kubernetes pod containing a set
of containers for a validator and related Sawtooth components.

::: note
::: title
Note
:::

For a single-node environment, see
`installing_sawtooth`{.interpreted-text role="doc"}.
:::

This procedure guides you through the following tasks:

> -   Installing `kubectl` and `minikube`
> -   Starting Minikube
> -   Downloading the Sawtooth configuration file
> -   Starting Sawtooth in a Kubernetes cluster
> -   Connecting to the Sawtooth shell containers
> -   Confirming network and blockchain functionality
> -   Configuring the allowed transaction types (optional)
> -   Stopping Sawtooth and deleting the Kubernetes cluster

# About the Kubernetes Sawtooth Network Environment

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

This test environment is a network of five Sawtooth nodes. This
environment uses [Minikube](https://kubernetes.io/docs/setup/minikube/)
to deploy Sawtooth as a containerized application in a local Kubernetes
cluster inside a virtual machine (VM) on your computer.

The Kubernetes cluster has a pod for each Sawtooth node. On each pod,
there are containers for each Sawtooth component. The Sawtooth nodes are
connected in an all-to-all peering relationship.

![](../images/appdev-environment-multi-node-kube.*){.align-center
width="100.0%"}

Each node in this Sawtooth network runs a `validator`{.interpreted-text
role="term"}, a `REST API`{.interpreted-text role="term"}, a consensus
engine, and the following
`transaction processors<transaction processor>`{.interpreted-text
role="term"}:

-   `Settings <../transaction_family_specifications/settings_transaction_family>`{.interpreted-text
    role="doc"} (`settings-tp`): Handles Sawtooth\'s on-chain
    configuration settings. The Settings transaction processor (or an
    equivalent) is required for all Sawtooth networks.
-   `IntegerKey <../transaction_family_specifications/integerkey_transaction_family>`{.interpreted-text
    role="doc"} (`intkey-tp-python`): Demonstrates basic Sawtooth
    functionality. The associated `intkey` client includes shell
    commands to perform integer-based transactions.
-   `XO <../transaction_family_specifications/xo_transaction_family>`{.interpreted-text
    role="doc"} (`sawtooth-xo-tp-python`: Simple application for playing
    a game of tic-tac-toe on the blockchain. The assocated `xo` client
    provides shell commands to define players and play a game. XO is
    described in a later section,
    `intro_xo_transaction_family`{.interpreted-text role="doc"}.
-   (PoET only)
    `PoET Validator Registry <../transaction_family_specifications/validator_registry_transaction_family>`{.interpreted-text
    role="doc"} (`poet-validator-registry-tp`): Configures PoET
    consensus and handles a network with multiple nodes.

::: important
::: title
Important
:::

Each node in a Sawtooth network must run the same set of transaction
processors.
:::

Like the `single-node test environment <kubernetes>`{.interpreted-text
role="doc"}, this environment uses parallel transaction processing and
static peering. However, it uses a different consensus algorithm
(Devmode consensus is not recommended for a network). You can choose
either PBFT or PoET consensus.

-   `PBFT consensus`{.interpreted-text role="term"} provides a
    voting-based consensus algorithm with Byzantine fault tolerance
    (BFT) that has finality (does not fork).

-   `PoET consensus`{.interpreted-text role="term"} provides a
    leader-election lottery system that can fork. This network uses PoET
    simulator consensus, which is also called [PoET CFT]{.title-ref}
    because it is crash fault tolerant.

    ::: note
    ::: title
    Note
    :::

    The other type of PoET consensus, PoET-SGX, relies on Intel Software
    Guard Extensions (SGX) that is Byzantine fault tolerant (BFT). PoET
    CFT provides the same consensus algorithm on an SGX simulator.
    :::

The first node creates the genesis block, which specifies the initial
on-chain settings for the network configuration. The other nodes access
those settings when they join the network.

# Prerequisites

-   This environment requires
    [kubectl](https://kubernetes.io/docs/concepts/) and
    [minikube](https://kubernetes.io/docs/setup/minikube/) with a
    supported VM hypervisor, such as
    [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
-   If you created a
    `single-node Kubernetes environment <kubernetes>`{.interpreted-text
    role="doc"} that is still running, shut it down and delete the
    Minikube cluster, VM, and associated files. For more information,
    see `stop-sawtooth-kube-label`{.interpreted-text role="ref"}.

# Step 1: Install kubectl and minikube

This step summarizes the Kubernetes installation procedures. For more
information, see the [Kubernetes
documentation](https://kubernetes.io/docs/tasks/).

1.  Install a virtual machine (VM) hypervisor such as VirtualBox,
    VMWare, KVM-QEMU, or Hyperkit. This procedure assumes that you\'re
    using VirtualBox.
2.  Install the `kubectl` command as described in the Kubernetes
    document [Install
    kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
    -   Linux quick reference:

        ``` none
        $ curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
        && chmod +x kubectl && sudo cp kubectl /usr/local/bin/ && rm kubectl
        ```

    -   Mac quick reference:

        ``` none
        $ curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl \
        && chmod +x kubectl && sudo cp kubectl /usr/local/bin/ && rm kubectl
        ```
3.  Install `minikube` as described in the Kubernetes document [Install
    Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/).
    -   Linux quick reference:

        ``` none
        $ curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
        && chmod +x minikube && sudo cp minikube /usr/local/bin/ && rm minikube
        ```

    -   Mac quick reference:

        ``` none
        $ curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64 \
        && chmod +x minikube && sudo mv minikube /usr/local/bin/
        ```

# Step 2: Start Minikube

1.  Start Minikube.

    ``` console
    $ minikube start
    Starting local Kubernetes vX.X.X cluster...
    ...
    Kubectl is now configured to use the cluster.
    Loading cached images from config file.
    ```

2.  (Optional) Test basic Minikube functionality.

    If you have problems, see the Kubernetes document [Running
    Kubernetes Locally via
    Minikube](https://kubernetes.io/docs/setup/minikube/).

    a.  Start Minikube\'s \"Hello, World\" test cluster,
        `hello-minikube`.

        ``` console
        $ kubectl run hello-minikube --image=k8s.gcr.io/echoserver:1.10 --port=8080

        $ kubectl expose deployment hello-minikube --type=NodePort
        ```

    b.  Check the list of pods.

        ``` console
        $ kubectl get pods
        ```

        After the cluster is up and running, the output of this command
        should display a pod starting with `hello-minikube...`.

    c.  Run a `curl` test to the cluster.

        ``` none
        $ curl $(minikube service hello-minikube --url)
        ```

    d.  Remove the `hello-minikube` cluster.

        ``` console
        $ kubectl delete services hello-minikube

        $ kubectl delete deployment hello-minikube
        ```

# Step 3: Download the Sawtooth Configuration File

Download the Kubernetes configuration (kubeconfig) file for a Sawtooth
network.

-   For PBFT, download
    [sawtooth-kubernetes-default-pbft.yaml](./sawtooth-kubernetes-default-pbft.yaml)
-   For PoET, download
    [sawtooth-kubernetes-default-poet.yaml](./sawtooth-kubernetes-default-poet.yaml)

The kubeconfig file creates a Sawtooth network with five pods, each
running a Sawtooth node. It also specifies the container images to
download (from DockerHub) and the network settings needed for the
containers to communicate correctly.

# Step 4: (PBFT Only) Configure Keys for the Kubernetes Pods

::: important
::: title
Important
:::

Skip this step if you are using PoET consensus.
:::

For a network using PBFT consensus, the initial member list must be
specified in the genesis block. This step generates public and private
validator keys for each pod in the network, then creates a Kubernetes
ConfigMap so that the Sawtooth network can use these keys when it
starts.

1.  Change your working directory to the same directory where you saved
    the configuration file.

2.  Download the following files:

    -   [sawtooth-create-pbft-keys.yaml](https://github.com/hyperledger/sawtooth-core/blob/master/docker/kubernetes/sawtooth-create-pbft-keys.yaml)
    -   [pbft-keys-configmap.yaml](https://github.com/hyperledger/sawtooth-core/blob/master/docker/kubernetes/pbft-keys-configmap.yaml)

    Save these files in the same directory where you saved
    `sawtooth-kubernetes-default-pbft.yaml...` (in the previous step).

3.  Use the following command to generate the required keys.

    ``` console
    $ kubectl apply -f sawtooth-create-pbft-keys.yaml
    job.batch/pbft-keys created
    ```

4.  Get the full name of the `pbft-keys` pod.

    ``` console
    $ kubectl get pods |grep pbft-keys
    ```

5.  Display the keys, then copy them for the next step. In the following
    command, replace `pbft-keys-xxxxx` with the name of this pod.

    ``` console
    $ kubectl logs pbft-keys-xxxxx
    ```

    The output will resemble this example:

    ``` console
    pbft0priv: 028de9ced7ae7c58f1c4b8bb84a8cbf9378eb5943948d2dd6f493d0e7f3cadf3
    pbft0pub: 036c14100c00188f0fe8e686d577f74f35032f97f10d78764f3ec910472f157c15
    pbft1priv: c3e91eac9f8ccebc4d25977b69dc7137e4cf5fc6356a79c36802e712a49fd4b7
    pbft1pub: 02554eddb36a2d0abcb7b51cd2316b213ebe030328cd949ebc105d061e8b6de5b5
    pbft2priv: d34d4133fc830556beb8c642f31db4f082773c557b4108ec409871a10d60d2f4
    pbft2pub: 03a86840dc802e19ea64b130d26f1ab7100f923396d3151ddedc76560bbdf2f778
    pbft3priv: b8c8c79f7c8fe89eae18a805a836e23ad415b014822c60ac244a14c4df2e9429
    pbft3pub: 02a87d1a87ed54cd467d1628a601e780ddc70a6718e4b98407f3d70bb88e8a1ee0
    pbft4priv: 6499688038b519bfc99564978918ce31d74aa758380852608481c7cc1f779483
    pbft4pub: 03186440394f4a447509874095a14550bc1b1821555560f0851a5f3549c8138ac2
    ```

6.  Edit `pbft-keys-configmap.yaml` to add the keys from the previous
    step.

    ``` console
    $ vim pbft-keys-configmap.yaml
    ```

    Locate the \"blank\" key lines under `data:` and replace them with
    the keys that you copied from in previous step.

    Make sure that the YAML format is correct. The result should look
    like this example:

    ``` console
    ...

    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: keys-config
    data:
      pbft0priv: 028de9ced7ae7c58f1c4b8bb84a8cbf9378eb5943948d2dd6f493d0e7f3cadf3
      pbft0pub: 036c14100c00188f0fe8e686d577f74f35032f97f10d78764f3ec910472f157c15
      pbft1priv: c3e91eac9f8ccebc4d25977b69dc7137e4cf5fc6356a79c36802e712a49fd4b7
      pbft1pub: 02554eddb36a2d0abcb7b51cd2316b213ebe030328cd949ebc105d061e8b6de5b5
      pbft2priv: d34d4133fc830556beb8c642f31db4f082773c557b4108ec409871a10d60d2f4
      pbft2pub: 03a86840dc802e19ea64b130d26f1ab7100f923396d3151ddedc76560bbdf2f778
      pbft3priv: b8c8c79f7c8fe89eae18a805a836e23ad415b014822c60ac244a14c4df2e9429
      pbft3pub: 02a87d1a87ed54cd467d1628a601e780ddc70a6718e4b98407f3d70bb88e8a1ee0
      pbft4priv: 6499688038b519bfc99564978918ce31d74aa758380852608481c7cc1f779483
      pbft4pub: 03186440394f4a447509874095a14550bc1b1821555560f0851a5f3549c8138ac2
    ```

7.  Apply the ConfigMap so that the Sawtooth network can use these keys
    in the next step.

    ``` console
    $ kubectl apply -f pbft-keys-configmap.yaml
    configmap/keys-config created
    ```

# Step 5: Start the Sawtooth Cluster

::: note
::: title
Note
:::

The Kubernetes configuration file handles the Sawtooth startup steps
such as generating keys and creating a genesis block. To learn about the
full Sawtooth startup process, see `ubuntu`{.interpreted-text
role="doc"}.
:::

Use these steps to start the Sawtooth network.

1.  Change your working directory to the same directory where you saved
    the `sawtooth-kubernetes-default-...` configuration file.

2.  Start Sawtooth as a local Kubernetes cluster.

    -   For PBFT:

        ``` console
        $ kubectl apply -f sawtooth-kubernetes-default-pbft.yaml
        deployment.extensions/pbft-0 created
        service/sawtooth-0 created
        deployment.extensions/pbft-1 created
        service/sawtooth-1 created
        deployment.extensions/pbft-2 created
        service/sawtooth-2 created
        deployment.extensions/pbft-3 created
        service/sawtooth-3 created
        deployment.extensions/pbft-4 created
        service/sawtooth-4 created
        ```

    -   For PoET:

        ``` console
        $ kubectl apply -f sawtooth-kubernetes-default-poet.yaml
        deployment.extensions/sawtooth-0 created
        service/sawtooth-0 created
        deployment.extensions/sawtooth-1 created
        service/sawtooth-1 created
        deployment.extensions/sawtooth-2 created
        service/sawtooth-2 created
        deployment.extensions/sawtooth-3 created
        service/sawtooth-3 created
        deployment.extensions/sawtooth-4 created
        service/sawtooth-4 created
        ```

3.  This Sawtooth network has five pods, numbered from 0 to 4, each
    running a Sawtooth node. You can use the `kubectl` command to list
    the pods and get information about each pod.

    1.  Display the list of pods.

        ``` console
        $ kubectl get pods
        NAME                     READY     STATUS             RESTARTS   AGE
        pod-0-aaaaaaaaaa-vvvvv   5/8       ContainerCreating  0          21m
        pod-1-bbbbbbbbbb-wwwww   5/8       ContainerCreating  0          21m
        pod-2-ccccccccc-xxxxx    5/8       ContainerCreating  0          21m
        pod-3-dddddddddd-yyyyy   5/8       Pending            0          21m
        pod-4-eeeeeeeeee-zzzzz   5/8       Pending            0          21m
        ```

        Wait until each pod is ready before continuing.

    2.  You can specify a pod name to display the containers (Sawtooth
        components) for that pod.

        In the following command, replace `pod-N-xxxxxxxxxx-yyyyy` with
        a pod name.

        ``` console
        $ kubectl get pods pod-N-xxxxxxxxxx-yyyyy -o jsonpath={.spec.containers[*].name}
        sawtooth-intkey-tp-python sawtooth-pbft-engine sawtooth-rest-api sawtooth-settings-tp sawtooth-shell sawtooth-smallbank-tp-rust sawtooth-validator sawtooth-xo-tp-python
        ```

        Note that each pod has a shell container named `sawtooth-shell`.
        You will connect to the shell containers in later steps.

4.  (Optional) Start the Minikube dashboard.

    > \$ minikube dashboard

    This command opens the dashboard in your default browser. The
    overview page includes workload status, deployments, pods, and
    Sawtooth services. The Logs viewer (on the Pods page) shows the
    Sawtooth log files. For more information, see [Web UI
    (Dashboard)](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
    in the Kubernetes documentation.

::: important
::: title
Important
:::

Any work done in this environment will be lost once you stop Minikube
and delete the Sawtooth cluster. In order to use this environment for
application development, or to start and stop Sawtooth nodes (and pods),
you would need to take additional steps, such as defining volume
storage. See the [Kubernetes
documentation](https://kubernetes.io/docs/home/) for more information.
:::

# Step 6: Confirm Network and Blockchain Functionality {#confirm-func-kube-label}

1.  Connect to the shell container on the first pod.

    In the following command, replace `pod-0-xxxxxxxxxx-yyyyy` with the
    name of the first pod, as shown by `kubectl get pods`.

    ``` none
    $ kubectl exec -it pod-0-xxxxxxxxxx-yyyyy --container sawtooth-shell -- bash

    root@sawtooth-0#
    ```

    ::: note
    ::: title
    Note
    :::

    In this procedure, the prompt `root@sawtooth-0#` marks the commands
    that should be run on the Sawtooth node in pod 0. The actual prompt
    is similar to `root@pbft-0-dabbad0000-5w45k:/#` (for PBFT) or
    `root@sawtooth-0-f0000dd00d-sw33t:/#` (for PoET).
    :::

2.  Display the list of blocks on the Sawtooth blockchain.

    > ``` none
    > root@sawtooth-0# sawtooth block list
    > ```

    The output will be similar to this example:

    > ``` console
    > NUM  BLOCK_ID                                                                                                                          BATS  TXNS  SIGNER
    > 2    f40b90d06b4a9074af2ab09e0187223da7466be75ec0f472f2edd5f22960d76e402e6c07c90b7816374891d698310dd25d9b88dce7dbcba8219d9f7c9cae1861  3     3     02e56e...
    > 1    4d7b3a2e6411e5462d94208a5bb83b6c7652fa6f4c2ada1aa98cabb0be34af9d28cf3da0f8ccf414aac2230179becade7cdabbd0976c4846990f29e1f96000d6  1     1     034aad...
    > 0    0fb3ebf6fdc5eef8af600eccc8d1aeb3d2488992e17c124b03083f3202e3e6b9182e78fef696f5a368844da2a81845df7c3ba4ad940cee5ca328e38a0f0e7aa0  3     11    034aad...
    > ```

    Block 0 is the `genesis block`{.interpreted-text role="term"}. The
    other two blocks contain transactions for on-chain settings.

3.  In a separate terminal window, connect to a different pod (such as
    pod 1) and verify that it has joined the Sawtooth network.

    In the following command, replace `pod-1-xxxxxxxxxx-yyyyy` with the
    name of the pod, as shown by `kubectl get pods`.

    > ``` none
    > $ kubectl exec -it pod-1-xxxxxxxxxx-yyyyy --container sawtooth-shell -- bash
    >
    > root@sawtooth-1#
    > ```
    >
    > The prompt `root@sawtooth-1#` marks the commands that should be
    > run on the Sawtooth node in this pod.

4.  Display the list of blocks on the pod.

    > ``` none
    > root@sawtooth-1# sawtooth block list
    > ```

    You should see the same list of blocks with the same block IDs, as
    in this example:

    > ``` console
    > NUM  BLOCK_ID                                                                                                                          BATS  TXNS  SIGNER
    > 2    f40b90d06b4a9074af2ab09e0187223da7466be75ec0f472f2edd5f22960d76e402e6c07c90b7816374891d698310dd25d9b88dce7dbcba8219d9f7c9cae1861  3     3     02e56e...
    > 1    4d7b3a2e6411e5462d94208a5bb83b6c7652fa6f4c2ada1aa98cabb0be34af9d28cf3da0f8ccf414aac2230179becade7cdabbd0976c4846990f29e1f96000d6  1     1     034aad...
    > 0    0fb3ebf6fdc5eef8af600eccc8d1aeb3d2488992e17c124b03083f3202e3e6b9182e78fef696f5a368844da2a81845df7c3ba4ad940cee5ca328e38a0f0e7aa0  3     11    034aad...
    > ```

5.  (Optional) You can run the following Sawtooth commands from any
    shell container to show the other nodes on the network.

    In the following commands, replace `pod-N-xxxxxxxxxx-yyyyy` with the
    name of the pod, as shown by `kubectl get pods`.

    a.  Connect to any shell container.

        ``` none
        $ kubectl exec -it pod-N-xxxxxxxxxx-yyyyy --container sawtooth-shell -- bash

        root@sawtooth-N#
        ```

    b.  Run `sawtooth peer list` to show the peers of a particular node.

        ``` console
        root@sawtooth-N# sawtooth peer list
        ```

    c.  Run `sawnet peers list` to display a complete graph of peers on
        the network (available in Sawtooth release 1.1 and later).

        ``` console
        root@sawtooth-N# sawnet peers list http://localhost:8008
        ```

6.  You can submit a transaction on one Sawtooth node, then look for the
    results of that transaction on another node.

    a.  From the shell container one pod (such as pod 0), use the
        `intkey set` command to submit a transaction on the first node.
        This example sets a key named `MyKey` to the value 999.

        > ``` console
        > root@sawtooth-0# intkey set MyKey 999
        > {
        >   "link":
        >   "http://127.0.0.1:8008/batch_statuses?id=1b7f121a82e73ba0e7f73de3e8b46137a2e47b9a2d2e6566275b5ee45e00ee5a06395e11c8aef76ff0230cbac0c0f162bb7be626df38681b5b1064f9c18c76e5"
        >   }
        > ```

    b.  From the shell container on a different pod (such as pod 1),
        check that the value has been changed on that node.

        > ``` console
        > root@sawtooth-1# intkey show MyKey
        > MyKey: 999
        > ```

7.  You can check whether a Sawtooth component is running by connecting
    to a different container, then running the `ps` command. The
    container names are available in the kubeconfig file or on a pod\'s
    page on the Kubernetes dashboard.

    The following example connects to the Settings transaction processor
    container (`sawtooth-settings-tp`) on pod 3, then displays the list
    of running process. Replace `pod-3-xxxxxxxxxx-yyyyy` with the name
    of the pod, as shown by `kubectl get pods`.

    ``` console
    $ kubectl exec -it pod-3-xxxxxxxxxx-yyyyy --container sawtooth-settings-tp -- bash

    root@sawtooth-3# ps --pid 1 fw
      PID TTY      STAT   TIME COMMAND
        1 ?        Ssl    0:02 settings-tp -vv -C tcp://sawtooth-3-5bd565ff45-2klm7:4004
    ```

At this point, your environment is ready for experimenting with
Sawtooth.

::: tip
::: title
Tip
:::

For more ways to test basic functionality, see
`kubernetes`{.interpreted-text role="doc"}. For example:

-   To use Sawtooth client commands to view block information and check
    state data, see `sawtooth-client-kube-label`{.interpreted-text
    role="ref"}.
-   For information on the Sawtooth logs, see
    `examine-logs-kube-label`{.interpreted-text role="ref"}.
:::

# Step 7. Configure the Allowed Transaction Types (Optional) {#configure-txn-procs-kube-label}

By default, a validator accepts transactions from any transaction
processor. However, Sawtooth allows you to limit the types of
transactions that can be submitted.

In this step, you will configure the Sawtooth network to accept
transactions only from the transaction processors running in the example
environment. Transaction-type restrictions are an on-chain setting, so
this configuration change is made on one node, then applied to all other
nodes.

The `Settings transaction processor
<../transaction_family_specifications/settings_transaction_family>`{.interpreted-text
role="doc"} handles on-chain configuration settings. You will use the
`sawset` command to create and submit a batch of transactions containing
the configuration change.

1.  Connect to the validator container of the first node. The next
    command requires the user key that was generated in that container.

    Replace `pod-0-xxxxxxxxxx-yyyyy` with the name of the first pod, as
    shown by `kubectl get pods`.

    ``` console
    $ kubectl exec -it pod-0-xxxxxxxxxx-yyyyy --container sawtooth-validator -- bash
    root@sawtooth-0#
    ```

2.  Run the following command from the validator container to specify
    the allowed transaction families.

    -   For PBFT:

        ``` console
        root@sawtooth-0# sawset proposal create --key /root/.sawtooth/keys/my_key.priv \
        sawtooth.validator.transaction_families='[{"family": "intkey", "version": "1.0"}, {"family":"sawtooth_settings", "version":"1.0"}, {"family":"xo", "version":"1.0"}]'
        ```

    -   For PoET:

        ``` console
        root@sawtooth-0# sawset proposal create --key /root/.sawtooth/keys/my_key.priv \
        sawtooth.validator.transaction_families='[{"family": "intkey", "version": "1.0"}, {"family":"sawtooth_settings", "version":"1.0"}, {"family":"xo", "version":"1.0"}, {"family":"sawtooth_validator_registry", "version":"1.0"}]'
        ```

    This command sets `sawtooth.validator.transaction_families` to a
    JSON array that specifies the family name and version of each
    allowed transaction processor (defined in the transaction header of
    each family\'s
    `transaction family specification <../transaction_family_specifications>`{.interpreted-text
    role="doc"}).

3.  After this command runs, a `TP_PROCESS_REQUEST` message appears in
    the log for the Settings transaction processor.

    -   You can use the Kubernetes dashboard to view this log message:
        a.  Run `minikube dashboard` to start the Kubernetes dashboard,
            if necessary.

        b.  From the Overview page, scroll to the list of pods and click
            on any pod name.

        c.  On the pod page, click `LOGS`{.interpreted-text
            role="guilabel"} (in the top right).

        d.  On the pod\'s log page, select logs from
            `sawtooth-settings-tp`, then scroll to the bottom of the
            log. The message will resemble this example:

            ``` none
            [2018-09-05 20:07:41.903 DEBUG    core] received message of type: TP_PROCESS_REQUEST
            ```

4.  Run the following command to check the setting change. You can use
    any container, such as a shell or another validator container.

    ``` console
    root@sawtooth-1# sawtooth settings list
    ```

    The output should be similar to this example:

    ``` console
    sawtooth.consensus.algorithm.name: {name}
    sawtooth.consensus.algorithm.version: {version}
    ...
    sawtooth.publisher.max_batches_per_block: 200
    sawtooth.settings.vote.authorized_keys: 03e27504580fa15da431...
    sawtooth.validator.transaction_families: [{"family": "intkey...
    ```

# Step 8: Stop the Sawtooth Kubernetes Cluster {#stop-sawtooth-kube2-label}

Use the following commands to stop and reset the Sawtooth network.

::: important
::: title
Important
:::

Any work done in this environment will be lost once you delete the
Sawtooth pods. To keep your work, you would need to take additional
steps, such as defining volume storage. See the [Kubernetes
documentation](https://kubernetes.io/docs/home/) for more information.
:::

1.  Log out of all Sawtooth containers.

2.  Stop Sawtooth and delete the pods. Run the following command from
    the same directory where you saved the configuration file.

    -   For PBFT:

        ``` console
        $ kubectl delete -f sawtooth-kubernetes-default-pbft.yaml
        deployment.extensions "pbft-0" deleted
        service "sawtooth-0" deleted
        deployment.extensions "pbft-1" deleted
        service "sawtooth-1" deleted
        deployment.extensions "pbft-2" deleted
        service "sawtooth-2" deleted
        deployment.extensions "pbft-3" deleted
        service "sawtooth-3" deleted
        deployment.extensions "pbft-4" deleted
        service "sawtooth-4" deleted
        ```

    -   For PoET:

        ``` console
        $ kubectl delete -f sawtooth-kubernetes-default-poet.yaml
        deployment.extensions "sawtooth-0" deleted
        service "sawtooth-0" deleted
        deployment.extensions "sawtooth-1" deleted
        service "sawtooth-1" deleted
        deployment.extensions "sawtooth-2" deleted
        service "sawtooth-2" deleted
        deployment.extensions "sawtooth-3" deleted
        service "sawtooth-3" deleted
        deployment.extensions "sawtooth-4" deleted
        service "sawtooth-4" deleted
        ```

3.  Stop the Minikube cluster.

    ``` console
    $ minikube stop
    Stopping local Kubernetes cluster...
    Machine stopped.
    ```

4.  Delete the Minikube cluster, VM, and all associated files.

    ``` console
    $ minikube delete
    Deleting local Kubernetes cluster...
    Machine deleted.
    ```


* [Ubuntu Test
Network]({% link docs/1.2/app_developers_guide/ubuntu_test_network.md %})

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
