# Conversion Status

<!--
  Copyright 2022 Cargill Incorporated

  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

This site is undergoing a transition!

Sawtooth 1.1 documentation has not yet been completely converted to the new
site's format.  You can find the documentation in sphinx-doc rst format at:

- <https://github.com/hyperledger/sawtooth-core/tree/1-1/docs>

If you wish to help contribute to the Sawtooth documentation conversion
project, please take a few pages and convert them from sphinx-doc to Jekyll.
A partial conversion has been done with pandoc here, and should be used as
a starting point:

- <https://github.com/hyperledger/sawtooth-docs/tree/refresh/docs/core/1.1>

And the next step is to review/fix the pages and integrate them into the new
1.1 documentation here:

- <https://github.com/hyperledger/sawtooth-docs/tree/refresh/docs/1.1>

A typical page conversion PR consists of the following steps:

- Commit 1: Move the file into the final location
- Commit 2: Update the file's markup (link syntax, note syntax, etc.) to work with Jekyll
- Commit 3: Link to the file in the sidebar by updating
  [_includes/1.1/left_sidebar.html](https://github.com/hyperledger/sawtooth-docs/blob/refresh/_includes/1.1/left_sidebar.html)

When submitting PRs, please keep file moves, content conversion, and content
changes as separate commits for easier review. Thanks!
