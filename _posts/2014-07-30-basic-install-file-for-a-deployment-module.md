---
layout: post
title: Basic install file for a deployment module
id: 65
created: 1406728820
tags:
  - snippet
permalink: /blog/65/basic-install-file-deployment-module/
redirect_from:
  - /blog/65/
  - /node/65/
---
Here is a typical .install file for [site deployment modules](http://blog.dcycle.com/blog/44/what-site-deployment-module):

    /**
     * @file
     * Incremental and initial deployment code.
     */

    /**
     * Implements hook_install().
     * See http://blog.dcycle.com/blog/43/run-all-update-hooks-install-hook
     */
    function mysite_deploy_install() {
      for ($i = 7001; $i < 8000; $i++) {
        $candidate = 'mysite_deploy_update_' . $i;
        if (function_exists($candidate)) {
          $candidate();
        }
      }
    }

    /**
     * Disable Overlay
     */
    function mysite_deploy_update_7001() {
      // some people don't like overlay...
      module_disable(array('overlay'));
    }

    /**
     * Install & Enable Admin_Menu
     */
    function mysite_deploy_update_7002() {
      module_enable(array('admin_menu_toolbar'));
      module_disable(array('toolbar'));
    }
