---
layout: series
title: Setting up Jenkins
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
prev: /kubernetes/14-custom-docker-images
next: /kubernetes/16-next-steps
---

We'll set up a Jenkins continuous integration server on our cluster, to be responsible for being informed when a new push is made to a specific branch of our GitHub project via a webhook.

First, let's set up Jenkins using [this script](https://github.com/dcycle/dcycle-kube-helper/blob/master/scripts/install-jenkins.sh):

    ./scripts/install-jenkins.sh

Note that we're using the dcycle/jenkins-helm image because we want Jenkins to have helm installed on our our Jenkins image.

Follow the instructions in the "Get your 'admin' password" section to get your password. You can also use [this script](https://github.com/dcycle/dcycle-kube-helper/blob/master/scripts/get-jenkins-admin-password.sh):

    ./scripts/get-jenkins-admin-password.sh

We now need to add a URL to access jenkins (use your own domain instead of "example.com") using [this script](https://github.com/dcycle/dcycle-kube-helper/blob/master/scripts/install-jenkins-domain.sh):

    export DOMAIN=jenkins.example.com
    ./scripts/install-jenkins-domain.sh

In some cases this might give you a error or not give you the "All done!" message. If such is the case, run it repeatedly.

Once yousee the "All done!" message, repeatedly run:

    kubectl describe certificate my-https-secret

Until you see, in the "message" section, that all is well ("up to date and has not expired").

You can also repeatedy run:

    kubectl get pods

To see when Jenkins is ready (it should be "running" and have a status of "ready"). Once it is, you will now be able to visit https://jenkins.example.com in the browser and log in.

We still need a few things to happen for our Jenkins server to be ready for action:

First We need Jenkins to receive Webhooks from Github
-----

One of our success criteria in this tutorial is make sure when a new github branch gets created, a new environment gets created as well. How environments are created: we build a Docker image, store it on a registry. Then we use a helm chart to fetch that environment and build a temporary environment with a domain name corresponding to the branch name.

_When are environments created?_ And, for that matter, _When are environments deleted?_ We'll use the concept of **webhooks** for that a bit later on. Webhooks are a way of pushing information from one system to another. Later on, we'll tell GitHub that every time a branch is created, deleted or updated, it should make a request to a URL resembling https://jenkins.example.com/webhook/bla/bla/bla.

There is a Jenkins plugin for exactly this purpose, the [Jenkins Generic Webhook Trigger](https://plugins.jenkins.io/generic-webhook-trigger/) plugin.

Go ahead and install it by visiting /pluginManager/available on your Jenkins server.

When you set it up, a token will be provided, so that the Payload URL will look like https://jenkins.example.com/generic-webhook-trigger/invoke?token=DqUoqJERmkqDVs1pnoSJBeq6RJw. In your GitHub project, in Settings: Webhooks, you will be able to add a Webhook which calls this URL only when branches are created, updated or deleted.

Next, we need Jenkins to manage some secrets
-----

We will need Jenkins to know the following secrets:

* Our DigitalOcean API security Token.
* Our DigitalOcean Cluster UUID.
* Our Docker Hub username.
* Our Docker Hub password.

This information is all very sensitive, and for this Jenkins, like any other Continous Integration system, uses _secret management_ which Jenkins calls "credentials". Here is how it works:

* On Jenkins, go to the credentials page at /credentials/store/system/.
* Use "Global credentials" if you want your credentials to be accessible to all your jobs on your servers. You can also limit access to your credentials, which is outside the scope of this article.
* Once in the "Global credentials" page, you can add the credentials you need, then access them from any of your Jenkins jobs.
