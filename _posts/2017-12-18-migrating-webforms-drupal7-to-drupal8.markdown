---
layout: post
title:  "Migrating Webforms from Drupal 7 to Drupal 8"
date:   2017-12-18
tags:
  - planet
  - blog
id: 2017-12-18
permalink: /blog/2017-12-18/migrating-webforms-drupal7-to-drupal8/
redirect_from:
  - /blog/2017-12-18/
---

I recently needed to port hundreds of Drupal 7 webforms with thousands of submissions from Drupal 7 to Drupal 8.

My requirements were:

* Node ids need to remain the same
* Webforms need to be [treated as data](https://www.drupal.org/project/webform/issues/2931104): they should be ignored by config export and import, just like nodes and taxonomy terms are. The reasonining is that in my setup, forms are managed by site editors, not developers. (This is not related to migration per se, but was a success criteria for my migration so I'll document my solution here)

Migration from Drupal 7
-----

I could not find a reliable upgrade or migration path from Drupal 7 to Drupal 8. I found [webform_migrate](https://www.drupal.org/project/webform_migrate) lacks documentation (I don't know where to start) and [migrate_webform](https://www.drupal.org/project/migrate_webform) is [meant for Drupal 6, not Drupal 7 as a source](https://www.drupal.org/project/migrate_webform/issues/2279477).

I settled on a my own combination of tools and workflows to perform the migration, all of them available on my Github account.

Using version 8.x-5.x of [webform](https://www.drupal.org/project/webform), I started by enabling `webform`, `webform_node` and `webform_ui` on my Drupal 8 site, this gives me an empty webform node type.

I then followed the instructions for a basic migration, which is outside the scope of this article. I have a [project on Github](https://github.com/dcycle/d6_to_d8_migration_example/tree/7) which I use as starting point from my Drpual 6 and 7 to 8 migrations. The blog post [Custom Drupal-to-Drupal Migrations with Migrate Tools, Drupalize.me, April 26, 2016 by William Hetherington](https://drupalize.me/blog/201604/custom-drupal-drupal-migrations-migrate-tools) provides more information on performing a basic migration of data.

Once you have set up your migration configurations as per those instructions, you should be able to run:

    drush migrate-import upgrade_d7_node_webform --execute-dependencies

And you should see something like:

    Processed 25 items (25 created, 0 updated, 0 failed, 0 ignored) - done with 'upgrade_d7_node_type'
    Processed 11 items (11 created, 0 updated, 0 failed, 0 ignored) - done with 'upgrade_d7_user_role'
    Processed 0 items (0 created, 0 updated, 0 failed, 0 ignored) - done with 'upgrade_d7_user_role'
    Processed 95 items (95 created, 0 updated, 0 failed, 0 ignored) - done with 'upgrade_d7_user'
    Processed 109 items (109 created, 0 updated, 0 failed, 0 ignored) - done with 'upgrade_d7_node_webform'

At this point I had all my webforms as nodes with the same node ids on Drupal 7 and Drupal 8, however this does nothing to import the actual forms or submissions.

Importing the data itself
-----

I found that the most efficient way of importing the data was to create my own Drupal 8 module, which [I have published on Dcycle's Github account](https://github.com/dcycle/webform_d7_to_d8), called `webform_d7_to_d8`. (I have decided against publishing this on Drupal.org because I don't plan on maintaining it long-term, and I don't have the resources to combine efforts with existing webform migration modules.)

I did my best to make that module self-explanatory, so you should be able to follow the steps the [README file](https://github.com/dcycle/webform_d7_to_d8), which I will summarize here:

Start by giving your Drupal 8 site access to your Drupal 7 database in `./sites/default/settings.php`:

    $databases['upgrade']['default'] = array (
      'database' => 'drupal7database',
      'username' => 'drupal7user',
      'password' => 'drupal7password',
      'prefix' => '',
      'host' => 'drupal7host',
      'port' => '3306',
      'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
      'driver' => 'mysql',
    );

Run the migration with our without options:

    drush ev 'webform_d7_to_d8()'

or

    drush ev 'webform_d7_to_d8(["nid" => 123])'

or

    drush ev 'webform_d7_to_d8(["simulate" => TRUE])'

...

More detailed information can be found in the module's [README file](https://github.com/dcycle/webform_d7_to_d8).

Treating webforms as data
-----

Once you have imported your webforms to Drupal 8, they are treated as configuration, that is, the Webform module assumes that developers, not site builders, will be creating the forms. This may be fine in many cases, however my usecase is that site editors want to create and edit forms directly on the production site, and we don't want them to be tracked by the configuration management system.

[Jacob Rockowitz](https://www.drupal.org/u/jrockowitz) [pointed me in the right direction](https://www.drupal.org/project/webform/issues/2931104) for making sure webforms are not treated as configuration. For that purpose I am using [Drush CMI tools](https://github.com/previousnext/drush_cmi_tools) by Previous Next and documented on their blog post, [Introducing Drush CMI tools, 24 Aug. 2016](https://www.previousnext.com.au/blog/introducing-drush-cmi-tools).

Once you install Drush CMI tools in your `~/.drush` folder and run `drush cc drush`, you can use `druch cexy` and `druch cimy` instead of `drush cim` and `drush cex` in your conguration management process. Here is how and why:

Normally, if you develop your site locally and, say, add a content type or field, or remove a content type of field, you can run `drush cex` to export your newly created configuration. Then, your colleagues can pull your code and run `drush cim` to pull your configuration. `drush cim` can also be used in continuous integration, preproduction, dev, and production environments.

The problem is that `drush cex` exports _all_ configuration, and `drush cim` deletes everything in the database which is not in configuration. In our case, we don't want to consider webforms as configuration but as data, just as nodes as taxonomy terms: we don't want them to be exported along with other configuration; and if they exist on a target environment we want to leave them as they are.

Using Drush CMI tools, you can add a file such as the following to `~/.drush/config-ignore.yml`:

    # See http://blog.dcycle.com/blog/2017-12-18
    ignore:
      - webform.webform.*

This has to be done on all developers' machines or, if you use Docker, on a shared Docker container (which is outside the scope of this article).

Now, for exporting configuration, run:

    drush cexy --destination='/path/to/config/folder'

Now, webforms will not be exported along with other configuration.

We also need to avoid erasing webforms on target environments: if you create a webform on a target environment, then run `drush cim`, you will see something like:

    webform.webform.webform_9521   delete
    webform.webform.webform_8996   delete
    webform.webform.webform_8991   delete
    webform.webform.webform_8986   delete

So, we need to avoid deleting webforms on the target environment when we import configuration. We could just do `drush cim --partial` but this avoids deleting _everything_, not just webforms.

Drush CMI tools provides an alternative:

    drush cimy --source=/path/to/config/folder

This works much like `drush cim --partial`, but it allows you to specify another parameter, --delete-list=/path/to/config-delete.yml

Then, in `config-delete.yml`, you can specify items that you actually want to delete on the target environment, for example content types, fields, and views which do not exist in code. This is dependent on your workflow and they way to set it up isdocumented on the [Drush CMI tools project homepage](https://github.com/previousnext/drush_cmi_tools).

With this in place, we'll have our Drupal 7 webforms on our Drupal 8 site.
