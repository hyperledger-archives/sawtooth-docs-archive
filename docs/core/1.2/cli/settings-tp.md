---
title: settings-tp
---

The `settings-tp` command starts the Settings transaction processor,
which provides a methodology for storing on-chain configuration
settings.

**Note:** This transaction processor is required in order to apply
changes to on-chain settings.

The settings stored in state as a result of this transaction family play
a critical role in the operation of a validator. For example, the
consensus module uses these settings. In the case of PoET, one
cross-network setting is target wait time (which must be the same across
validators), that is stored as `sawtooth.poet.target_wait_time`. Other
parts of the system use these settings similarly; for example, the list
of enabled transaction families is used by the transaction processing
platform. In addition, pluggable components such as transaction family
implementations can use the settings during their execution.

This design supports two authorization options: either a single
authorized key that can make changes or multiple authorized keys. In the
case of multiple keys, a percentage of votes signed by the keys is
required to make a change. Note that only the keys in
`sawtooth.settings.vote.authorized_keys` are allowed to submit setting
transactions.

::: literalinclude
output/settings-tp_usage.out
:::
