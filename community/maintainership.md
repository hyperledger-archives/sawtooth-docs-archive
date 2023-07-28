<!--
  SPDX-License-Identifier: CC-BY-4.0

  This file was derived from:
    https://github.com/hyperledger/toc/blob/gh-pages/guidelines/SAMPLE-MAINTAINERS.md
-->

# Maintainership

## Active Maintainers

| Name | GitHub | Repo |
| --- | --- | --- |
| Andi Gunderson | agunde406 | All |
| Cian Montgomery | cianx | All |
| Dan Anderson | danintel | Docs |
| Dan Middleton | dcmiddle | All |
| Isabel Tomb | isabeltomb | Lib |
| James Mitchell | jsmitchell | All |
| Kelly Olson | ineffectualproperty | Docs |
| Peter Schwarz | peterschwarz | All |
| Richard Berg | rberg2 | All |
| Ryan Banks | RyanLassigBanks | Sabre |
| Ryan Beck-Buysse | rbuysse | All |
| Shawn Amundson | vaporos | All |
| Shannyn Telander | shannynalayna | Swift |
| Tom Barnes | TomBarnes | Docs |

For a complete list of active and emeritus maintainers, see
[MAINTAINERS.md](https://github.com/hyperledger/sawtooth-core/blob/main/MAINTAINERS.md).

## Becoming a Maintainer

This community welcomes contributions. Interested contributors are encouraged
to progress to become maintainers. A contributor can qualify to become
a maintainer by demonstrating both quality code contributions over a duration
of time and an understanding (and acceptance) of the project's established
contribution rules (such as the commit process) and other project and
Hyperledger norms (such as Discord etiquette).

As a general guideline, maintainers should require a minimum of 6 months of
contributions and at minimum of 5 non-trivial, high-quality PRs.

To become a maintainer the following steps occur, roughly in order.

- A PR is created by an existing maintainer to update MAINTAINERS.md to add the
  proposed maintainer to the list of active maintainers.
- The proposed maintainer confirms their interest in being a maintainer by
  adding a comment to the PR. The comment from the proposed maintainer must
  include their willingness
  to be a long-term (more than 6 month) maintainer.
- Once the PR and necessary comments have been received, an approval timeframe
  begins.
- The PR MUST be communicated on all relevant community calls and the
  #sawtooth-contributor Discord channel. Comments of support from the community
  are welcome.
- The PR is merged and the proposed maintainer becomes a maintainer if either:
  - Two weeks have passed since at least an absolute majority of maintainer PR
    approvals have been recorded and no maintainer has dissented, OR
  - All maintainers have approved the PR.
- If the PR does not get the requisite PR approvals, it may be closed.
- Once the PR has been merged, any necessary updates to the GitHub teams are
  made.

## Removing Maintainers

Occasionally, it is appropriate to move a maintainer to emeritus status. This
can occur in the following situations:

- Resignation of a maintainer.
- Inactivity.
    - A general measure of inactivity will be no commits, code review comments,
      or other participation for one year. This will not be strictly enforced
      if the maintainer expresses a reasonable intent to continue contributing.
    - Reasonable exceptions to inactivity will be granted for known long term
      leave such as parental leave and medical leave.
    - Other circumstances at the discretion of the other maintainers.

The process to move a maintainer from active to emeritus status is comparable
to the process for adding a maintainer, outlined above. In the case of
voluntary resignation, the Pull Request can be merged following maintainer PR
approval.  If the removal is for any other reason, the following steps SHOULD
be followed:

- A PR is created to update this file to move the maintainer to the list of
  emeritus maintainers.
- The PR is authored by, or has a comment supporting the proposal from, an
  existing maintainer.
- Once the PR and necessary comments have been received, the approval timeframe
  begins.
- The PR MAY be communicated on appropriate communication channels, including
  relevant community calls and chat channels.
- The PR is merged and the maintainer transitions to maintainer emeritus if:
    - The PR is approved by the maintainer to be transitioned, OR
    - Two weeks have passed since at least an absolute majority of maintainer
      PR approvals have been recorded and no maintainer has dissented, OR
    - An absolute majority of maintainers have approved the PR.
- If the PR does not get the requisite PR approvals, it may be closed.

Returning to active status from emeritus status uses the same steps as adding
a new maintainer. Note that the emeritus maintainer already has the 5 required
significant changes as there is no contribution time horizon for those.
