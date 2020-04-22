---
layout: series
title: Downloading the latest version of your cluster YAML file
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
prev: /kubernetes/03-api-not-gui
next: /kubernetes/05-interacting
---

Now, any time you want to get a local copy of the YAML file necessary to interact with your Kubernetes cluster (including now!), you can run [this script](https://github.com/dcycle/dcycle-kube-helper/blob/master/scripts/get-digitalocean-yaml-file.sh):

    export DOCLUSTERNAME=kubernetes-tutorial
    ./scripts/get-digitalocean-yaml-file.sh

All DigitalOcean Kubernetes clusters need a YAML file to interact when them, and we'll store these YAML files in the `$HOME/.kube` folder. Every week or so, these files will become outdated and no longer usable, you all you need to do is rerun the above commands which will overwrite the old YAML file and replace it with a fresh one.

If you want to see what the YAML file looks like, you can run:

    cat "$HOME/.kube/kubernetes-helper-kubernetes-tutorial.yml"

And, again, you can manage several Kubernetes clusters by naming their YAML files accordingly.

**You now have a Kubernetes cluster on Digital Ocean, and you're ready to interact with it. Let's use it!**
