---
layout: post
title: Deploying language negociation settings
id: 60
created: 1399037721
tags:
  - snippet
permalink: /blog/60/deploying-language-negociation-settings/
redirect_from:
  - /blog/60/
  - /node/60/
---
If you need to deploy language negociation settings, you can add something like this to your [site deployment module](http://dcycleproject.org/blog/44).

    /**
     * Set URL language negociation
     */
    function mysite_deploy_update_7045() {
      // see https://drupal.org/comment/8476803#comment-8476803
      // see http://dcycleproject.org/blog/60
      $negotation = array(
        LOCALE_LANGUAGE_NEGOTIATION_URL => 1,
        LANGUAGE_NEGOTIATION_DEFAULT => 5,
      );
      // see https://drupal.org/node/1721410
      include_once DRUPAL_ROOT . '/includes/language.inc';
      language_negotiation_set(LANGUAGE_TYPE_INTERFACE, $negotation);
    }
