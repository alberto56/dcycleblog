---
layout: post
title: Removing blocks such as the Powered By block in your deploy module
author: admin
id: 22
created: 1378326345
permalink: /blog/removing-blocks-such-powered-block-your-deploy-module/
redirect_from:
  - /blog/22/
  - /node/22/
---
On most sites you will want to remove the "Powered by Drupal" block and perhaps other blocks.

This example code shows how you can remove some blocks in your deployment module. Put the code either in your `hook_install()` or your `hook_update_n()`:

    $theme = 'mytheme';
    $block = array('navigation', 'powered-by');

    foreach ($blocks as $block) {
      $num_updated = db_update('block') // Table name no longer needs {}
        ->fields(array(
          'region' => '-1',
        ))
        ->condition('delta', $block, '=')
        ->condition('theme', $theme, '=')
        ->execute();
    }
