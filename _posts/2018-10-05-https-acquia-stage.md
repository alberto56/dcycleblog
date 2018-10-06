---
layout: post
title:  "HTTPS on Acquia stage environments with LetsEncrypt, semi-automated"
date:   2018-10-05
tags:
  - blog
  - planet
id: 2018-10-05
permalink: /blog/2018-10-05/https-acquia-stage/
redirect_from:
  - /blog/2018-10-05/
---

I recently ran into a series of weird issues on my Acquia production environment which I traced back to some code I deployed which depended on my site being served securely using HTTPS.

Acquia Staging environments don't use HTTPS by default and require you to install SSL certificates using a tedious manual process, which in my opinion is outdated, because competitors such as [Platform.sh](https://docs.platform.sh/configuration/routes/https.html) and [Pantheon](https://pantheon.io/features/managed-https), [Aegir](https://www.drupal.org/project/hosting_https), even [Github pages](https://blog.github.com/2018-05-01-github-pages-custom-domains-https/) support lots of automation around HTTPS using Let's Encrypt.

Anyhow, because staging did not have HTTPS, I could not test some code I deployed, which ended up costing me an evening debugging an outage on a production environment. (Any difference between environments will _eventually_ result in an outage.)

I found a great blog post which explains how to set up Let's Encrypt on Acquia environments, [Installing (FREE) Let's Encrypt SSL Certificates on Acquia, by Chris at Redfin solutions, May 2, 2017](https://redfinsolutions.com/blog/installing-free-lets-encrypt-ssl-certificates-acquia). Although the process is very well documented, I made some tweaks:

* First, I prefer using Docker-based solutions rather than install softward on my computer. So, instead of install [certbot](https://certbot.eff.org) on my Mac, I opted to use the [Certbot Docker Image](https://hub.docker.com/r/certbot/certbot/), this has two advantages for me: first, I don't need to install certbot on every machine I use this script on; and second, I don't need to worry about updating certbot, as the Docker image is updated automatically. Of course, this does require that you install Docker on your machine. 
* Second, I automated everything I could. This result in [this gist](https://gist.github.com/alberto56/80c418c656bdf218cae663c3ba227e9a) (a "gist" a basically a single file hosted on Github), a script which you can install locally.

Running the script 
-----

When you put the script locally on your computer (I added it to my project code), at, say `./scripts/set-up-letsencrypt-acquia-stage.sh`, and run it:

* the first time you run it, it will tell you where to put your environment information (in ./acquia-stage-letsencrypt-environments/environment-my-acquia-project-one.source, ./acquia-stage-letsencrypt-environments/environment-my-acquia-project-two.source, etc.), and what to put in those files.
* the next time you run it, it will automate what it can and tell you exactly what you need to do manually.

I tried this and it works for creating new certs, and should work for renewals as well!
