---
layout: post
title: Making sure no two features define the same permission
author: admin
id: 101
created: 1444402982
tags:
  - snippet
permalink: /blog/101/making-sure-no-two-features-define-same-permission/
redirect_from:
  - /blog/101/
  - /node/101/
---
When developing Drupal 7 sites, I am a fan of having one mega-feature per site. One of the problems that you can run across when there is more than one feature is that two features may define different roles, and each feature may give its role the same permission. If this is causing problems for you, you might want to add a test to your test suite which explicitly fails if more than feature defines the same permission. Here is a sample code:

    function _checkPermissionOverlap() {
      $defined_permissions = array();
      foreach (module_list(TRUE) as $module) {
        $infofile = drupal_parse_info_file(drupal_get_path('module', $module) . '/' . $module . '.info');
        if (isset($infofile['features']['user_permission'])) {
          foreach ($infofile['features']['user_permission'] as $permission) {
            if (isset($defined_permissions[$permission])) {
              $info = 'Two separate modules, ' . $defined_permissions[$permission] . ' and ' . $module . ', are attempting to set the permission ' . $permission;
            }
            else {
              $info = 'The permission ' . $permission . ' is being set by the module ' . $module . ' and has not yet been set by any other module.';
            }
            $this->assertFalse(isset($defined_permissions[$permission]), $info);
            $defined_permissions[$permission] = $module;
          }
        }
      }
    }

You might also want to use this version which makes sure the administrator user never left out of any permissions:

    /**
     * Asserts that no two features are trying to set the same permission.
     *
     * If feature A gives permission B et role C, and feature D gives permission B to
     * role E, the permission B will not be set to both roles C and E because
     * permission-role mappings are not cumulative.
     *
     * See http://dcycleproject.org/blog/101
     *
     * This function asserts that no two features are trying to set the same
     * permissions.
     */
    function _checkPermissionOverlap() {
      $defined_permissions = array();
      foreach (module_list(TRUE) as $module) {
        $infofile = drupal_parse_info_file(drupal_get_path('module', $module) . '/' . $module . '.info');
        if (isset($infofile['features']['user_permission'])) {
          foreach ($infofile['features']['user_permission'] as $permission) {
            if (isset($defined_permissions[$permission])) {
              $info = 'Two separate modules, ' . $defined_permissions[$permission] . ' and ' . $module . ', are attempting to set the permission ' . $permission;
            }
            else {
              $info = 'The permission ' . $permission . ' is being set by the module ' . $module . ' and has not yet been set by any other module.';
            }
            $this->assertFalse(isset($defined_permissions[$permission]), $info);
            $this->assertTrue(module_load_include('inc', $module, $module . '.features.user_permission.inc'));
            $function = $module . '_user_default_permissions';
            $this->assertTrue(function_exists($function), 'Function ' . $function . ' exists.');
            if (function_exists($function)) {
              // don't die if function does not exist
              foreach ($function() as $key => $perm) {
                $this->assertTrue(isset($perm['roles']['administrator']), 'No permission should exclude the administrator user, because it will unset existing perms: in ' . $function . ', ' . $key . ' includes the administrator user');
              };
            }
            $defined_permissions[$permission] = $module;
          }
        }
      }
    }

Please see the related issue https://www.drupal.org/node/656312 which explains why permissions are not cumulative.
