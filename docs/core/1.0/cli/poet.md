---
title: poet
---

The `poet` command initializes the Proof of Elapsed Time (PoET)
consensus mechanism for Sawtooth by generating enclave setup information
and creating a Batch for the genesis block. For more information, see
`/architecture/poet`{.interpreted-text role="doc"}.

The `poet` command provides subcommands for configuring a node to use
Sawtooth with the PoET consensus method.

::: literalinclude
output/poet_usage.out
:::

# poet registration

The `poet registration` subcommand provides a command to work with the
PoET validator registry.

::: literalinclude
output/poet_registration_usage.out
:::

# poet registration create

The `poet registration create` subcommand creates a batch to enroll a
validator in the network\'s validator registry. It must be run from the
validator host wishing to enroll.

::: literalinclude
output/poet_registration_create_usage.out
:::

# poet enclave

The `poet enclave` subcommand generates enclave setup information.

::: literalinclude
output/poet_enclave_usage.out
:::
