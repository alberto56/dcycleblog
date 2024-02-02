---
layout: post
title: Disabling Blocks
id: 32
created: 1382788207
tags:
  - snippet
permalink: /blog/32/disabling-blocks/
redirect_from:
  - /blog/32/
  - /node/32/
---
Dcycle considers two types of block positionings on a site:

 * End-user defined blocks, positioned with the blocks module.
 * Deployable block positionings, deployed through features and context.

To remove default blocks like the "Powered by Drupal", "Search" and "Navigation", put this code in your deployment module's update or install hook. If you need them to appear later, you can put them where you want with Context and Features.

    $mytheme = 'mytheme';
    foreach (array('user' => 'login', 'search' => 'form', 'system' => 'navigation') as $module => $delta) {
      $num_updated = db_update('block') // Table name no longer needs {}
        ->fields(array(
          'region' => '-1',
        ))
        ->condition('module', $module, '=')
        ->condition('delta', $delta, '=')
        ->condition('theme', $mytheme, '=')
        ->execute();
    }
