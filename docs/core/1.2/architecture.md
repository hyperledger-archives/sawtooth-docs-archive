---
title: Architecture Guide
---

The following diagram shows a high-level view of the Sawtooth
architecture.

This guide describes the design and architecture of Hyperledger
Sawtooth, an enterprise blockchain platform for building distributed
ledger applications and networks.

This guide starts by explaining the important concepts of
`global state`{.interpreted-text role="term"} and
`Sawtooth batches<batch>`{.interpreted-text role="term"}. Next, it
describes key parts of the `validator`{.interpreted-text role="term"}
and other core features, including the journal for block management,
consensus, transaction scheduling, permissioning, and more.

![](images/arch-sawtooth-overview.*){.align-center width="100.0%"}

::: toctree
architecture/global_state architecture/transactions_and_batches
architecture/journal architecture/scheduling architecture/rest_api
architecture/validator_network architecture/permissioning_requirement
architecture/injecting_batches_block_validation_rules
architecture/events_and_transactions_receipts PBFT Consensus
\<<https://sawtooth.hyperledger.org/docs/pbft/releases/latest/architecture.html>\>
PoET 1.0 Consensus \<architecture/poet>
:::
