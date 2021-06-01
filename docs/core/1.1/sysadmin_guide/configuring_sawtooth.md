---
title: About Sawtooth Configuration Files
---

Each Sawtooth component, such as the validator or the REST API, has an
optional configuration file that controls the component\'s behavior.
These configuration files provide an alternative to specifying Sawtooth
command options when starting a component.

::: note
::: title
Note
:::

Using configuration files is an example of [off-chain
configuration]{.title-ref}. Changes are made on the local system only.
For more information, see `configuring_permissions`{.interpreted-text
role="doc"}.
:::

When a Sawtooth component starts, it looks for a
[TOML-format](https://github.com/toml-lang/toml) configuration file in
the config directory, `/etc/sawtooth/` (by default).

By default (when Sawtooth is installed), no configuration files are
created. However, Sawtooth includes example configuration files that can
be customized for your system. See
`off_chain_settings`{.interpreted-text role="doc"} for this procedure.

::: important
::: title
Important
:::

After changing a configuration file for a component, you must restart
that component in order to load the changes.
:::

Sawtooth also supports several non-component configuration files:

-   The `log_configuration`{.interpreted-text role="doc"} allows you to
    configure the log output for each component.
-   The `configuring_sawtooth/path_configuration_file`{.interpreted-text
    role="doc"} controls the location of Sawtooth directories, such as
    the configuration directory (`config_dir`) and log directory
    (`log_dir`). This file also lets you set an optional
    `$SAWTOOTH_HOME` environment variable to change the base location of
    Sawtooth files and directories.

::: toctree
configuring_sawtooth/validator_configuration_file
configuring_sawtooth/rest_api_configuration_file
configuring_sawtooth/cli_configuration
configuring_sawtooth/poet_sgx_enclave_configuration_file
configuring_sawtooth/identity_tp_configuration
configuring_sawtooth/settings_tp_configuration
configuring_sawtooth/xo_tp_configuration log_configuration
configuring_sawtooth/path_configuration_file
:::
