---
title: intkey
---

The `intkey` command starts the IntegerKey transaction processor, which
provides functions that can be used to test deployed ledgers.

The `intkey` command provides subcommands to set, increment, and
decrement the value of entries stored in a state dictionary.

::: literalinclude
output/intkey_usage.out
:::

# intkey set

The `intkey set` subcommand sets a key ([name]{.title-ref}) to the
specified value. This transaction will fail if the value is less than 0
or greater than 2^32^ - 1.

::: literalinclude
output/intkey_set_usage.out
:::

# intkey inc

The `intkey inc` subcommand increments a key ([name]{.title-ref}) by the
specified value. This transaction will fail if the key is not set or if
the resulting value would exceed 2^32^ - 1.

::: literalinclude
output/intkey_inc_usage.out
:::

# intkey dec

The `intkey dec` subcommand decrements a key ([name]{.title-ref}) by the
specified value. This transaction will fail if the key is not set or if
the resulting value would be less than 0.

::: literalinclude
output/intkey_dec_usage.out
:::

# intkey show

The `intkey show` subcommand displays the value of the specified key
([name]{.title-ref}).

::: literalinclude
output/intkey_show_usage.out
:::

# intkey list

The `intkey list` subcommand displays the value of all keys.

::: literalinclude
output/intkey_list_usage.out
:::
