---
layout: post
title: Installing Docker and Docker Compose en Ubuntu 20
id: 2022-06-14
author: admin
tags:
  - snippet
permalink: /blog/2022-06-14/docker-docker-compose-ubuntu/
redirect_from:
  - /blog/2022-06-14/
  - /node/2022-06-14/
---

    echo '=> Installing Docker, see https://docs.docker.com/engine/install/ubuntu/.'
    echo '=> See also https://blog.dcycle.com/blog/2022-06-14/.'
    sudo apt-get update
    sudo apt-get install -y \
      ca-certificates \
      curl \
      gnupg \
      lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

    echo '=> Installing Docker Compose.'
    sudo apt-get -y install docker-compose
