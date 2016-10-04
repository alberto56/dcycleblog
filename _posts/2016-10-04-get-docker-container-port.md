---
layout: post
title: Getting a Docker container's dynamic port on the command line
id: 2016-10-04
tags:
  - snippet
permalink: /snippet/2016-10-04/get-docker-container-port/
redirect_from:
  - /snippet/2016-10-04/
---

Generally I like to map my Docker containers to dynamic ports to avoid port collisions, so I'll build my containers like this:

    docker run --name some-container-name -d -p 80 some-image

Here, Docker will find a free port and map it to port 80 on the container.

Although not foolproof, the following code will tell you what that port is:

    PORT="$(docker ps|grep some-container-name|sed \
      's/.*0.0.0.0://g'|sed 's/->.*//g')"
