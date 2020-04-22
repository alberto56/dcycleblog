---
layout: series
title: Installing vanilla Drupal with Helm
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
prev: /kubernetes/07-helm-on-docker
next: /kubernetes/09-ingress
---

Our initial setup is complete, time to install our first Drupal site on Kubernetes!

We will not actually create a fully-functional customized Drupal site, but rather use a community chart, just wake us up slightly.

**If you have decided to use [./scripts/helm.sh](https://github.com/dcycle/dcycle-kube-helper/blob/master/scripts/helm.sh) instead of creating an alias for helm in your .bash_profile, substitute "helm" for "./scripts/helm.sh" in the following examples and for the rest of this tutorial.**

    helm repo add bitnami https://charts.bitnami.com/bitnami
    # "stable" has been added to your repositories
    helm upgrade --install my-first-vanilla-drupal bitnami/drupal

If everything went well, this should result in something like:

    NOTES:
    *******************************************************************
    *** PLEASE BE PATIENT: Drupal may take a few minutes to install ***
    *******************************************************************

    1. Get the Drupal URL:

      You should be able to access your new Drupal installation through

      http://drupal.local/

    2. Login with the following credentials

      echo Username: user
      echo Password: $(kubectl get secret --namespace default my-first-vanilla-drupal -o jsonpath="{.data.drupal-password}" | base64 --decode)

You can now see Drupal in your list of Helm-deployed applications:

    helm list
    # NAME                   	NAMESPACE	REVISION	UPDATED                              	STATUS  	CHART       	APP VERSION
    # my-first-vanilla-drupal	default  	1       	2020-03-07 02:21:56.9271403 +0000 UTC	deployed	drupal-6.2.8	8.8.2

Let's take a look at our **services**:

    kubectl get services
    # NAME                     TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
    # kubernetes               ClusterIP      10.245.0.1      <none>        443/TCP                      35d
    # vanilla-drupal-drupal    LoadBalancer   10.245.210.73   <pending>     80:32232/TCP,443:30494/TCP   50s
    # vanilla-drupal-mariadb   ClusterIP      10.245.86.36    <none>        3306/TCP                     50s

**Services** define your application as an abstraction layer: underlying resources (storage, computing power) may die or change; your service will always be available. In the above example, we have created a database service, and a Drupal service (the Drupal codebase along with a webserver). The external IP of the LoadBalancer service is how we'll access Drupal. In the above example, the external IP is `<pending>`; rerun `kubectl get services` until you see an external IP for the LoadBalancer service. When I tried this I got `138.197.224.150`, so **after waiting five minutes for things to warm up**, when I used a browser to visit http://138.197.224.150, I saw an actual running Drupal site. Yay! If after fifteen minutes you're still not seeing a Drupal site, you might have a problem; if you see your Drupal site, let's move on!

First things first
-----

Let's not get too excited just yet. I just wanted to show you a Drupal site so you'd keep reading instead of falling asleep. However, our site is not set in a way that's optimal for our needs:

* It exposes itself to the outside world via a _LoadBalancer_ instead of _ClusterIP_. This is great if you want to quickly look at a site, but in our case we don't want to access our site directly; rather we'll use a reverse proxy to manage LetsEncrypt. Plus, each LoadBalancer is tied to our cloud provider DigitalOcean charges you $10 a month per LoadBalancer.
* It sets up two 8Gb persistent volumes to store data outside of Kubernetes, you can see these by typing `kubectl get pvc`. These are charged at $0.10 a month by Gb, for a total of $1.60 a month.

We'll prefer a more cost effective way to store data and to access our sites, but that entails a bit more work.

Let's, therefore, delete our first site before moving on:

    helm delete my-first-vanilla-drupal

You might have a volume (or, rather a PVC -- persistent volume claim -- see the glossary) lying around which was not deleted (and thus keeps incurring charges), you can delete it like this:

    kubectl get pvc
    # NAME
    # data-my-first-vanilla-drupal-mariadb-0
    # ...

    kubectl delete pvc data-my-first-vanilla-drupal-mariadb-0
    # persistentvolumeclaim "data-my-first-vanilla-drupal-mariadb-0" deleted
