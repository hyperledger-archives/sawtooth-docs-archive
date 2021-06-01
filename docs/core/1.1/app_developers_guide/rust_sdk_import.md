---
title: Importing the Rust SDK
---

::: note
::: title
Note
:::

The Sawtooth Rust SDK assumes that you have the latest version of Rust
and its package manager Cargo, which can be installed with
[rustup](https://rustup.rs/).
:::

Once you\'ve got a working version of Sawtooth, there are a few
additional steps you\'ll need to take to get started developing for
Sawtooth in Rust.

1.  Add Sawtooth to your `Cargo.toml` file. The Rust SDK is located at
    `/project/sawtooth-core/sdk/rust` in the [main Sawtooth
    repository](https://github.com/hyperledger/sawtooth-core/tree/master/sdk/rust).

``` ini
[package]
name = "package_name"
version = "0.1.0"
authors = ["..."]

[dependencies]
sawtooth_sdk = { git = "https://github.com/hyperledger/sawtooth-core.git" }
// --snip--
```

2.  Import the SDK into your Rust files. At the top of your files,
    specify `extern crate sawtooth_sdk;` and then `use` the packages you
    need from the Sawtooth SDK. For example:

``` rust
extern crate sawtooth_sdk;

use sawtooth_sdk::processor::TransactionProcessor;

// --snip--
```
