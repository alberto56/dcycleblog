---
layout: post
title: Setting up Phabricator to track a git repo
author: admin
id: 80
created: 1417546235
tags:
  - blog
permalink: /blog/80/setting-phabricator-track-git-repo/
redirect_from:
  - /blog/80/
  - /node/80/
---
[Phabricator](http://phabricator.org) is a free open-source code review and workflow management system. Here is how it can be used to track a git repo.

Step 1: install Phabricator
---------------------------

If you are just evaluating Phabricator you can use [these instructions](http://dcycleproject.org/blog/79/installing-evaluation-version-phabricator) to set up an evaluation version in less than an hour.

Step 2: set up authentication
-----------------------------

By default anyone can create accounts. In this example we will limit new accounts to people with emails from our organization. Go to http://phabricator.example.com/auth/, click `auth.email-domains` and follow the ensuing instructions.

Step 3: make sure you have a GitHub account with a dummy project
----------------------------------------------------------------

Although Phabricator can host Git repos, in our example we will use an existing repo as most organizations already have a git hosting system. We will be using GitHub. Make sure you have an account and a project you can use for testing purposes (you can fork my [Drupal 7 sample site](https://github.com/alberto56/drupal7ci_stage2) if you wish -- See the project's README.md for how to install it).

Step 4: give Phabricator its own GitHub account with access to your repo
------------------------------------------------------------------------

Phabricator needs to access this git repo with an SSH key pair. We do not want to give Phabricator access to all of git, because of security concerns.

 * Open a browser you don't normally use, one on which you are not connected to GitHub with your existing account.
 * Visit GitHub and create a new account. Tip: if you are using Gmail, you can set Phabricator's account's email address to my-email-address+phabricator@gmail.com
 * Take note of the account name and password.
 * Create a public private SSH key pair for Phabricator to link to your Git Repo:

On your computer, type *BUT DO NOT PRESS ENTER JUST YET*:

		ssh-keygen -t rsa -C "my-email-address+phabricator@gmail.com"

*IMPORTANT:* Make sure that at the following prompt you do not enter the default location, or else you will overwrite your existing key. Instead, save the new key to the desktop:

    /Users/my-user-name-on-my-computer/Desktop/id_rsa

Now you can visit [Phabricator's GitHub profile](https://github.com/settings/ssh) and add its public SSH key, which you can retrieve through:

    cat ~/Desktop/id_rsa.pub

Now you can log out of Phabricator's GitHub account and log back into your GitHub account and navigate to your dummy project. In settings > collaborators, you can add the account name you just created.

Step 5: Make Phabricator aware of your Git repo
-----------------------------------------------

Because we are using an external repo to host our project, we need to make Phabricator aware of it.

 * Go to Diffusion, Phabricator's repository management system at http://phabricator.example.com/diffusion/
 * Click "New repository" and follow the instructions for importing an existing repository. *Even though it says "importing", don't worry: "The authoritative master version of the repository will stay where it is now"*
 * Follow the instructions on screen until you reach the "Authentication" section.
 * At the "Authentication" section, click "Add credential"
 * Add the private key you can get by typing `cat ~/Desktop/id_rsa` on your computer.
 * When you hit the page which says "Start import now", check that option and continue.
 * On the next page, you likely will have errors. Fix them on the command line of your Phabricator server as per the instructions, and reload that page until all the status indicators are green.

Note: when attempting to start the daemon, you may get "PHP missing extensions errors". I needed to install posix:

    sudo yum install -y php-posix

Next step
----------

 * [Using Phabricator for code review](http://dcycleproject.org/blog/81/setting-phabricator-review-code).
