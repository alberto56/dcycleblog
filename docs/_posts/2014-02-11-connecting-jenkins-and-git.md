---
layout: post
title: Connecting Jenkins and Git
id: 51
created: 1392137590
tags:
  - blog
permalink: /blog/51/connecting-jenkins-and-git/
redirect_from:
  - /blog/51/
  - /node/51/
---
For your Jenkins job to connect to Git, you need two things:

1. An ssh key on your jenkins account
-------------------------------------------

The Jenkins user needs to have a public private key pair. To do this you need to log into your command line as the jenkins user. [Here is how](http://stackoverflow.com/questions/18068358). Use `sudo` if the system asks you for a password.

Once logged in, you can create your SSH key pair, and then add your public key to Github (or whatever you are using).

2. Establish the fingerprint
------------------------------

When you first start using Jenkins, you will probably get the following error:

    Failed to connect to repository : Command "git ls-remote -h ssh://git@example.com/my/repo.git HEAD" returned status code 128:
    stdout:
    stderr: Host key verification failed.
    fatal: The remote end hung up unexpectedly

In order to continue, log into jenkins once again in the command line (make sure you are the jenkins user by typing `sudo su -s /bin/bash jenkins`), and run the command:

    git ls-remote -h ssh://git@example.com/my/repo.git HEAD

Now, you will be able to accept the fingerprint and continue.
