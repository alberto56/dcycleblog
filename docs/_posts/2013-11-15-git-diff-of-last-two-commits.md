---
layout: post
title: Git diff of last two commits
id: 39
created: 1384529957
permalink: /blog/39/git-diff-last-two-commits/
redirect_from:
  - /blog/39/
  - /node/39/
---
The following command can be useful in your Jenkins server if you want to display between the latest build and the one before it:

    git log -p -n1

This will display, as a patch, what the latest change was.
