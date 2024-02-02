---
layout: post
title: Using Drush and SSH to clone a remote database
id: 33
created: 1383067646
tags:
  - blog
permalink: /blog/33/using-drush-and-ssh-clone-remote-database/
redirect_from:
  - /blog/33/
  - /node/33/
---
Sometime one needs to clone an entire remote website in order to diagnose certain problems. Here's how I go about it:

The following example assumes that:

 * You have a local webserver, in this example MAMP.
 * You have [Drush](http://drupal.org/project/drush) installed both locally and on your remote server.
 * Make sure you have the same code locally as on your remote server, *but not the sites/default/settings.php file*
 * your site name is "example"
 * your local MySQL credentials are root/root
 * you have SSH public-private key access to your remote server (otherwise you will be prompted for a password)
 * your remote server is at root@example.com

Here is the code for initial site creation:

    cd /path/to/local/drupal
    echo 'create database example' | mysql -uroot -proot
    drush si --db-url=mysql://root:root@localhost/example
    ssh root@example.com "drush -r /path/to/remote/drupal sql-dump" > ~/remote.sql
    drush sqlc < ~/remote.sql
    rm ~/remote.sql
    drush uli

If you want to replace an existing database with the clone:

    ssh root@example.com "drush -r /path/to/remote/drupal sql-dump" > ~/remote.sql
    drush sqlc < ~/remote.sql
    rm ~/remote.sql
    drush uli

In the above example, you start by setting the working directory to your local Drupal site, then you create a new local database, and create the initial installation and the sites/default/settings.php file. Then you log into the remote server and dump your database to your local computer. Next, import it with `drush sqlc`, delete the local dump, and generate a login link because you don't remember the password to the remote site.
