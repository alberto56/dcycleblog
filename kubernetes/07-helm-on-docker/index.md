---
layout: series
title: Do not install Helm, use it within a Docker container
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
prev: /kubernetes/06-helm
next: /kubernetes/08-drupal-helm
---

I am not a fan of installing software for the following reasons:

* Once you have software on your computer, you need to have a software update policy;
* The more software you have on your computer, the harder it is to reproduce behaviour from one machine to another;
* If you install software for each tutorial you read, you end up with a bunch of dead software on your computer, taking up resources and space.

For these reasons, I prefer using the Docker approach and running everything I need within a _Docker container_. Let's run Helm without installing it:

    docker run -e KUBECONFIG="$KUBECONFIGONDOCKER" -ti --rm -v $(pwd):/apps -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm -v ~/.config/helm:/root/.config/helm -v ~/.cache/helm:/root/.cache/helm alpine/helm

Remember, earlier, when we set the KUBECONFIGONDOCKER environment variable in our .bash_profile file? Now we can see it in use: because we're sharing ~/.kube on our local machine with /root/.kube on our helm container, KUBECONFIG would not work on the container. Hence, KUBECONFIGONDOCKER.

You should see some output from the Helm tool, as if you had installed helm locally and typed `helm`.

(In this case we are running helm within a local Docker container based on its [community-supported image](https://hub.docker.com/r/alpine/helm). We are sharing our required local directories with the container, and making sure the container has access to the same `KUBECONFIG` environment variable as we have locally.)

To avoid typing this in every time we need helm, we can add the following **alias** to ~/.bash_profile:

    alias helm='docker run -e KUBECONFIG="$KUBECONFIGONDOCKER" -ti --rm -v $(pwd):/apps -v ~/.kube:/root/.kube -v ~/.config/helm:/root/.config/helm -v ~/.cache/helm:/root/.cache/helm -v ~/.helm:/root/.helm alpine/helm'
    source ~/.bash_profile
    helm version
    # version.BuildInfo{Version:"v3.1.1", GitCommit:"afe70585407b420d0097d07b21c47dc511525ac8", GitTreeState:"clean", GoVersion:"go1.13.8"}

Your version may differ, but make sure it's 3 or above.
