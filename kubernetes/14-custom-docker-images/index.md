---
layout: series
title: Creating your own Docker images
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
prev: /kubernetes/13-secure-wildcard-subdomains
next: /kubernetes/15-jenkins
---

In order to be able to deploy your Drupal site to Kubernetes, you'll need a place to store your Docker images, called a Docker registry. You can use the free version of [Docker Hub](https://hub.docker.com), in case you want your images to be public; or the paid version of the Docker hub to store private images.

You can also create your own registry, which is outside the scope of this article. If you'd like to set up your own private registry, it's just another helm chart away: [stable/docker-registry](https://github.com/helm/charts/tree/master/stable/docker-registry). But for this article we'll go with the free public Docker Hub registry: create an account (which we'll call "example-account" in this article), and make sure you have your credentials handy.

You will also need to develop using Docker containers. Your technique can differ from mine, but the important thing is that your codebase contain a script which can create the packaged Docker images (for example one with Drupal and PHP and a webserver; another with a mariadb database).

For the purposes of this tutorial, we can use the [Dcycle Drupal Starterkit](https://github.com/dcycle/starterkit-drupalsite), designed exactly for this purpose. Feel free to fork that project if you'd like to follow along. Here is how it works:

    cd ~/Desktop
    git clone https://github.com/dcycle/starterkit-drupal8site.git
    cd ./starterkit-drupal8site
    ./scripts/deploy.sh

After a few minutes, you should be seeing something like:

    If all went well you can now access your site at:

     => Drupal: http://0.0.0.0:32783/user/reset/1/1587565168/FJWEqYnG2SvJVmWy6hbsaDDImgJbm6kIkwM85MDBx5w/login

Visit that URL (which will differ for you), and you should be seeing a local Drupal site, ready for use. If your codebase is not based off the Dcycle Drupal Starterkit, you will still need to have a one-click deployment method similar to ./scripts/deploy.sh.

Still, this is not (yet!) ready for deployment to Kubernetes, for the following reason: [your custom code is shared with your container using a volume](https://github.com/dcycle/starterkit-drupal8site/blob/406e03c22e9e10a77cc039adc87d032d8b9fb7ec/docker-compose.dev.yml#L16), which is great for development, but not for deployment to Kubernetes.

To make code deployable to Kubernetes, we will need to add our custom to our container, by running:

    ./scripts/destroy.sh
    ./scripts/deploy.sh build

The above command will print instructions for what to do next, something like:

    export DOCKERHUBUSER=xxxx
    export DOCKERHUBPASS=xxxx
    export DOCKERHUBREPONAME=example-account/my-project
    export DOCKERHUBREPOTAG=mybranchname
    ./scripts/docker-hub/push-build.sh"

At the end of this script, you will obtain a link to see your image on the Docker Hub. I used this technique to create [an image with the tag "demotag" on the Docker Hub](https://hub.docker.com/r/dcycle/drupal-starterkit/tags).

Because nothing in life is simple, later on we will need to consider the OS architecture of your image, which is determined by the Docker host computer used to build the image. For example, if you're building the image with mac OS on an M-series chip, the architecture can be something like linux/amd64. If you use an Intel chip, the architecture of your image can be linux/amd64.
