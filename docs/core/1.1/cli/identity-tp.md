---
title: identity-tp
---

The `identity-tp` command starts the Identity transaction processor,
which handles on-chain permissioning for transactor and validator keys
to streamline managing identities for lists of public keys.

The Settings transaction processor is required when using the Identity
transaction processor.

In order to send identity transactions, your public key must be stored
in `sawtooth.identity.allowed_keys`.

::: literalinclude
output/identity-tp_usage.out
:::
