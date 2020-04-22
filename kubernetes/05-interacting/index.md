---
layout: series
title: Interacting with your Kubernetes cluster
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
prev: /kubernetes/04-latest-yaml
next: /kubernetes/06-helm
---

You manage your different clusters using the `kubectl` command line tool on your local computer.

All the credentials to manage your clusters are in the yaml files such as `$HOME/.kube/kubernetes-helper-kubernetes-tutorial.yml` which we downloaded earlier.

It is a good idea to store all your Kubernetes YAML files in your ~/.kube directory. Keep in mind that these files contain sensitive material so don't share them.

We still need to tell `kubectl` that this file exists. This is done using an environment variable. To make it always available when we use our command line, let's add it to `~/.bash_profile`. Edit that file and add the following line to it:

    export KUBECONFIG=~/.kube/config:~/.kube/kubernetes-helper-kubernetes-tutorial.yml
    export KUBECONFIGONDOCKER=/root/.kube/config:/root/.kube/kubernetes-helper-kubernetes-tutorial.yml

The KUBECONFIG environment variable will be used by our `kubectl`. The KUBECONFIGONDOCKER environment is identical, but assumes that our YAML files are in the .kube directory of the root user, which is the case if we run commands on Docker containers which require access to our YAML files. We'll see a concrete example later on with Helm.

In the future, if you have several Kubernetes clusters, each will have their own yaml file and the above line might look something like:

    # This is an example!
    export KUBECONFIG=~/.kube/config:~/.kube/my-cluster-one.yaml:~/.kube/some-other-cluster.yaml:~/.kube/a-third-cluster.yaml
    export KUBECONFIGONDOCKER=/root/.kube/config:/root/.kube/my-cluster-one.yaml:/root/.kube/some-other-cluster.yaml:/root/.kube/a-third-cluster.yaml

Every time you modify ~/.bash_profile, you need to _source_ it on your open terminal windows; it will be loaded automatically for new terminal windows. On your open terminal windows, you can see that this works by running:

    source ~/.bash_profile
    echo $KUBECONFIG

The output should be

    /Users/me/.kube/config:/Users/me/.kube/kubernetes-helper-kubernetes-tutorial.yml

(In new terminal windows, it is not necessary to run `source ~/.bash_profile`.)

Now, we can list all available clusters (which Kubernetes calls **contexts**) available to us:

    kubectl config get-contexts

You should see somethng like (but not exactly):

    CURRENT   NAME                          CLUSTER                       AUTHINFO                            NAMESPACE
              docker-for-desktop            docker-for-desktop-cluster    docker-for-desktop
              minikube                      minikube                      minikube
              do-nyc1-kubernetes-tutorial   do-nyc1-kubernetes-tutorial   do-nyc1-kubernetes-tutorial-admin

You might be seeing `docker-for-desktop`, `minikube`, as well our `kubernetes-tutorial` context, which is this case is prefixed with "do-nyc1" for "digital ocean New York datacenter".

Select the appropriate context, in my case this can be done by typing:

    kubectl config use-context do-nyc1-kubernetes-tutorial

Any `kubectl` commands we use henceforth should pertain to our cluster. Let's confirm this works by listing the nodes (or VMs) available on our cluster:

    kubectl get nodes
    # NAME              STATUS    ROLES     AGE       VERSION
    # pool-h80rmo94z-33lp0   Ready     <none>    2h        v1.16.6
    # pool-h80rmo94z-33lp1   Ready     <none>    2h        v1.16.6

> Note that if you get the message "error: You must be logged in to the server (Unauthorized)", you might need to re-download a fresh version of the config file from the dashboard; for that see "Downloading the latest version of your cluster YAML file", above.
