---
layout: post
title: 'arc diff and ERR_CLOSED: This revision has already been closed.'
author: admin
id: 93
created: 1426016613
tags:
  - snippet
permalink: /blog/93/arc-diff-and-errclosed-revision-has-already-been-closed/
redirect_from:
  - /blog/93/
  - /node/93/
---
Our team uses Phabricator's Differential tool, and the command-line tool Arcanist on each developer's machine, to generate nice-looking code-review dashboards.

Here is the workflow:

First, a developer works on a branch features-123. When he or she is ready to request a code review, the following command can be used:

    arc diff master

That's it: a nice code review dashboard is created, with a code like D34.

However, if we need to update the code, sometimes the review is marked as closed by differential, I'm not yet sure why, and I could not figure out how to reopen it. Now we get

    arc diff master
    ...
    ERR_CLOSED: This revision has already been closed.

If ignoring the current revision and just creating a new one (D35) fits your workflow, as it does ours, you have to specify that you want to create a new revision:

    arc diff --create master

And voilà!
