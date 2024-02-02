---
layout: post
title: 'Docker-compose cp'
author: admin
id: ae67284c
tags:
  - snippet
permalink: /blog/ae67284c/docker-compose-cp/
redirect_from:
  - /blog/ae67284c/
  - /node/ae67284c/
---
Docker-compose [currently does not support `cp`](https://github.com/docker/compose/issues/3593).

Here is a workaround:

    docker cp /path/to/my-local-file.sql "$(docker-compose ps -q mycontainer)":/file-on-container.sql

Now /file-on-container.sql will exist on your running container:

    docker-compose exec mycontainer /bin/bash -c 'ls -lah /file-on-container.sql'
    -rw-r--r-- 1 root root 244M Nov 14 19:48 /file-on-container.sql

