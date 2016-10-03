---
layout: post
title: Use admin menu instead of the toolbar
id: 41
created: 1384547253
tags:
  - snippet
permalink: /blog/41/use-admin-menu-instead-toolbar/
redirect_from:
  - /blog/41/
  - /node/41/
---
I do this on all projects I inherit: change the default toolbar to [admin_menu](https://drupal.org/project/admin_menu)'s admin_menu_toolbar. Add this code to your deployment module's .install file, change mymodule for your deployment module's name, and use a sequential update number:


    /**
     * Better menu
     */
    function mymodule_deploy_update_7004() {
      // make sure admin_menu has been downloaded and added to your git repo, or this will fail.
      module_enable(array('admin_menu_toolbar'));
      module_disable(array('toolbar'));
    }
