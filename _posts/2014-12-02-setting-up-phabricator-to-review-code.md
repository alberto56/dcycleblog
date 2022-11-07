---
layout: post
title: Setting up Phabricator to review code
author: admin
id: 81
created: 1417553429
tags:
  - blog
permalink: /blog/81/setting-phabricator-review-code/
redirect_from:
  - /blog/81/
  - /node/81/
---
[Phabricator](http://phabricator.org) is a free open-source code review and workflow management system. Here is how it can be integrated into a code-review workflow.

Step 1: install Phabricator and make it track a git repo
---------------------------

 * If you are just evaluating Phabricator you can use [these instructions](http://blog.dcycle.com/blog/79/installing-evaluation-version-phabricator) to set up an evaluation version in less than an hour.
 * Once that is done, [set up Phabricator to track a git repo](http://blog.dcycle.com/blog/80/setting-phabricator-track-git-repo).

Step 2: understand the difference between reviews and audits
------------------------------------------------------------

Read [this article](https://secure.phabricator.com/book/phabricator/article/reviews_vs_audit/) which gives a good overview of what a review is and what an audit is in the Phabricator universe. In this tutorial we will be looking at reviews using Phabricator's differential tool.

Step 3: install Phabricator's Arcanist (`arc`) command-line tool
----------------------------------------------------------------

We will use `arc` to communicate between developers' workstations and the Phabricator server. This will allow us to request code reviews without going through the git repo. [Here is the installation guide for arc for Mac OS X](https://secure.phabricator.com/book/phabricator/article/arcanist_mac_os_x/).

Once you have installed `arc`, you need to point it to your Phabricator server and confirm that you are a valid user, here is how:

    arc set-config default http://phabricator.example.com
    arc install-certificate

Follow the instructions on-screen.

By default, it is required for each review to submit a [test plan](https://secure.phabricator.com/book/phabricator/article/differential_test_plans/). If you find this too intrusive, you can disable it (for example, if you define a test plan in your issue tracker):

		# this is done on your Phabricator server, not your local machine
    cd /path/to/phabricator
    bin/config set differential.require-test-plan-field false

Step 4: make a change to you code using git flow
------------------------------------------------

We will be using a simplified [gitflow](http://nvie.com/posts/a-successful-git-branching-model/) development model. The important thing is that discrete code changes with business value will occur on short-lived (less than one sprint) features branches.

Consider the following scenario:

 * Create a simple issue, [something like this](https://github.com/alberto56/drupal7ci_stage2/issues/1).
 * On your local computer, clone the repo and create a new feature branch called dev/1 (I am calling this branch dev/1 because my issue number is 1): `git checkout -b dev/1`.
 * Make as many commits as you with on this branch, related to this issue.
 * You can also push the branch to origin if you like.

Step 5: trigger the review process
----------------------------------

On your computer, make sure you have no uncommitted changes and type:

    arc diff master

This signifies that you would like a review of the diff between master and your current branch.

This will open the nano text editor with a "request for review message". The only thing which is compulsory (unless you disabled it; see above) is the [test plan, which should describe what your change does and how to test it](https://secure.phabricator.com/book/phabricator/article/differential_test_plans/). For example, you might write:

    Test Plan: Remove the Drupal "Powered by" block, check that it's removed

On your issue tracker, you can also set your issue to "needs review", which signals to your colleagues that they can assign themselves to the issue and visit http://phabricator.example.com/differential/ and start the review process. You will be able to add comments to the entire change, or inline in the diffs by clicking on individual line numbers.

At this point any user can comment on the review change.
