---
layout: series
title: Accessing our Drupal site via Nginx and Letsencrypt
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
prev: /kubernetes/12-customize-helm-template
next: /kubernetes/14-custom-docker-images
---

We still do not have access to our Drupal site, though. Because we have set up wildcard subdomains to point to our server, above, we can decide on any subdomain to load our Drupal site.

Let's choose kube-drupal.example.com.

The ingress and appropriate certificates requires some YAML files for configuration, where we tell Kubernetes, say, that kube-drupal.example.com should load up our Drupal instance. However in our case, recall that one of our success criteria is branch staging environments, meaning that we'll need to update our YAML files on the fly depending on which branches are created and deleted in our codebase. So we can't hard-code them. Instead, we'll use YAML templates. Thankfully, we already know Helm, and YAML templates are exactly what Helm does.

Instead of walking you through the process, you can head back to your local copy of Dcycle Kube Helper you downloaded earlier. Now, copy the entire contents of ./unversioned-examples to ./unversioned and modify them with your own information: in addition to your email in the ./unversioned/email file, these files should be present:

    # unversioned/domains/kube-drupal.example.com
    SERVICE=my-first-vanilla-drupal
    PORT=80
    DOMAIN_PATH=/

Remove all other example files from ./unversioned/domains.

Unless you're feeling like a cowboy, keep the ./unversioned/other file and make sure it contains:

    STAGING=true

Once this is all done, run:

    ./scripts/apply.sh

This will set up your ingress and your Letsencrypt certificates.

Even after you see the "All done!" message, this takes a while to warm up; you can follow progress by running:

    kubectl describe certificate my-https-secret

In the "message" section, after a few minutes, it should say: "Certificate is up to date and has not expired".

You will be able to load your domains (say, kube-drupal.example.com) in a browser but **for now, the certificate will not be valid** because it will be "Fake LE root X1" (staging) type certificate.

This is good thing, it means your logic works!

Once you can access your site(s) with an invalid HTTPS "Fake LE root X1" certificate, remove the /unversioned/other file altogether, or remove the line "STAGING=true" from it, and rerun:

    source ./scripts/apply.sh

Again, you can follow the progress of this by running:

    kubectl describe certificate my-https-secret

and looking at the "message" section:

* If you see something like 'Waiting for CertificateRequest "my-https-secret-2383316903" to complete', run the above command again.
* Once you see "Certificate is up to date and has not expired", everything is ready!

Within a few minutes, you should now be able to access your site securely with valid HTTPS certificate!
