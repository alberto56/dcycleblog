---
layout: series
title: API, not GUI
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
prev: /kubernetes/02-create-cluster
next: /kubernetes/04-latest-yaml
---

Managing a Digital Ocean Kubernetes cluster requires downloading a YAML file, _which expires every week or so_.

Logging into the DigitalOcean GUI (graphical user interface) and fiddling with a graphical user interface to get a new copy of the YAML file once a week is not cool. To automate it, now is a good time to get into the habit of interacting with DigitalOcean using the API, not the GUI.

Let's start by getting your API key:

* Go to https://cloud.digitalocean.com/account/api/tokens;
* Create a new token called **mylocaldev** with read-only access (meaning you cannot use the key to modify the cluster's architecture; however you'll still be able to add Drupal instances to the architecture, and remove them);
* Your token will look something like `d630f25abcb3e56253ced4439321c07efb7f1e99241395189e04301f6adda621` (no, that's not my real token, thanks for asking). Write it down on a napkin because it won't be shown again.

Now figure out your cluster's UUID: go back to the Kubernetes section, find your cluster, which is probably still being created, and look at the URL related to it; it should look like: https://cloud.digitalocean.com/kubernetes/clusters/6130f72a-a8fd-4187-9a18-9fc3ee990894?i=07706e. In this example, the cluster's UUID is `6130f72a-a8fd-4187-9a18-9fc3ee990894` (the question mark and everything after it is not part of your cluster's UUID). Again, note it down somewhere.

Starting now we'll be running a lot of commands, so if you want you can use a GitHub project I set up for this called Dcycle Kube Helper at <https://github.com/dcycle/dcycle-kube-helper>. Every time we suggest a script, we will link to it on Dcycle Kube Helper page. Feel free to adapt it to your needs, or simply download the Dcycle Kube Helper scripts and run them locally (as in the examples).

If you would like to download dcycle-kube-helper, go ahead and do it now:

    cd ~/Desktop
    git clone https://github.com/dcycle/dcycle-kube-helper.git
    cd ~/Desktop/dcycle-kube-helper

[Let's start with this script](https://github.com/dcycle/dcycle-kube-helper/blob/master/scripts/set-digitalocean-token.sh) which will create a file `$HOME/.digitalocean/tutorial-token` to store your token on your computer. Obviously, with your own token and UUID, not the dummy ones from this article:

    export DOCLUSTERNAME=kubernetes-tutorial
    export DOTOKEN=d630f25abcb3e56253ced4439321c07efb7f1e99241395189e04301f6adda621
    export DOCLUSTERUUID=6130f72a-a8fd-4187-9a18-9fc3ee990894
    ./scripts/set-digitalocean-token.sh

Note that the above will store your token in plain text in your home folder. While this is OK for the tutorial, you might want to set more stringent policies if you're using tokens for clusters which contain more sensitive data. For example, the [pass](https://www.passwordstore.org) utilily combined with GPG encryption and full-disk encryption might be better suited to managing production environments, because statistically, someone in your organization will eventually forget their laptop at Dunkin' Donuts. If you manage your Kubernetes cluster from a CI environment such as Jenkins or CircleCI, use those products' secret management systems.

You can see what this file looks like by typing:

    cat "$HOME/.digitalocean/kubernetes-tutorial"

Let's make sure this works. Open up a new terminal window enter [this script](https://github.com/dcycle/dcycle-kube-helper/blob/master/scripts/check-digitalocean-token.sh):

    export DOCLUSTERNAME=kubernetes-tutorial
    ./scripts/check-digitalocean-token.sh

If you see "Unable to authenticate you", go through the previous section again and make sure you follow all the steps exactly.

If everything works, you should now see some JSON which describes your Kubernetes cluster (including its UUID), which should be provisioned (meaning ready for use) by now.

Notice that we called our file `$HOME/.digitalocean/tutorial-token` and then ran `export DOCLUSTERNAME=tutorial-token` before our call to the test script. This approach will make it easy to manage different token-UUID pairs for different projects.
