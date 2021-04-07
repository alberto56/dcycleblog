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

Edit: if you're having trouble with Docker-Compose, read [this follow-up post](http://blog.dcycle.com/blog/7f3ea9e1/letsencrypt-docker-compose/).

Step one: make sure you have a public VM
-----

To follow along, create a new virtual machine (VM) with Docker, for example using the "Docker" distribution in the "One-click apps" section of Digital Ocean.

This will not work on localhost, because in order to use Let's Encrypt, you need to demonstrate ownership over your domain(s) to the outside world.

In this tutorial we will serve two different sites, one simple HTML site and one Drupal site, each using standard ports, on the same Docker host, using a **reverse proxy**, a container which sits in front of your other containers and directs traffic.

Step two: Set up two domains or subdomains you own and point them to your server
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
      --restart=always \
      jwilder/nginx-proxy

And, finally, start the LetEncrypt companion:

    docker run -d \
      --name nginx-letsencrypt \
      -v "$HOME"/certs:/etc/nginx/certs:rw \
      -v /var/run/docker.sock:/var/run/docker.sock:ro \
      --volumes-from nginx-proxy \
      --restart=always \
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

Edit: domain-specific configurations
-----

I used this technique to create a Docker registry, and make it accessible securely:

    docker run \
      --entrypoint htpasswd \
      registry:2 -Bbn username password > auth/htpasswd

    docker run -d --expose 5000 \
      -e "VIRTUAL_HOST=mydomain.example.com" \
      -e "LETSENCRYPT_HOST=mydomain.example.com" \
      -e "LETSENCRYPT_EMAIL=me@example.com" \
      -e "REGISTRY_AUTH=htpasswd" \
      -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
      -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \ 
      --restart=always -v "$PWD"/auth:/auth \
      --name registry registry:2

But when trying to push an image, I was getting "413 Request Entity Too Large". This is an error with the nginx-proxy, not the Docker registry. To fix this, you can set domain-specific configurations, in this example we are allowing a maximum of 600M to be passed but only to the Docker registry at mydomain.example.com:

    docker exec nginx-proxy /bin/bash -c 'cp /etc/nginx/vhost.d/default /etc/nginx/vhost.d/mydomain.example.com'
    docker exec nginx-proxy /bin/bash -c 'echo "client_max_body_size 600M;" >> /etc/nginx/vhost.d/mydomain.example.com'
    docker restart nginx-proxy

Edit: Reverse proxy on Drupal 8 or 9
-----

Thanks to @wells on [this issue](https://www.drupal.org/project/social_auth_google/issues/3207114) and nitin.k on [this issue](https://www.drupal.org/project/metatag/issues/2842049#comment-13948744) for pointing me in the right direction on how Drupal can know its base url should be HTTPS. In order to use modules such as social_auth_google and metatag which require Drupal to know its public URL even if it is behind a reverse proxy, you need to figure out the reverse proxy IP. 

To do so temporarily install devel_php on your site, and then go to /devel/php and enter `dpm($_SERVER['REMOTE_ADDR']);`. This will give you a result such as 172.18.0.5. It is _not_ the same IP as what you get when you ping your URL, or when you inspect the headers the reverse proxy sends to Drupal.

Then add this to your settings, and clear your cache:

    $settings['reverse_proxy'] = TRUE;
    $settings['reverse_proxy_addresses'] = ['172.18.0.5'];

Enjoy!
-----

You can now bask in the knowledge that your cooking blog will not be man-in-the-middled.
