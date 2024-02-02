---
layout: post
title:  "PHP and Apache (or Nginx) in separate Docker containers using Docker Compose"
author: admin
id: 2022-03-25
tags:
  - blog
permalink: /blog/2022-03-25/php-apache-different-containers/
redirect_from:
  - /blog/2022-03-25/
  - /node/2022-03-25/
---

In many cases, PHP and Apache are run in the same container and based on a single image.

For example, the [PHP image](https://hub.docker.com/_/php) has tags which combine Apache and Debian; Similarly for the [Drupal CMS image](https://hub.docker.com/_/drupal).

If you are currently managing a project which uses `php:apache-buster` on the `linux/arm64/v8` architecture, the image's uncompressed size as of this writing is 131.16 MB.

This might be fine for you; however maybe you want to move to Alpine, or Nginx; in such cases you might not be able to find a well-maintained base image to suit your needs.

That's where the idea of using _separate_ containers based on _separate_ images comes in.

In this post we will examine how to do that.

Example of a single-container solution
-----

Let's look at the simplest possible single-container solution. We'll have two files:

Our first file is `docker-compose.yml`:

    ---
    version: '3'

    services:
      php:
        image: php:apache-buster
        volumes:
          - ".:/var/www/html"
        ports:
          - "8888:80"

Our second file will be `index.php`:

    <?php

    print('<html><body><h2>This page was genrated on ' . date('Y-m-d H:i:s') . '</h2></body></html>');

Let's build this and start the containers:

    docker-compose up -d --build

Now when you visit http://0.0.0.0:8888, you should see something like:

    This page was genrated on 2022-03-25 12:40:03

How to make this a two-container solution
-----

First, I'd like to thank all the users who posted answers to [Alpine variants of PHP and Apache/httpd in Docker on Stack Overflow](https://stackoverflow.com/questions/41303775/alpine-variants-of-php-and-apache-httpd-in-docker/41306316#41306316), who pointed me in the right direction for this example. Most of the code is lifted directly from the article "Containerize This! How to use PHP, Apache, MySQL within Docker containers", linked in the Resources section at the end of this post.

Let's start by setting it up, and we'll look at how it works after.

First, we need to create a conf file for Apache, in ./php.apache.conf:

    ServerName localhost

    LoadModule deflate_module /usr/local/apache2/modules/mod_deflate.so
    LoadModule proxy_module /usr/local/apache2/modules/mod_proxy.so
    LoadModule proxy_fcgi_module /usr/local/apache2/modules/mod_proxy_fcgi.so

    <VirtualHost *:80>
        # Proxy .php requests to port 9000 of the php-fpm container
        ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://php:9000/var/www/html/$1
        DocumentRoot /var/www/html/
        <Directory /var/www/html/>
            DirectoryIndex index.php
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>

        # Send apache logs to stdout and stderr
        CustomLog /proc/self/fd/1 common
        ErrorLog /proc/self/fd/2
    </VirtualHost>

We now need to create our own image in Dockerfile, which uses the above conf file, in Dockerfile-httpd:

    FROM httpd:alpine

    COPY php.apache.conf /usr/local/apache2/conf/php.apache.conf
    RUN echo "Include /usr/local/apache2/conf/php.apache.conf" \
        >> /usr/local/apache2/conf/httpd.conf

Finally, let's rewrite our docker-compose.yml file:

    version: '3'

    services:
      php:
        image: php:fpm-alpine
        volumes:
          - ".:/var/www/html"

      server:
        build:
          context: .
          dockerfile: Dockerfile-httpd
        volumes:
          - ".:/var/www/html"
        ports:
          - "8888:80"

Let's test it:

    docker-compose up -d --build

Now when you visit, once again, http://0.0.0.0:8888, you should, again, see something like:

    This page was genrated on 2022-03-25 12:49:03

Whoah, whoah, whoah, what's going on here?
-----

Part of the magic here is using PHP-FPM. Because we're using FPM, the image broadcasts on TCP port 9000. You can confirm this by running:

    docker-compose ps

You will notice that, in the PORTS column:

    9000/tcp

This is how our Apache container will get the result from the PHP container even if PHP is not installed on the Apache container.

The second part of the magic happens in the php.apache.conf file, which directs Apache to fetch the result from an upstread server php at port 9000.

Finally, thanks to [cytopia](https://stackoverflow.com/a/40449377/1207752) for cluing me into the necessety for the source files to be accessible as a volume on both PHP and Apache.

What about Nginx?
-----

I tested [an answer by Rafael Quintela, edited by Potherca, to the StackOverflow question "How to correctly link php-fpm and Nginx Docker containers?"](https://stackoverflow.com/questions/29905953/how-to-correctly-link-php-fpm-and-nginx-docker-containers), which works perfectly. I won't reproduce it here, but I did make a few minor adjustments:

* I used the alpine tags because they're much smaller in size, which makes me happy;
* You don't need to expose port 9000 in docker-compose.yml, as user Seer pointed out in the comments.

The advantages of multiple containers
-----

A different container for each process is really the Docker way, and allows for easier maintenance.

In addition, it gives us more leeway in selecting which webserver we want: swapping out Apache for Nginx, for instance, is easier if it's completely separate from our PHP container.

Finally, it allows us to use Alpine images, hence reducing the compressed size of required resources:

Recall that our `php:apache-buster` image was 131.16 MB; `httpd:alpine` and `php:fpm-alpine`, taken together, are 42.94 MB for the `linux/arm64/v8` architecture, a 67% decrease in compressed size. If you're using Nginx instead of Apache, the size is even smaller, at a combined 36.72 MB, a 72% size decrease over our first example in this post.

Resources
-----

* [Containerize This! How to use PHP, Apache, MySQL within Docker containers, Cloudreach, 16 July 2018](https://www.cloudreach.com/en/technical-blog/containerize-this-how-to-use-php-apache-mysql-within-docker-containers/)
* [php docker link apache docker, StackOverflow](https://stackoverflow.com/questions/33230871/php-docker-link-apache-docker)
