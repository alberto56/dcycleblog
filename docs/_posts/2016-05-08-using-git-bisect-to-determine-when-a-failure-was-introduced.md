---
layout: post
title: Using git bisect to determine when a failure was introduced
author: admin
id: 111
created: 1462669698
tags:
  - blog
permalink: /blog/111/using-git-bisect-determine-when-failure-was-introduced/
redirect_from:
  - /blog/111/
  - /node/111/
---
So your project's tests are failing and you're not sure when the failure was introduced. Your git history might look like:

    f09c875 - failing commit
    9344dc8 - ?
    a84feca - ?
    1a66df1 - ?
    05e4293 - ?
    acbddb6 - ?
    5fb7fac - ?
    fba9f93 - ?
    93cdfa0 - ?
    c9e0fc2 - ?
    804e201 - ?
    60f034e - ?
    8db21ad - ?
    67974f0 - passing commit

You know that f09c875 is failing and 67974f0 is passing. Your failure was introduced in one of the intermediate commits, but which is it?

First, determine which script will determine whether a commit is good or bad. In this example, let's imagine there is a script called `./test.sh` which returns `0` on pass and `1` on fail. (this script can be inside or outside of your git repo).

Instead of running `./test.sh` on random intermediate commits until we find our answer, `git bisect` can do it for us. In this example, we'll tell `git bisect` which is the first commit we know to be failing, and which commit we know to be passing.

    git bisect reset
    git bisect start
    git bisect bad f09c875
    git bisect good 67974f0

Now we can tell `git bisect` to repeatedly run `./test.sh` on as many commits as necessary (ceil(_n_ log(2)) where _n_ is the number of unknown commits, in this example ceil(12 log(2)) = 4) in order to find out exactly when ./test.sh started failing:

    git bisect run ./test.sh

In this example, I have purposefully inserted a failure at commit acbddb6, so `git bisect run` will do two things, first it will tell me what the first failing commit it:

    acbddb6 is the first bad commit

Then it will checkout the last good commit, in this case `5fb7fac`.

Generally, my continuous integration server will tell me immediately if something is failing; however in rare cases, for example if our CI server is down or gives us false negatives or positives, or if we decide as a team that it is acceptable to merge in a failing branch to develop and fix it before merging develop to master, we can find ourselves in a situation where we lost track of exactly when a specific failure was introduced.

In such cases `git bisect` automation can be a great time-saver. I have recently had to use it for tests which take 10 minutes to run, on 20 commits. I started it before leaving for the night and had my answer the next morning.
