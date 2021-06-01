---
title: sawset
---

The `sawset` command is used to work with settings proposals.

Sawtooth supports storing settings on-chain. The `sawset` subcommands
can be used to view the current proposals, create proposals, vote on
existing proposals, and produce setting values that will be set in the
genesis block.

::: literalinclude
output/sawset_usage.out
:::

# sawset genesis

The `sawset genesis` subcommand creates a Batch of settings proposals
that can be consumed by `sawadm genesis` and used during genesis block
construction.

::: literalinclude
output/sawset_genesis_usage.out
:::

# sawset proposal

The Settings transaction family supports a simple voting mechanism for
applying changes to on-change settings. The `sawset proposal`
subcommands provide tools to view, create and vote on proposed settings.

::: literalinclude
output/sawset_proposal_usage.out
:::

# sawset proposal create

The `sawset proposal create` subcommand creates proposals for settings
changes. The change may be applied immediately or after a series of
votes, depending on the vote threshold setting.

::: literalinclude
output/sawset_proposal_create_usage.out
:::

# sawset proposal list

The `sawset proposal list` subcommand displays the currently proposed
settings that are not yet active. This list of proposals can be used to
find proposals to vote on.

::: literalinclude
output/sawset_proposal_list_usage.out
:::

# sawset proposal vote

The `sawset proposal vote` subcommand votes for a specific
settings-change proposal. Use `sawset proposal list` to find the
proposal id.

::: literalinclude
output/sawset_proposal_vote_usage.out
:::
