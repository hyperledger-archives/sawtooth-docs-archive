---
title: "PBFT Only: Updating the PBFT Member List"
---

If you are adding a new node to an existing PBFT network, you must
update the on-chain setting `sawtooth.consensus.pbft.members` after the
new node has been installed and configured. This setting takes effect
after the containing block has been committed.

See `adding-a-pbft-node-label`{.interpreted-text role="ref"} for this
procedure.
