---
title: Introduction
---

The primary goal of the Sawtooth-Ethereum integration project,
affectionately dubbed \"Seth\", is to add support for running Ethereum
Virtual Machine smart contracts to the Hyperledger Sawtooth platform. In
order to make this possible, the Hyperledger Sawtooth project worked
with the [Hyperledger Burrow](https://github.com/hyperledger/burrow)
project to integrate their EVM implementation, the Burrow EVM, into with
the Hyperledger Sawtooth platform.

The secondary goal of Seth is to make it easy to port existing EVM smart
contracts and DApps that depend on them to Sawtooth. This has been
largely accomplished by replicating the [Ethereum JSON RPC
API](https://github.com/ethereum/wiki/wiki/JSON-RPC).

Seth is composed of three components:

1.  The `seth <seth-cli-reference-label>`{.interpreted-text role="ref"}
    client
2.  The `seth-tp <seth-tp-reference-label>`{.interpreted-text
    role="ref"} transaction processor
3.  The `seth-rpc <seth-rpc-reference-label>`{.interpreted-text
    role="ref"} server

The `seth` client is the user-facing CLI tool for interacting with a
Sawtooth network that has Seth deployed on it. The `seth-tp` transaction
processor is the component that implements \"Ethereum-like\"
functionality within the Sawtooth platform. Running Seth on a Sawtooth
network is equivalent to connecting a `seth-tp` process to all validator
nodes. The `seth-rpc` server is an HTTP server that acts as an adapter
between the [Ethereum JSON RPC
API](https://github.com/ethereum/wiki/wiki/JSON-RPC) and the client
interface provided by Sawtooth.

It is important to note that Seth is not a complete Ethereum
implementation. The Sawtooth platform has made fundamental design
decisions that differ from those made by the Ethereum platform. While
most EVM smart contracts can be run on the Sawtooth network, there are
some differences to be aware of:

1.  Blocks within Sawtooth are not identified by a 32-byte block hash.
    They are instead identified by a 64-byte header signature. When
    running smart contracts that use the BLOCKHASH instruction, the
    first 32 bytes of the header signature are used in place of a block
    hash.
2.  The public Ethereum network depends on economic incentives to limit
    execution resources. On the other hand, the Hyperledger Burrow
    project depends on permissions to control and limit execution
    resources. Seth currently only supports the permissioned-network
    model. As a consequence, \"gas\" is free but finite and permissions
    can be applied to all accounts.
3.  Transaction execution within Sawtooth is modularized so that
    transactions cannot have knowledge of being executed within the
    context of a block chain. This feature has useful implications from
    a design perspective, such as simplifying the Sawtooth state
    transaction function. However, it is in direct opposition to
    transaction execution within Ethereum, in which transactions can
    depend on the block numbers, hashes, and timestamps. By default,
    these instructions are not supported by Seth. However, if the Block
    Info Transaction Family is running on the same network as Seth,
    these instructions will attempt to read from state at the addresses
    defined by that family.

::: note
::: title
Note
:::

Code documentation can be [found here](../cargo/seth/index.html).
:::
