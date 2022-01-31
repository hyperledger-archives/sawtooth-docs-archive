# Architecture Guide


The following diagram shows a high-level view of the Sawtooth
architecture.

This guide describes the design and architecture of Hyperledger
Sawtooth, an enterprise blockchain platform for building distributed
ledger applications and networks.

This guide starts by explaining the important concepts of
`global state` and `Sawtooth batches`. Next, it
describes key parts of the `validator` and other core features,
including the journal for block management, consensus, transaction
scheduling, permissioning, and more.


<img alt="Sawtooth architecture"
src="/images/1.2/arch-sawtooth-overview.svg">


* [Global State]({% link docs/1.2/architecture/global_state.md%})
* [Transactions and Batches]({% link docs/1.2/architecture/transactions_and_batches.md%})
* [Journal]({% link docs/1.2/architecture/journal.md%})
* [Transaction Scheduling]({% link docs/1.2/architecture/transaction_scheduling.md%})
* [REST API]({% link docs/1.2/architecture/rest_api.md%})
* [Sawtooth Network]({% link docs/1.2/architecture/validator_network.md%})
* [Permissioning Design]({% link docs/1.2/architecture/permissioning_requirement.md%})
* [Injecting Batches and On-Chain Block Validation Rules]({% link docs/1.2/architecture/injecting_batches_block_validation_rules.md%})
* [Events and Transaction Receipts]({% link docs/1.2/architecture/events_and_transactions_receipts.md%})

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
