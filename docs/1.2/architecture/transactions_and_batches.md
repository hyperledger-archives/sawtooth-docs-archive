<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

# Transactions and Batches

Modifications to state are performed by creating and applying
transactions. A client creates a transaction and submits it to the
validator. The validator applies the transaction which causes a change
to state.

Transactions are always wrapped inside of a batch. All transactions
within a batch are committed to state together or not at all. Thus,
batches are the atomic unit of state change.

The overall structure of batches and transactions includes Batch,
BatchHeader, Transaction, and TransactionHeader:

![Transaction and batch entity diagram](../images/arch_batch_and_transaction.svg)

## Transaction Data Structure

Transactions are serialized using Protocol Buffers. They consist of two
message types:

```protobuf
// Copyright 2016 Intel Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// -----------------------------------------------------------------------------

syntax = "proto3";

option java_multiple_files = true;
option java_package = "sawtooth.sdk.protobuf";
option go_package = "transaction_pb2";

message TransactionHeader {
    // Public key for the client who added this transaction to a batch
    string batcher_public_key = 1;

    // A list of transaction signatures that describe the transactions that
    // must be processed before this transaction can be valid
    repeated string dependencies = 2;

    // The family name correlates to the transaction processor's family name
    // that this transaction can be processed on, for example 'intkey'
    string family_name = 3;

    // The family version correlates to the transaction processor's family
    // version that this transaction can be processed on, for example "1.0"
    string family_version = 4;

    // A list of addresses that are given to the context manager and control
    // what addresses the transaction processor is allowed to read from.
    repeated string inputs = 5;

    // A random string that provides uniqueness for transactions with
    // otherwise identical fields.
    string nonce = 6;

    // A list of addresses that are given to the context manager and control
    // what addresses the transaction processor is allowed to write to.
    repeated string outputs = 7;

    //The sha512 hash of the encoded payload
    string payload_sha512 = 9;

    // Public key for the client that signed the TransactionHeader
    string signer_public_key = 10;
}

message Transaction {
    // The serialized version of the TransactionHeader
    bytes header = 1;

    // The signature derived from signing the header
    string header_signature = 2;

    // The payload is the encoded family specific information of the
    // transaction. Example cbor({'Verb': verb, 'Name': name,'Value': value})
    bytes payload = 3;
}

// A simple list of transactions that needs to be serialized before
// it can be transmitted to a batcher.
message TransactionList {
    repeated Transaction transactions = 1;
}
```

### Transaction Header, Signature, and Public Keys

The Transaction header field is a serialized version of a
TransactionHeader. The header is signed by the signer\'s private key
(not sent with the transaction) and the resulting signature is stored in
header_signature. The header is present in the serialized form so that
the exact bytes can be verified against the signature upon receipt of
the Transaction.

-   The verification process verifies that the key in signer_public_key
    signed the header bytes resulting in header_signature.
-   The batcher_public_key field must match the public key used to sign
    the batch in which this transaction is contained.
-   The resulting serialized document is signed with the transactor\'s
    private ECDSA key using the secp256k1 curve.

The validator expects a normalized 64-byte \"compact\" signature. This
is a concatenation of the *R* and *S* fields of
the signature. Some libraries will include an additional header byte,
recovery ID field, or provide DER encoded signatures. Sawtooth will
reject the signature if it is anything other than 64 bytes.

> **Note**
>
> The ECDSA signature must be normalized to a \"low S\" form, which is
> also called a *low-S signature* (See [Bitcoin Transaction
> Malleability](https://eklitzke.org/bitcoin-transaction-malleability) for
> the rationale for this type of normalization.) This implies that the
> ECDSA must compute *(R,S)* and *(R, N-S)*, where
> *N* is the order of the secp256k1 curve, and the effective
> signature is the one with the smallest of *S* and
> *N-S* values (that is, *min(S, N-S)*.
> Otherwise, Sawtooth will reject the transaction signature.
>
> If you are using the Python3 Sawtooth SDK or other libraries for ECDSA
> on secp256k1 that derive from the Bitcoin secp256k1 library, you don\'t
> have to worry about this normalization. However, some libraries do not
> normalize the signature this way (for example, mbed TLS and openSSL).

> **Tip**
>
> The original header bytes as constructed from the sender are used for
> verification of the signature. It is not considered good practice to
> de-serialize the header (for example, to a Python object) and then
> re-serialize the header with the intent to produce the same byte
> sequence as the original. Serialization can be sensitive to programming
> language or library, and any deviation would produce a sequence that
> would not match the signature; thus, best practice is to always use the
> original header bytes for verification.

### Transaction Family

In Hyperledger Sawtooth, the set of possible transactions are defined by
an extensible system called transaction families. Defining and
implementing a new transaction family adds to the taxonomy of available
transactions which can be applied. For example, in the language-specific
tutorials that show you how to write your own transaction family (see
the
[Application Developers Guide]({% link docs/1.2/app_developers_guide/index.md %})),
we define a transaction family called \"xo\" which defines a set of
transactions for playing tic-tac-toe.

In addition to the name of the transaction family (family_name), each
transaction specifies a family version string (family_version). The
version string enables upgrading a transaction family while coordinating
the nodes in the network to upgrade.

### Dependencies and Input/Output Addresses

Transactions can depend upon other transactions, which is to say a
dependent transaction cannot be applied prior to the transaction upon
which it depends.

The dependencies field of a transaction allows explicitly specifying the
transactions which must be applied prior to the current transaction.
Explicit dependencies are useful in situations where transactions have
dependencies but cannot be placed in the same batch (for example, if
the transactions are submitted at different times).

To assist in parallel scheduling operations, the inputs and outputs
fields of a transaction contain state addresses. The scheduler
determines the implicit dependencies between transactions based on
interaction with state. The addresses may be fully qualified leaf-node
addresses or partial prefix addresses. Input addresses are read from the
state and output addresses are written to state. While they are
specified by the client, input and output declarations on the
transaction are enforced during transaction execution. Partial addresses
work as wildcards and allow transactions to specify parts of the tree
instead of just leaf nodes.

### Payload

The payload is used during transaction execution as a way to convey the
change which should be applied to state. Only the transaction family
processing the transaction will deserialize the payload; to all other
components of the system, payload is just a sequence of bytes.

The payload_sha512 field contains a SHA-512 hash of the payload bytes.
As part of the header, payload_sha512 is signed and later verified,
while the payload field is not. To verify the payload field matches the
header, a SHA-512 of the payload field can be compared to
payload_sha512.

### Nonce

The nonce field contains a random string generated by the client. With
the nonce present, if two transactions otherwise contain the same
fields, the nonce ensures they will generate different header
signatures.

## Batch Data Structure

Batches are also serialized using Protocol Buffers. They consist of two
message types:

```protobuf
// Copyright 2016 Intel Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// -----------------------------------------------------------------------------

syntax = "proto3";

option java_multiple_files = true;
option java_package = "sawtooth.sdk.protobuf";
option go_package = "batch_pb2";

import "transaction.proto";

message BatchHeader {
    // Public key for the client that signed the BatchHeader
    string signer_public_key = 1;

    // List of transaction.header_signatures that match the order of
    // transactions required for the batch
    repeated string transaction_ids = 2;
}

message Batch {
    // The serialized version of the BatchHeader
    bytes header = 1;

    // The signature derived from signing the header
    string header_signature = 2;

    // A list of the transactions that match the list of
    // transaction_ids listed in the batch header
    repeated Transaction transactions = 3;

    // A debugging flag which indicates this batch should be traced through the
    // system, resulting in a higher level of debugging output.
    bool trace = 4;
}

message BatchList {
    repeated Batch batches = 1;
}

```

### Batch Header, Signature, and Public Keys

Following the pattern presented in the Transaction data structure, the
Batch header field is a serialized version of a BatchHeader. The header
is signed by the signer\'s private key (not sent with the batch) and the
resulting signature is stored in header_signature. The header is present
in the serialized form so that the exact bytes can be verified against
the signature upon receipt of the Batch.

The resulting serialized document is signed with the transactor\'s
private ECDSA key using the secp256k1 curve.

The validator expects a normalized 64-byte \"compact\" signature. This
is a concatenation of the *R* and *S* fields of the signature.
Some libraries will include an additional header byte,
recovery ID field, or provide DER encoded signatures. Sawtooth will
reject the signature if it is anything other than 64 bytes.

> **Note**
>
> The ECDSA signature must be normalized to a \"low S\" form, which is
> also called a *low-S signature*. (See [Bitcoin Transaction
> Malleability](https://eklitzke.org/bitcoin-transaction-malleability) for
> the rationale for this type of normalization.) This implies that the
> ECDSA must compute *(R,S)* and *(R, N-S)*, where
> *z* is the order of the secp256k1 curve, and the effective
> signature is the one with the smallest of *S* and
> *N-S* values (that is, *min(S, N-S)*).
> Otherwise, Sawtooth will reject the transaction signature.
>
> If you are using the Python3 Sawtooth SDK or other libraries for ECDSA
> on secp256k1 that derive from the Bitcoin secp256k1 library, you don\'t
> have to worry about this normalization. However, some libraries do not
> normalize the signature this way (for example, mbed TLS and openSSL).

### Transactions

The transactions field contains a list of Transactions which make up the
batch. Transactions are applied in the order listed. The transaction_ids
field contains a list of Transaction header_signatures and must be the
same order as the transactions field.

## Why Batches?

As we have stated above, a batch is the atomic unit of change in the
system. If a batch has been applied, all transactions will have been
applied in the order contained within the batch. If a batch has not been
applied (maybe because one of the transactions is invalid), then none of
the transactions will be applied.

This greatly simplifies dependency management from a client perspective,
since transactions within a batch do not need explicit dependencies to
be declared between them. As a result, the usefulness of explicit
dependencies (contained in the dependencies field on a Transaction) are
constrained to dependencies where the transactions cannot be placed in
the same batch.

Batches solve an important problem which cannot be solved with explicit
dependencies. Suppose we have transactions A, B, and C and that the
desired behavior is A, B, C be applied in that order, and if any of them
are invalid, none of them should be applied. If we attempted to solve
this using only dependencies, we might attempt a relationship between
them such as: C depends on B, B depends on A, and A depends on C.
However, the dependencies field cannot be used to represent this
relationship, since dependencies enforce order and the above is cyclic
(and thus cannot be ordered).

Transactions from multiple transaction families can also be batched
together, which further encourages reuse of transaction families. For
example, transactions for a configuration or identity transaction family
could be batched with application-specific transactions.

Transactions and batches can also be signed by different keys. For
example, a browser application can sign the transaction and a
server-side component can add transactions and create the batch and sign
the batch. This enables interesting application patterns, including
aggregation of transactions from multiple transactors into an atomic
operation (the batch).

There is an important restriction enforced between transactions and
batches, which is that the transaction must contain the public key of
the batch signer in the batcher_public_key field. This is to prevent
transactions from being reused separate from the intended batch. So, for
example, unless you have the batcher\'s private key, it is not possible
to take transactions from a batch and repackage them into a new batch,
omitting some of the transactions.
