---
layout: post
title: settings.php setup when using multiple domains
id: 67
created: 1408377974
tags:
  - snippet
permalink: /blog/67/settingsphp-setup-when-using-multiple-domains/
redirect_from:
  - /blog/67/
  - /node/67/
---
When using multiple domains (one per language), I use [language_domains](https://www.drupal.org/project/language_domains), which requires that _each_ environment be setup as follows (for example):

    $base_url = 'http://fr.mysite.local';  // NO trailing slash!
    /**
     * See https://www.drupal.org/project/language_domains
     */
    $conf['language_domains']['en'] = 'en.mysite.local';
    $conf['language_domains']['fr'] = 'fr.mysite.local';

Normally, we deploy variables with a [site deployment module](http://dcycleproject.org/blog/44/what-site-deployment-module), but in this case the variables must have different values for each environment.
