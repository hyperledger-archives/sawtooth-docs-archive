---
title: Installing Hyperledger Sawtooth
---

::: note
::: title
Note
:::

These instructions have been tested on Ubuntu 18.04 (Bionic) only.
:::

This procedure describes how to install Hyperledger Sawtooth on a Ubuntu
system for proof-of-concept or production use in a Sawtooth network.

1.  Choose whether you want the stable version (recommended) or the most
    recent nightly build (for testing purposes only).

    -   (Release 1.2 and later) To add the stable repository, run these
        commands in a terminal window on your host system.

        ``` console
        $ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8AA7AF1F1091A5FD
        $ sudo add-apt-repository 'deb [arch=amd64] http://repo.sawtooth.me/ubuntu/chime/stable bionic universe'
        ```

        ::: note
        ::: title
        Note
        :::

        The `chime` metapackage includes the Sawtooth core software and
        associated items such as separate consensus software.
        :::

    -   The latest version of Sawtooth is available in a repository of
        nightly builds. These builds may incorporate undocumented
        features and should be used for testing purposes only.

        To use the nightly repository, run the following commands in a
        terminal window on your host system.

        ``` console
        $ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 44FC67F19B2466EA
        $ sudo apt-add-repository 'deb [arch=amd64] http://repo.sawtooth.me/ubuntu/nightly bionic universe'
        ```

2.  Update your package lists.

    ``` console
    $ sudo apt-get update
    ```

3.  Install the Sawtooth packages. Sawtooth consists of several Ubuntu
    packages that can be installed together using the `sawtooth`
    meta-package. Run the following command:

    ``` console
    $ sudo apt-get install -y sawtooth
    ```

> 1.  (PBFT only) Install the PBFT consensus engine package.
>
>     ``` console
>     $ sudo apt-get install -y sawtooth sawtooth-pbft-engine
>     ```
>
> 2.  (PoET only) Install the PoET consensus engine, transaction
>     processor, and CLI packages.
>
>     ``` console
>     $ sudo apt-get install -y sawtooth \
>     python3-sawtooth-poet-cli \
>     python3-sawtooth-poet-engine \
>     python3-sawtooth-poet-families
>     ```
>
> > ::: tip
> > ::: title
> > Tip
> > :::
> >
> > Any time after installation, you can view the installed Sawtooth
> > packages with the following command:
> >
> > ``` console
> > $ dpkg -l '*sawtooth*'
> > ```
> > :::
