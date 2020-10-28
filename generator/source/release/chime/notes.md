---
layout: page
hide: true
title: Hyperledger Sawtooth 1.2 (Chime)
permalink: /release/chime/
release: 1.2
release-name: chime
# Copyright (c) 2019 Cargill Incorporated
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/
---

<a href="top"></a>

Hyperledger Sawtooth 1.2 (Chime) is now available.  See the [latest
documentation](https://sawtooth.hyperledger.org/docs/core/releases/1.2/) to
get started.

This page describes the new and changed features in Hyperledger Sawtooth 1.2
(since release 1.1).  Information is organized in the following categories:

- [New Features](#new-features)
- [Non-Breaking Changes](#non-breaking-changes)
- [Documentation Changes](#documentation-changes)

# Hyperledger Sawtooth 1.2

## New Features

- Support for [Sawtooth PBFT consensus engine version
  1.0](https://sawtooth.hyperledger.org/docs/pbft/releases/1.0.1/).
  - Sawtooth PBFT is the recommended consensus mechanism. It is designed to
    handle small to medium network sizes with finality and byzantine fault
    tolerance.
  - Sawtooth PoET is designed for larger networks at the expense of slower /
    probabilistic finality.
  - Sawtooth Raft is designed for small to medium networks but performs more
    slowly than Sawtooth PBFT and lacks byzantine fault tolerance.
- Mobile SDKs for iOS (Swift) and Android (as part of the Java SDK).
  - [Sawtooth SDK Swift](https://github.com/hyperledger/sawtooth-sdk-swift)
  - [Sawtooth SDK Java](https://github.com/hyperledger/sawtooth-sdk-java)
- Support for raw transaction headers, as specified in [Sawtooth RFC
  #23](https://github.com/hyperledger/sawtooth-rfcs/blob/master/text/0023-raw-txn-header.md).
  This feature is backward compatible via the use of a protocol version indicator.
- All core transaction families are compatible with [Sawtooth Sabre release
  0.4](https://sawtooth.hyperledger.org/docs/sabre/releases/0.4.0/).

[> back to top <](#top)

## Non-breaking changes

- PoET has the following patches:
  - Resolve a security defect where a correctly admitted validator could game
    its wait times. Thanks to Huibo Wang, Guoxing Chen, Yinqian Zhang,
    and Zhiqiang Lin for analyzing the poet implementation and identifying the
    defect.
  - Support the updated attestation service API
- A new BlockManager has been implemented, as specified in [Sawtooth RFC
  #5](https://github.com/hyperledger/sawtooth-rfcs/pull/5). This new feature
  improves block management and helps remove a known race condition that can cause
  network nodes to fork.
- Several core transaction families have been rewritten in Rust: Settings,
  Identity, and BlockInfo.
- All SDKs are in separate repositories for improved build time and release
  scheduling. The following SDKs were moved to their own repositories in this
  release:
  - [hyperledger/sawtooth-sdk-go](https://github.com/hyperledger/sawtooth-sdk-go)
  - [hyperledger/sawtooth-sdk-python](https://github.com/hyperledger/sawtooth-sdk-python)
  - [hyperledger/sawtooth-sdk-rust](https://github.com/hyperledger/sawtooth-sdk-rust)
- The Devmode consensus engine has been moved to a separate repository:
  [hyperledger/sawtooth-devmode](https://github.com/hyperledger/sawtooth-devmode).
- Consensus support has been modified to improve compatibility with PBFT
  consensus.
- Cache performance has been improved for settings and identity state.
- Duplicate signature validations have been eliminated.
- Duplicate batches are now removed from the pending queue and candidate blocks
- Transaction processors now receive a registration ACK before receiving
  transaction process requests.
- Long-lived futures are expired when awaiting network message replies.
- Logs now have fewer duplicate log messages.

[> back to top <](#top)

## Documentation changes

- Improved summary of the supported consensus algorithms: PBFT, PoET, Raft, and
  Devmode. See
  ["Introduction"](https://sawtooth.hyperledger.org/docs/core/releases/1.2/introduction.html).
- Complete procedures for configuring PBFT consensus on a Sawtooth node and
  changing network membership. For procedures to configure either PBFT or PoET
 consensus, see:
- [“Creating a Sawtooth Test Network” (Application Developer’s
  Guide)](https://sawtooth.hyperledger.org/docs/core/releases/1.2/app_developers_guide/creating_sawtooth_network.html)
- [“Setting Up a Sawtooth Network” (System Administrator’s
  Guide)](https://sawtooth.hyperledger.org/docs/core/releases/1.2/sysadmin_guide/setting_up_sawtooth_network.html)
- New Swift and Java tutorials, including SDK reference documentation, for
  writing native mobile client applications for Sawtooth. See the Java and Swift
  links in [“Using the Sawtooth
  SDKs”](https://sawtooth.hyperledger.org/docs/core/releases/1.2/app_developers_guide/using_the_sdks.html).
- Technical corrections, bug fixes, and general improvements throughout the
  documentation.

[> back to top <](#top)
