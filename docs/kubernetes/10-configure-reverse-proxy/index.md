---
layout: series
title: Configuring the traffic cop
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
prev: /kubernetes/09-ingress
next: /kubernetes/11-letsencrypt
---

At this point you should set up a domain name to resolve to your public IP address using wildcard subdomains, meaning that this.example.com, and-this.example.com, and-effectively-anything.example.com all load the same IP (of course, use your own domain rather than example.com.).

If you are using Namecheap, for example, you can follow [these instructions](https://www.namecheap.com/support/knowledgebase/article.aspx/597/2237/how-can-i-set-up-a-catchall-wildcard-subdomain), however don't do a redirect, head straight to the advanced features. In all cases, you'll want to create an A record for your domain which points "*" (which means wildcard subdomains) to to the public IP of your Nginx ingress, so your entry will look like this (use your reverse proxy's external ip instead of 167.172.10.117):

| Record type   | Host    | Value              |
|---------------|---------|--------------------|
| A             | *       | 167.172.10.117     |

It will tell you that it can take up to 48 hours to propagate; in my experience it takes a few minutes:

    curl hello.example.com
    # default backend - 404
    curl world.example.com
    # default backend - 404

(We'll make sure they load up the correct applications later on in the article.)
