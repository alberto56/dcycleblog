---
layout: series
title: Next Steps
top: /kubernetes
toptitle: Next steps
prev: /kubernetes/15-jenkns
---

We're nearing the end of our exciting journey with Kubernetes... for now. Let's see how we did with the success criteria we set up [at the onset of this tutorial](/kubernetes):

* **Minimal vendor lock-in**. Check. Although certain of our custom scripts are DigitalOcean-specific, our underlying application structure uses standard Docker and Kubernetes, not vendor-specific solutions.
* **Deployment of Drupal alongside other applications**. Check. We have deployed Drupal alongside Jenkins.
* **Secret management**. Meh. Although we are storing secrets such as the Jenkins password, we did not yet delve into how this works or how to add your own.
* **LetsEncrypt**. Check. All our sites are accesible using wildcard subdomains and Let's Encrypt-backed "set-it-and-forget-it" https.
* **Volumes**. Meh. Although we are using volumes for our Drupal sites and our Jenkins setup (type `kubectl get pvc` to see your volumes), we have not yet fully explored how these work or how they tie into the structure of our Kubernetes cluster.
* **Automation of incremental deployments**. Nope. We have not yet touched this at all. That will be for next time.
* **Easy local development**. Check. Although we haven't looked at it directly, I would recommend you play around with the [Dcycle Drupal Starterkit](https://github.com/dcycle/starterkit-drupalsite/issues), which we easily deployed, and which we used as a basis for our application's Docker image.
* **Branch staging environments**: Meh. Although all the pieces of the puzzle are in place, we still haven't managed to get to a point where a new or updated GitHub branches triggers a new environment; and a deleted branch triggers an environment to be deleted.

Next steps
-----

In the next installment of this series, which will be released _when it's ready_, we will delve more into:

* Secrets management on the cluster.
* Volumes and how they work.
* Automation of incremental deployments.
* Branch staging environments.

Until then, I hope your confinement is allowing you some time play around with Kubernetes!
