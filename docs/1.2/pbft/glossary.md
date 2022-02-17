# Glossary

Block

:   Part of the
    [blockchain](https://en.wikipedia.org/wiki/Block%20chain) that
    contains one or more operations (called *transactions*)
    and a link to the previous block.

Client

:   Machine that sends requests to and receives replies from the network
    of Sawtooth nodes. PBFT has no direct interaction with clients; the
    validator bundles all client requests into blocks and sends them
    through the consensus API to the consensus engine.

Consensus API

:   Sawtooth component that abstracts consensus-related interactions
    between the validator and a consensus engine. The consensus API
    allows *dynamic consensus*, a feature that allows a
    choice of consensus for a Sawtooth network.

Consensus engine

:   Component that provides consensus functionality for a Sawtooth
    network. The consensus engine communicates with the validator
    through the consensus API.

Consensus seal

:   Proof that a block went through consensus.

Leader

:   See [primary node](#primary-node)

Member node

:   Sawtooth node that participates in PBFT consensus. Membership is controlled
    by the on-chain setting `sawtooth.consensus.pbft.members`. Each member node
    is either a [primary node](#primary-node) or a [secondary
    node](#secondary-node).

Message

:   Consensus-related information that nodes send to each other. For
    more information, see [Consensus Messages]({% link
    docs/1.2/pbft/architecture.md %}#consensus-messages-label).

Node

:   Virtual or physical machine running all the components necessary for
    a working Sawtooth blockchain: a validator, an optional REST API, at
    least one transaction processor, and the PBFT consensus engine.

    The [original PBFT
    paper](http://pmg.csail.mit.edu/papers/osdi99.pdf) uses the terms
    *server* or *replica* instead of *node*.

Primary node <a name="primary-node"></a>

:   Node that directs the consensus process for the network. (The other
    nodes in the network participate as secondary nodes.) The primary
    node creates each block and publishes it to the network, then starts
    the consensus process for the block.

Secondary node <a name="secondary-node"></a>

:   Auxiliary node used for consensus. A Sawtooth network using PBFT
    consensus has one [primary node](#primary-node); all
    other nodes are secondary nodes.

    The [original PBFT
    paper](http://pmg.csail.mit.edu/papers/osdi99.pdf) uses the term
    *backup* instead of *secondary node*.

Transaction processor

:   Sawtooth component that validates transactions and updates state based on
    rules defined by the associated *transaction family*. (These rules specify
    the business logic, also called a *smart contract*, for the transaction
    processor.) For more information, see [Transaction Family Specifications]({%
    link docs/1.2/transaction_family_specifications/index.md %}).

Validator

:   Sawtooth component that is responsible for interactions with the
    blockchain. The validator interacts with the consensus engine
    through the consensus API.

View

:   The period of time when the current primary node is in charge. The
    view changes at regular intervals (controlled by the on-chain
    setting `sawtooth.consensus.pbft.forced_view_change_interval`), and
    when the primary node is deemed faulty. For more information, see [View
    Changes: Choosing a New Primary]({% link docs/1.2/pbft/architecture.md
    %}#view-changes-choosing-primary-label).

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
