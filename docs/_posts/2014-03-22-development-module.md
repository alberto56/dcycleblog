---
layout: post
title: Development module
id: 54
created: 1395526543
tags:
  - snippet
permalink: /blog/54/development-module/
redirect_from:
  - /blog/54/
  - /node/54/
---
When working on a project, I like to have my [site deployment module](http://blog.dcycle.com/blog/44/what-site-deployment-module), a custom module (for custom code), a single [feature](https://drupal.org/project/features), and a development module.

The purpose of the development module is to enable all development tools at once for a given environment. It consists only of dependencies for the moment but could also define, say, [better dummy content](https://drupal.org/comment/7834865#comment-7834865), mock objects and the like. I'd eventually like to have a way to disable these all at once.

Sometimes when my development database is off-track, I can do away with it and reinstall the site (this is easy because I'm [not cloning the database](http://blog.dcycle.com/blog/48/do-not-clone-database)]:

    drush si -y; drush en mysite_deploy mysite_devel -y;

Here is what my `mysite_devel`'s `.info` file looks like:

    name = My Site Devel
    core = 7.x
    description = Activate on dev environments only

    dependencies[] = devel
    dependencies[] = search_krumo
    dependencies[] = maillog
    dependencies[] = simpletest
    dependencies[] = masquerade
    dependencies[] = views_ui
    dependencies[] = context_ui
    dependencies[] = devel_generate
