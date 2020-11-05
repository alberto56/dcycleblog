---
layout: post
title: Traccar fleet management software evaluation
author: admin
id: 2020-11-05
tags:
  - blog
permalink: /blog/2020-11-05/evaluating-traccar/
redirect_from:
  - /blog/2020-11-05/
  - /node/2020-11-05/
---
I found myself in need of managing a fleet of 4 vehicles with a plan to increase to over 20 vehicles in the coming years:

* track milage
* cross-reference fuel usage with milage
* I want my system to be open-source and self-hosted
* I want my system to have Android clients
* I want my system to be installable with a Docker image on a server

My fuel usage is tracked in an Google Sheets database.

Traccar
-----

[Traccar](http://traccar.org) seems to fit the bill on all of the above. It has a [Docker image](https://hub.docker.com/r/traccar/traccar) for easy server installation.

I started by creating a new server (virtual machine) with Docker preisntalled on DigitalOcean using their API.

I then logged onto my new machine and installed Traccar server as per the [Docker documentation](https://hub.docker.com/r/traccar/traccar):

    mkdir -p /var/docker/traccar/logs
    docker run \
      --rm \
      --entrypoint cat \
      traccar/traccar:latest \
      /opt/traccar/conf/traccar.xml > /var/docker/traccar/traccar.xml

I did not modify the xml file. I used the defaults for my evaluation. I then started my container:

    docker run \
      -d --restart always \
      --name traccar \
      --hostname traccar \
      -p 80:8082 \
      -p 5000-5150:5000-5150 \
      -p 5000-5150:5000-5150/udp \
      -v /var/docker/traccar/logs:/opt/traccar/logs:rw \
      -v /var/docker/traccar/traccar.xml:/opt/traccar/conf/traccar.xml:ro \
      traccar/traccar:latest

At this point I could visit port 80 on my server, log in using the default admin/admin, change my email and password, and view my fleet of zero vehciles.

Next up, I installed Traccar fleet management software on my Android phone: I went to the Google Play Store and installed the free Traccar client software.

I allowed the software to access the device's location (obviously), changed the server tracker URL to port 5055 of my server, and took note of the device's "identifier" which looks like 1234567. Then, on my Traccar dashboard, I added a device using the device's "Device identifier" and the name "test", and voilà! Next step is to test this with multiple devices.

<img src="/assets/img/2020-11-05-traccar-evaluation/traccar-dashboard.jpg" alt="Traccar dashboard with one user"/>
