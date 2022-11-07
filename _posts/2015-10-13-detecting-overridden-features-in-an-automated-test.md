---
layout: post
title: Detecting overridden features in an automated test
author: admin
id: 102
created: 1444766671
tags:
  - snippet
permalink: /blog/102/detecting-overridden-features-automated-test/
redirect_from:
  - /blog/102/
  - /node/102/
---
Sometimes features are overridden the moment you enable them. Here is an automated test to fail when features are overridden. You can include it in your [site deployment module](http://blog.dcycle.com/blog/44/what-site-deployment-module)'s automated test.

    /**
     * Information on Features override status. Can fail if some features are overridden.
     *
     * see http://blog.dcycle.com/blog/102
     *
     * @param $exceptions = array()
     *   Overrides we know of and which should not trigger a failure:
     *
     *     array(
     *       'my_feature_name' => array(
     *         'user_permission',
     *         ...
     *       ),
     *       'feature_2' => array(
     *         'variable',
     *       ),
     *     );
     *
     *  For the feature components defined in this array, tests will not fail if they
     *  are overridden. In this example, no feature is allowed to be overridden, _except_
     *  user_permissions in my_feature_name and variable in feature_2.
     */
    function _checkFeaturesStatus($exceptions = array()) {
      module_load_include('inc', 'features', 'features.export');
      module_load_include('inc', 'features', 'features.admin');
      $states = features_get_component_states();
      foreach ($states as $feature => $components) {
        foreach ($components as $component => $status) {
          $fail = FALSE;
          $message = 'The ' . $component . ' component of the feature ' . $feature . ' has the status ' . ($status ? 'OVERRIDDEN' : 'NOT OVERRIDDEN');
          if ($status) {
            if (!isset($exceptions[$feature]) || in_array($component, $exceptions[$feature])) {
              $message .= ' but this exception is allowed by the test';
            }
            else {
              $fail = TRUE;
              $this->assertFalse($fail, 'Please see verbose message to see the exact difference between the database and the code for the component ' . $component . ' of feature ' . $feature);
              $overrides = features_detect_overrides(features_load_feature($feature));
              $this->verbose('<pre>' . print_r($overrides[$component], TRUE) . '</pre>');
            }
          }
          $this->assertFalse($fail, $message);
        }
      }
    }
