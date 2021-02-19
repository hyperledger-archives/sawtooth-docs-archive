# Sawtooth FAQ: REST

<!--
  Copyright (c) 2018, Intel Corporation.
  © Copyright 2020, Dr Kent G LAU, <kenty@kenty.com>.
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

**Contents**

  - [What\'s the difference between the `sawtooth-rest-api --bind` and `--connect` options?](#whats-the-difference-between-the-sawtooth-rest-api bind-and connect-options)
  - [Is the REST API at TCP port 8080 or 8008?](#is-the-rest-api-at-tcp-port-8080-or-8008)
  - [What REST API commands are available?](#what-rest-api-commands-are-available)
  - [What is a transaction receipt?](#what-is-a-transaction-receipt)
  - [How do I retrieve a transaction receipt?](#how-do-i-retrieve-a-transaction-receipt)
  - [What does this error mean: `[... DEBUG route_handlers] Received CLIENT_STATE_GET_RESPONSE response from validator with status NO_RESOURCE`](#what-does-this-error-mean)
  - [What does this REST API error mean:](#what-does-this-rest-api-error-mean)
  - [I am getting this error:`Cross-Origin Request Blocked: The Same Origin Policy disallows reading the remote resource at http://localhost:8008/batches?wait. (Reason: CORS header 'Access-Control-Allow-Origin' missing).`](#i-am-getting-this-error)
  - [What does this error mean: `Request failed with status code 429`](#what-does-this-error-mean-1)
  - [What is the back pressure test?](#what-is-the-back-pressure-test)
  - [Can I disable the back pressure test?](#can-i-disable-the-back-pressure-test)
  - [What does this error mean from sawset: `There is no resource with the identifier`](#what-does-this-error-mean-from-sawset)

 

## What\'s the difference between the `sawtooth-rest-api --bind` and `--connect` options?

- `sawtooth-rest-api --bind` (`-B`)
  - specifies where your rest-api would listen. 
  - The default is
    <http://localhost:8008>

- `sawtooth-rest-api --connect` (`-C`)
  - specifies where your rest-api can reach to the validator. 
  - The
    default is <http://localhost:4004>

 

## Is the REST API at TCP port 8080 or 8008?

- TCP Port 8008. It was 8080 before the 1.0 release and old examples and
diagrams may use the old port number.

 

## What REST API commands are available?

Use localhost to access the REST API from the Validator Docker container
or from where the Validator is running. 

For example, to get state
history (equivalent to `sawtooth state list`) type:

- `curl http://localhost:8008/state`

From the Client Docker container, access from rest-api. For example:

- `curl http://rest-api:8008/state`

These are the supported REST API commands:

- **POST /batches**
  - Submit a protobuf-formatted batch list to the validator

- **GET /batches**
  - Fetch a paginated list of batches from the validator

- **GET /batches/{batch\_id}**
  - Fetch the specified batch

- **GET /batch\_statuses**
  - Fetch the committed statuses for a set of batches

- **POST /batch\_statuses**
  - Same as GET /batch\_statuses except can be used for \> 15 IDs

- **GET /state**
  - Fetch a paginated list of leaves for the current state, or relative
    to a particular head block

- **GET /state/{address}**
  - Fetch a particular leaf from the current state

- **GET /blocks**
  - Fetch a paginated list of blocks from the validator

- **GET /blocks/{block\_id}**
  - Fetch the specified block

- **GET /transactions**
  - Fetch a paginated list of transactions from the validator.

- **GET /transactions/{transaction\_id}**
  - Fetch the specified transaction

- **GET /receipts?id={transaction\_ids}**
  - Fetch receipts for 1 or more transactions

- **POST /receipts**
  - Same as GET /receipts except can be used for \> 15 IDs

- **GET /peers**
  - Fetch a list of current peered validators

For more information, see the Sawtooth REST API Reference at
<https://sawtooth.hyperledger.org/docs/core/releases/latest/rest_api.html>

 

## What is a transaction receipt?

- Transaction receipts are transaction execution information that is not
stored in state, such as how the transaction changed state, transaction
family-specific data, transaction-related events, and if the transaction
was valid.  

- The transaction family-specific receipt data is usually
empty, but can be added by the TP with `context.add_receipt_data()`  

- To
access transaction receipts, use the REST API. For more information, see
<https://sawtooth.hyperledger.org/docs/core/releases/latest/architecture/events_and_transactions_receipts.html#transaction-receipts>

 

## How do I retrieve a transaction receipt?

- Use the REST API. Here\'s a sample request (The ID is the transaction
ID, listed with [sawtooth transaction list]{.title-ref}):  
  `wget http://localhost:8008/receipts?id=YourTransactionIDsHere` 
  
- Replace
`YourTransactionIDsHere` with 1 or more comma-separated 128 hex
character transaction IDs. Change [localhost]{.title-ref} to
[rest-api]{.title-ref} for Docker. The response is several lines of JSON
format output. 
- For example,
<https://gist.github.com/danintel/0f878141c60bb566237e8db11226aa4e> .
- For more than 15 IDs, use `POST /receipts` . For Receipts REST API
details, see `receipts` at
<https://sawtooth.hyperledger.org/docs/core/releases/latest/rest_api/endpoint_specs.html>

 

## What does this error mean: 
>`[... DEBUG route_handlers] Received CLIENT_STATE_GET_RESPONSE response from validator with status NO_RESOURCE`?

- It means the transaction processor for this transaction is not running.

 

## What does this REST API error mean: 
>`The submitted BatchList was rejected by the validator. It was poorly formed, or has an invalid signature`

- Most likely you are not putting the transaction into a batch or the batch
in a batchlist for posting to the REST API.  

- This is required, even for a
single transaction.

 

## I am getting this error: 
>`Cross-Origin Request Blocked: The Same Origin Policy disallows reading the remote resource at http://localhost:8008/batches?wait. (Reason: CORS header 'Access-Control-Allow-Origin' missing).`

- The Sawtooth REST API doesn\'t support CORS.  

- To allow cross-origin
access to the Sawtooth API, put it behind a proxy.

 

## What does this error mean: 
>`Request failed with status code 429`

- To avoid DDoS attacks (too many requests from a single source), Sawtooth
has a mechanism called \"backpressure test\" which avoids such things as
excessive network traffic and excessive Sawtooth transactions.

 

## What is the back pressure test?

- Back pressure is a flow-control technique to help prevent DoS attacks.  

- It results in a `Status.QUEUE_FULL` client batch submit response or a
429 \"Too Many Requests\" REST API error.   
- If the validator is
overwhelmed it will stop accepting new batches until it can handle more
work.   
- The number of batches that validator can accept is based on a
multiplier, QUEUE\_MULTIPLIER (currently 10, formerly 2), times a
rolling average of the number of published batches.

 

## Can I disable the back pressure test?

- No. There isn\'t a way to disable that currently because it\'s
determined based on a multiplier of the publishing rate of the network.

- Back pressure test is about rejecting load (in the form of batches) that
the network wouldn\'t be able to accommodate in a reasonable amount of
time (next couple blocks). 
- This should never be turned off as without
this feature it is trivial to do a client-based attack which overwhelms
the network creating a DoS. 
- You would have to make a custom build of
Sawtooth to remove that check.

 

## What does this error mean from sawset: 
>`There is no resource with the identifier`?

- It means the command format is correct, but the identifier does not
exist.