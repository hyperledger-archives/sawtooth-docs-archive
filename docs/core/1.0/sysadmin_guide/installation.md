---
title: Installing Hyperledger Sawtooth
---

The easiest way to install Hyperledger Sawtooth is with apt-get.

::: note
::: title
Note
:::

These instructions have been tested on Ubuntu 16.04 only.
:::

Stable Builds:

To add the stable repository, run these commands in a terminal window on
your host system:

``` console
$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8AA7AF1F1091A5FD
$ sudo add-apt-repository 'deb http://repo.sawtooth.me/ubuntu/1.0/stable xenial universe'
```

Nightly Builds:

If you\'d like the latest version of Sawtooth, we also provide a
repository of nightly builds. These builds may incorporate undocumented
features and should be used for testing purposes only. To use the
nightly repository, run the following commands in a terminal window on
your host system:

``` console
$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 44FC67F19B2466EA
$ sudo apt-add-repository "deb http://repo.sawtooth.me/ubuntu/nightly xenial universe"
```

Update your package lists and install Sawtooth:

``` console
$ sudo apt-get update
$ sudo apt-get install -y sawtooth
```
