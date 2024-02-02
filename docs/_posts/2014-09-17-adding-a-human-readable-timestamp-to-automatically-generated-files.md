---
layout: post
title: Adding a human-readable timestamp to automatically generated files
author: admin
id: 73
created: 1410958940
tags:
  - snippet
permalink: /blog/73/adding-human-readable-timestamp-automatically-generated-files/
redirect_from:
  - /blog/73/
  - /node/73/
---
Let's say you are creating backups as part of a script, and you want each backup to have a human-readable timestamp.

Drush can be used to generate a backup of your Drupal site, and send it to a file:

    drush cc all && drush sql-dump > /backups/backup-$(date '+%Y-%m-%d-%H-%M-%S').sql

This will create a file that looks like:

    /backups/backup2014-09-17-08-53-41.sql

You might also want to include the git commit number in there:

    drush sql-dump > /backups/backup--$(git log --pretty=format:'%h' -n1)--$(date '+%Y-%m-%d-%H-%M-%S').sql

This will create a file that looks like:

    /backups/backup--8818eca--2014-09-17-08-57-57.sql

In case of a problem now you will be able to revert to previous version of your site in case of a problem with your upgrade.

 * Revert your codebase to commit 8818eca (as per the example above).
 * git sqlc < /backups/backup--8818eca--2014-09-17-08-57-57.sql
