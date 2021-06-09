\-\--layout: page hide: true tags: \[appendix\] title: Appendix -
Sawtooth Transaction Family Prefixes permalink: /faq/prefixes/ \#
Copyright (c) 2018, Intel Corporation. \# Licensed under Creative
Commons Attribution 4.0 International License \#
<https://creativecommons.org/licenses/by/4.0/> \-\--FAQ Appendix:
Transaction Family Prefixes ========================================= ..
class:: mininav

[PREVIOUS](/faq/glossary/) [FAQ](/faq/) [NEXT](/faq/settings/)

::: contents
:::

This is an unofficial list of some Transaction Family (TF) prefixes.
There is no central registry, most or all of these TFs are found on
GitHub ( <https://github.com/> especially
<https://github.com/hyperledger> and
<https://github.com/hyperledger-labs> ).

Sawtooth addresses are 70 hex characters. The prefix is either the first
6 characters of the SHA-512 hash of the namespace, or, for some base
namespaces, a \"hex word\". The Sawtooth Validator registry is an
outlier. It uses the SHA-256 hash (not SHA-512) and hashes
\"validator_registry\" (not \"sawtooth_validator_registry\"). The
remainder of the address is TF-specific and defined for each TF. Listing
of a TF does not imply endorsement.

All data payloads are encoded in base64 after serializing. Sawtooth
headers are serialized with Protobuf.

For base TF specifications, see
<https://sawtooth.hyperledger.org/docs/core/releases/latest/transaction_family_specifications/>

+-------------+---------+-------+-------------------------------------+
| TRANSACTION | SERIAL- | P     | PREFIX ENCODING                     |
| FAMILY NAME | IZATION | REFIX |                                     |
+=============+=========+=======+=====================================+
| settings    | P       | 0     | Validator settings. Only required   |
|             | rotobuf | 00000 | TF                                  |
+-------------+---------+-------+-------------------------------------+
| identity    | P       | 0     | Validator Identity for TP/Validator |
|             | rotobuf | 0001d | keys                                |
+-------------+---------+-------+-------------------------------------+
| sawtooth    | P       | 6     | PoET Validator Registry. Used by    |
| \_validator | rotobuf | a4372 | PoET consensus to track other       |
| \_registry  |         |       | validators. See note above about    |
|             |         |       | hash prefix .                       |
+-------------+---------+-------+-------------------------------------+
| blockinfo   | P       | 0     | Validator Block Info. Used for SETH |
|             | rotobuf | 0b10c |                                     |
|             |         |       | 00b10c00 metadata namespace info    |
|             |         |       | about other namespaces              |
|             |         |       |                                     |
|             |         |       | 00b10c01 block info namespace       |
|             |         |       | historic block info                 |
|             |         |       |                                     |
|             |         |       | 00b10c0100\....00\<block \# in hex> |
|             |         |       | info on block at block \#           |
+-------------+---------+-------+-------------------------------------+
| sabre       | P       | 0     | WebAssembly VM: NamespaceRegistry   |
|             | rotobuf | 0ec00 |                                     |
|             |         |       | Wasm: ContractRegistry              |
|             |         | 0     |                                     |
|             |         | 0ec01 | Wasm: Contracts                     |
|             |         |       |                                     |
|             |         | 0     |                                     |
|             |         | 0ec02 |                                     |
+-------------+---------+-------+-------------------------------------+
| seth        | P       | a     | SETH (Sawtooth Ethereum VM)         |
|             | rotobuf | 68b06 |                                     |
+-------------+---------+-------+-------------------------------------+
| pdo\_       | P       | a     | Private Data Objects (PDO) Contract |
| contract\_  | rotobuf | a2a93 | Instance Registry                   |
| instance\_  |         |       |                                     |
| registry    |         |       |                                     |
+-------------+---------+-------+-------------------------------------+
| pdo\_       | P       | 0     | Private Data Objects (PDO) Contract |
| contract\_  | rotobuf | b936f | Enclave Registry                    |
| enclave\_   |         |       |                                     |
| registry    |         |       |                                     |
+-------------+---------+-------+-------------------------------------+
| ccl\_       | P       | d     | Private Data Objects (PDO)          |
| contract\_  | rotobuf | b13a2 | Coordination and Commit Log (CCL)   |
| contract\_  |         |       | Contract State Registry             |
| state\_     |         |       |                                     |
| registry    |         |       |                                     |
+-------------+---------+-------+-------------------------------------+
| > \*\*SOME  | TFs\*\* |       |                                     |
| > EXAMPLE   |         |       |                                     |
+-------------+---------+-------+-------------------------------------+
| battleship  | JSON    | 6     | Battleship example game             |
|             |         | e10df |                                     |
+-------------+---------+-------+-------------------------------------+
| intkey      | CBOR    | 1     | Integer Key. Full production        |
|             |         | cf126 | example                             |
+-------------+---------+-------+-------------------------------------+
| smallbank   | P       | 3     | Small Bank example app              |
|             | rotobuf | 32514 |                                     |
+-------------+---------+-------+-------------------------------------+
| xo          | C       | 5     | Tic-tac-toe example game            |
|             | SV-UTF8 | b7349 |                                     |
+-------------+---------+-------+-------------------------------------+
| s           | P       | 3     | Asset (Fish) Supply Chain example   |
| upply_chain | rotobuf | 400de | app                                 |
+-------------+---------+-------+-------------------------------------+
| marketplace | P       | c     | Marketplace example app             |
|             | rotobuf | d6744 |                                     |
+-------------+---------+-------+-------------------------------------+
| transfer-   | JS      | 1     | Simple Tuna Supply Chain app. Used  |
| chain       | ON-UTF8 | 9d832 | for edX LFS171x class               |
+-------------+---------+-------+-------------------------------------+
| s           | C       | 7     | Simple Wallet minimal example       |
| implewallet | SV-UTF8 | e2664 |                                     |
+-------------+---------+-------+-------------------------------------+
| cookiejar   | C       | a     | Cookie Jar minimal example          |
|             | SV-UTF8 | 4d219 |                                     |
+-------------+---------+-------+-------------------------------------+
| simple\_    | P       | 5     | Simple Supply example used for      |
| supply      | rotobuf | d6af4 | future edX LFS201 class             |
+-------------+---------+-------+-------------------------------------+
| pirate-talk | UTF8    | a     | Pirate Talk minimal example         |
|             |         | aaaaa |                                     |
+-------------+---------+-------+-------------------------------------+
| c           | raw     | 1     | Cookie Maker minimal example        |
| ookie-maker |         | a5312 |                                     |
+-------------+---------+-------+-------------------------------------+
| > \*\*SOME  | ARTY    | ION   |                                     |
| > THIRD-P   | PRODUCT | TF    |                                     |
|             |         | s\*\* |                                     |
+-------------+---------+-------+-------------------------------------+
| rbac        | P       | 8     | T-Mobile NEXT Identity Platform     |
|             | rotobuf | 563d0 |                                     |
+-------------+---------+-------+-------------------------------------+
| s           | P       | d     | Primechain Blockchain-eKYC bank     |
| awtoothekyc | rotobuf | bf420 | records                             |
+-------------+---------+-------+-------------------------------------+
| pub_key     | P       | a     | REMME REMChain                      |
|             | rotobuf | 23be1 |                                     |
+-------------+---------+-------+-------------------------------------+
| bitagora-   | JSON    | b     | Bitagora voting ballot              |
| ballots     |         | 42861 |                                     |
+-------------+---------+-------+-------------------------------------+
| bitagora-   | JSON    | 1     | Bitagora voting polls               |
| polls       |         | 54f9c |                                     |
+-------------+---------+-------+-------------------------------------+

::: mininav
[PREVIOUS](/faq/glossary/) [FAQ](/faq/) [NEXT](/faq/settings/)
:::

© Copyright 2018, Intel Corporation.
