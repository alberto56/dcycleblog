---
layout: post
title: Rebasing in Git (squashing commits)
author: admin
id: 90
created: 1424203011
tags:
  - blog
permalink: /blog/90/rebasing-git-squashing-commits/
redirect_from:
  - /blog/90/
  - /node/90/
---
Here is a typical usecase:

 * You master branch contains your code in a potentially deployable state
 * You have a feature branch, with a bunch of commits.
 * When your feature branch is ready, you want to merge it to master _as a single commit_.

For example, if your feature branch is 2428203 and your stable branch is 7.x-1.x, you might be in this situation:

    git checkout 2428203
    git log --pretty=format:'%d %h %s'
    (HEAD, test, 2428203) 19beead removed excess lines
    (2427339) ce64181 added readme
    (origin/2427339) c622c94 move readme.txt to readme.md
    e9d8404 fixed tests, better sorting, patch for sqlite
    a3471e6 test not working
    (origin/HEAD, origin/7.x-1.x, 7.x-1.x) fc20992 Updates to the README.txt file

We'd like the 5 latest commits to be merged to 7.x-1.x, but as a single commit. Here is how:

    git checkout -b 2428203-rebased
    git rebase -i 7.x-1.x

Note that I created a new branch, just to avoid losing information. This will give you a file like this:

    pick a3471e6 test not working
    pick e9d8404 fixed tests, better sorting, patch for sqlite
    pick c622c94 move readme.txt to readme.md
    pick ce64181 added readme
    pick 19beead removed excess lines
    ...

Simply squash all but the first line, and save:

    pick a3471e6 test not working
    squash e9d8404 fixed tests, better sorting, patch for sqlite
    squash c622c94 move readme.txt to readme.md
    squash ce64181 added readme
    squash 19beead removed excess lines

On the next page you will get something like:

    # This is a combination of 4 commits.
    # The first commit's message is:
    test not working
    # This is the 2nd commit message:

Here you can change the commit message to something that makes sense:

    # This is a combination of 4 commits.
    # The first commit's message is:
    Issue 2428203: Docker support
    # This is the 2nd commit message:

Now merge 2428203-rebased to 7.x-1.x, and delete the intermediary branch, like this:

    git checkout 7.x-1.x
    git merge 2428203-rebased
    git branch -d 2428203-rebased

Now your log will look a lot nicer:

    git log --pretty=format:'%d %h %s'
    (HEAD, 7.x-1.x) 2590e4a Issue 2428203: Docker support
    (tag: 7.x-1.0-beta2, origin/HEAD, origin/7.x-1.x) fc20992 Updates to the README.txt file
