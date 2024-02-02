---
layout: series
title: Introducing Helm
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
prev: /kubernetes/05-interacting
next: /kubernetes/07-helm-on-docker
---

I normally don't like using too many different software products that need installing,  maintaining, and understanding; they often complicate things. **Helm**, however, is different, and for me fills a real need for Kubernetes deployments in these major ways:

First, by abstracting away the complexities of a deployment: at first, Kubernetes overwhelmed me by requiring a half-dozen yaml files to deploy a single application. Each of these files represents a resource with its own Kubernetes-specific jargon. Updating these resources can be done independently; whereas the way I think of an application is as a whole. Enter [Helm](https://helm.sh), which can package all the resources necessary for an application within what Helm calls a **chart**.

Also, Helm allows developers to share application charts; you can use any the [charts supported by Helm](https://github.com/helm/charts/tree/master/stable) or create your own.
