---
layout: post
title: Don't clone your database
id: 42
created: 1384782654
permalink: /blog/42/dont-clone-your-database/
redirect_from:
  - /blog/42/
  - /node/42/
---
One common model for Drupal development is maintaining development, staging and production environments, and managing code via git.

New features are moved _downstream_ from the development to the production environment using `hook_update_n()`s and config management (in Drupal 8) or Features (Drupal 7), combined with a written procedure to reproduce the desired behaviour on each environment.

In such a model, the production database is often cloned back _upstream_ to the development environment:

<img src="http://dcycleproject.org/sites/dcycleproject.org/files/environment_flow.png" style="width:100%"/>
