---
layout: post
title: sed for changing text in a file
author: admin
id: 103
created: 1445957303
permalink: /blog/103/sed-changing-text-file/
redirect_from:
  - /blog/103/
  - /node/103/
---
    $ echo hello > world
    $ cat world
    hello
    $ sed -i.bak 's/$/ world/g' world
    $ cat world
    hello world
