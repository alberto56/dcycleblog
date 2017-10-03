---
layout: post
title: Letsencrypt HTTPS for Drupal on Docker
id: 170a6078
tags:
  - planet
  - blog
permalink: /blog/170a6078/letsencrypt-drupal-docker/
redirect_from:
  - /blog/170a6078/
  - /node/170a6078/
---
This article is about serving your Drupal Docker container, and/or any other container, via https with a valid [Let's encrypt](https://letsencrypt.org) SSL certificate.

Step one: make sure you have a public VM
-----

To follow along, create a new virtual machine (VM) with Docker, for example using the "Docker" distribution in the "One-click apps" section of Digital Ocean.

This will not work on localhost, because in order to use Let's Encrypt, you need to demonstrate ownership over your domain(s) to the outside world.

In this tutorial we will serve two different sites, one simple HTML site and one Drupal site, each on their own port, on the same Docker host, using a **reverse proxy**, a container which sits in front of your other containers and directs traffic.

Step two: Set up two domains or subdomains you own to point to your server
-----

Start by making sure you have two domains which point to your server, in this example we'll use:

 * test-one.example.com will be a simple HTML site.
 * test-two.example.com will be a Drupal site.

Step three: create your sites
-----

We do not want to map our containers' ports directly to our host ports using `-p 80:80 -p 443:443` because we will have more than one app using the same port (the secure 443). Port mapping will be the responsibility of the reverse proxy (more on that later). **Replace example.com with your own domain**:

    DOMAIN=example.com
    docker run -d \
      -e "VIRTUAL_HOST=test-one.$DOMAIN" \
      -e "LETSENCRYPT_HOST=test-one.$DOMAIN" \
      -e "LETSENCRYPT_EMAIL=my-email@$DOMAIN" \
      --expose 80 --name test-one \
      httpd
    docker run -d \
      -e "VIRTUAL_HOST=test-two.$DOMAIN" \
      -e "LETSENCRYPT_HOST=test-two.$DOMAIN" \
      -e "LETSENCRYPT_EMAIL=my-email@$DOMAIN" \
      --expose 80 --name test-two \
      drupal

Now you have two running sites, but they're not yet accessible to the outside world.

Step three: a reverse proxy and Let's encrypt
-----

The term "proxy" means something which represents something else. In our case we want to have a webserver container which represents our Drupal and html containers. The Drupal and html containers are effectively hidden in front of a proxy. Why "reverse"? The term "proxy" is already used and means that the web _user_ is hidden from the server. If it is the web servers that are hidden (in this case Drupal or the html containers), we use the term "reverse proxy".

[Let's encrypt](https://letsencrypt.org) is a free certificate authority which certifies that you are the owner of your domain.

We will use [nginx-proxy](https://github.com/jwilder/nginx-proxy) as our reverse proxy. Because that does not take care of certificates, we will use [LetsEncrypt companion container for nginx-proxy](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) to set up and maintain Let's Encrypt certificates.

Let's start by creating an empty directory which will contain our certificates:

    mkdir "$HOME"/certs

Now, following the instructions of the LetsEncrypt companion project, we can set up our reverse proxy:

    docker run -d -p 80:80 -p 443:443 \
      --name nginx-proxy \
      -v "$HOME"/certs:/etc/nginx/certs:ro \
      -v /etc/nginx/vhost.d \
      -v /usr/share/nginx/html \
      -v /var/run/docker.sock:/tmp/docker.sock:ro \
      --label com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy \
      jwilder/nginx-proxy

And, finally, start the LetEncrypt companion:

    docker run -d \
      --name nginx-letsencrypt \
      -v "$HOME"/certs:/etc/nginx/certs:rw \
      -v /var/run/docker.sock:/var/run/docker.sock:ro \
      --volumes-from nginx-proxy \
      jrcs/letsencrypt-nginx-proxy-companion

Wait a few minutes for `"$HOME"/certs` to be populated with your certificate files, and you should now be able to access your sites:

 * https://test-two.example.com/ should show the Drupal installer (setting up a MySQL container to actually install Drupal is outside the scope of this article);
 * https://test-one.example.com should show the "It works!" page.
 * In both cases, the certificate should be valid and you should get no error message.
 * http://test-one.example.com should redirect to https://test-one.example.com
 * http://test-two.example.com should redirect to https://test-two.example.com

A note about renewals
-----

Let's Encrypt certificates [last 3 months](https://letsencrypt.org/2015/11/09/why-90-days.html), so we generally want to renew every two months. [LetsEncrypt companion container for nginx-proxy](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) states that it automatically renews certificates which are set to expire in less than a month, and it checks this hourly, although there are some renewal-related issues in the [issue queue](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion/issues?utf8=✓&q=renewal).

It seems to also be possible to force renewals by running:

    docker exec nginx-letsencrypt /app/force_renew

So it might be worth considering to be on the lookout for failed renewals and force them if necessary.

Enjoy!
-----

You can now bask in the knowledge that your cooking blog will be man-in-the-middled.
