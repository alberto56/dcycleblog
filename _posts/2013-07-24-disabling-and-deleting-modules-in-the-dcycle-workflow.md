---
layout: post
title: Disabling and deleting modules in the Dcycle workflow
id: 18
created: 1374680795
permalink: /blog/disabling-and-deleting-modules-dcycle-workflow/
redirect_from:
  - /blog/18/
  - /node/18/
---
In the dev-stage-prod workflow defined by Dcycle,

* The entire Drupal installation is under version control in a git repo
* Work is done locally
* Changes are pushed to stage, and eventually production, using features and hook_update_n()s.

When you want to delete a module from your installation, start by disabling and uninstalling the module in a hook_update_n(), most likely in your deployment module, as such (for example):

    demo_deploy_update_7032() {
      module_disable(array('bad_module'));
      drupal_uninstall_modules(array('bad_module'));
    }


it is important not to delete it from the repo until you are sure that all environments have disabled the module in their databases, that is, that they have all applied the update 7032.

Consider the following scenario:

* An update hook is created disabling the module, and pushed to git.
* The update hook is applied to the stage and prod sites, but _not_ to the local environment of one of your colleagues.
* bad_module is now deleted from the git repo, and pushed.
* When the git repo is pulled to stage and prod, everything works.
* When your colleague pulls the git repo, the local database _expects_ bad_module to be present, which most likely will result in a PHP error.

To avoid this, a _support period_ can be defined, of two months for example: this means that any environment not updated for two months can crash. With this in mind:

* A minimum of two months must elapse between a module's uninstallation and its deletion.
* Any environment which is not updated at least every two months is expected to crash.
* An automated tool to manage this (for example to remind you to delete a module which was disabled more than two months ago) might be created.

If an environment does crash because a module has been deleted from the git repo, one has two options.

The first, which applies to a local development with no real content, is to simply reinstall the entire site. Because the Dcycle method requires that a deployment module exist, and that enabling on a brand new Drupal installation will deploy your entire site, recreating the site is easy (devel_generate can be used to recreate dummy content in that case).

If a site crashes which has content (worst case: the production site). One can

* git checkout a commit which is known to contain the module before it was deleted.
* Disable and uninstall the module using drush updb -y (which calls the update hook).
* git checkout the latest version of the git repo (in which the module is deleted).
