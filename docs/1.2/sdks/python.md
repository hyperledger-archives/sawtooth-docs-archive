# Python SDK API Reference

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Transaction Processor:

The processor module defines:

1. A TransactionHandler interface to be
used to create new transaction families.

2. A high-level, general purpose TransactionProcessor to which any
number of handlers can be added.

3. A Context class used to abstract getting and setting addresses in
global validator state.

### Submodules

- [Config](python_sdk/processor/config.html)
- [Context](python_sdk/processor/context.html)
- [Core](python_sdk/processor/core.html)
- [Exceptions](python_sdk/processor/exceptions.html)
- [Handler](python_sdk/processor/handler.html)
- [Log](python_sdk/processor/log.html)


## Sawtooth Signing

The signing module provides secp256k1 signing for clients.

### Submodules

- [Core](python_sdk/signing/core.html)
- [Secp256k1](python_sdk/signing/secp256k1.html)
