---
title: Setting the Allowed Transaction Types (Optional)
---

By default, a validator accepts transactions from any transaction
processor. However, Sawtooth allows you to limit the types of
transactions that can be submitted.

This setting, `sawtooth.validator.transaction_families`, improves the
Sawtooth network\'s security by ignoring any unrecognized transaction
processors. It is an on-chain setting, which means that the change is
submitted on one node; the other nodes in the network apply the settings
change when they receive the block with this transaction. Note that the
`Settings transaction processor <../transaction_family_specifications/settings_transaction_family>`{.interpreted-text
role="doc"} is required to handle on-chain configuration settings.

In this procedure, you will configure the Sawtooth network to limit the
accepted transaction types to those from this network\'s transaction
processors (as started in `systemd`{.interpreted-text role="doc"}).

1.  Log into the node with your public/private key files.

    ::: important
    ::: title
    Important
    :::

    If the genesis block was created with the first validator\'s key,
    and there are no other
    `authorized users <adding_authorized_users>`{.interpreted-text
    role="doc"}, you **must** run this procedure on the same node that
    created the genesis block, because the `sawset proposal create`
    command requires the private validator key from that node.
    :::

2.  Use the `sawset proposal create` command to create and submit a
    batch of transactions that changes the allowed transaction types.

    ::: note
    ::: title
    Note
    :::

    For `{PRIVATE-KEY}`, specify the path to the private key file for an
    authorized user or validator, such as the key used to create the
    genesis block. For more information, see
    `/sysadmin_guide/adding_authorized_users`{.interpreted-text
    role="doc"}.
    :::

    -   For PBFT:

        ``` console
        $ sudo sawset proposal create --key {PRIVATE-KEY} \
        sawtooth.validator.transaction_families='[{"family":"sawtooth_identity", "version":"1.0"}, {"family":"intkey", "version": "1.0"}, {"family":"sawtooth_settings", "version":"1.0"}]'
        ```

    -   For PoET:

        ``` console
        $ sudo sawset proposal create --key {PRIVATE-KEY} \
        sawtooth.validator.transaction_families='[{"family":"sawtooth_identity", "version":"1.0"}, {"family":"intkey", "version": "1.0"}, {"family":"sawtooth_settings", "version":"1.0"}, {"family":"sawtooth_validator_registry", "version":"1.0"}]'
        ```

    This command sets `sawtooth.validator.transaction_families` to a
    JSON array that specifies the family name and version of the
    following transaction processors:

    -   `sawtooth_identity` (Identity)
    -   `intkey` (IntegerKey)
    -   `sawtooth_settings` (Settings)
    -   (PoET only) `sawtooth_validator_registry` (PoET Validator
        Registry)

    See
    `transaction family specification <../transaction_family_specifications>`{.interpreted-text
    role="doc"} for the family names and versions of all Sawtooth
    transaction processors.

3.  Run the following command to check the setting change.

    ``` console
    $ sawtooth settings list
    ```

    The output should be similar to this example:

    -   For PBFT:

        ``` console
        sawtooth.consensus.algorithm.name=pbft
        sawtooth.consensus.algorithm.version=1.0
        sawtooth.consensus.pbft.members="03e27504580fa15...
        sawtooth.publisher.max_batches_per_block: 200
        sawtooth.settings.vote.authorized_keys: 03e27504580fa15...
        sawtooth.validator.transaction_families: [{"family": "in...
        ```

    -   For PoET:

        ``` console
        sawtooth.consensus.algorithm.name: PoET
        sawtooth.consensus.algorithm.version: 0.1
        sawtooth.poet.initial_wait_time: 15
        sawtooth.poet.key_block_claim_limit: 100000
        sawtooth.poet.report_public_key_pem: -----BEGIN PUBL...
        sawtooth.poet.target_wait_time: 15
        sawtooth.poet.valid_enclave_basenames: b785c58b77152cb...
        sawtooth.poet.valid_enclave_measurements: c99f21955e38dbb...
        sawtooth.poet.ztest_minimum_win_count: 100000
        sawtooth.publisher.max_batches_per_block: 200
        sawtooth.settings.vote.authorized_keys: 03e27504580fa15...
        sawtooth.validator.transaction_families: [{"family": "in...
        ```

4.  You can also check the log file for the Settings transaction
    processor, `/var/log/sawtooth/logs/settings-{xxxxxxx}-debug.log` for
    a `TP_PROCESS_REQUEST` message. (Note that the Settings log file has
    a unique string in the file name.)

    The message will resemble this example:

    -   For PBFT:

        ``` none
        [20:07:58.039 [MainThread] core DEBUG] received message of type: TP_PROCESS_REQUEST
        [20:07:58.190 [MainThread] handler INFO] Setting setting sawtooth.validator.transaction_families changed from None to [{"family": "intkey", "version": "1.0"}, {"family":"sawtooth_settings", "version":"1.0"}]'
        ```

    -   For PoET:

        ``` none
        [20:07:58.039 [MainThread] core DEBUG] received message of type: TP_PROCESS_REQUEST
        [20:07:58.190 [MainThread] handler INFO] Setting setting sawtooth.validator.transaction_families changed from None to [{"family": "intkey", "version": "1.0"}, {"family":"sawtooth_settings", "version":"1.0"}, {"family":"sawtooth_validator_registry", "version":"1.0"}]'
        ```
