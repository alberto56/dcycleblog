---
layout: post
title: Updating dependencies with a function
author: admin
id: 70
created: 1410557236
tags:
  - snippet
permalink: /blog/70/updating-dependencies-function/
redirect_from:
  - /blog/70/
  - /node/70/
---
I used to add `module_enable(array('whatever'))` in an update hook every time I'd want add a dependency. The problem is every call to module_enable() is very, very long.

Now, I add this function to my site deployment module and call it from an update hook. Every time something changes, I just change the number in my hook name.

    /**
     * Update dependencies and disable unwanted modules.
     *
     * Prepend with an underscore (_) to avoid confusion with hook_update_dependencies().
     *
     * See http://blog.dcycle.com/blog/70/updating-dependencies-function
     */
    function _mysite_deploy_update_dependencies() {
      $info_file = drupal_parse_info_file(drupal_get_path('module', 'mysite_deploy') . '/mysite_deploy.info');
      if (isset($info_file['dependencies'])) {
        module_enable($info_file['dependencies']);
      }
      if (isset($info_file['to_disable'])) {
        module_disable($info_file['to_disable']);
        drupal_uninstall_modules($info_file['to_disable']);
      }
    }

My [site deployment module](http://blog.dcycle.com/blog/44/what-site-deployment-module)'s install file might contain something like:

    mysite_deploy_update_7123() {
      _mysite_deploy_update_dependencies();
      features_revert();
    }

When I change something in a feature, or add/remove dependencies, I just change 7123 to 7124, like this:

    mysite_deploy_update_7124() {
      _mysite_deploy_update_dependencies();
      features_revert();
    }

Now, all environments can just use `drush updb -y` to update features and dependencies.
