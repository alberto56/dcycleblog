---
layout: series
title: Setup
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
next: /kubernetes/02-create-cluster
---

* Have the latest free version of **Docker Desktop** installed on your computer, this should include `docker-compose` (which we will use for local development) and `kubectl` (which we will use to interact with our Kubernetes cluster). If you're on mac OS, these are all included in Docker Desktop; for other operating systems, refer to the Docker documentation. Everything in this article has been tested on Docker Desktop for Mac in **October, 2022**; please leave a comment or use the "Edit this page" link at the bottom of any page if you find anything has changed by the time you read this.
* Have a credit card handy to create a Kubernetes cluster on [DigitalOcean](http://digitalocean.com), a cloud provider. If you only use the cluster for the tutorial and destroy it right after, it will probably cost less than a meat-free hamburger (and be as delicious).
* Have a domain name and access to your dashboard on your registrar; make sure your registrar supports wildcard subdomains for Let's Encrypt-secured staging environments per branch. The steps in this article have been tested on [NameCheap](https://www.namecheap.com), which supports wildcard subdomains.
* Set aside at least several hours, ideally a day, to get the most of this tutorial.

Try the following commands to make sure everything is set up:

    docker -v
    docker-compose -v
    kubectl version

The output should look something like this, although the version numbers may differ:

    $ docker -v
    Docker version 20.10.20, build 9fdeb9c
    $ docker-compose -v
    Docker Compose version v2.12.0
    $ kubectl version
    WARNING: This version information is deprecated and will be replaced with the output from kubectl version --short.  Use --output=yaml|json to get the full version.
    Client Version: version.Info{Major:"1", Minor:"25", GitVersion:"v1.25.3", GitCommit:"434bfd82814af038ad94d62ebe59b133fcb50506", GitTreeState:"clean", BuildDate:"2022-10-12T10:47:25Z", GoVersion:"go1.19.2", Compiler:"gc", Platform:"darwin/arm64"}
    Kustomize Version: v4.5.7
    Server Version: version.Info{Major:"1", Minor:"24", GitVersion:"v1.24.4", GitCommit:"95ee5ab382d64cfe6c28967f36b53970b8374491", GitTreeState:"clean", BuildDate:"2022-08-17T18:47:37Z", GoVersion:"go1.18.5", Compiler:"gc", Platform:"linux/amd64"}

You can ignore errors (if any) related to the kubectl for now, as long as you see version info. If any of these commands are "not found", make sure you install them before moving on.

Previous knowledge
-----

OK, I know I said "no previous knowledge". I was bending the truth there a bit: you should be comfortable using the command line and logging into servers via ssh. We will not assume any other knowledge... for now.
