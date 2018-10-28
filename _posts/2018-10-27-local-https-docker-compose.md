---
layout: post
title:  "Local development using Docker Compose and HTTPS"
date:   2018-10-27
tags:
  - blog
  - planet
id: 2018-10-27
permalink: /blog/2018-10-27/local-https-docker-compose/
redirect_from:
  - /blog/2018-10-27/
---

This article discusses how to use HTTPS for local development if you use Docker and Docker Compose to develop Drupal 7 or Drupal 8 (indeed any other platform as well) projects. We're assuming you already have a technique to deploy your code to production (either a build step, rsync, etc.).

In this article we will use [the Drupal 8 site starterkit](https://github.com/dcycle/starterkit-drupal8site), a Docker Compose-based Drupal application that comes with everything you need to build a Drupal site with a few commands (including local HTTPS); we'll then discuss how HTTPS works.

If you want to follow along, install and launch the latest version of Docker, make sure ports 80 and 443 are not used locally, and run these commands:

    cd ~/Desktop
    git clone https://github.com/dcycle/starterkit-drupal8site.git
    cd starterkit-drupal8site
    ./scripts/https-deploy.sh

The script will prompt you for a domain (for example my-website.local) to access your local development environment. You might also be asked for your password if you want the script to add "127.0.0.1 my-website.local" to your /etc/hosts file. (If you do not want to supply your password, you can add that line to /etc/hosts before running ./scripts/https-deploy.sh).

After a few minutes you will be able to access a Drupal environment on http://my-website.local and https://my-website.local. For https, you will need to explicitly accept the certificate in the browser, because it's self-signed.

**Troubleshooting: if you get a connection error, try using an incongnito (private) window in your browser, or a different browser.**

Being a security-conscious developer, you probably read through  [`./scripts/https-deploy.sh`](https://github.com/dcycle/starterkit-drupal8site/blob/master/scripts/https-deploy.sh) before running it on your computer. If you haven't, you are encouraged to do so now, as we will be explaining how it works in this article.

You cannot use Let's Encrypt locally
-----

I often see questions related to setting up Let's Encrypt for local development. This is not possible because the idea behind Let's Encrypt is to certify that you own the domain on which you're working; because no one uniquely owns _localhost_, or _my-project.local_, no one can get a certificate for it.

For local development, the Let's Encrypt folks suggest using [trusted, self-signed certificates instead](https://letsencrypt.org/docs/certificates-for-localhost/), which is what we are doing in our script.

(If you are interested in setting up Let's Encrypt for a publicly-available domain, this article is not for you. You might be interested, instead, in [Letsencrypt HTTPS for Drupal on Docker](https://blog.dcycle.com/blog/170a6078/letsencrypt-drupal-docker/) and [Deploying Letsencrypt with Docker-Compose](http://blog.dcycle.com/blog/7f3ea9e1/letsencrypt-docker-compose/).)

Make sure your project works _without_ https first
-----

So let's look at how the [`./scripts/https-deploy.sh`](https://github.com/dcycle/starterkit-drupal8site/blob/master/scripts/https-deploy.sh) script we used above works.

Let's start by making sure our project works without https, then add a https access in a separate container.

In our starterkit project, you can run:

    ./scripts/deploy.sh

At the end of that scripts, you will see something like:

    If all went well you can now access your site at:

     => http://0.0.0.0:32780/user/reset/...

Docker is serving our application using a random non-secure port, in this case 32780, and mapping it to port 80 on our container.

If you use Docker Compose for local development, you might have several applications running at the same time on different host ports, all mapped to port 80 on their respective container. At the end of this article you should be able to see each of them on port 443, something like:

* https://my-application-one.local
* https://my-application-two.local
* https://my-application-three.local
* ...

The secret to all your local projects sharing port 443 is a reverse proxy container which receives requests to port 443, and indeed port 80 also, and acts as a sort of traffic cop to direct traffic the appropriate container.

That is why your individual projects should not directly use ports 80 and/or 443.

Adding an Nginx proxy container in front of your project's container
-----

An oft-seen approach to making your project available locally via HTTPS is to fiddle with [your Dockerfile](https://github.com/dcycle/starterkit-drupal8site/blob/master/Dockerfile), installing openssl, setting up the certificate there; and rebuilding your container. This can work, but I would argue that it has significant drawbacks:

* If you have several projects running on https port 443 locally, you could only develop one at a time because you only have one 443 port on your host machine.
* You would need to maintain the SSL portion of your code for each of your projects.
* It would go against the principle of [separation of concerns](https://devops.stackexchange.com/questions/447/why-it-is-recommended-to-run-only-one-process-in-a-container) which makes containers so robust.
* You would be reinventing the wheel: there's already a [well-maintained Nginx proxy image](https://github.com/jwilder/nginx-proxy) which does exactly what you want.
* Your job as a software developer is not to set up SSL.
* If you decide to deploy your project to production Kubernetes cluster, it would longer makes sense for each of your Apache containers to support SSL.

For all those reasons, we will loosely couple our project with the act of serving it via HTTPS; we'll leave our project alone and place an Nginx proxy in front of it to deal with the SSL/HTTPS portion of our local deployment.

Local https for one or more running projects
-----

In this example we set up only one starterkit application, but real-world developers often need HTTPS with more than one application. Because **you only have one local 443 port** for HTTPS, We need a way to differentiate between our running applications.

Our approach will be for each of our projects to have an assigned local domain. This is why the https script we used in our example asked you to choose a domain like `starterkit-drupal8.local`.

Our script stored this information in the `.env` file at the root or your project, and also made sure it resolves to localhost in your /etc/hosts file.

Launching the Nginx reverse proxy
-----

To me the terms "proxy" and "reverse proxy" are not intuitive. I'll try to demystify them here.

The term "proxy" means something which represents something else; that term is already widely used to denote a web client being hidden from the user. So, a server might deliver content to a proxy which then delivers it to the end user, thereby _hiding the end user from the server_.

In our case we want to do the reverse: the client (you) is not placing a proxy in front of it; rather the _application_ is placing a proxy in front of it, thereby _hiding the project server from the browser_: the browser communicates with Nginx, and Nginx communicates with your project.

Hence, "reverse proxy".

Our reverse proxy uses [a widely used and well-maintained GitHub project](https://github.com/jwilder/nginx-proxy). The script you used earlier in this article launched a container based on that image.

Linking the reverse proxy to our application
-----

With our starterkit application running on a random port (something like 32780) and our nginx proxy application running on ports 80 and 443, how are the two linked?

We now need to tell our Nginx proxy that when it receives a request for domain starterkit-drupal8.local, it should display our starterkit application.

There are a few steps to this, most handled by our script:

* Your project's `docker-compose.yml` file [should look something like this](https://github.com/dcycle/starterkit-drupal8site/blob/master/docker-compose.yml): it needs to contain the environment variable `VIRTUAL_HOST=${VIRTUAL_HOST}`. This takes the VIRTUAL_HOST environment variable that our script added to the `./.env` file, and makes it available inside the container.
* Our script assumes that your project contains a [`./scripts/deploy.sh`]((https://github.com/dcycle/starterkit-drupal8site/blob/master/scripts/deploy.sh)) file, which deploys our project to a random, non-secure port.
* Our script assumes that only the Nginx Proxy container is published on ports 80 and 443, so if these ports are already used by something else, you'll get an error.
* Our script appends `VIRTUAL_HOST=starterkit-drupal8.local` to the `./.env` file.
* Our script attempts to add `127.0.0.1 starterkit-drupal8.local` to our `/etc/hosts` file, which might require a password.
* Our script finds the network your project is running on locally (all Docker-compose projects run on their own local named network), and gives the reverse proxy accesss to it.

That's it!
-----

You should now be able to access your project locally with https://starterkit-drupal8.local (port 443) _and_ http://starterkit-drupal8.local (port 80), and apply this technique to any number of Docker Compose projects.

**Troubleshooting: if you get a connection error, try using an incongnito (private) window in your browser, or a different browser; also note that you need to explicitly trust the certificate.**

You can copy paste the script to your Docker Compose project at ./scripts/https-deploy.sh _if_:

* Your ./docker-compose.yml contains the environment variable `VIRTUAL_HOST=${VIRTUAL_HOST}`;
* You have a script, ./scripts/deploy.sh, which launches a non-secure version of your application on a random port.

Happy coding!
