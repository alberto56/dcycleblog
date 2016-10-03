---
layout: post
title: Using git's --graph option to view branch history in the command line
author: admin
id: 95
created: 1436195103
tags:
  - snippet
permalink: /blog/95/using-gits-graph-option-view-branch-history-command-line/
redirect_from:
  - /blog/95/
  - /node/95/
---
When merging branches in git, it might be useful to view the commit history in the form of a graph.

Here is an example on a simple directory with a master branch and two feature branches, a and b. To set up the example you can run the following commands:

    mkdir test
    cd test
    echo 'a' >> hello.txt
    echo 'b' >> hello.txt
    echo 'c' >> hello.txt
    git init
    git add hello.txt
    git commit -am 'initial commit'
    git checkout -b a
    sed -i -e 's/a/aa/g' hello.txt
    git commit -am 'doubled a'
    git checkout master
    git checkout -b b
    sed -i -e 's/b/bb/g' hello.txt
    git commit -am 'doubled b'
    git checkout master
    git merge a
    git merge b
    echo 'aa' > hello.txt
    echo 'bb' >> hello.txt
    echo 'c' >> hello.txt
    git commit -am 'fixed conflict'

Here is the output from a non-graph git history:

    git log --pretty=format:'%h %d %s'
    bf18175  (HEAD, master) fixed conflict
    270ff87  (b) doubled b
    8a3e654  (a) doubled a
    342769f  initial commit

In some cases you might want to see the history in the form of a graph to understand where different commits are coming from. Here is how:

    git log --graph --pretty=format:'%h %d %s'
    *   bf18175  (HEAD, master) fixed conflict
    |\  
    | * 270ff87  (b) doubled b
    * | 8a3e654  (a) doubled a
    |/  
    * 342769f  initial commit
