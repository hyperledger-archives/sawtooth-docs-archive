# Adding or Removing a PBFT Node

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

Membership of a Sawtooth PBFT network is controlled by the on-chain setting
`sawtooth.consensus.pbft.members`. An administrator must update this setting
when [adding a new node](#adding-a-pbft-node-label) or [removing an existing
node](#removing-a-pbft-node-label).

All nodes in the network monitor this setting. When a node detects a
change, it updates its local list of PBFT members to match the new list.

## Adding a PBFT Node {#adding-a-pbft-node-label}

To add a new node to an existing PBFT network, you will install and
configure the node, start it and wait for it to catch up with the rest
of the network. Next, the administrator of an existing node will update
`sawtooth.consensus.pbft.members`.

You can add several nodes at the same time.

1. Install and configure Sawtooth on the new node, as described in
   [Setting Up a Sawtooth Network]({% link
   docs/1.2/sysadmin_guide/setting_up_sawtooth_network.md %}). Note
   these important items:

   - Skip the procedure to create a genesis block.

   - In the
     [off-chain validator settings]({% link
     docs/1.2/sysadmin_guide/setting_up_sawtooth_network.md
     %}#sysadm-configure-validator-label) , set `peers` to include all other
     nodes in the network. (A PBFT network must fully peered.) If you copy this
     setting from another node, be sure to include that node in the list of
     peers.

     You do not need to update the peer list on other nodes, because
     Sawtooth peering is bidirectional.

2. Start the new node. It will join the Sawtooth network and start the
   block catch-up procedure, where it receives and commits the blocks
   that are already on the blockchain. (For details, see the [PBFT node
   catch-up
   RFC](https://github.com/hyperledger/sawtooth-rfcs/blob/master/text/0031-pbft-node-catchup.md).)

3. Wait for the node to catch up to the rest of the network (get within
   a few blocks of the chain head). If the new node becomes a PBFT
   member before it has caught up, the entire network could slow down
   or stall while the new member node catches up.

   This process can take a while, depending on the blockchain size,
   node\'s hardware, and network speed. You can look at the logs or run
   [sawtooth block list]({% link docs/1.2/cli/sawtooth.md
   %}#sawtooth-block-list-label) to check on the new node\'s progress.

4. Send the new node\'s public validator key to the administrator who
   will update `sawtooth.consensus.pbft.members`. Use this command to
   display the public validator key:

   ``` console
   $ cat /etc/sawtooth/keys/validator.pub
   ```

   This command assumes that the validator key is stored in the default
   location, `/etc/sawtooth/keys`. If not, use the location specified
   by the `key_dir` setting (see [Path Configuration File]({% link
   docs/1.2/sysadmin_guide/configuring_sawtooth.md %}#path-configuration-file)).

5. An authorized user must update the on-chain setting
   `sawtooth.consensus.pbft.members` to include the public validator
   key of the new node.

   a. Log into an existing member node as a user who has permission to
      change on-chain settings (by default, the owner of the private
      key used to create the genesis block). For more information, see
      [Adding Authorized Users for Settings Proposals]({% link
      docs/1.2/sysadmin_guide/adding_authorized_users.md %}).

   b. List the current PBFT member nodes:

      ``` console
      $ sawtooth settings list --filter sawtooth.consensus.pbft.members
      ```

      Copy the list of validator keys to use in the next step.

   c. Submit a transaction that specifies the new list of all PBFT
      member nodes (the previous list plus the new node\'s key).

      > **Important**
      >
      > BE VERY CAREFUL! Make sure to specify the full list of keys. Use
      > double quotes around each key and surround the entire members
      > string in single quotes, as shown in the following example.
      >
      > Double-check each key before you run this command, because a
      > typo could stall the network.

      ``` console
      $ sawset proposal create \
        --key /etc/sawtooth/keys/validator.priv \
        sawtooth.consensus.pbft.members='[previous-list,"NEW-KEY"]'
      ```

      If there are no errors, this change will be committed to the
      blockchain.

When all nodes have detected the change and updated their local copy of
the member list, the new member node begins to participate in the PBFT
network.

## Removing a PBFT Node {#removing-a-pbft-node-label}

To remove an existing node from a PBFT network, an authorized user will
delete the node\'s validator key from the
`sawtooth.consensus.pbft.members` setting.

You can delete several nodes at the same time.

> **Note**
>
> PBFT consensus requires a network with at least four nodes. A network
> with fewer than four nodes will fail.

1. Send the node\'s public validator key to the administrator who will
   update `sawtooth.consensus.pbft.members`. On the node you want to
   remove, use this command to display the public validator key:

   ``` console
   $ cat /etc/sawtooth/keys/validator.pub
   ```

2. An authorized user must update the on-chain setting
   `sawtooth.consensus.pbft.members` to delete the public validator key
   of the node to be removed.

   a. Log into an existing member node as a user who has permission to
      change on-chain settings (by default, the owner of the private
      key used to create the genesis block). For more information, see
      [Adding Authorized Users for Settings Proposals]({% link
      docs/1.2/sysadmin_guide/adding_authorized_users.md %}).

   b. List the current PBFT member nodes:

      ``` console
      $ sawtooth settings list --filter sawtooth.consensus.pbft.members
      ```

   c. Submit a transaction that specifies the new list of PBFT member
      nodes (the previous list, minus the key of the node or nodes to
      be removed).

      > **Important**
      >
      > BE VERY CAREFUL! Make sure to specify the correct list of keys.
      > Use double quotes around each key and surround the entire
      > members string in single quotes, as shown in the following
      > example.
      >
      > Double-check each key before you run this command, because a
      > typo could stall the network.

      ``` console
      $ sawset proposal create \
        --key /etc/sawtooth/keys/validator.priv \
        sawtooth.consensus.pbft.members='[UPDATED-LIST]'
      ```

      If there are no errors, this change will be committed to the
      blockchain.

3. Make sure that change has been committed. You can check the setting
   from any node.

   ``` console
   $ sawtooth settings list --filter sawtooth.consensus.pbft.members
   ```

   > **Important**
   >
   > Until the settings change is committed on all nodes, the removed
   > node is considered part of the network. If the node is shut down too
   > soon, it could be impossible to commit the settings change if there
   > are too few working nodes. This is especially important on a small
   > network or when removing several nodes at once.

   When all nodes have detected the change and updated their local copy
   of the member list, the node being removed stops participating in
   the PBFT network.

4. Shut down the old node.

   a. To stop the Sawtooth services, see [Stop or Restart Sawtooth Services]({%
      link docs/1.2/sysadmin_guide/setting_up_sawtooth_network.md
      %}#stop-restart-sawtooth-services-label).
   b. To delete blockchain data, logs, and keys from this node, see [Step 14:
      Stop Sawtooth Components]({% link docs/1.2/app_developers_guide/installing_sawtooth.md
      %}#stop-sawtooth-ubuntu-label).

   > **Note**
   >
   > You do not need to remove this node from the `peers` list on the
   > other nodes (in the [off-chain validator settings]({% link docs/1.2/sysadmin_guide/setting_up_sawtooth_network.md %}#changing-off-chain-settings-with-configuration-files).
   > The network will operate correctly even if a removed node is still
   > in this list.
