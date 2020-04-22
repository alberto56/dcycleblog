---
layout: series
title: Accessing our applications from the outside world
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
prev: /kubernetes/08-drupal-helm
next: /kubernetes/10-configure-reverse-proxy
---

We don't want every one of applications (Drupal, but also eventually others) to manage how they are exposed to the outside world, but rather all be exposed using the same IP and automatic encrypted URLs using wildcard subdomains.

Following the principle of separation of concerns, we don't want to install LetsEncrypt, and manage domains and virtual hosts, for each application. Rather, we will put in place a **traffic cop** which will manage HTTPS encryption and, based on the requested domain and path, load up the application we want.

Kubernetes uses the term **ingress** to refer to a pathway from the outside world to the cluster. (If you did not understand this sentence, refer to the glossary!)

We will use Nginx to act as our traffic cop, also called **reverse proxy**, which means that it stands between the outside world and our applications. (A _proxy_ is something else entirely, it is the opposite of a _reverse proxy_.)

Installing a traffic cop
-----

Lucky for us, the Nginx ingress is just another helm chart. Let's call it "traffic-cop":

    helm upgrade --install traffic-cop stable/nginx-ingress

After a few seconds you'll see a bunch of output which we can ignore for now.

Now we can find out the public IP of the reverse proxy **service** (in Kubernetes, a **service** is basically a running application):

    kubectl get services | grep traffic-cop
    # traffic-cop-nginx-ingress-controller        LoadBalancer   10.245.137.97    <pending>         80:32524/TCP,443:30090/TCP   55s
    # traffic-cop-nginx-ingress-default-backend   ClusterIP      10.245.189.153   <none>            80/TCP                       55s

We're looking for the public IP of our service. In the above output, the public IP is still `<pending>`. After a minute or so the public IP should be assigned, so run kubectl again until you see it. For example:

    kubectl get services | grep traffic-cop
    # traffic-cop-nginx-ingress-controller        LoadBalancer   10.245.137.97    167.172.10.117     80:32524/TCP,443:30090/TCP   1m
    # traffic-cop-nginx-ingress-default-backend   ClusterIP      10.245.189.153   <none>            80/TCP                       1m

In the above example, the public IP is 167.172.10.117. In your case, this will differ, of course. Trying to visit that IP on a webserver will result in an empty page with content like "default backend - 404". This is because we haven't yet told the reverse proxy how to direct traffic to specific services:

    curl 167.172.10.117
    # default backend - 404

This $10-a-month LoadBalancer is now all we need for all our applications, rather than one-per-application using the previous method. Don't you just _love_ saving money?
