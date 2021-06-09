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
