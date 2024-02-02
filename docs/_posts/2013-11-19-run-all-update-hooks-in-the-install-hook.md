---
layout: post
title: Run all update hooks in the install hook
id: 43
created: 1384874736
tags:
  - snippet
permalink: /blog/43/run-all-update-hooks-install-hook/
redirect_from:
  - /blog/43/
  - /node/43/
---
I wouldn't recommend this for a contrib module, but for your deployment module, you'll probably want an initial deployment, which calls _only_ the install hook, to result in the site being in the same state as all the update hooks. Note that this can be time-consuming, so it's necessary to `drush en mysite_deploy` rather than the modules page in the GUI. Thus, when you run your simpletests, when you deploy a new common or local environment, you can be confident that your database resembles what you have on an environment which has existed for a longer period of time.

    function mysite_deploy_install() {
      for ($i = 7001; $i < 8000; $i++) {
        $candidate = 'mysite_deploy_update_' . $i;
        if (function_exists($candidate)) {
          $candidate();
        }
      }
    }



