---
layout: post
title: Erasing old builds on Jenkins to free up space
id: 57
created: 1398193710
tags:
  - snippet
permalink: /blog/57/erasing-old-builds-jenkins-free-space/
redirect_from:
  - /blog/57/
  - /node/57/
---
If you need to free up space on your Jenkins server and you don't mind losing all your old build information, you can do this:

    sudo rm -rf /var/lib/jenkins/jobs/MYJOBNAME/builds
    sudo service jenkins restart
    sudo apachectl restart
