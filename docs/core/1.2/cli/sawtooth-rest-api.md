---
title: sawtooth-rest-api
---

The `sawtooth-rest-api` command starts the REST API and connects to the
validator.

The REST API is designed to run alongside a validator, providing
potential clients access to blockchain and state data through common
HTTP/JSON standards. It is a stateless process, and does not store any
part of the blockchain or blockchain state. Instead it acts as a go
between, translating HTTP requests into validator requests, and sending
back the results as JSON. As a result, running the Sawtooth REST API
requires that a validator already be running and available over TCP.

Options for `sawtooth-rest-api` specify the bind address for the host
and port (by default, `http://localhost:8008`) and the TCP address where
the validator is running (the default is `tcp://localhost:4004`). An
optional timeout value configures how long the REST API will wait for a
response for the validator.

::: literalinclude
output/sawtooth-rest-api_usage.out
:::
