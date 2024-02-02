---
layout: post
title: Setting up Gerrit on CentOS for evaluation
author: admin
id: 82
created: 1417556376
tags:
  - blog
permalink: /blog/82/setting-gerrit-centos-evaluation/
redirect_from:
  - /blog/82/
  - /node/82/
---
[Gerrit](https://code.google.com/p/gerrit/) is a free open-source code review platform created by Google. Here is how to set up a quick, insecure version of Gerrit for evaluation.

You might also be interested in [Phabricator](http://phabricator.org) ([installing](http://blog.dcycle.com/blog/79), [linking with git](http://blog.dcycle.com/blog/80), and [reviewing code](http://blog.dcycle.com/blog/81)), another product which I am also evaluating for code review.

Step 1: get a new server
------------------------

I do not recommend installing this on an existing server or alongside other software. Start with a new CentOS 6.x server with 1 Gb of RAM (I used [Digital Ocean](https://www.digitalocean.com/)). Note your server IP address (1.2.3.4).

Step 2: set up a subdomain to point to your server
--------------------------------------------------

Using your domain management system (I use [AlternC](http://alternc.org) hosted at [Koumbit](https://www.koumbit.org)), create a new subdomain (gerrit.example.com) which points to 1.2.3.4.

Step 3: Create a directory for storing git repos
------------------------------------------------

Because this server is for evaluation purposes, we will run as root. Do not do this if you decide to use Gerrit for production. We need to create a directory to store our git repos:

    mkdir /root/git

Step 4: Download Java, Git and Gerrit
-----------------------

Start by finding the path the latest Gerrit war using a web search. In our case we will use http://gerrit-releases.storage.googleapis.com/gerrit-2.9.2.war

    cd /tmp
    sudo yum install wget
    sudo yum install git
    sudo yum install java-1.7.0-openjdk
    wget http://gerrit-releases.storage.googleapis.com/gerrit-2.9.2.war

Now run the following command and give the default replies for all questions *except* the Git repo location, which, instead of "git", should be "/root/git".

    sudo java -jar gerrit*.war init -d /srv/gerrit

Step 5: Start the Gerrit daemon
-------------------------------

    /srv/gerrit/bin/gerrit.sh start

Now you can visit gerrit.example.com:8080 and you will see the Gerrit dashboard!

Next step
--------

 * [Set up Gerrit with a git repo](http://blog.dcycle.com/blog/84/setting-gerrit-git-repo)

Next step
----

 * [Reviewing a code change with Gerrit](http://blog.dcycle.com/blog/85/using-gerrit-review-change-your-code)

Resources
---------

 * [Notes on setting up Gerrit on CentOS](http://readystate4.com/2011/06/23/notes-on-setting-up-gerrit-code-review-on-centos/)
