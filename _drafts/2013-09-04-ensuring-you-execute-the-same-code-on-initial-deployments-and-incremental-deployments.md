---
layout: post
title: Ensuring you execute the same code on initial deployments and incremental deployments.
author: admin
id: 23
created: 1378326762
permalink: /blog/ensuring-you-execute-same-code-initial-deployments-and-incremental-deployments/
redirect_from:
  - /blog/23/
  - /node/23/
---

Dcycle requires that your environments be in the same state (except for content), whether you are performing an initial deployment, or whether you are incrementally deploying using update hooks. The following approach can make sure that your update hooks are all called in your install hook, making sure you don't forget anything.

    function mynamespace_deploy_install() {
      for ($i = 7001; $i < 8000; $i++) {
        $candidate = dcycle_deploy_update_ . $i;
        if (function_exists($candidate)) {
          $candidate();
        }
      }
    }

    function mynamespace_deploy_update_7001() {
      // enable modules and revert features, and
      // do other stuff to set the database up to date.
    }

    function mynamespace_deploy_update_7013() {
      // enable modules and revert features, and
      // do other stuff to set the database up to date.
    }
