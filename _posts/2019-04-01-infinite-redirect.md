---
layout: post
title: Sometimes you really want an infinite redirect: how to create one with mod_rewrite
author: admin
id: 2019-04-01
date: 2019-04-01
tags:
  - snippet
permalink: /blog/2019-04-01/infinite-redirect-mod-rewrite/
redirect_from:
  - /blog/2019-04-01/
---

I recently ran into [this issue](https://stackoverflow.com/questions/52618632/drupal-8-how-to-prevent-drupal-httpclient-from-caching-invalid-results-such-as); to fix it I needed to simulate an infinite redirect. To do so edit the .htaccess file and, right after `RewriteEngine on`, put:

    RewriteRule ^(.*)$ /$1 [R=301,L]
