---
layout: post
title: Removing a field in code
id: 55
created: 1396875575
tags:
  - snippet
permalink: /blog/55/removing-field-code/
redirect_from:
  - /blog/55/
  - /node/55/
---
Here is a situation that happens once in a while:

 * A new content type is created, where you need a unique `nid` accross translations (for example, if you have an English and French version of an event, they both need to have nid 1 because other entities reference the entity itself (1) rather than a specific translation of the event).
 * Other content types (pages, for example) can be translated the traditional way (where you have different `nid`s for different languages).
 * To do this, [entity translation](https://drupal.org/project/entity_translation) can be used to make fields translatable, so you create a new `translatable-body` field just for events.

The above will result in there being two body fields for events, one translatable and one not. If you are using Features and a [site deployment module](http://blog.dcycle.com/blog/44/what-site-deployment-module) to deploy your site, you can use something like the following code in your site deployment module's [update hooks](https://api.drupal.org/api/drupal/modules%21system%21system.api.php/function/hook_update_N/7) to remove the superfluous body field instance in the event content type:

    /**
     * Remove extra body field from event
     */
    function mysite_deploy_update_7212() {
      // this might cause data loss, so it should be done before there
      // is content on production. Extra logic is needed if your have
      // data you need to move from one field instance to another.
      $entity_type = 'node';
      $field_name = 'body';
      $bundle_name = 'event';
      field_delete_instance(field_info_instance($entity_type, $field_name, $bundle_name));
      // before committing this update, make sure the event's body field
      // is removed on your dev environment and update your feature. The
      // following code will revert your feature on target sites, thus
      // ensuring that the field does not remain in your feature, where
      // it can be reintroduced later when other developers update the
      // feature
      features_revert(array('tremblant_feature' => array('node')));
      features_revert(array('tremblant_feature' => array('field_instance')));
    }
