---
layout: post
title:  "Alpine and Docker, a perfect fit"
author: admin
id: 2022-04-21
tags:
  - blog
permalink: /blog/2022-04-21/alpine-docker/
redirect_from:
  - /blog/2022-04-21/
  - /node/2022-04-21/
---

Working with a new M1-powered MacBook has had a big effect on my Docker workflows.

On the one hand, containers properly configured for the ARM achitecture, used by M1, are very fast, as discussed in [Docker PHP on the M1 chip, example with Static Analysis on Drupal: 9 times faster, on November 17, 2021](https://blog.dcycle.com/blog/2021-11-17/m1-docker-php-speed-test/).

On the other hand, I've often gotten very ugly errors when using Docker buildx to try to make multi-platform images, both using PHP and Node. One such error is described in [Warning: 'ldconfig' not found in PATH or not executable](https://github.com/dcycle/docker-drupal/issues/21) -- like I said, very, very ugly and not fun to debug.

I have found that moving from Debian to Alpine-base images has done away with these weird errors completely, while having an agreeable side-effect: vastly smaller images.

We'll look at smaller images in second, but first, some issues I've encountered with Alpine...

PHP and the webserver need to be in separate images
-----

I know that the "Docker way" is to split responsibilities between different containers, so in my projects I've always split out my database container from my PHP container using Docker Compose.

However, perhaps by habit from my pre-Docker days, I've always kept the webserver and PHP applications (Drupal, for example) on the same container. This has always been easy because images like [php](https://hub.docker.com/_/php?tab=tags&page=1&name=apache) and [Drupal](https://hub.docker.com/_/drupal?tab=tags&page=1&name=apache) provide "apache" tags which combine PHP and Apache in the same container.

Upon first toying with Alpine, however, I was puzzled that images didn't provide "alpine-apache" tags. But on further inspection, this makes a lot of sense, since Apache and PHP are really two seprate things: it makes sense to split them into separate containers; this also has the added benefit of making it possible to easily switch out Apache for Nginx if such is your desire.

I touch more on this subject in the article [PHP and Apache (or Nginx) in separate Docker containers using Docker Compose, March 25, 2022](https://blog.dcycle.com/blog/2022-03-25/php-apache-different-containers/).

When I moved one of my projects, the [Dcycle Drupal Starterkit](https://github.com/dcycle/starterkit-drupalsite), to Alpine, I applied this separation into distinct containers with good results. [Here is docker-compose.yml files which demonstrates that](https://github.com/dcycle/starterkit-drupalsite/blob/master/docker-compose.yml).

Alpine over Debian: vastly smaller size
-----

Big image sizes is not just a nuisance, and reducing the size of the Docker images increases the speed of every step of your pipeline, from development to continuous integration to testing to building. Furthermore, any time a developer finds themselves using a slow internet connection, having smaller-sized images can make the difference between working, and waiting.

Let's look at tags [3](https://hub.docker.com/r/dcycle/browsertesting/tags?page=1&name=3) and [4](https://hub.docker.com/r/dcycle/browsertesting/tags?page=1&name=4) of an image I maintain, which [runs end-to-end tests agains a headless browser](https://github.com/dcycle/docker-browsertesting).

At the time of this writing:

* The 3 tag, based Node using Debian Bullseye, is 524.77 MB
* The 4 tag, using Alpine, is 177.03 MB on AMD, and 175.52 MB on ARM.

The Alpine tag is just one third the size of the Debian tag. This has a significant impact on our development cycle here at Dcycle; and I plan to move all images and projects I maintain to Alpine when it is feasible to do so.
