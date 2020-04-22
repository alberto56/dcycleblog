---
layout: series
title: Create a Kubernetes cluster
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
prev: /kubernetes/01-setup
next: /kubernetes/03-api-not-gui
---

Let's use [DigitalOcean](https://www.digitalocean.com) to create our Kubernetes cluster in the cloud. Create an account and fill in your billing information, then log into the dashboard.

Once on the dashboard:

* Click the "Manage" > "Kubernetes" tab, then "Create a Kubernetes cluster".
* Select a region, and, in Cluster Capacity use two (2) nodes instead of the default 3 (leave other default values intact). Kubernetes Nodes are Virtual Machines (VMs) that make up the cluster. Your application does not interact directly with these nodes; they exist to provide the amount of computing power we need, and the abstraction layer we crave.
* Choose the name "kubernetes-tutorial" and click "Create cluster".

This takes a few minutes, but do not rest quite yet, we have other tasks to complete while the cluster is being set up. Read on!
