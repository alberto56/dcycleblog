---
layout: post
title: Flushing your image style
id: 47
created: 1387303332
tags:
  - snippet
permalink: /blog/47/flushing-your-image-style/
redirect_from:
  - /blog/47/
  - /node/47/
---
Once in a while you will change your image styles, and deploy them, but even after clearing caches they won't change. In your [site deployment module](http://dcycleproject.org/node/44)'s `hook_update_N()`, you can add something like:

    image_style_flush(image_style_load('myimagestyle'));
