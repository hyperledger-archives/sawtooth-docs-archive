# sawtooth-rest-api

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

```console
usage: sawtooth-rest-api [-h] [-B BIND] [-C CONNECT] [-t TIMEOUT]
                         [--client-max-size CLIENT_MAX_SIZE] [-v]
                         [--opentsdb-url OPENTSDB_URL]
                         [--opentsdb-db OPENTSDB_DB] [-V]

Starts the REST API application and connects to a specified validator.

optional arguments:
  -h, --help            show this help message and exit
  -B BIND, --bind BIND  identify host and port for API to run on default:
                        http://localhost:8008)
  -C CONNECT, --connect CONNECT
                        specify URL to connect to a running validator
  -t TIMEOUT, --timeout TIMEOUT
                        set time (in seconds) to wait for validator response
  --client-max-size CLIENT_MAX_SIZE
                        the max size (in bytes) of a request body
  -v, --verbose         enable more verbose output to stderr
  --opentsdb-url OPENTSDB_URL
                        specify host and port for Open TSDB database used for
                        metrics
  --opentsdb-db OPENTSDB_DB
                        specify name of database for storing metrics
  -V, --version         display version information

```

<!--
     Copyright 2017 Intel Corporation

     Licensed under the Apache License, Version 2.0 (the "License");
     you may not use this file except in compliance with the License.
     You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

     Unless required by applicable law or agreed to in writing, software
     distributed under the License is distributed on an "AS IS" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     See the License for the specific language governing permissions and
     limitations under the License.

  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->
