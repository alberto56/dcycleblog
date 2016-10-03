---
layout: post
title: A Drupal 8 site deployment module
author: admin
id: 69
created: 1410375278
tags:
  - snippet
permalink: /blog/69/drupal-8-site-deployment-module/
redirect_from:
  - /blog/69/
  - /node/69/
---
Here is what you might have in a [site deployment module](http://dcycleproject.org/blog/44/what-site-deployment-module) for Drupal 8.

In `mysite_deploy.info.yml`:

    type: module
    name: 'mysite_deploy'
    core: '8.x'

In `mysite_deploy.module`:

    /**
     * @file
     * site deployment functions
     */
    use Drupal\Core\Extension\InfoParser;

    /**
     * Updates dependencies based on the site deployment's info file.
     *
     * If during the course of development, you add a dependency to your
     * site deployment module's .info file, increment the update hook
     * (see the .install module) and this function will be called, making
     * sure dependencies are enabled.
     */
    function mysite_deploy_update_dependencies() {
      $parser = new InfoParser;
      $info_file = $parser->parse(drupal_get_path('module', 'mysite_deploy') . '/mysite_deploy.info.yml');
      if (isset($info_file['dependencies'])) {
        \Drupal::moduleHandler()->install($info_file['dependencies'], TRUE);
      }
    }

    /**
     * Set the UUID of this website.
     *
     * By default, reinstalling a site will assign it a new random UUID, making
     * it impossible to sync configuration with other instances. This function
     * is called by site deployment module's .install hook.
     *
     * @param $uuid
     *   A uuid string, for example 'e732b460-add4-47a7-8c00-e4dedbb42900'.
     */
    function mysite_deploy_set_uuid($uuid) {
      \Drupal::config('system.site')
        ->set('uuid', $uuid)
        ->save();
    }    

An in  `mysite_deploy.install`:

    /**
     * @file
     * site deployment install functions
     */

    /**
     * Implements hook_install().
     */
    function mysite_deploy_install() {
      // This module is designed to be enabled on a brand new instance of
      // Drupal. Settings its uuid here will tell this instance that it is
      // in fact the same site as any other instance. Therefore, all local
      // instances, continuous integration, testing, dev, and production
      // instances of a codebase will have the same uuid, enabling us to
      // sync these instances via the config management system.
      // See also https://www.drupal.org/node/2133325
      mysite_deploy_set_uuid('e732b460-add4-47a7-8c00-e4dedbb42900');
      for ($i = 7001; $i < 8000; $i++) {
        $candidate = 'mysite_deploy_update_' . $i;
        if (function_exists($candidate)) {
          $candidate();
        }
      }
    }

    /**
     * Update dependencies and revert features
     */
    function mysite_deploy_update_7003() {
      // If you add a new dependency during your development:
      // (1) add your dependency to your .info file
      // (2) increment the number in this function name (example: change
      //     change 7003 to 7004)
      // (3) now, on each target environment, running drush updb -y
      //     will call the mysite_deploy_update_dependencies() function
      //     which in turn will enable all new dependencies.
      mysite_deploy_update_dependencies();
    }

The only real difference between a site deployment module for D7 and D8, thus, is that the D8 version must define a UUID common to all instances of a website (local, dev, prod, testing...).
