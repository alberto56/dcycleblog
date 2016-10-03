---
layout: post
title: A quick intro to Docker for a Drupal project
author: admin
id: 91
created: 1424271955
tags:
  - blog
  - planet
permalink: /blog/91/quick-intro-docker-drupal-project/
redirect_from:
  - /blog/91/
  - /node/91/
---
I recently [added Docker support to Realistic Dummy Content](https://www.drupal.org/node/2428203), a project I maintain on Drupal.org. It is now possible (with Docker installed, preferably on a [CoreOS VM](https://coreos.com/docs/running-coreos/platforms/vagrant/)) to run `./scripts/dev.sh` directly from the project directory (use the latest dev version if you try this), and have a development environment, _sans_ MAMP.

I don't consider myself an expert in Docker, virtualization, DevOps and config management, but here, nonetheless, is my experience. If I'm wrong about something, please leave a comment!

Intro: Docker and DevOps
-----

The DevOps movement, popularized starting in about 2010, promises to include environment information along with application information in the same git repo for smoother development, testing, and production environments. For example, if your Drupal module requires version 5.4 of PHP, along with a given library, then that information should be somewhere in your Git repo. Building an environment for testing, development or production should then use that information and not be dependent on anything which is unversioned. Docker is a tool which is anchored in the DevOps movement.

DevOps: the Config management approach
-----

The family of tools which has been around for awhile now includes [Puppet](http://puppetlabs.com), [Chef](https://www.chef.io), and [Ansible](http://www.ansible.com/home). These tools are configuration management tools: they define environment information (PHP version should be 5.3, Apache mod_rewrite should be on, etc.) and make sure a given environment conforms to that information.

I have used Puppet, along with [Vagrant](https://www.vagrantup.com), to deliver applications, including my [Jenkins server hosted on GitHub](https://github.com/alberto56/vagrant-jenkins).

Virtualization and containers
-----

Using Puppet and Vagrant, you need to use Virtualization: create a Virtual Machine on your host machine.

Docker works with a different principle: instead of creating a VM on top of your host OS, Docker uses containers, so resources are shared. The article [Getting Started with Docker (Servers for Hackers, 2014/03/20)](https://serversforhackers.com/getting-started-with-docker/) contains some graphics which demonstrate how much more efficient containers are as opposed to virtualization.

Puppet and Vagrant are slow; Docker is fast
-----

Puppet and Vagrant together work for packaging software and environment configuration, but it is excruciatingly slow: it can take several minutes to launch an environment. My reaction to this has been to cringe every time I have to do it.

Docker, on the other hand, uses caching agressively: if a server was already in a given state, Docker uses a cached version of it to move along faster. So, when building a container, Docker goes through a series of steps, and caches each step to make it lightning fast.

One example: launching a dev environment of [the Jenkins Vagrant project](https://github.com/alberto56/vagrant-jenkins) on Mac OS takes over five minutes, but launching a dev environment of my Drupal project [Realistic Dummy Content](https://www.drupal.org/project/realistic_dummy_content) (which uses Docker), takes less than 15 seconds the first time it is run once the server code has been downloaded, _and, because of caching, less than one (1) second_ subsequent times if no changes have been made. *Less than one second to fire up a full-fledged development environment which is functionally independent from your host*. That's huge to me.

Configuration management is idempotent, Docker is not
-----

Before we move on, note that Docker is not incompatible with config management tools, but Docker does not require them. Here is why I think, in many cases, config management tools are not necessary.

The config management tools such as Puppet are _idempotent_: you define how an environment should be, and the tools run whatever steps are necessary to make it that way. This sounds like a good idea in theory, but it [looks like this](https://github.com/alberto56/vagrant-jenkins/blob/master/manifests/init.pp) in practice. I have come to the conclusion that this is not the way I think, and it forces me to relearn how to think of my environments. I suspect that many developers have a hard time wrapping their heads around idempotence.

Docker is not idempotent; it defines a series of steps to get to a given state. If you like idempotence, one of the steps can be to run a puppet manifest; but if, like me, you think idempotence is overrated, then you don't need to use it. [Here is what a Dockerfile looks like](https://github.com/b7alt/drupal/blob/master/Dockerfile): I understood it at first glace, it doesn't require me to learn a new way of thinking.

The CoreOS project
-----

The [CoreOS](https://coreos.com) project has seen the promise of Docker and containers. It is an OS which ships with Docker, Git, and a few other tools, but is designed so that everything you do happens within containers (using the included Docker, and eventually [Rocket](https://coreos.com/blog/rocket/), a tool they are building). The result is that CoreOS is tiny: it takes 10 seconds to build a CoreOS instance on [DigitalOcean](https://www.digitalocean.com), for example, but almost a minute to set up a CentOS instance.

Because Docker does not work on Mac OS [without going through hoops](https://docs.docker.com/installation/mac/), I decided to use [Vagrant to set up a CoreOS VM on my Mac](https://coreos.com/docs/running-coreos/platforms/vagrant/), which is speedy and works great.

Docker for deploying to production
-----

We have seen that Docker can work for quickly setting up dev and testing environments. Can it be used to deploy to production? I don't see why not, especially if used with CoreOS. For an example see the blog post [Building an Internal Cloud with Docker and CoreOS (Shopify, Oct. 15, 2014)](http://www.shopify.ca/technology/15563928-building-an-internal-cloud-with-docker-and-coreos).

In conclusion, I am just beginning to play with Docker, and it just feels right to me. I remember working with [Joomla](http://www.joomla.org) in 2006, when I discovered [Drupal](https://www.drupal.org), and _it just felt right_, and I have made a career of it since then. I am having the same feeling now discovering Docker and CoreOs.

I am looking forward to your comments explaining why I am wrong about not liking idempotence, how to make config management and virutalization faster, and how and why to integrate config management tools with Docker!
