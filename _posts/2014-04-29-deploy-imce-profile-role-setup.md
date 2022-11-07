---
layout: post
title: Deploy IMCE profile-role setup
id: 59
created: 1398790633
tags:
  - snippet
permalink: /blog/59/deploy-imce-profile-role-setup/
redirect_from:
  - /blog/59/
  - /node/59/
---
By default [IMCE](https://drupal.org/project/imce) only allows user 1 to access it, leading to the User 1 trap: it all works on developers' machines, but as soon as a non-user-1 administrators to use IMCE, it doesn't show up.

Setting up IMCE correctly requires assigning an IMCE profile to administrators. The easiest way to do this, if you don't need fine-grained control over what your users do, is to assign the User 1 profile to all admins. However, IMCE is designed for this to be done in in the GUI. If you are using a [site deployment module](http://blog.dcycle.com/blog/44/what-site-deployment-module), however, you have to do this in a hook_update_n() so it can be deployed automatically to all your environments (dev, stage, prod, jenkins, your developers' computers...). Here is how:

    /**
     * Set correct role-profile setup in IMCE
     *
     * See http://blog.dcycle.com/blog/59
     */
    function mysite_deploy_update_7123() {
      variable_set('imce_roles_profiles', array(
        user_role_load_by_name('administrator')->rid =>
        array (
          'public_pid' => 1,
        ),
        user_role_load_by_name('authenticated user')->rid =>
        array (
          'public_pid' => 0,
        ),
        user_role_load_by_name('anonymous user')->rid =>
        array (
          'public_pid' => 0,
        ),
      ));
    }
