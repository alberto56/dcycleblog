---
layout: series
title: Glossary
top: /kubernetes
toptitle: Deploying Drupal to Kubernetes
---

* **Application**: A running application on your Kubernetes cluster, such as Drupal or Jenkins.
* **Chart**: Seel "Helm chart".
* **Context**: A Kubernetes cluster with which we are currently interacting.
* **Cluster**: A pool of Kubernetes resources such as volumes and nodes.
* **ClusterIP**: A visibility method for a service whereby only other services within the cluster can see it. This is useful if all traffic from the outside passes through a reverse proxy, for example.
* **Container**: a relatively isolated environment which acts like a virtual machine.
* **Docker**: allows the easy management of containers.
* **Docker-compose**: tie in containers, networks, and volumes into a running application.
* **Docker Desktop**: a packaged installation of Docker, Docker Compose, and kubectl for your laptop.
* **Helm**: an abstraction layer between you and Kubernetes, also often described as a package manager for Kubernetes.
* **Helm chart**: code which defines how to deploy a specific application via Helm.
* **Helm repo**: A collection of Helm charts.
* **Ingress**: A way for the outside world to access a Kubernetes cluster.
* **Image**: A template for docker containers.
* **Kubectl**: command-line tool to manage Kubernetes clusters.
* **Kubernetes**: abstraction layer between your application and your infrastructure.
* **Load balancer**: a type of ingress.
* **Node**: in the context of Kubernetes, a virtual machine which provides computing power; you do not normally interact directly with it.
* **Payload URL**: a public URL, often containing a security token, called by a webhook.
* **Persistent volume claim (PVC)**: a claim from an application on volume storage.
* **Pod**: an abstraction layer between any number of containers (in our tutorial we always use a single one) and the user of the containers. For example, if you need immense computing power and redundancy, you might have a dozen identical containers, but you still interact with a single pod, the same way you would if you were interacting with a single container.
* **Registry**: storage for Docker images.
* **Release**: is an instance of a chart running in a Kubernetes cluster.
* **Reverse proxy**: a layer between a running application or group of applications (for example Kubernetes) and a user. The user interacts with the reverse proxy, which then interacts with the underlying application.
* **Service**: an abstraction of a container or list of containers.
* **Tiller**: a server component of Helm which was [removed as a dependency in version 3](https://helm.sh/docs/faq/#removal-of-tiller).
* **Webhook**: An url which is called by an application (for example GitHub) when something happens (for example a new branch is created).
* **Wildcard subdomains**: manage any number of domains such as a.example.com, b.example.com, c.example.com, without having to reconfigure them each time.
* **YAML**: standard formatting of structured information in a text file.
