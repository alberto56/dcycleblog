---
layout: post
title: Multiple git remotes, the --depth parameter and repo size
author: admin
id: 87
created: 1421767863
tags:
  - blog
  - planet
permalink: /blog/87/multiple-git-remotes-depth-parameter-and-repo-size/
redirect_from:
  - /blog/87/
  - /node/87/
---
When building a Drupal 7 site, one oft-used technique is to keep the entire Drupal root under git (for Drupal 8 sites, I favor [having the Drupal root one level up](http://dcycleproject.org/blog/68)).

Starting a new project can be done by downloading an unversioned copy of D7, and initializing a git repo, like this:

Approach #1
-----------

    drush dl
    cd drupal*
    git init
    git add .
    git commit -am 'initial project commit'
    git remote add origin ssh://me@mygit.example.com/myproject

Another trick I learned from my colleagues at the Linux Foundation is to get Drupal via git and have two origins, like this:

Approach #2
-----------

    git clone --branch 7.x http://git.drupal.org/project/drupal.git drupal
    cd drupal
    git remote rename origin drupal
    git remote add origin ssh://me@mygit.example.com/myproject

This second approach lets you push changes to your own repo, and pull changes from the Drupal git repo. This has the advantage of keeping track of Drupal project commits, and your own project commits, in a unified git history.

    git push origin 7.x
    git pull drupal 7.x

If you are tight for space though, there might be one inconvenience: Approach #2 keeps track of the _entire Drupal 7.x commit history_, for example we are now tracking in our own repo commit e829881 by natrak, on June 2, 2000:

    git log |grep e829881 --after-context=4
    commit e8298816587f79e090cb6e78ea17b00fae705deb
    Author: natrak <>
    Date:   Fri Jun 2 18:43:11 2000 +0000

        CVS drives me nuts *G*

All of this information takes disk space: Approach #2 takes 156Mb, vs. 23Mb for approach #1. This may add up if you are working on several projects, and especially if for each project you have several environments for feature branches. If you have a continuous integration server tracking multiple projects and spawning new environments for each feature branch, several gigs of disk space can be used.

If you want to streamline the size of your git repos, you might want to try the `--depth` option of git clone, like this:

Approach #3
-----

    git clone --branch 7.x --depth 1 http://git.drupal.org/project/drupal.git drupal
    cd drupal
    git remote rename origin drupal
    git remote add origin ssh://me@mygit.example.com/myproject

Adding the `--depth` parameter here reduces the initial size of your repo to 18Mb in my test, which interestingly is even less than approach #1. Even though your repo is now linked to the Drupal git repo, by running `git log` you will see that the entire history is not being stored.
