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
    [PoET Validator Registry]({%link docs/1.2/transaction_family_specifications/validator_registry_transaction_family.md%})
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

## Using Kubernetes for a Sawtooth Test Network

This procedure describes how to use [Kubernetes](https://kubernetes.io/)
to create a network of five Sawtooth nodes for an application
development environment. Each node is a Kubernetes pod containing a set
of containers for a validator and related Sawtooth components.

> **Note**
>
> For a single-node environment, see [Installing
> Sawtooth]({% link docs/1.2/app_developers_guide/installing_sawtooth.md%})

This procedure guides you through the following tasks:

> -   Installing `kubectl` and `minikube`
> -   Starting Minikube
> -   Downloading the Sawtooth configuration file
> -   Starting Sawtooth in a Kubernetes cluster
> -   Connecting to the Sawtooth shell containers
> -   Confirming network and blockchain functionality
> -   Configuring the allowed transaction types (optional)
> -   Stopping Sawtooth and deleting the Kubernetes cluster

### About the Kubernetes Sawtooth Network Environment

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

<img alt="Appdev Environment Multi-Node Kube" src="/images/1.2/appdev-environment-multi-node-kube.svg">

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
    [PoET Validator Registry]({%link docs/1.2/transaction_family_specifications/validator_registry_transaction_family.md%})
     (`poet-validator-registry-tp`): Configures PoET consensus and handles a
     network with multiple nodes.

> Important
>
> Each node in a Sawtooth network must run the same set of transaction
> processors.

Like the [single-node test environment
kubernetes]({% link docs/1.2/app_developers_guide/installing_sawtooth.md%}#kubernetes),
this environment uses parallel transaction processing and
static peering. However, it uses a different consensus algorithm
(Devmode consensus is not recommended for a network). You can choose
either PBFT or PoET consensus.

-   PBFT consensus provides a voting-based consensus algorithm with
    Byzantine fault tolerance (BFT) that has finality (does not fork).

-   PoET consensus provides a leader-election lottery system that can fork.
    This network uses PoET simulator consensus, which is also called
    PoET CFT because it is crash fault tolerant.

    > **Note**
    >
    > The other type of PoET consensus, PoET-SGX, relies on Intel Software
    > Guard Extensions (SGX) that is Byzantine fault tolerant (BFT). PoET
    > CFT provides the same consensus algorithm on an SGX simulator.

The first node creates the genesis block, which specifies the initial
on-chain settings for the network configuration. The other nodes access
those settings when they join the network.

### Prerequisites

-   This environment requires
    [kubectl](https://kubernetes.io/docs/concepts/) and
    [minikube](https://kubernetes.io/docs/setup/minikube/) with a
    supported VM hypervisor, such as
    [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
-   If you created a
    [single-node Kubernetes environment
    kubernetes]({% link docs/1.2/app_developers_guide/installing_sawtooth.md%}) that is still running, shut it down and delete the
    Minikube cluster, VM, and associated files. For more information,
    see [Stop the Sawtooth Kubernetes
    Cluster]({% link docs/1.2/app_developers_guide/installing_sawtooth.md%}#stop-sawtooth-kube-label)

### Step 1: Install kubectl and minikube

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

### Step 2: Start Minikube

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

### Step 3: Download the Sawtooth Configuration File

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

### Step 4: (PBFT Only) Configure Keys for the Kubernetes Pods

> **Important**
>
> Skip this step if you are using PoET consensus.

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

### Step 5: Start the Sawtooth Cluster

> **Note**
>
> The Kubernetes configuration file handles the Sawtooth startup steps
> such as generating keys and creating a genesis block. To learn about the
> full Sawtooth startup process, see [Ubuntu]({% link docs/1.2/app_developers_guide/installing_sawtooth.md%}#ubuntu)

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

> **Important**
>
> Any work done in this environment will be lost once you stop Minikube
> and delete the Sawtooth cluster. In order to use this environment for
> application development, or to start and stop Sawtooth nodes (and pods),
> you would need to take additional steps, such as defining volume
> storage. See the [Kubernetes
> documentation](https://kubernetes.io/docs/home/) for more information.

### Step 6: Confirm Network and Blockchain Functionality {#confirm-func-kube-label}

1.  Connect to the shell container on the first pod.

    In the following command, replace `pod-0-xxxxxxxxxx-yyyyy` with the
    name of the first pod, as shown by `kubectl get pods`.

    ``` none
    $ kubectl exec -it pod-0-xxxxxxxxxx-yyyyy --container sawtooth-shell -- bash

    root@sawtooth-0#
    ```

    > **Note**
    >
    > In this procedure, the prompt `root@sawtooth-0#` marks the commands
    > that should be run on the Sawtooth node in pod 0. The actual prompt
    > is similar to `root@pbft-0-dabbad0000-5w45k:/#` (for PBFT) or
    > `root@sawtooth-0-f0000dd00d-sw33t:/#` (for PoET).

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

> **Tip**
>
> For more ways to test basic functionality, see
> [Kubernetes]({% link docs/1.2/app_developers_guide/installing_sawtooth.md%}#kubernetes). For example:
>
> -   To use Sawtooth client commands to view block information and check
>     state data, see [Use Sawtooth Commands as a
>     Client]({% link docs/1.2/app_developers_guide/installing_sawtooth.md%}#sawtooth-client-kube-label)
> -   For information on the Sawtooth logs, see [Examine Sawtooth
>     Logs]({% link docs/1.2/app_developers_guide/installing_sawtooth.md%}#examine-logs-kube-label)

### Step 7. Configure the Allowed Transaction Types (Optional) {#configure-txn-procs-kube-label}

By default, a validator accepts transactions from any transaction
processor. However, Sawtooth allows you to limit the types of
transactions that can be submitted.

In this step, you will configure the Sawtooth network to accept
transactions only from the transaction processors running in the example
environment. Transaction-type restrictions are an on-chain setting, so
this configuration change is made on one node, then applied to all other
nodes.

The [Settings transaction
processor]({% link docs/1.2/transaction_family_specifications/settings_transaction_family.md%})
handles on-chain configuration settings. You will use the
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
    [transaction family
    specification](({% link docs/1.2/transaction_family_specifications/index.md%}))

3.  After this command runs, a `TP_PROCESS_REQUEST` message appears in
    the log for the Settings transaction processor.

    -   You can use the Kubernetes dashboard to view this log message:
        a.  Run `minikube dashboard` to start the Kubernetes dashboard,
            if necessary.

        b.  From the Overview page, scroll to the list of pods and click
            on any pod name.

        c.  On the pod page, click `LOGS` (in the top right).

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

### Step 8: Stop the Sawtooth Kubernetes Cluster {#stop-sawtooth-kube2-label}

Use the following commands to stop and reset the Sawtooth network.

> **Important**
>
> Any work done in this environment will be lost once you delete the
> Sawtooth pods. To keep your work, you would need to take additional
> steps, such as defining volume storage. See the [Kubernetes
> documentation](https://kubernetes.io/docs/home/) for more information.

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

## Using Ubuntu for a Sawtooth Test Network

This procedure describes how to create a Sawtooth network for an
application development environment on a Ubuntu platform. Each host
system (physical computer or virtual machine) is a [Sawtooth
node]{.title-ref} that runs a validator and related Sawtooth components.

> **Note**
>
> For a single-node environment, see [ubuntu]({% link docs/1.2/app_developers_guide/installing_sawtooth.md%}#ubuntu)

This procedure guides you through the following tasks:

> -   Installing Sawtooth
> -   Creating user and validator keys
> -   Creating the genesis block on the first node (includes specifying
>     either PBFT or PoET consensus)
> -   Starting Sawtooth on each node
> -   Confirming network functionality
> -   Configuring the allowed transaction types (optional)

For information on Sawtooth dynamic consensus or to learn how to change
the consensus type, see [About Dynamic
Consensus]({% link docs/1.2/sysadmin_guide/about_dynamic_consensus.md %}).

> **Note**
>
> These instructions have been tested on Ubuntu 18.04 (Bionic) only.

### About the Ubuntu Sawtooth Network Environment {#about-sawtooth-nw-env-label}

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

This test environment is a network of several Sawtooth nodes. The
following figure shows a network with five nodes.

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
    [PoET Validator Registry]({%link docs/1.2/transaction_family_specifications/validator_registry_transaction_family.md%})
     (`poet-validator-registry-tp`): Configures PoET consensus and handles a
     network with multiple nodes.

> Important
>
> Each node in a Sawtooth network must run the same set of transaction
> processors.

Like the single-node environment, this environment uses parallel
transaction processing and static peering. However, it uses a different
consensus algorithm (Devmode consensus is not recommended for a
network).

This procedure explains how to configure either PBFT or PoET consensus.
The initial network must include the minimum number of nodes for the
chosen consensus:

> -   PBFT consensus requires four or
>     more nodes. At least four nodes must be configured and running in
>     order for the network to start.
>
> -   PoET consensus requires three or
>     more nodes. You can start the first node and test basic
>     functionality, then add the other nodes.
>
>
>     **Note**
>
>     This procedure uses PoET simulator consensus (also called PoET CFT
>     because it is crash fault tolerant), which is a version of
>     PoET-SGX consensus that runs on any processor.
>
> -   Devmode consensus has no minimum
>     requirement, but it is not recommended for multiple-node test
>     networks or production networks. Devmode is a light-weight
>     consensus that is intended for short-term testing on a single node
>     or a very small network (two or three nodes). It is not crash
>     fault tolerant and does not handle forks efficiently.


> **Note**
>
> For PBFT consensus, the network must be fully peered (each
> node must be connected to all other nodes).


### Prerequisites {#prereqs-multi-ubuntu-label}

-   Remove data from an existing single node: To reuse the single test
    node described in
    [Ubuntu]({%link docs/1.2/app_developers_guide/installing_sawtooth.md%}#ubuntu), stop
    Sawtooth and delete all blockchain data and logs from that node.
    1.  If the first node is running, stop the Sawtooth components
        (validator, REST API, consensus engine, and transaction
        processors), as described in [Stop Sawtooth
        Components](#stop-sawtooth-ubuntu-label)
    2.  Delete the existing blockchain data by removing all files from
        `/var/lib/sawtooth/`.
    3.  Delete the logs by removing all files from `/var/log/sawtooth/`.
    4.  You can reuse the existing user and validator keys. If you want
        to start with new keys, delete the `.priv` and `.pub` files from
        `/home/yourname/.sawtooth/keys/` and `/etc/sawtooth/keys/`.
-   Gather networking information: For each node that will be on your
    network, gather the following information.
    -   **Component bind string**: Where this validator will listen for
        incoming communication from this validator\'s components. You
        will set this value with `--bind component` when starting the
        validator. Default: `tcp://127.0.0.1:4004`.
    -   **Network bind string**: Where this validator will listen for
        incoming communication from other nodes (also called peers). You
        will set this value with `--bind network` when starting the
        validator. Default: `tcp://127.0.0.1:8800`.
    -   **Public endpoint string**: The address that other peers should
        use to find the validator on this node. You will set this value
        with `--endpoint` when starting the validator. You will also
        specify this value in the peers list when starting a validator
        on another node. Default: `tcp://127.0.0.1:8800`.
    -   **Consensus endpoint string**: Where this validator will listen
        for incoming communication from the
        consensus engine. You will set this value with `--bind consensus` when
        starting the validator. Default: `tcp://127.0.0.1:5050`.
    -   **Peers list**: The addresses that this validator should use to
        connect to the other nodes (peers); that is, the public endpoint
        strings of those nodes. You will set this value with `--peers`
        when starting the validator. Default: none.

#### About component and network bind strings

For the network bind string and component bind string, you would
typically use a specific network interface that you want to bind to. The
`ifconfig` command provides an easy way to determine what this interface
should be. `ifconfig` displays the network interfaces on your host
system, along with additional information about the interfaces. For
example:

``` console
$ ifconfig
eth0      Link encap:Ethernet  HWaddr ...
          inet addr:...  Bcast:...  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:17964 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6134 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:26335425 (26.3 MB)  TX bytes:338394 (338.3 KB)
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

This example output shows that `eth0` is a network interface that has
access to the Internet. In this case, you could use one of the
following:

-   If you would like the validator to accept connections from other
    nodes on the network behind `eth0`, you could specify a network bind
    string such as `tcp://eth0:8800`.
-   If you would like the validator to accept only connections from
    local Sawtooth components, you could specify the component bind
    string `tcp://lo:4004`. Note that this is equivalent to
    `tcp://127.0.0.1:4004`.

For more information on how to specify the component and network bind
strings, see \"Assigning a local address to a socket\" in the [zmq-tcp
API Reference](http://api.zeromq.org/4-2:zmq-tcp).

#### About the public endpoint string {#about-endpoint-string-label}

The correct value for your public endpoint string depends on your
network configuration.

-   If this network is for development purposes and all of the nodes
    will be on the same local network, the IP address returned by
    `ifconfig` should work as your public endpoint string.

-   If part of your network is behind a NAT or firewall, or if you want
    to start up a public network on the Internet, you must determine the
    correct routable values for all the nodes in your network.

    Determining these values for a distributed or production network is
    an advanced networking topic that is beyond the scope of this guide.
    Contact your network administrator for help with this task.

For information on how to specify the public endpoint string, see
\"Connecting a socket\" in the [zmq-tcp API
Reference](http://api.zeromq.org/4-2:zmq-tcp).

### Step 1: Install Sawtooth on All Nodes

Use these steps on each system to install Hyperledger Sawtooth.

> **Note**
>
> -   For PBFT consensus, you must install Sawtooth and generate keys for
>     all nodes before continuing to step 3 (creating the genesis block on
>     the first node).
> -   For PoET consensus, you can choose to install Sawtooth on the other
>     nodes after configuring and starting the first node.

1.  Choose whether you want the stable version (recommended) or the most
    recent nightly build (for testing purposes only).

    -   (Release 1.2 and later) To add the stable repository, run these
        commands in a terminal window on your host system.

        ``` console
        $ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8AA7AF1F1091A5FD
        $ sudo add-apt-repository 'deb [arch=amd64] http://repo.sawtooth.me/ubuntu/chime/stable bionic universe'
        ```

        > **Note**
        >
        >
        > The `chime` metapackage includes the Sawtooth core software and
        > associated items such as separate consensus software.

    -   The latest version of Sawtooth is available in a repository of
        nightly builds. These builds may incorporate undocumented
        features and should be used for testing purposes only.

        To use the nightly repository, run the following commands in a
        terminal window on your host system.

        ``` console
        $ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 44FC67F19B2466EA
        $ sudo apt-add-repository 'deb [arch=amd64] http://repo.sawtooth.me/ubuntu/nightly bionic universe'
        ```

2.  Update your package lists.

    ``` console
    $ sudo apt-get update
    ```

3.  Install the Sawtooth packages. Sawtooth consists of several Ubuntu
    packages that can be installed together using the `sawtooth`
    meta-package. Run the following command:

    ``` console
    $ sudo apt-get install -y sawtooth
    ```

> 1.  (PBFT only) Install the PBFT consensus engine package.
>
>     ``` console
>     $ sudo apt-get install -y sawtooth sawtooth-pbft-engine
>     ```
>
> 2.  (PoET only) Install the PoET consensus engine, transaction
>     processor, and CLI packages.
>
>     ``` console
>     $ sudo apt-get install -y sawtooth \
>     python3-sawtooth-poet-cli \
>     python3-sawtooth-poet-engine \
>     python3-sawtooth-poet-families
>     ```
>
> > **Tip**
> >
> > Any time after installation, you can view the installed Sawtooth
> > packages with the following command:
> >
> > ``` console
> > $ dpkg -l '*sawtooth*'
> > ```

### Step 2: Create User and Validator Keys

> **Note**
>
> Skip this step if you are reusing an existing node that already has user
> and validator keys.

> **Important**
>
> For PBFT, repeat this procedure on the other nodes in the initial
> network. When you create the genesis block on the first node, you will
> need the validator keys for at least three other nodes.

1.  Generate your user key for Sawtooth.

    ``` console
    $ sawtooth keygen my_key
    writing file: /home/yourname/.sawtooth/keys/my_key.priv
    writing file: /home/yourname/.sawtooth/keys/my_key.pub
    ```

    > **Note**
    >
    > This command specifies `my_key` as the base name for the key files,
    > to be consistent with the key name that is used in some example
    > Docker and Kubernetes files. By default (when no key name is
    > specified), the `sawtooth keygen` command uses your user name.

2.  Generate the key for the validator, which runs as root.

    ``` console
    $ sudo sawadm keygen
    writing file: /etc/sawtooth/keys/validator.priv
    writing file: /etc/sawtooth/keys/validator.pub
    ```

    > **Note**
    >
    > By default, this command stores the validator key files in
    > `/etc/sawtooth/keys/validator.priv` and
    > `/etc/sawtooth/keys/validator.pub`. However, settings in the path
    > configuration file could change this location; see [Path Configuring
    > Sawtooth]({% link docs/1.2/sysadmin_guide/configuring_sawtooth.md%}).

### Step 3: Create the Genesis Block on the First Node

The first node creates the genesis block, which specifies the initial
on-chain settings for the network configuration. Other nodes access
those settings when they join the network.

**Prerequisites**:

-   If you are reusing an existing node, make sure that you have deleted
    the blockchain data before continuing (as described in
    the Ubuntu section's prerequisites).
-   For PBFT, the genesis block requires the validator keys for at least
    four nodes (or all nodes in the initial network, if known). If you
    have not installed Sawtooth and generated keys on the other nodes,
    perform [Step 1](#step-1-install-sawtooth-on-all-nodes) and
    [Step 2](#step-2-create-user-and-validator-keys)
    on those nodes, then gather the public keys from
    `/etc/sawtooth/keys/validator.pub` on each node.

The first node in a new Sawtooth network must create the genesis
block (the first block on the distributed ledger). When the
other nodes join the network, they use the on-chain settings that were
specified in the genesis block.

The genesis block specifies the consensus algorithm and the keys for
nodes (or users) who are authorized to change configuration settings.
For PBFT, the genesis block also includes the keys for the other nodes
in the initial network.

> **Important**
>
> Use this procedure **only** for the first node on a Sawtooth network.
> Skip this procedure for a node that will join an existing network.

1.  Ensure that the required user and validator keys exist on this node:

    ``` console
    $ ls $HOME/.sawtooth/keys/
    my_key.priv    my_key.pub

    $ ls /etc/sawtooth/keys/
    validator.priv   validator.pub
    ```

    If these key files do not exist, create them as described in the
    previous step.

2.  Change to a writable directory such as `/tmp`.

    ``` console
    $ cd /tmp
    ```

3.  Create a batch with a settings proposal for the genesis block.

    ``` console
    $ sawset genesis --key $HOME/.sawtooth/keys/my_key.priv \
    -o config-genesis.batch
    ```

    This command authorizes you to set and change Sawtooth settings. The
    settings changes will take effect after the validator and Settings
    transaction processor have started.

    > **Note**
    >
    > You must use the same key for the `sawset proposal create` commands
    > in the following steps. In theory, some of these commands could use
    > a different key, but configuring multiple keys is a complicated
    > process that is not shown in this procedure. For more information,
    > see [Adding Authorized
    > Users]({% link docs/1.2/sysadmin_guide/adding_authorized_users.md%}).


4.  Create a batch to initialize the consensus settings.

    -   For PBFT:

        ``` console
        $ sawset proposal create --key $HOME/.sawtooth/keys/my_key.priv \
        -o config-consensus.batch \
        sawtooth.consensus.algorithm.name=pbft \
        sawtooth.consensus.algorithm.version=1.0 \
        sawtooth.consensus.pbft.members='["VAL1KEY","VAL2KEY",...,"VALnKEY"]'
        ```

        Replace `"VAL1KEY","VAL2KEY","VAL3KEY",...,"VALnKEY"` with the
        validator public keys of all the nodes (including this node).
        This information is in the file
        `/etc/sawtooth/keys/validator.pub` on each node. Be sure to use
        single quotes and double quotes correctly, as shown in the
        example.

        > **Tip**
        >
        > The PBFT version number is in the file
        > `sawtooth-pbft/Cargo.toml` as
        > `version = "{major}.{minor}.{patch}"`. Use only the first two
        > digits (major and minor release numbers); omit the patch number.
        > For example, if the version is 1.0.3, use `1.0` for this
        > setting.

    -   For PoET:

        ``` console
        $ sawset proposal create --key $HOME/.sawtooth/keys/my_key.priv \
        -o config-consensus.batch \
        sawtooth.consensus.algorithm.name=PoET \
        sawtooth.consensus.algorithm.version=0.1 \
        sawtooth.poet.report_public_key_pem="$(cat /etc/sawtooth/simulator_rk_pub.pem)" \
        sawtooth.poet.valid_enclave_measurements=$(poet enclave measurement) \
        sawtooth.poet.valid_enclave_basenames=$(poet enclave basename)
        ```

    > **Note**
    >
    > This is a complicated command. Here's an explanation of the options
    > and arguments:
    >
    > `--key $HOME/.sawtooth/keys/my_key.priv`
    >
    > :   Signs the proposal with your private key. Only this key can be
    >     used to change on-chain settings.
    >
    > `-o config-consensus.batch`
    >
    > :   Wraps the consensus proposal transaction in a batch named
    >     `config-consensus.batch`.
    >
    > `sawtooth.consensus.algorithm.name`
    >
    > :   Specifies the consensus algorithm for this network; this setting
    >     is required.
    >
    > `sawtooth.consensus.algorithm.version`
    >
    > :   Specifies the version of the consensus algorithm; this setting
    >     is required.
    >
    > (PBFT only) `sawtooth.consensus.pbft.members`
    >
    > :   Lists the member nodes on the initial network as a
    >     JSON-formatted string of the validators\' public keys, using the
    >     following format:
    >
    >     `'["<public-key-1>","<public-key-2>",...,"<public-key-n>"]'`
    >
    > (PoET only) `sawtooth.poet.report_public_key_pem="$(cat /etc/sawtooth/simulator_rk_pub.pem)"`
    >
    > :   Adds the public key for the PoET Validator Registry transaction
    >     processor to use for the PoET simulator consensus.
    >
    > (PoET only) `sawtooth.poet.valid_enclave_measurements=$(poet enclave measurement)`
    >
    > :   Adds a simulated enclave measurement to the blockchain. The PoET
    >     Validator Registry transaction processor uses this value to
    >     check signup information.
    >
    > (PoET only) `sawtooth.poet.valid_enclave_basenames=$(poet enclave basename)`
    >
    > :   Adds a simulated enclave basename to the blockchain. The PoET
    >     Validator Registry uses this value to check signup information.

5.  (PoET only) Create a batch to register the first Sawtooth node with
    the PoET Validator Registry transaction processor, using the
    validator\'s private key. Without this command, the validator would
    not be able to publish any blocks.

    ``` console
    $ poet registration create --key /etc/sawtooth/keys/validator.priv -o poet.batch
    ```

6.  (Optional) Create a batch to configure other consensus settings.

    -   For PBFT:

        ``` console
        $ sawset proposal create --key $HOME/.sawtooth/keys/my_key.priv \
        -o pbft-settings.batch \
        SETTING-NAME=VALUE \
        ... \
        SETTING-NAME=VALUE
        ```

        For the available settings and their default values, see
        [PBFT On-Chain
        Settings]({%link docs/1.2/pbft/configuring-pbft.md%}#pbft-on-chain -settings)
        in the Sawtooth PBFT documentation.

    -   For PoET:

        ``` console
        $ sawset proposal create --key $HOME/.sawtooth/keys/my_key.priv \
        -o poet-settings.batch \
        sawtooth.poet.target_wait_time=5 \
        sawtooth.poet.initial_wait_time=25 \
        sawtooth.publisher.max_batches_per_block=100
        ```

        > **Note**
        >
        >
        > This example shows the default PoET settings. For more
        > information, see the [Hyperledger Sawtooth Settings
        > FAQ]({% link faq/settings.md%}).

7.  As the sawtooth user, combine the separate batches into a single
    genesis batch that will be committed in the genesis block.

    -   For PBFT:

        ``` console
        $ sudo -u sawtooth sawadm genesis \
        config-genesis.batch config-consensus.batch pbft-settings.batch
        ```

    -   For PoET:

        ``` console
        $ sudo -u sawtooth sawadm genesis \
        config-genesis.batch config-consensus.batch poet.batch poet-settings.batch
        ```

    You'll see some output indicating success:

    ``` console
    Processing config-genesis.batch...
    Processing config-consensus.batch...
    ...
    Generating /var/lib/sawtooth/genesis.batch
    ```

    > **Note**
    >
    > The `sawtooth.consensus.algorithm.name` and
    > `sawtooth.consensus.algorithm.version` settings are required;
    > `sawadm genesis` will fail if they are not present in one of the
    > batches unless the `--ignore-required-settings` flag is used.

When this command finishes, the genesis block is complete.

The settings in the genesis block will be available after the first node
has started and the genesis block has been committed.

### Step 4. (PBFT Only) Configure Peers in Off-Chain Settings

For PBFT, each node specify the peer nodes in the network, because a
PBFT network must be fully peered (all nodes must be directly
connected). This setting is in the off-chain [validator configuration
file]({%link docs/1.2/sysadmin_guide/configuring_sawtooth/validator_configuration_file.md%}).

1.  Create the validator configuration file by copying the example file.

    ``` console
    $ sudo cp -a /etc/sawtooth/validator.toml.example /etc/sawtooth/validator.toml
    ```

2.  Use `sudo` to edit this file.

    ``` console
    $ sudo vi /etc/sawtooth/validator.toml
    ```

3.  Locate the `peering` setting and make sure that it is set to
    `static` (the default).

4.  Find the `peers` setting and enter the URLs for other validators on
    the network.

    Use the format `tcp://{hostname}:{port}` for each peer. Specify
    multiple peers in a comma-separated list. For example:

    ``` ini
    peers = ["tcp://node1:8800", "tcp://node2:8800", "tcp://node3:8800"]
    ```

This setting will take effect when the validator starts.

> **Note**
>
> For information about optional configuration settings, see [Off Chain
> Settings]({% link docs/1.2/sysadmin_guide/setting_up_sawtooth_network.md%}#changing-off-chain-settings-with-configuration-files).

### Step 5. Start Sawtooth on the First Node

This step shows how to start all Sawtooth components: the validator,
REST API, transaction processors, and consensus engine. Use a separate
terminal window to start each component.

1.  Start the validator with the following command.

    Substitute your actual values for the component and network bind
    strings, public endpoint string, and peer list, as described in Ubuntu
    Prerequisites.

    ``` console
    $ sudo -u sawtooth sawtooth-validator \
    --bind component:{component-bind-string} \
    --bind network:{network-bind-string} \
    --bind consensus:{consensus-bind-string} \
    --endpoint {public-endpoint-string} \
    --peers {peer-list}
    ```

    Specify multiple peers in a comma-separated list, as in this
    example:

    > ``` none
    > --peers tcp://203.0.113.0:8800,198.51.100.0:8800
    > ```

    > **Important**
    >
    > For PBFT, specify all known peers in the initial network. (PBFT
    > requires at least four nodes.) If you want to add another PBFT node
    > later, see [Adding or Removing a PBFT
    > Node]({% link docs/1.2/sysadmin_guide/pbft_adding_removing_node.md%}).

    The following example uses these values:

    -   component bind address `127.0.0.1:4004` (the default value)

    -   network bind address and endpoint `192.0.2.0:8800` (a TEST-NET-1
        example address)

    -   consensus bind address and endpoint `192.0.2.0:5050`

    -   three peers at the public endpoints `203.0.113.0:8800`,
        `203.0.113.1:8800`, and `203.0.113.2:8800`.

        > ``` console
        > $ sudo -u sawtooth sawtooth-validator \
        > --bind component:tcp://127.0.0.1:4004 \
        > --bind network:tcp://192.0.2.0:8800 \
        > --bind consensus:tcp://192.0.2.0:5050 \
        > --endpoint tcp://192.0.2.0:8800 \
        > --peers tcp://203.0.113.0:8800,tcp://203.0.113.1:8800,tcp://203.0.113.2:8800
        > ```

    Leave this window open; the validator will continue to display
    logging output as it runs.

2.  Open a separate terminal window and start the REST API.

    ``` console
    $ sudo -u sawtooth sawtooth-rest-api -v
    ```

    If necessary, use the `--connect` option to specify a non-default
    value for the validator\'s component bind address and port, as
    described in Ubuntu Prerequisites. The following example shows the default
    value:

    > ``` none
    > $ sudo -u sawtooth sawtooth-rest-api -v --connect 127.0.0.1:4004
    > ```

3.  Start the transaction processors. Open a separate terminal window to
    start each one.

    As with the previous command, use the `--connect` option for each
    command, if necessary, to specify a non-default value for
    validator\'s component bind address and port.

    ``` console
    $ sudo -u sawtooth settings-tp -v
    ```

    ``` console
    $ sudo -u sawtooth intkey-tp-python -v
    ```

    ``` console
    $ sudo -u sawtooth xo-tp-python -v
    ```


    > Note
    >
    > The transaction processors for Integer Key (`intkey-tp-python`) and
    > XO (`xo-tp-python`) are not required for a Sawtooth network, but are
    > used for the other steps in this guide.

4.  (PoET only) Also start the PoET Validator Registry transaction
    processor in a separate terminal window.

    ``` console
    $ sudo -u sawtooth poet-validator-registry-tp -v
    ```

5.  Start the consensus engine in a separate terminal window.

    > Note
    >
    > Change the `--connect` option, if necessary, to specify a
    > non-default value for validator\'s consensus bind address and port.

    -   For PBFT:

        ``` console
        $ sudo -u sawtooth pbft-engine -vv --connect tcp://localhost:5050
        ```

    -   For PoET:

        ``` console
        $ sudo -u sawtooth poet-engine -vv --connect tcp://localhost:5050
        ```

    The terminal window displays log messages as the consensus engine
    connects to and registers with the validator. The output will be
    similar to this example:

    ``` console
    [2019-01-09 11:45:07.807 INFO     handlers] Consensus engine registered: ...

    DEBUG | {name:}:engine | Min: 0 -- Max: 0
    INFO  | {name:}:engine | Wait time: 0
    DEBUG | {name}::engine | Initializing block
    ```

### Step 6. Test the First Node

Although the Sawtooth network is not fully functional until other nodes
have joined the network, you can use any or all of the following
commands to verify the REST API and check that the genesis block has
been committed.

-   Confirm that the REST API is reachable.

    ``` console
    $ curl http://localhost:8008/blocks
    ```

    > **Note**
    >
    > The Sawtooth environment described this guide runs a local REST API
    > on each node. For a node that is not running a local REST API,
    > replace `localhost:8008` with the externally advertised IP address
    > and port.

    You should see a JSON response that is similar to this example:

    ``` console
    {
      "data": [
        {
          "batches": [
            {
              "header": {
                "signer_public_key": . . .
    ```

    If not, check the status of the REST API service and restart it, if
    necessary.

-   Check the list of blocks on the blockchain.

    ``` console
    $ sawtooth block list
    ```

    For the first node on a network, this list will contain only a few
    blocks. If this node has joined an existing network, the block list
    could be quite long. In both cases, the list should end with output
    that resembles this example:

    ``` console
    NUM  BLOCK_ID                                                                                                                          BATS  TXNS  SIGNER
    .
    .
    .
    2    f40b90d06b4a9074af2ab09e0187223da7466be75ec0f472f2edd5f22960d76e402e6c07c90b7816374891d698310dd25d9b88dce7dbcba8219d9f7c9cae1861  3     3     02e56e...
    1    4d7b3a2e6411e5462d94208a5bb83b6c7652fa6f4c2ada1aa98cabb0be34af9d28cf3da0f8ccf414aac2230179becade7cdabbd0976c4846990f29e1f96000d6  1     1     034aad...
    0    0fb3ebf6fdc5eef8af600eccc8d1aeb3d2488992e17c124b03083f3202e3e6b9182e78fef696f5a368844da2a81845df7c3ba4ad940cee5ca328e38a0f0e7aa0  3     11    034aad...
    ```

    Block 0 is the genesis block. The
    other two blocks contain the initial transactions for on-chain
    settings, such as setting the consensus algorithm.

-   (PBFT only) Ensure that the on-chain setting
    `sawtooth.consensus.pbft.members` lists the validator public keys of
    all PBFT member nodes on the network.
    a.  Connect to the first node (the one that created the genesis
        block).

    b.  Display the on-chain settings.

        ``` console
        $ sawtooth settings list
        ```

    c.  In the output, look for `sawtooth.consensus.pbft.members` and
        verify that it includes the public key for each node.

        ``` console
        sawtooth.consensus.pbft.members=["03e27504580fa15...
        ```


        > **Tip**
        >
        > You can use the `sawset proposal create` command to change this
        > setting. For more information, [Adding or Removing a PBFT
        > Node]({% link docs/1.2/sysadmin_guide/pbft_adding_removing_node.md%}).

### Step 7: Start the Other Nodes {#install-second-val-ubuntu-label}

After confirming basic functionality on the first node, start Sawtooth
on all other nodes in the initial network.

Use the procedure in [Step 5](#step-5-start-sawtooth-on-the-first-node).

> **Important**
>
> Be careful to specify the correct values for the component and network
> bind address, endpoint, and peers settings. Incorrect values could cause
> the network to fail.
>
> Start the same transaction processors that are running on the first
> node. For example, if you chose not to start `intkey-tp-python` and
> `xo-tp-python` on the first node, do not start them on the other nodes.

When each node\'s validator fully starts, it will peer with the other
running nodes.

# Step 8: Confirm Network Functionality {#confirm-nw-funct-ubuntu-label}

For the remaining steps, multiple nodes in the network must be running.

> -   PBFT requires at least four nodes.
> -   PoET requires at least three nodes.

1.  To check whether peering has occurred on the network, submit a peers
    query to the REST API on the first node.

    Open a terminal window on the first node and run the following
    command.

    > ``` console
    > $ curl http://localhost:8008/peers
    > ```

    > **Note**
    >
    > This environment runs a local REST API on each node. For a node that
    > is not running a local REST API, you must replace `localhost:8008`
    > with the externally advertised IP address and port. (Non-default
    > values are set with the `--bind` option when starting the REST API.)

    If this query returns a 503 error, the nodes have not yet peered
    with the Sawtooth network. Repeat the query until you see output
    that resembles the following example:

    > ``` console
    > {
    >     "data": [
    >     "tcp://validator-1:8800",
    >   ],
    >   "link": "http://rest-api:8008/peers"
    > }
    > ```

2.  Run the following Sawtooth commands on a node to show the other
    nodes on the network.

    a.  Run `sawtooth peer list` to show the peers of a particular node.
    b.  Run `sawnet peers list` to display a complete graph of peers on
        the network (available in Sawtooth release 1.1 and later).

3.  Verify that transactions are being processed correctly.

    a.  Submit a transaction to the REST API on the first node. This
        example sets a key named `MyKey` to the value 999.

        Run the following command in a terminal window on the first
        node.

        ``` console
        $ intkey set MyKey 999
        ```

    b.  Watch for this transaction to appear on the other node. The
        following command requests the value of `MyKey` from the REST
        API on the that node.

        Open a terminal window on another node to run the following
        command.

        ``` console
        $ intkey show MyKey
        MyKey: 999
        ```

### Step 9. (Optional) Configure the Allowed Transaction Types {#configure-txn-procs-ubuntu-label}

By default, a validator accepts transactions from any transaction
processor. However, Sawtooth allows you to limit the types of
transactions that can be submitted.

For this procedure, see [Setting Allowed
Transactions]({% link docs/1.2/sysadmin_guide/setting_allowed_txns.md%}).


<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
