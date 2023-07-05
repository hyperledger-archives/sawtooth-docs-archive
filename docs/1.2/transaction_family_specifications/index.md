# Transaction Family Specifications

Sawtooth includes several transaction families as examples for
developing your own transaction family. These transaction families are
available in the `sawtooth-core` repository unless noted below.

-   The [BlockInfo Transaction
    Family]({% link docs/1.2/transaction_family_specifications/blockinfo_transaction_family.md%})
    provides a way to store information about a configurable
    number of historic blocks. The family name is `block_info`. The
    transaction processor is `block-info-tp`.

-   The [Identity Transaction Family]({% link
    docs/1.2/transaction_family_specifications/identity_transaction_family.md %})
    is an extensible role- and policy-based system for
    defining permissions in a way that can be used by other Sawtooth
    components. The family name is `sawtooth_identity`; the associated
    transaction processor is
    [identity-tp]({% link docs/1.2/cli/identity-tp.md %}).

-   The [Intkey Transaction Family]({% link
    docs/1.2/transaction_family_specifications/integerkey_transaction_family.md %})
    (also called \"intkey\") simply sets, increments, and
    decrements the value of entries stored in a state dictionary. The
    [intkey]({% link docs/1.2/cli/intkey.md%}) command
    provides an example CLI client.

    intkey is available in several languages, including Go, Java, and
    JavaScript (Node.js); see the `sawtooth-sdk-{language}` repositories
    under `examples`.

    The family name is `intkey`. The transaction processor is
    `intkey-tp-{language}`.

-   The [Settings Transaction
    Family]({% link
    docs/1.2/transaction_family_specifications/settings_transaction_family.md %})
    provides a methodology for storing
    on-chain configuration settings. The
    [settings]({% link docs/1.2/cli/sawset.md %}) command
    provides an example CLI client.

    The family name is `sawtooth_settings`. The transaction processor is
    [settings-tp]({% link docs/1.2/cli/identity-tp.md %}).

    > **Note**
    >
    > In a production environment, you should always run a transaction
    > processor that supports the Settings transaction family.

-   The [Smallbank Transaction Family]({% link
    docs/1.2/transaction_family_specifications/smallbank_transaction_family.md %})
    provides a cross-platform workload for comparing the
    performance of blockchain systems. The family name is `smallbank`.
    The transaction processor is `smallbank-tp-{language}`.

-   The [XO Transaction Family]({% link
    docs/1.2/transaction_family_specifications/xo_transaction_family.md %})
    allows two users to play a simple game of tic-tac-toe (see [Playing with the
    XO Transaction Family]({% link docs/1.2/app_developers_guide/intro_xo_transaction_family.md%})).
    The [xo]({% link docs/1.2/cli/xo.md %}) command provides an
    example CLI client.

    XO is available in several languages. The various implementations
    can be found in the `sawtooth-sdk-{language}` repositories under
    `examples`.

    The family name is `xo`. The transaction processor is
    `xo-tp-{language}`.

The following transaction families run on top of the Sawtooth platform:

-   [Sawtooth Sabre Transaction
    Family]({% link docs/1.2/sabre/sabre_transaction_family.md%}):
    Implements on-chain smart contracts that are executed in a
    WebAssembly (WASM) virtual machine. This transaction family is in
    the [sawtooth-sabre](https://github.com/hyperledger/sawtooth-sabre)
    repository.
-   [Sawtooth Seth Transaction
    Family](https://sawtooth.hyperledger.org/docs/seth/nightly/master/):
    Supports running Ethereum Virtual Machine (EVM) smart contracts on
    Sawtooth. This transaction family is in the
    [sawtooth-seth](https://github.com/hyperledger/sawtooth-seth)
    repository.

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
