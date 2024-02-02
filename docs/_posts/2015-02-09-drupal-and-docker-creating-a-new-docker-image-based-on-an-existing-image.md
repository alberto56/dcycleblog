---
layout: post
title: 'Drupal and Docker: Creating a new Docker image based on an existing image'
author: admin
id: 89
created: 1423492015
tags:
  - blog
  - planet
permalink: /blog/89/drupal-and-docker-creating-new-docker-image-based-existing-image/
redirect_from:
  - /blog/89/
  - /node/89/
---
To get the most of this blog post, please read and understand [Getting Started with Docker (Servers for Hackers, 2014/03/20)](https://serversforhackers.com/getting-started-with-docker/). Also, all the steps outlined here have been done on a [Vagrant CoreOS virtual machine (VM)](https://coreos.com/docs/running-coreos/platforms/vagrant/).

I recently needed a really simple non-production Drupal Docker image on which I could run tests. `b7alt/drupal` (which you can find by typing `docker search drupal`, or [on GitHub](https://github.com/b7alt/drupal)) worked for my needs, except that it did not have the cUrl php library installed, so `drush en simpletest -y` was throwing an error.

Therefore, I decided to create a new Docker image which is based on `b7alt/drupal`, but with the `php5-curl` library installed.

I started by creating a new local directory (on my CoreOS VM), which I called `docker-drupal`:

    mkdir docker-drupal

In that directory, I created `Dockerfile` which takes `b7alt/drupal` as its base, and runs `apt-get install curl`.

    FROM b7alt/drupal

    RUN apt-get update
    RUN apt-get -y install curl

(You can find this code at my GitHub account at [`alberto56/docker-drupal`](https://github.com/alberto56/docker-drupal).)

When you run this you will get:

    docker build .
    ...
    Successfully built 55a8c8999520

That hash is a Docker image ID, and your hash might be different. You can run it and see if it works as expected:

    docker run -d 55a8c8999520
    c9a98bdcab4e027e8571bde71ee92b4380247a44ef9314749ef5680864de2928

In the above, we are telling Docker to create a container based on the image we just created (`55a8c8999520`). The resulting container hash is displayed (yours might be different). We are using `-d` so that our containers runs in the background. You can see that the container is actually running by typing:

    docker ps
    CONTAINER ID        IMAGE               COMMAND...
    c9a98bdcab4e        55a8c8999520        "/usr/bin/supervisor...

This tells you that there is a running container (`c9a98bdcab4e`) based on the image `55a8c8999520`. Again, your hases will be different. Let's log into that container now:

    docker exec -it c9a98bdcab4e bash
    root@c9a98bdcab4e:/#

To make sure that cUrl is successfully installed, I will figure out where Drupal resides on this container, and then try to enable Simpletest. If that works, I will consider my image a success, and `exit` from my container:

    root@c9a98bdcab4e:/# find / -name 'index.php'
    /srv/drupal/www/index.php
    root@c9a98bdcab4e:/# cd /srv/drupal/www
    root@c9a98bdcab4e:/srv/drupal/www# drush en simpletest -y
    The following extensions will be enabled: simpletest
    Do you really want to continue? (y/n): y
    simpletest was enabled successfully.                   [ok]
    root@c9a98bdcab4e:/srv/drupal/www# exit
    exit

Now I know that my `55a8c8999520` image is good for now and for my purposes; I can create an account on [Docker.com](https://www.docker.com) and push it to my account for later use:

    Docker build -t alberto56/docker-drupal .
    docker push alberto56/docker-drupal

Anyone can now run this Docker image by simply typing:

    docker run alberto56/docker-drupal

One thing I had a hard time getting my head around was having a GitHub project and Docker project, and both are different but linked. The GitHub project is the the recipe for creating an image, whereas the Docker project is the image itself.

One we start thinking of our environments like this (as entities which should be versioned and shared), the risk of differences between environments is greatly reduced. I was used to running simpletests for my projects on an environment which is managed by hand; when I got a strange permissions error on the test environment, I decided to start using Docker and version control to manage the container where tests are run.
