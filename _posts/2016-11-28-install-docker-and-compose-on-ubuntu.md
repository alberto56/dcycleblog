---
layout: post
title: 'Installing Docker and Docker-compose on Ubuntu 16'
author: admin
id: dbab31ca
tags:
  - snippet
permalink: /blog/dbab31ca/install-docker-ubuntu
redirect_from:
  - /blog/dbab31ca/
  - /node/dbab31ca/
---
Here is a quick script which installs Docker and Docker compose on new Ubuntu 16 VMs:

    curl -sSL https://get.docker.com/ | sh
    curl -L https://github.com/docker/compose/releases/download/1.9.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
You should now have Docker and Docker compose on your Ubuntu VM:

    docker-compose -v
    docker -v
