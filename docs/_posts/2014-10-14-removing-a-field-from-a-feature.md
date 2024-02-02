---
layout: post
title: Removing a field from a feature
author: admin
id: 75
created: 1413318263
tags:
  - snippet
permalink: /blog/75/removing-field-feature/
redirect_from:
  - /blog/75/
  - /node/75/
---
So you've created a feature, and made it a dependency of your [site deployment module](http://blog.dcycle.com/blog/44/what-site-deployment-module), and it contains a field you don't want.

The problem is: your colleagues have the field installed on their local development machines, and the field is on your dev and prod environment.

What to do?

 * Delete your field from your feature
 * In your `hook_update_n()`, revert your feature and add the following code:

(code to add:)

    $fields_to_delete = array(
      'field_to_be_deleted_along_with_all_its_instances',
    );

    $field_instances_to_delete = array(
      array(
        'entity_type' => 'node',
        'field_name' => 'field_for_which_to_delete_only_specific_instances',
        'bundle_name' => 'node_type_where_a_field_instance_lives',
      ),
    );

    foreach ($fields_to_delete as $field_to_delete) {
      if (field_info_field($field_to_delete)) {
        field_delete_field($field_to_delete);
      }
    }

    foreach ($field_instances_to_delete as $field_instance_to_delete) {
      $instance = field_info_instance($field_instance_to_delete['entity_type'], $field_instance_to_delete['field_name'], $field_instance_to_delete['bundle_name']);
      if ($instance) {
        field_delete_instance($instance);
      }
    }
