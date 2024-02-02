---
layout: post
title: Deploying Letsencrypt with Docker-Compose
id: 7f3ea9e1
tags:
  - blog
permalink: /blog/7f3ea9e1/letsencrypt-docker-compose/
redirect_from:
  - /blog/7f3ea9e1/
  - /node/7f3ea9e1/
---

Last week I [wrote about setting up a reverse-proxy](http://blog.dcycle.com/blog/170a6078/letsencrypt-drupal-docker/) to serve a number any number of Docker containers via https.

In order for this technique to work with Docker-Compose, we need to add a network to the Docker-Compose container.

Premise
-----

Let's say you have a server, such a stage.example.com, where you are running a number of Docker-Compose based projects, and you want each of them to be available on HTTPS.

You might have previously set up projects on that server using the technique described in [my last post](http://blog.dcycle.com/blog/170a6078/letsencrypt-drupal-docker/), and now you want to deploy a docker-compose based project to the same server using a new domain, my-new-domain.example.com.

Here's how to do it:

Step one: launch your Docker-compose project
-----

Use the appropriate environment variables. A very simple Docker-compose file might look like:

    version: '2'
    
    services:
      httpd:
        image: httpd
        environment:
          VIRTUAL_HOST: my-new-domain.example.com
          LETSENCRYPT_HOST: my-new-domain.example.com
          LETSENCRYPT_EMAIL: me@example.com
        expose:
          - "80"

Run `docker-compose up -d` and your project will be up, but even though the environment variables are correctly set, your site will not be publicly available.

Step two: add your new network and restart your letsencrypt container
-----

You can find your network id by typing `docker network ls`. It should be something like directory_name_default (we'll use that in this example). You can also declare the network name in the compose file so it's always the same.

Now that you know the network id (directory_name_default), you need to add it to the nginx-proxy container, and restart the nginx-letsencrypt container:

    docker network connect directory_name_default nginx-proxy
    docker restart nginx-letsencrypt
