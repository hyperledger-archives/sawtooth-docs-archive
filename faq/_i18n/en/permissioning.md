# Sawtooth FAQ: Permissioning

<!--
  Copyright (c) 2018, Intel Corporation.
  © Copyright 2020, Dr Kent G LAU, <kenty@kenty.com>.
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## How to solve this error `Wait timed out! Policy was not committed... PENDING` when `sawtooth identity policy create` is run?

- There is a possibility that rest-api is down or identity-tp is not
running or it might be due to permissioning issues. If the cause is due
to permissioning, follow these steps:

-   `sawset proposal create --key /etc/sawtooth/keys/validator.priv sawtooth.identity.allowed_keys={user pub key created through 'sawtooth keygen'}`
-   `sawtooth identity policy create policy_1 "PERMIT_KEY {key1}" "PERMIT_KEY {key2}"`
-   `sawtooth identity role create transactor policy_1`

- Refer  
   <https://sawtooth.hyperledger.org/docs/core/nightly/master/sysadmin_guide/configuring_permissions.html>
for detailed information.