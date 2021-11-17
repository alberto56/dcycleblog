---
layout: post
title:  "Docker PHP on the M1 chip, example with Static Analysis on Drupal: 9 times faster"
author: admin
id: 2021-11-17
tags:
  - blog
  - planet
permalink: /blog/2021-11-17/m1-docker-php-speed-test/
redirect_from:
  - /blog/2021-11-17/
  - /node/2021-11-17/
---

In 2020, Apple unveiled a new chip, M1, which uses a different architecture than the Intel chips widely used in servers and laptops.

Docker calls the intel architecture "linux/amd64", and the M1 architecture "linux/arm64" (can also be linux/arm64/v7, linux/arm64/v8, etc.).

We will attempt to look at a speed test for a typical Dockerized PHP processs.

Our test
-----

I have used a [Dockerized version of PHPStan for Drupal](https://github.com/dcycle/docker-phpstan-drupal) that I am maintaining, in order to run the tests.

The goal of this is to perform static analysis of PHP code, making sure it has an internal logic, without actually running it.

I use Jenkins to rebuild this Docker image weekly to make sure it is always up-to-date. My Jenkins job uses the DigitalOcean API to create a new virtual machine, then uses the technique described by Artur Klauser in his article [Building Multi-Architecture Docker Images With Buildx, Artur Klauser, Medium, Jan 18, 2020](https://medium.com/@artur.klauser/building-multi-architecture-docker-images-with-buildx-27d80f7e2408) to create a multi-architecture image. [I have also created a GitHub project which helps set this up on the VM](https://github.com/dcycle/prepare-docker-buildx).

The image is available on the [Docker Hub](https://hub.docker.com/r/dcycle/phpstan-drupal/tags?page=1&ordering=last_updated).

On a weekly basis, I push a tag 4 which is always the latest version, I also push a tag with the day's date and time, for example the tag "4.2021-10-21-20-15-31-UTC" only has the linux/amd64 architecture, whereas the tag "4.0.2021-11-17-13-45-26-UTC" has both linux/amd64 and linux/arm64.

Our test consists of running the static analysis agains the _node_ module, part of the Drupal project.

We have run our tests on the latest version of Docker Desktop, on a mid-2014 dual-core Intel i7 chip Macbook Pro, and on a 2021 M1 Max MacBook Pro. In both cases, we allocated 10 Gb RAM to Docker; for our Intel mac, we allocate 2 CPUs; and on M1 we allocated 5 CPUs.

Results using emulation
-----

We will start by using a Docker image built only for the linux/amd64 architecture, forcing our M1 Mac to use emulation:

    docker pull dcycle/phpstan-drupal:4.2021-10-21-20-15-31-UTC
    time docker run --rm dcycle/phpstan-drupal:4.2021-10-21-20-15-31-UTC /var/www/html/core/modules/node --memory-limit=-1

On our 2014 Intel Macbook, we get 1:27.258; and on M1, we get 1:25.16, not a speed increase you'd write to your mother about (not that she'd understand if you did).

In this case M1 warns us:

    WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested

For these tests, we're not interested in the actual test results, although

Results with a native ARM image
-----

    docker pull dcycle/phpstan-drupal:4.0.2021-11-17-13-45-26-UTC
    time docker run --rm dcycle/phpstan-drupal:4.0.2021-11-17-13-45-26-UTC /var/www/html/core/modules/node --memory-limit=-1

Now we have a more eyebrow-rising speed increase: 9.782 seconds for the M1, and, unsurprisingly, 1m26.842 for the Intel (there is always a small variation in execution times, so we will consider the difference between the two image build times insignificant for the Intel).

Conclusion
-----

If you're using PHP Docker images in emulation module, there is virtually no speed increase between a 2014 Intel-based Macbook Pro and and a M1 Max-based Macbook Pro.

However, if you invest in using M1-optimized images, [like I did with my PHPStan Drupal image](https://github.com/dcycle/docker-phpstan-drupal/commit/70324881392f34d24f7f8620e7f2cc72f424e1ee), you can reap very interesting speed increases for your PHP, and other, Docker jobs.
