---
layout: post
title: Setting up Gerrit with a git repo
author: admin
id: 84
created: 1417701225
tags:
  - blog
permalink: /blog/84/setting-gerrit-git-repo/
redirect_from:
  - /blog/84/
  - /node/84/
---
[Gerrit](https://code.google.com/p/gerrit/) is a free open-source code review platform created by Google. In this post we will set up Gerrit with a Git repo.

Step 1: install Gerrit
----------------------

See [this post](http://blog.dcycle.com/blog/82) for instructions on how to install Gerrit on CentOS. We will assume that your Gerrit instance is available at http://gerrit.example.com:8080.

Step 2: Set the canonical URL
-----------------------------

Make sure the canonical web url is correctly set to http://gerrit.example.com:8080. This is required to log into the web interface.

    vi /srv/gerrit/etc/gerrit.config

Once that is done, restart gerrit

    /srv/gerrit/bin/gerrit.sh restart

Step 3: log into Gerrit
-----------------------

Gerrit relies on OpenID, and because of [this bug](https://code.google.com/p/gerrit/issues/detail?id=2677&q=openid&colspec=ID%20Type%20Stars%20Milestone%20Status%20Priority%20Owner%20Summary) Google does not qualify as of this writing. You have to use an alternate "supported" OpenID provider such as Yahoo, which we'll use here: open a Yahoo account which you will use to log into Gerrit. To create the first account, visit your Gerrit front page and create your account by clicking "Register".

Add your name and your public ssh key.

**It is important to set your username as well in order to be able to clone and push git repos.**

*Important note:* I could not figure out how to disable registration of new users to Gerrit, so it is important to set access rules at the project level.

Step 4: Understanding how Gerrit works.
-----------------------------

Gerrit seems to be designed to _manage_ git repos, rather than tack onto an existing workflow ([like Phabricator](http://blog.dcycle.com/blog/81/setting-phabricator-review-code)). I [looked this up](http://stackoverflow.com/questions/15384799/how-to-update-gerrit-repos-with-changes-submitted-directly-to-git/15393748#15393748) and it seems that Gerrit requires you to host your Git repo on the Gerrit server itself.

If you are already hosting your git repos on Stash, or Gitolite, or GitHub, you might want to experiment using mirroring or some other technique, but for this demo I will make Gerrit the canonical git provider for my repo.

According to [Using Gerrit and Git (video)](https://www.youtube.com/watch?v=Wxx8XndqZ7A), reviews are at the commit level (5 commits = 5 reviews), which may or may not be in line with your shop's practices. The idea is that we want to _force_ developers to squash commits into valuable units for better commit log. We'll see how later on.

Step 5: Move your canonical git repo to Gerrit
-----------------------------

Wherever your current git repo is now, the only way I could get Gerrit to work was to move the Git repo to Gerrit, although [there is a discussion about this (and maybe some workaround)](https://groups.google.com/forum/#!topic/repo-discuss/-QjX2aT-3v0).

So: first thing to do is to log into Gerrit and move to Gerrit's git folder. If you followed [these instructions](http://blog.dcycle.com/blog/82) to install Gerrit, your git directory on Gerrit will be at `/root/git`. This is not an ideal location, and is probably not secure, but if you are just evaluating Gerrit with some dummy repositories, it will do.

As described [here](https://groups.google.com/forum/#!topic/repo-discuss/UBxDXPmRMvc), you will need to create a local copy of your external git repo. Gerrit's local copy _will become the canonical git repo for your project_. Here is an example with [one of my projects on GitHub](https://github.com/alberto56/drupal7ci_stage2):

 * Start by going to Projects > Create new project and create a new project `whatever.git`. This will create a new _empty_ git repo on your server at `/root/git/whatever.git`.
 * Now log onto your Gerrit server in the command line and replace the git repo just created with a clone of your _bare_ git repo:

    cd /root/git # I know, this is not ideal, it's just for evaluation!
    rm -rf whatever.git
    git clone --bare https://github.com/alberto56/drupal7ci_stage2.git whatever.git

The above will work because I'm cloning an open source directory. You might need to create an ssh key pair for Gerrit to connect to your git repo if it is not publicly available, but that's outside the scope of this article.
