---
layout: post
title: Using Gerrit to review a change to your code
author: admin
id: 85
created: 1417702518
tags:
  - blog
permalink: /blog/85/using-gerrit-review-change-your-code/
redirect_from:
  - /blog/85/
  - /node/85/
---
[Gerrit](https://code.google.com/p/gerrit/) is a free open-source code review platform created by Google. In this post we will develop code locally and review it in Gerrit.

Step 1: install Gerrit and set up your git repo.
----------------------

 * Start by [installing a Gerrit server](http://blog.dcycle.com/blog/82) at http://gerrit.example.com:8080.
 * Then, [make sure you have a git repo](http://blog.dcycle.com/blog/82/setting-gerrit-centos-evaluation) on your Gerrit server.

Step 2: set up your computer with `git-review`
--------------

Each developer needs to instal `git-review` on his or her laptop in order to work with Gerrit. [These detailed instructions](http://www.mediawiki.org/wiki/Gerrit/Tutorial#Prepare_to_work_with_gerrit) show how, but if your local machine is Mac OS X you can try this:

    sudo easy_install pip
    sudo pip install git-review
    mkdir -p ~/.config/git-review/
    echo "[gerrit]" >> ~/.config/git-review/git-review.conf
    echo "defaultremote = origin" >> ~/.config/git-review/git-review.conf

Step 3: clone the repo
--------------

Navigate to your project at http://gerrit.example.com:8080, and you will see the git clone command for that repository. It is important to use the ssh protocol (you will have the options for HTTP or SSH). If you do not see SSH, make sure you have a username set up on your Gerrit account, and an public ssh key associated with it. If it still does not work you can [read these instructions](http://gerrit.blog.dcycle.com:8080/Documentation/access-control.html).

Copy that command and paste it on your local machine, it will look like this:

    git clone http://username@gerrit.example.com:8080/projectname
    cd projectname
    git review -s

Step 4: develop your code
--------------

Before developing, create a new feature branch.

    git checkout -b ISSUE1234

Develop your code as you normally would, commit as many times as you want.

Step 5: squash your commits
--------------

Gerrit enforces one review per commit, the idea being that a commit should be a small valuable piece of code. If you have several commits which, taken separately, have no meaning in the larger scale of the project, you need to _squash them_.

    git rebase -i origin/master

This will open a text editor with something like:

    pick 680a9de another error
    pick a8b63ab fixed typo
    pick a8b63ab syntax error
    ...

Change this to

    pick 680a9de another error
    squash a8b63ab fixed typo
    squash a8b63ab syntax error
    ...

Save. On the following screen you can change the message "another error" to something  meaningful like "#ISSUE1234 this is a reasonable description of the issue"

Step 6: Request a review
------------------------

Now your code is perfect, and you are ready to request a review:

    git review -R

If you get a message complaining that you have more than one commit, make sure you squash your commits (see above). If it complains that you have a Change-Id missing, see [this article](http://www.mediawiki.org/wiki/Gerrit/Tutorial#Prepare_to_work_with_gerrit). If you have an access denied, make sure your ssh key is set up properly and you have access to the repo via Gerrit's ACL system (if you followed the instructions herein, you should have).

Step 7: View the change in Gerrit's Review GUI
------------------------

Navigate to your Gerrit web page, and go to All > Open, and you will be able to click on your review request. You can see changes to files, and click on the line numbers to leave inline comments.

References
----------
 * [Gerrit Code Review - Quick get started guide](https://gerrit-review.googlesource.com/Documentation/install-quick.html#_my_first_change)
 * [Gerrit explained](http://forum.xda-developers.com/showthread.php?t=2628545)
