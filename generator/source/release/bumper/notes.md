---
layout: page
hide: true
title: Bumper Release Notes
permalink: /release/bumper/
release: 1.1
release-name: bumper
# Copyright (c) 2018 Bitwise IO, Inc.
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/
---

<a href="top"></a>

Hyperledger Sawtooth 1.1 (Bumper) is now available. See the [latest
documentation](https://sawtooth.hyperledger.org/docs/core/releases/latest/) to
get started.

The following release notes describe the new and changed features in
Hyperledger Sawtooth 1.1 (since release 1.0). They have been organized into the
following categories:

- [Core](#core): Changes to core Sawtooth components
- [Consensus](#consensus): Changes to the consensus API, changes to existing
  consensus algorithm implementations, and announcements for new consensus
  algorithm support
- [Documentation](#documentation): Changes to the Sawtooth documentation
- [Smart Contract Engines](#smart-contract-engines): Changes to smart contract
  engines supported by Sawtooth
- [DevOps and CI](#devops-and-ci): Changes to the project's build tools and CI
  process
- [Website](#website): Changes to the Sawtooth website content, structure, and
  development processes

# Core

## New Features

- The consensus API has been completely redesigned. Consensus has been moved to
  a separate process, called a “consensus engine”. See [Hyperledger Sawtooth
  Consensus](#hyperledger-sawtooth-consensus), below for more details.
- State pruning is now supported at a configurable block horizon. This helps
  limit the total storage requirements for global state by removing historic
  state after the configured horizon. Check out the [state pruning
  RFC](https://github.com/hyperledger/sawtooth-rfcs/pull/8) for more details.
- Several example transaction processors have been rewritten in Rust, including
  IntegerKey (intkey), XO, and Smallbank.
- A new /status endpoint and sawtooth status show command are available to
  query status information for an active validator.
- New metrics have been added for submitted batches and transactions, thread
  pools, transaction processing, and dispatcher queue sizes.
- The internal metrics library has been refactored to be more modular and
  similar to the logging API.
- The gossip protocol used by Sawtooth is now versioned to support
  backwards-compatible upgrades in the future.

## Major Improvements

- The Rust SDK has matured. It now includes libraries for signing, writing
  transaction processors, and writing consensus engines, along with supporting
  information for the auto-generated SDK documentation.
- Several key items have been rewritten in Rust: validator CLI argument
  parsing, global state database (and supporting views), ChainController, and
  BlockPublisher. This change allows some code to be executed outside of the
  Python global interpreter lock (GIL).
- The ChainController and BlockPublisher have been substantially refactored to
  be more modular and support validating blocks in parallel.

## Minor Improvements

- Transaction processors can now report the maximum number of transactions that
  they can handle at a time. The validator will only request that many
  transactions at a time for processing.
- Logging has been improved to reduce the volume and improve the quality of
  generated log messages.
- Discarded blocks are now explicitly canceled to avoid wasting effort on
  blocks that will never be chosen.
- Deserialization is now cached for messages that have multiple handlers to
  avoid redundant work.
- Peers are requested only from connections that have passed authorization.
- Client message handling has been moved to a separate thread pool to avoid
  interfering with transaction processing.
- The parallel scheduler has been refactored to use a generic PredecessorTree
  data structure.

## Bug Fixes

- Fixed a bad internal configuration that allowed the Completer and
  ChainController to get out of sync about which blocks were in the system
- Add missing handlers for client messages
- Correctly decrement time to live on gossip messages
- Handled an edge case where a new node will not get the chain until a new
  block is published
- Stopped trying to unschedule transactions that haven't been scheduled yet
- Fixed a number of concurrency issues where data structure were being accessed
  concurrently without protection or with incorrect usage of synchronization
  primitives
- Fixed a bug where a future could be executed in the event loop instead of in
  a thread pool
- Only broadcast to peers that have completed authorization
- Ensured that candidate blocks are only built in the BlockPublisher thread

## Upgrade Considerations

- The consensus setting sawtooth.consensus.algorithm setting has been
  deprecated and no longer has an effect. Instead, use the settings
  sawtooth.consensus.algorithm.name and sawtooth.consensus.algorithm.version to
  set the name and version of the consensus engine.
- All SDKs except Rust and Python have been moved out of core and into [separate
  repositories](https://github.com/hyperledger?utf8=%E2%9C%93&q=sawtooth-sdk&type=&language=).
- PoET has been moved to [a new repository](https://github.com/hyperledger/sawtooth-poet).

[> back to top <](#top)

# Consensus

Hyperledger Sawtooth 1.1 includes a new consensus interface that enables
features like language independence for consensus algorithms. Consensus
protocols are now implemented as separate processes called “consensus engines",
which enables more consensus options for Sawtooth. Check out the [consensus API
RFC](https://github.com/hyperledger/sawtooth-rfcs/pull/4) for more details.

- The network deployment tools have been updated to launch the consensus
  processes. If you have made your own custom launch scripts, note that the
  consensus engine now runs as its own process, like other services such as the
  REST API and transaction processors. Please see the example Sawtooth
  docker-compose files for reference.
- This release includes the following consensus engines based on the new
  consensus API:
  - [PoET consensus engine](https://github.com/hyperledger/sawtooth-poet), a
    refactored version of the previous PoET consensus module.
  - Dev mode consensus engine, based on the previous dev mode consensus module.
  - New [PBFT consensus engine](https://github.com/hyperledger/sawtooth-pbft),
    based on the PBFT consensus algorithm.
  - New [Raft consensus engine](https://github.com/hyperledger/sawtooth-raft),
    based on the Raft consensus algorithm.

## Sawtooth PoET

Sawtooth PoET consensus can be deployed as a pure Python application using a
simulated enclave, called PoET simulator, or with a C++ module implementing an
IntelⓇ Software Guard Extensions (IntelⓇ SGX) enclave, called PoET-SGX.

- PoET simulator is available in the 1.1 release as a consensus engine. If you
  are using PoET simulator consensus, we recommend upgrading to Sawtooth 1.1.
- PoET-SGX has not been validated on Sawtooth 1.1. Users relying on PoET-SGX
  are recommended to remain on Sawtooth 1.0. We are working on a new
  implementation of poet and its TEE enclave, which is anticipated for a point
  release in the near future.

## Sawtooth Raft

Hyperledger Sawtooth 1.1 supports a developer preview of [Sawtooth
Raft](https://github.com/hyperledger/sawtooth-raft), a Rust implementation of
Raft based on the [raft-rs](https://github.com/pingcap/raft-rs) library used by
[TiKV](https://github.com/tikv/tikv). The Sawtooth Raft consensus engine uses
the new consensus API.

Sawtooth Raft is still in the prototype phase and is under active development.

## Sawtooth PBFT

The Hyperledger Sawtooth 1.1 release includes the [Sawtooth PBFT consensus
engine](https://github.com/hyperledger/sawtooth-pbft). Sawtooth PBFT is based
on the [original PBFT paper](http://pmg.csail.mit.edu/papers/osdi99.pdf) with
several extensions to make it compatible with Sawtooth and to resolve known
issues with the original protocol. See the RFCs for more details:

- [Initial RFC](https://github.com/hyperledger/sawtooth-rfcs/pull/19)
- [Extension RFC to mitigate fair ordering and silent leader issues](https://github.com/hyperledger/sawtooth-rfcs/pull/29)
- [Extension RFC to enable observer validation of consensus](https://github.com/hyperledger/sawtooth-rfcs/pull/30)

Sawtooth PBFT is still in the prototype phase and is under active development.

[> back to top <](#top)


# Documentation

In addition to updates for Hyperledger Sawtooth 1.1 features, technical
corrections, and bug fixes throughout, the Sawtooth documentation has the
 following changes and improvements.

## Application Developer’s Guide

- Improved procedures for running a single Sawtooth node with Docker, Ubuntu,
  or AWS, plus a new Kubernetes procedure. See [Setting Up a Sawtooth
  Application Development Environment](https://sawtooth.hyperledger.org/docs/core/nightly/master/app_developers_guide/installing_sawtooth.html).
- New procedures to add multiple nodes to a network for Docker, Ubuntu, and
  Kubernetes. See [Creating a Sawtooth Network](https://sawtooth.hyperledger.org/docs/core/nightly/master/app_developers_guide/creating_sawtooth_network.html).
- Updated procedure for trying the example tic-tac-toe transaction processor in
  Sawtooth. See [Playing with the XO Transaction Family](https://sawtooth.hyperledger.org/docs/core/nightly/master/app_developers_guide/intro_xo_transaction_family.html).
- Improved and expanded tutorials for using the Sawtooth JavaScript, Go, and
  Python SDKs, plus a new Rust version. See [Using the Sawtooth SDKs](https://sawtooth.hyperledger.org/docs/core/nightly/master/app_developers_guide/using_the_sdks.html).

## API References

- New Rust SDK documentation; see
  [Rust SDK API Reference](https://sawtooth.hyperledger.org/docs/core/nightly/master/sdks.html#rust).

## System Administrator’s Guide

- Improved procedure for setting up a Sawtooth network with PoET simulator
  consensus, including new steps to change off-chain settings and test the
  system. See [Setting Up a Sawtooth Node](https://sawtooth.hyperledger.org/docs/core/nightly/master/sysadmin_guide/setting_up_sawtooth_poet-sim.html).
- Updated procedure to configure a proxy server. See [Using a Proxy Server to
  Authorize the REST API](https://sawtooth.hyperledger.org/docs/core/nightly/master/sysadmin_guide/rest_auth_proxy.html).
- Updated permission information. See [Configuring Validator and Transactor
  Permissions](https://sawtooth.hyperledger.org/docs/core/nightly/master/sysadmin_guide/configuring_permissions.html).
- New procedure to configure Sawtooth to display Grafana metrics. See [Using
  Grafana to Display Sawtooth Metrics](https://sawtooth.hyperledger.org/docs/core/nightly/master/sysadmin_guide/grafana_configuration.html).

## Architecture Guide

- General improvements and a new architecture overview.

## Glossary

- New glossary of Sawtooth terminology.

[> back to top <](#top)

# Smart Contract Engines

## Sawtooth Seth

Hyperledger Sawtooth 1.1 continues to support [Sawtooth
Seth](https://github.com/hyperledger/sawtooth-seth), an Ethereum-compatible
transaction family for the Hyperledger Sawtooth platform. Significant changes
in this release:

- A new seth CLI that is capable of communicating with the existing JSON-RPC
  API. This CLI will let us test the JSON-RPC API, and will eventually allow us
  to deprecate the existing REST-API-based CLI, which is now available in the
  seth-cli-go container.
- The existing JSON-RPC API has been updated to align more closely with
  existing Ethereum JSON-RPC implementations, particularly in how it handles
  account management. This change provides better inter-compatibility with
  off-the-shelf Ethereum tooling.
- The Burrow version was updated from 0.17 to 0.21 and vendor dependencies were
  removed.
- The build process and dependencies have been updated and aligned with current
  best practices, such as formatting the Rust code and linting it with Clippy.
- The documentation has been updated with minor corrections.
- Several minor bugs have been fixed, such as a segfault occurring when
  creating an account with a nonce, and invalid addresses being displayed in
  contract listing.
- This release includes Dockerfiles suitable for publishing to Docker Hub.

## Sawtooth Sabre

Hyperledger Sawtooth 1.1 supports [Sawtooth
Sabre](https://github.com/hyperledger/sawtooth-sabre), a transaction family
that implements on-chain smart contracts executed in a WebAssembly virtual
machine. Sabre smart contracts are stored on chain and executed using the Sabre
transaction processor.

Sawtooth Sabre includes an SDK for writing Sabre smart contracts in Rust. The
smart contracts can be written in such a way that they can be compiled into
transaction processor and run without Sabre. This also makes it easy to convert
already-written Rust transaction processors to a Sabre smart contract.

**Note:** Sabre is currently at version 0.1 and is under active development.

[> back to top <](#top)

# DevOps and CI

## Build System Improvements

- The `bin/build_all` and related build scripts have been replaced with
  docker-compose.
- The docker-compose files now have 'build' sections, so that pre-building
  steps aren't necessary and all required images can be built with a single
  `docker-compose up` command.
- The sawtooth-dev-{lang} Dockerfiles are deprecated. Each component now has
  its own Dockerfile for development.
- Check out the [build system
  RFC](https://github.com/hyperledger/sawtooth-rfcs/pull/25) for more details.

**Note**: Requires Docker Engine 18.02.0 or later.

## Docker

- Each component now has "installed" Dockerfiles that utilize multi-stage
  builds. These Dockerfiles are suitable for publishing to a docker registry.

**Note**: Requires Docker Engine 18.02.0 or later.

## Kubernetes

- This release includes example files for two Kubernetes deployments: a
  five-node network using PoET simulator and a single-node environment using
  devmode consensus. The Application Developer’s Guide describes how to use
  this example files; see [Hyperledger Sawtooth
  Documentation](#hyperledger-sawtooth-documentation), below.

[> back to top <](#top)

# Website

The Sawtooth website,
[sawtooth.hyperledger.org](https://sawtooth.hyperledger.org), has been updated
with this release. This update includes:

- A new home page for Hyperledger Sawtooth that provides links to examples,
  documentation, and timely, informational posts.
- The structure to update the static information pages and posts more easily
- The ability to conduct agile changes, reviews, and approvals through Github

Expect changes on a regular basis. In the short term, we plan to:

- Improve website navigation
- Apply consistent formatting throughout the site
- Automate the website build and deployment, based on the model for Sawtooth
  PRs

[> back to top <](#top)

---

[The Hyperledger Sawtooth Team](https://sawtooth.hyperledger.org/)
