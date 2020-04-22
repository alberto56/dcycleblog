---
layout: series
title: Let's encrypt
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
prev: /kubernetes/10-configure-reverse-proxy
next: /kubernetes/12-customize-helm-template
---

Recall that one of our success criteria from the beginning of this article is set-it-and-forget-it Let's Encrypt HTTPS encryption for all our domains. The goal here is to automatically generate, and renew, encryption certificates, for our domains, with zero manual steps.

We will use the [cert-manager](https://hub.kubeapps.com/charts/stable/cert-manager) as in [this script](https://github.com/dcycle/dcycle-kube-helper/blob/master/scripts/install-cert-manager.sh)

    ./scripts/install-cert-manager.sh

(I get a "Failed to download OpenAPI" error but it seems to work nonetheless.)

Note that we have not yet generated certificates; we just installed the tools necessary to automate HTTPS access to our environments. We'll use these later on.
