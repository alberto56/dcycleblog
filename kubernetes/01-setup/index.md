---
layout: series
title: Setup
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
next: /kubernetes/02-create-cluster
---

* Have the latest free version of **Docker Desktop** installed on your computer, this should include `docker-compose` (which we will use for local development) and `kubectl` (which we will use to interact with our Kubernetes cluster). If you're on mac OS, these are all included in Docker Desktop; for other operating systems, refer to the Docker documentation. Everything in this article has been tested on Docker Desktop for Mac in April, 2020; please leave a comment if you find anything has changed significantly by the time you read this.
* Have a credit card handy to create a Kubernetes cluster on [DigitalOcean](http://digitalocean.com), a cloud provider. If you only use the cluster for the tutorial and destroy it right after, it will probably cost less than a meat-free hamburger (and be as delicious).
* Have a domain name and access to your dashboard on your registrar; make sure your registrar supports wildcard subdomains for Let's Encrypt-secured staging environments per branch. The steps in this article have been tested on [NameCheap](https://www.namecheap.com), which supports wildcard subdomains.
* Set aside at least several hours, ideally a day, to get the most of this tutorial.

Try the following commands to make sure everything is set up:

    docker -v
    docker-compose -v
    kubectl version

The output should look something like this, although the version numbers may differ:

    $ docker -v
    Docker version 19.03.5, build 633a0ea
    $ docker-compose -v
    docker-compose version 1.25.4, build 8d51620a
    $ kubectl version
    Client Version: version.Info{Major:"1", Minor:"8", GitVersion:"v1.8.3", GitCommit:"f0efb3cb883751c5ffdbe6d515f3cb4fbe7b7acd", GitTreeState:"clean", BuildDate:"2017-11-08T18:39:33Z", GoVersion:"go1.8.3", Compiler:"gc", Platform:"darwin/amd64"}

You can ignore errors (if any) related to the kubectl for now, as long as you see version info. If any of these commands are "not found", make sure you install them before moving on.

Previous knowledge
-----

OK, I know I said "no previous knowledge". I was bending the truth there a bit: you should be comfortable using the command line and logging into servers via ssh. We will not assume any other knowledge... for now.
