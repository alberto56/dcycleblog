---
layout: post
title: 'Don''t perform logic in your hook_form_submit: use an API'
id: 27
created: 1384179257
tags:
  - blog
  - planet
permalink: /blog/27/dont-perform-logic-your-hookformsubmit-use-api/
redirect_from:
  - /blog/27/
  - /node/27/
---
Examples like these are rampant throughout Drupal 7, in [block_admin_display_form_submit()](https://api.drupal.org/api/drupal/modules%21block%21block.admin.inc/function/block_admin_display_form_submit/6), for example:

    /**
     * Form submission handler for block_admin_display_form().
     *
     * @see block_admin_display_form()
     */
    function block_admin_display_form_submit($form, &$form_state) {
      $transaction = db_transaction();
      try {
        foreach ($form_state['values']['blocks'] as $block) {
          $block['status'] = (int) ($block['region'] != BLOCK_REGION_NONE);
          $block['region'] = $block['status'] ? $block['region'] : '';
          db_update('block')
            ->fields(array(
              'status' => $block['status'],
              'weight' => $block['weight'],
              'region' => $block['region'],
            ))
            ->condition('module', $block['module'])
            ->condition('delta', $block['delta'])
            ->condition('theme', $block['theme'])
            ->execute();
        }
      }
      catch (Exception $e) {
        $transaction->rollback();
        watchdog_exception('block', $e);
        throw $e;
      }
      drupal_set_message(t('The block settings have been updated.'));
      cache_clear_all();
    }

What's wrong with this is that the _logic_ for performing the desired action (moving a block to a different region) is tied to the use of a form, in the GUI. Let's say you want a third-party module to move the navigation and powered-by block out of the theme xyz, one would expect there to exist, in the API, a function resembling `block_move($blocks, $region, $theme)`, but there is no such function.

On a recent project where I needed to do exactly that, I installed and enabled [devel](https://drupal.org/project/devel), and put `dpm($form); dpm($form_state);` at the top of the block_admin_display_form_submit() function then went through the actions in the GUI, _to figure out what Drupal is doing_, finally coming up with this code.

    foreach (array('navigation', 'powered-by') as $block) {
      $num_updated = db_update('block') // Table name no longer needs {}
        ->fields(array(
          'region' => '-1',
        ))
        ->condition('delta', $block, '=')
        ->condition('theme', 'xyz', '=')
        ->execute();
    }

That's [reverse engineering](http://en.wikipedia.org/wiki/Reverse_engineering), and it's time-consuming, error-prone, and developer-unfriendly.

Recently in one of my own modules I realized I had [made the same mistake](https://drupal.org/node/2100531).

The correct approach is to define an api (for example a function like `block_move()` in the above example, and call that API function from your form- and GUI-related functions like `block_admin_display_form_submit()`).

The result will be that developers will have as easy a time interacting with your module as human users. This will open the door to third-party interaction, adding value to your module.

Also, it will allow you to run more automated tests without actually loading pages, which is faster.
