---
title: Python SDK Installation
---

# Overview

<!--
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

The Python SDK is installed automatically when you install Hyperledger
Sawtooth by following the instructions in
`installing_sawtooth`{.interpreted-text role="doc"}. This tutorial
explains how import the SDK into your Python environment.

# Prerequisites

The Sawtooth Python SDK requires Python version 3.5 or higher.

::: note
::: title
Note
:::

If you install Sawtooth as described in
`installing_sawtooth`{.interpreted-text role="doc"}, using the method
described in `ubuntu`{.interpreted-text role="doc"}, then Python is
installed for you automatically if it is not already installed.
:::

# Importing the SDK

As part of the installation process, the Python SDK is installed and
made available through the standard Python import system. From the
Python REPL, for example, you could import the SDK and then view the
SDK\'s docstring:

``` python
>>> import sawtooth_sdk
>>> help(sawtooth_sdk)
Help on package sawtooth_sdk:

NAME
    sawtooth_sdk

DESCRIPTION
    # Copyright 2016 Intel Corporation
    #
    # Licensed under the Apache License, Version 2.0 (the "License");
    # you may not use this file except in compliance with the License.
    # You may obtain a copy of the License at
    #
    #     http://www.apache.org/licenses/LICENSE-2.0
    #
    # Unless required by applicable law or agreed to in writing, software
    # distributed under the License is distributed on an "AS IS" BASIS,
    # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    # See the License for the specific language governing permissions and
    # limitations under the License.
    # ------------------------------------------------------------------------------

PACKAGE CONTENTS
    client (package)
    processor (package)
    protobuf (package)
    workload (package)

DATA
    __all__ = ['client', 'processor']

FILE
    /usr/lib/python3/dist-packages/sawtooth_sdk/__init__.py
```
