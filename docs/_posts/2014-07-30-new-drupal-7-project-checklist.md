---
layout: post
title: New Drupal 7 project checklist
id: 66
created: 1406729425
tags:
  - blog
  - planet
permalink: /blog/66/new-drupal-7-project-checklist/
redirect_from:
  - /blog/66/
  - /node/66/
---
I had this checklist documented internally, but I keep referring back to it so I'll make it available here in case anyone else needs it. The idea here is to document a minimum (not an ideal) set of modules and tasks which I do for almost all projects.

Questions to ask of a client at the project launch
--------------------------------------------------

 * Is your site bilingual? If so is there more than one domain? (if so, and you are exporting your languages as Features, your domain is exported with it. If your domains are different on different environments, you might want to use [language_domain](https://www.drupal.org/project/language_domains) to override the domains per environment)
 * What type of compatibility do you need: tablet, mobile, which versions of IE?
 * How do you see your post-launch support and core/module update contract?
 * Do you need SSL support?
 * What is your hosting arrangement?
 * Do you have a contact form?
 * What is your anti-spam method? Note that [CAPTCHA is no longer useful](http://www.popsci.com/article/technology/rip-captcha?src=SOC&dom=fb); I like [Mollom](https://mollom.com), but it's giving me more and more false positives with time. [Honeypot](https://www.drupal.org/project/honeypot) has given me good results as well.
 * Is WYSIWYG required? I strongly suggest [using Markdown instead](http://readwrite.com/2012/04/17/why-you-need-to-learn-markdown).
 * Confirm that all emails are sent in plain text, not HTML. If you're sending out HTML mail, [do it right](http://www.aweber.com/blog/email-marketing/plain-text-vs-html-email-2014.htm).
 * Do you need an on-site search utility? If so, some thought, and resources, need to go into it or it will be frustrating.
 * What kind of load do you expect on your site (anonymous and admin users)? This information can be used for load testing.
 * If you already have a site, should old paths of critical content map to paths on the new site?
 * Should users be allowed to create accounts (with spam considerations, and see if an admin should approve them).

[Sprint Zero](http://www.scrumalliance.org/community/articles/2013/september/what-is-sprint-zero): starting the project
---------------------------------

Here is what should get done in the first Agile sprint, aka Sprint Zero:

 * If you are using [continuous integration](http://blog.dcycle.com/blog/46/continuous-deployment-drupal-style), a Jenkins job for tracking the master branch: this job should fail if any test fails on the codebase, or if quality metrics ([code review](https://www.drupal.org/project/coder), for example, or [pdepend](http://pdepend.org) metrics) reach predefined thresholds.
 * A Jenkins job for pushing to dev. This is triggered by the first job if tests pass. It pushed the new code to the dev environment, and updates the dev environment's database. [The database is never cloned](http://blog.dcycle.com/blog/48/do-not-clone-database); rather, a [site deployment module](http://blog.dcycle.com/blog/44/what-site-deployment-module) is used.
 * An issue queue is set up and the client is given access to it, and training on how to use it.
 * A wiki is set up.
 * A dev environment is set up. This is where the code gets pushed automatically if all tests pass.
 * A prod environment is set up. This environment is normally updated manually after each end of sprint demo.
 * A git repo is set up with a basic Drupal site.
 * A custom module is set up in `sites/*/modules/custom`: this is where custom function go.
 * A [site deployment module](http://blog.dcycle.com/blog/44/what-site-deployment-module) in `sites/all/modules/custom`. All deployment-related code and dependencies go here. A [`.test`](http://blog.dcycle.com/blog/30/basic-test) file and an [`.install`](http://blog.dcycle.com/blog/65/basic-install-file-deployment-module) should be included.
 * A site development module is set up in `sites/*/modules/custom`, which is meant to contain all modules required or useful for development, as dependencies.
 * A custom theme is created.
 * An initial feature is created in `sites/*/modules/features`. This is where all your features will be added.
 * A "sites/*/modules/patches" folder is created (with a README.txt file, to make sure it goes into git). This is where core and contrib patches should go. Your site's maintainers should apply these patches when core or contrib modules are updated. Patch names here should include the node id and comment number on Drupal.org.

Basic module list (always used)
-------------------------------

 * [views](https://drupal.org/project/views)
 * [context](https://drupal.org/project/context)
 * [strongarm](https://drupal.org/project/strongarm)
 * admin_menu_toolbar (part of [admin_menu](https://drupal.org/project/admin_menu))
 * [markdown](https://drupal.org/project/markdown)
 * [transliteration](https://drupal.org/project/transliteration)
 * [globalredirect](https://drupal.org/project/globalredirect)
 * [redirect](https://drupal.org/project/redirect)
 * [config_builder](https://drupal.org/project/config_builder), almost always useful to create a single form allowing clients to change site variables.
 * [features](https://drupal.org/project/features)
 * [logintoboggan](https://drupal.org/project/logintoboggan)

Development modules (not enabled on production)
-----------------------------------------------

I normally create a custom development module with these as dependencies:

 * [diff](https://drupal.org/project/diff)
 * [devel](https://drupal.org/project/devel)
 * realistic_dummy_content_api (part of [realistic_dummy_content](https://drupal.org/project/realistic_dummy_content))
 * coder_review (part of [coder](https://drupal.org/project/coder))
 * context_ui (part of [context](https://drupal.org/project/context))
 * views_ui (part of [views](https://drupal.org/project/views))
 * [masquerade](https://drupal.org/project/masquerade)
 * [search_krumo](https://drupal.org/project/search_krumo)
 * [simpletest_turbo](https://drupal.org/project/simpletest_turbo)
 * devel_generate (part of [devel](https://drupal.org/project/devel))
 * config_builder_ui (part of [config_builder](https://drupal.org/project/config_builder))
 * [maillog](https://drupal.org/project/maillog), to keep track of sent email

I make sure this module is in my repo but it is not enabled unless used:

 * [devel_themer](https://drupal.org/project/devel_themer)

Experimental modules
--------------------------

 * [dcycle](https://www.drupal.org/project/dcycle), this is a module that is in active development, not ready for prime yet, but where I try to add all my code to help with testing, etc.

Multilingual modules
--------------------

 * [i18n](https://drupal.org/project/i18n)
 * [potx](https://drupal.org/project/potx)
 * [l10n_update](https://drupal.org/project/l10n_update)
 * [entity_translation](https://www.drupal.org/project/entity_translation) if you need the same node id to display in several languages. This is useful if you have references to nodes which should be translated.
 * [title](https://www.drupal.org/project/title) if you are using entity translations and your titles can be multilingual.

Launch checklist
----------------

 * Design a custom 404, error and maintenance page.
 * Path, alias and permalink strategy. (Might require [pathauto](https://drupal.org/project/pathauto).)
 * Think of adding revisions to content types to avoid clients losing their data.
 * Don't display errors on production.
 * Optimize CSS, JS and page caching.
 * Views should be cached.
 * System messages are properly themed.
 * Prevent very simple passwords.
 * [Using syslog instead of dblog](http://linuxdev.dk/blog/sending-drupal-log-enteries-syslog) on prod

In conclusion
-------------

Most shops, and most developers, have some sort of checklist like this. Mine is not any better or worse than most, but can be a good starting point. Another note: I've seen at least three Drupal teams try, and fail, to implement a "Drupal Starter kit for Company XYZ" and keep it under version control. The problem with that approach, as opposed to a checklist, is that it's not lightweight enough: it is a software product which needs maintenance, and after a while no one maintains it.
