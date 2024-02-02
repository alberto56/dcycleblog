---
layout: post
title:  "Deploying Drupal to Kubernetes, no previous knowledge required"
date: 2020-04-22T14:27:32.381Z
updated: 2022-11-06T14:27:32.381Z
id: 2020-04-22
tags:
  - blog
  - planet
permalink: /kubernetes/
redirect_from:
  - /blog/2020-04-22/kubernetes/
  - /blog/2020-04-09/
---
Kubernetes is a way of deploying resilient, scalable applications to the cloud.

* **Resilient** because Kubernetes is designed to recover if something goes wrong.
* **Scalable** because with Kubernetes, your application is not linked to a single virtual machine (VM), but rather to a **cluster** of VMs which you can scale up or down transparently.

What Kubernetes is _not_ is a magic bullet. Before investing too much in Kubernetes, you are encouraged to read [“Let’s use Kubernetes!” Now you have 8 problems, by Itamar Turner-Trauring, Python Speed, March 4th, 2020](https://pythonspeed.com/articles/dont-need-kubernetes/).

In this article, we will create a Kubernetes cluster and deploy a minimum viable Drupal installation to it, with the following features (this list will be our success criteria at the end of this article):

* **Minimal vendor lock-in**: we will avoid vendor-specific resources such as database and volume storage where possible, prefering our own containers.
* **Deployment of Drupal alongside other applications**: we will deploy applications other than Drupal to demonstrate how your Drupal app can coexist nicely on a Kubernetes cluster.
* **Secret management**: Your Drupal application probably has _secrets_: environment-specific information such as API keys, or database passwords which should not be in the codebase. We will see how to manage these in Kubernetes.
* **LetsEncrypt**: We will serve our different cluster applications via HTTPS using an Nginx reverse proxy, with set-it-and-forget-it automatic certificate renewals.
* **Volumes**: Our Kubernetes applications will store their data in _volumes_ which can be backed up. In the case of Drupal, the MySQL database and the `/sites/default/files` directory will be on volumes. All application code will be on containers, as we will see later.
* **Automation of incremental deployments**: deployment should generally be as automated as possible; most modern applications see deployments to production several times daily. _In the context of this tutorial we are not recommending Kubernetes on production just yet, but rather to serve development environments; the performance and security concerns related to Kubernetes on production are outside the scope of this article, and frankly at the time of this writing I haven't yet used Kubernetes on production myself._
* **Easy local development**: although having a local version of Kubernetes is possible, it can make your laptop really, really hot. We will use Docker and docker-compose rather than Kubernetes to develop our code locally.
* **Branch staging environments**: we will spin up environments per GitHub branch and destroy the environments when the branch gets deleted.

Notice that I haven't gotten into the jargon of Kubernetes: nodes, pods, deployments, services; for me this has taken a while to get my head around, so my approach in this article will be to introduce concepts only as we need them. You can always refer to the **glossary** at the end of this article if you'd like quick definitions.

This tutorial is presented in several sections for your convenience:

* [Setup](/kubernetes/01-setup)
* [Creating a cluster](/kubernetes/02-create-cluster)
* [API, not GUI](/kubernetes/03-api-not-gui)
* [Getting the latest Kubernetes YAML file](/kubernetes/04-latest-yaml)
* [Interacting with Kubernetes](/kubernetes/05-interacting)
* [Introducing Helm](/kubernetes/06-helm)
* [Helm on Docker](/kubernetes/07-helm-on-docker)
* [Install Drupal via Helm](/kubernetes/08-drupal-helm)
* [Using a reverse-proxy ingress](/kubernetes/09-ingress)
* [Configuring the reverse proxy](/kubernetes/10-configure-reverse-proxy)
* [Letsencrypt](/kubernetes/11-letsencrypt)
* [Customizing the Helm template](/kubernetes/12-customize-helm-template)
* [Secure wildcard subdomains](/kubernetes/13-secure-wildcard-subdomains)
* [Custom Docker images](/kubernetes/14-custom-docker-images)
* [Jenkins](/kubernetes/15-jenkins)
* [Next Steps](/kubernetes/16-next-steps)
* [Glossary](/kubernetes/glossary)
* [Resources](/kubernetes/resources)
