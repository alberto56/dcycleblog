---
layout: post
title: Avoid reverting features just enabled
id: 62
created: 1400612025
tags:
  - snippet
permalink: /blog/62/avoid-reverting-features-just-enabled/
redirect_from:
  - /blog/62/
  - /node/62/
---
During deployment, in your hook_install, if you are cycling through all your hook_update_n(), and there can be hundreds, you don't want to call features_revert(). You can define a class to keep track of modules which were just enabled, and for those modules, don't call features_revert.

    /**
     * Speeds up deployment by not feature reverting features just enabled.
     */
    class MySiteDeploy {
      static $initial_deploy;
      static function setInitialDeploy() {
        self::$initial_deploy = TRUE;
      }
      static function features_revert($info) {
        if (!self::$initial_deploy) {
          features_revert($info);
        }
      }
    }

Now your hook install can look like:

    /**
     * Implements hook_install().
     */
    function mysite_deploy_install() {
      MySiteDeploy::setInitialDeploy();
      for ($i = 7001; $i < 8000; $i++) {
        $candidate = 'mysite_deploy_update_' . $i;
        if (function_exists($candidate)) {
          $candidate();
        }
      }
    }

And your update hooks can look like:

    /**
     * Metatag node.
     */
    function mysite_deploy_update_7368() {
      // only called during incremental deployment, for faster initial deployments.
      MySiteDeploy::features_revert(array('mysite_feature' => array('views_view')));
    }
