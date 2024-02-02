---
layout: post
title: An approach to code-driven development in Drupal 8
author: admin
id: 68
created: 1410380934
tags:
  - blog
  - planet
permalink: /blog/68/approach-code-driven-development-drupal-8/
redirect_from:
  - /blog/68/
  - /node/68/
---
What is code-driven development and why is it done?
---------------------------------------------------

Code-driven development is the practice of placing all development in code. How can development not be in code?, you ask.

In Drupal, what makes your site unique is often configuration which resides in the database: the current theme, active modules, module-specific configuration, content types, and so on.

For the purpose of this article, our goal will be for all _configuration_ (the current theme, the content types, module-specific config, the active module list...) to be in _code_, and only _content_ to be in the database. There are several advantages to this approach:

 * Because all our configuration is in code, we can package all of it into a single module, which we'll call a [site deployment module](http://blog.dcycle.com/blog/44/what-site-deployment-module). When enabled, this module should provide a fully workable site without any content.
 * When a site deployment module is combined with generated content, it becomes possible to create new instances of a website [without cloning the database](http://blog.dcycle.com/blog/48/do-not-clone-database). [Devel](https://www.drupal.org/project/devel)'s `devel_generate` module, and [Realistic Dummy Content](https://www.drupal.org/project/realistic_dummy_content) can be used to create realistic dummy content. This makes on-ramping new developers easy and consistent.
 * Because unversioned databases are not required to be cloned to set up new environments, your continuous integration server can set up new instances of your site based on a known good starting point, making tests more robust.

Code-driven development for Drupal 7
------------------------------------

Before moving on to D8, let's look at a typical D7 workflow: The technique I use for developing in Drupal 7 is making sure I have one or more [features](http://drupal.org/project/features) with my content types, views, [contexts](http://drupal.org/project/context), and so on; as well as a [site deployment module](http://blog.dcycle.com/blog/44/what-site-deployment-module) which contains, in its `.install` file, [update hooks](https://api.drupal.org/api/drupal/modules%21system%21system.api.php/function/hook_update_N/7) which revert my features when needed, enable new modules, and programmatically set configuration which can't be exported via features. That way,

 * incrementally deploying sites is as simple as calling `drush updb -y` (to run new update hooks).
 * deploying a site for the first time (or redeploying it from scratch) requires creating the database, enabling our site deployment module (which [runs all or update hooks](http://blog.dcycle.com/blog/43/run-all-update-hooks-install-hook)), and optionally generating dummy content if required. For example: `drush si -y && drush en mysite_deploy -y && drush en devel_generate && drush generate-content 50`.

I have been using this technique for a few years on all my D7 projects and, in this article, I will explore how something similar can be done in D8.

New in Drupal 8: configuration management
-----------------------------------------

If, like me, you are using [features](http://drupal.org/project/features) exclusively to deploy websites (as opposed to using it to bundle generic functionality, for example having a "blog" feature, or a "calendar" feature you can add to any site), config management will replace features in D8. In D7, [context](https://www.drupal.org/project/context) is used to provide the ability to export block placement to features, and [strongarm](https://www.drupal.org/project/strongarm) exports variables. In D8, variables no longer exist, and block placement is now exportable. All of these modules are thus no longer needed.

They are replaced by the concept of [configuration management](https://www.drupal.org/documentation/administer/config), a central API for importing and exporting configuration as yml files.

Configuration management and site UUIDs
---------------------------------------

In Drupal 8, [sites are now assigned a UUID on install](https://www.drupal.org/node/2133325) and configuration can only be synchronized between sites having the same UUID. This is fine if the site has been cloned at some point from one environment to another, but as mentioned above, we are avoiding database cloning: we want it to be possible to install a brand new instance of a site at any time.

We thus need a mechanism to assign the same UUID to all instances of our site, but still allow us to reinstall it without cloning the database.

The solution I am using is to assign a site UUID in the site deployment module. Thus, in Drupal 8, my site deployment module's `.module` file looks like this:

    /**
     * @file
     * site deployment functions
     */
    use Drupal\Core\Extension\InfoParser;

    /**
     * Updates dependencies based on the site deployment's info file.
     *
     * If during the course of development, you add a dependency to your
     * site deployment module's .info file, increment the update hook
     * (see the .install module) and this function will be called, making
     * sure dependencies are enabled.
     */
    function mysite_deploy_update_dependencies() {
      $parser = new InfoParser;
      $info_file = $parser->parse(drupal_get_path('module', 'mysite_deploy') . '/mysite_deploy.info.yml');
      if (isset($info_file['dependencies'])) {
        \Drupal::service('module_installer')->install($info_file['dependencies'], TRUE);
      }
    }

    /**
     * Set the UUID of this website.
     *
     * By default, reinstalling a site will assign it a new random UUID, making
     * it impossible to sync configuration with other instances. This function
     * is called by site deployment module's .install hook.
     *
     * @param $uuid
     *   A uuid string, for example 'e732b460-add4-47a7-8c00-e4dedbb42900'.
     */
    function mysite_deploy_set_uuid($uuid) {
      \Drupal::configFactory() ->getEditable('system.site')
        ->set('uuid', $uuid)
        ->save();
    }

And the site deployment module's .install file looks like this:

    /**
     * @file
     * site deployment install functions
     */

    /**
     * Implements hook_install().
     */
    function mysite_deploy_install() {
      // This module is designed to be enabled on a brand new instance of
      // Drupal. Settings its uuid here will tell this instance that it is
      // in fact the same site as any other instance. Therefore, all local
      // instances, continuous integration, testing, dev, and production
      // instances of a codebase will have the same uuid, enabling us to
      // sync these instances via the config management system.
      // See also https://www.drupal.org/node/2133325
      mysite_deploy_set_uuid('e732b460-add4-47a7-8c00-e4dedbb42900');
      for ($i = 8001; $i < 9000; $i++) {
        $candidate = 'mysite_deploy_update_' . $i;
        if (function_exists($candidate)) {
          $candidate();
        }
      }
    }

    /**
     * Update dependencies and revert features
     */
    function mysite_deploy_update_8003() {
      // If you add a new dependency during your development:
      // (1) add your dependency to your .info file
      // (2) increment the number in this function name (example: change
      //     change 8003 to 8004)
      // (3) now, on each target environment, running drush updb -y
      //     will call the mysite_deploy_update_dependencies() function
      //     which in turn will enable all new dependencies.
      mysite_deploy_update_dependencies();
    }

The only real difference between a site deployment module for D7 and D8, thus, is that the D8 version must define a UUID common to all instances of a website (local, dev, prod, testing...).

Configuration management directories: active, staging, deploy
-------------------------------------------------------------

Out of the box, there are two directories which can contain config management yml files:

 * The *active* directory, which is always empty and unused. It used to be there to store your active configuration, and it is still possible to do so, but [I'm not sure how](https://www.drupal.org/node/2323529). We can ignore this directory for our purposes.
 * The *staging* directory, which can contain `.yml` files to be imported into a target site. (For this to work, as mentioned above, the `.yml` files will need to have been generated by a site having the same UUID as the target site, or else you will get an error message -- on the GUI the error message makes sense, but on the command line you [will get the cryptic "There were errors validating the config synchronization."](https://github.com/drush-ops/drush/issues/807)).

I will propose a workflow which ignores the staging directory as well, for the following reasons:

 * First, the staging directory is placed in `sites/default/files/`, a directory which contains user data and is explicitly ignored in Drupal's `example.gitignore` file (which makes sense). In our case, we want this information to reside in our git directory.
 * Second, my team has come to rely heavily on reinstalling Drupal and our site deployment module when things get corrupted locally. When you reinstall Drupal using `drush si`, the staging directory is deleted, so even if we did have the staging directory in git, we would be prevented from running `drush si -y && drush en mysite_deploy -y`, which we don't want.
 * Finally, you might want your config directory to be outside of your Drupal root, for security reasons.

For all of these reasons, we will add a new "deploy" configuration directory and put it in our git repo, but outside of our Drupal root.

Our directory hierarchy will now look like this:

    mysite
      .git
      deploy
        README.txt
        ...
      drupal_root
        CHANGELOG.txt
        core
        ...

You can also have your deploy directory inside your Drupal root, but keep in mind that certain configuration information are sensitive, containing email addresses and the like. We'll see later on how to tell Drupal how it can find your "deploy" directory.

Getting started: creating your Drupal instance
----------------------------------------------

Let's get started. Make sure you have version 7.x of Drush (compatible with Drupal 8), and create your git repo:

    mkdir mysite
    cd mysite
    mkdir deploy
    echo "Contains config meant to be deployed, see http://blog.dcycle.com/blog/68" >> deploy/README.txt
    drush dl drupal-8.0.x
    mv drupal* drupal_root
    cp drupal_root/example.gitignore drupal_root/.gitignore
    git init
    git add .
    git commit -am 'initial commit'

Now let's install our first instance of the site:

    cd drupal_root
    echo 'create database mysite'|mysql -uroot -proot
    drush si --db-url=mysql://root:root@localhost/mysite -y

Now create a site deployment module: [here is the code that works for me](http://blog.dcycle.com/blog/69/drupal-8-site-deployment-module). We'll set the correct site UUID in `mysite_deploy.install` later. Add this to git:

    git add drupal_root/modules/custom
    git commit -am 'added site deployment module'

Now let's tell Drupal where our "deploy" config directory is:

 * Open sites/default/settings.php
 * Find the lines beginning with $config_directories
 * Add `$config_directories['deploy'] = '../deploy';`

Edit: using a config directory name other than 'sync' will [cause an issue Config Split](https://www.drupal.org/node/2916091) at the time of this writing.

We can now perform our first export of our site configuration:

    cd drupal_root
    drush config-export deploy -y

You will now notice that your "deploy" directory is filled with your site's configuration files, and you can add them to git.

    git add .
    git commit -am 'added config files'

Now we need to sync the site UUID from the database to the code, to make sure all subsequent instances of this site have the same UUID. Open deploy/system.site.yml and find UUID property, for example:

    uuid: 03821007-701a-4231-8107-7abac53907b1
    ...

Now add this same value to your site deployment module's `.install` file, for example:

    ...
    function mysite_deploy_install() {
      mysite_deploy_set_uuid('03821007-701a-4231-8107-7abac53907b1');
    ...

Let's create a view! A content type! Position a block!
------------------------------------------------------

To see how to export configuration, create some views and content types, position some blocks, and change the default theme.

Now let's export our changes

    cd drupal_root
    drush config-export deploy -y

Your git repo will be changed accordingly

    cd ..
    git status
    git add .
    git commit -am 'changed theme, blocks, content types, views'

Deploying your Drupal 8 site
----------------------------

At this point you can push your code to a git server, and clone it to a dev server. For testing purposes, we will simply clone it directly

    cd ../
    git clone mysite mysite_destination
    cd mysite_destination/drupal_root
    echo 'create database mysite_destination'|mysql -uroot -proot
    drush si --db-url=mysql://root:root@localhost/mysite_destination -y

If you visit mysite_destination/drupal_root with a browser, you will see a plain new Drupal 8 site.

Before continuing, we need to open sites/default/settings.php on mysite_destination and add `$config_directories['deploy'] = '../deploy';`, as we did on the source site.

Now let the magic happen. Let's enable our site deployment module (to make sure our instance UUID is synched with our source site), and import our configuration from our "deploy" directory:

    drush en mysite_deploy -y
    drush config-import deploy -y

Now, on your destination site, you will see all your views, content types, block placements, and the default theme.

This deployment technique, which can be combined with generated dummy content, allows one to create new instances very quickly for new developers, testing, demos, continuous integration, and for production.

_Incrementally_ deploying your Drupal 8 site
--------------------------------------------

What about changes you make to the codebase once everything is already deployed. Let's change a view and run:

    cd drupal_root
    drush config-export deploy -y
    cd ..
    git commit -am 'more fields in view'

Let's deploy this now:

    cd ../mysite_destination
    git pull origin master
    cd drupal_root
    drush config-import deploy -y

As you can see, incremental deployments are as easy and standardized as initial deployments, reducing the risk of errors, and allowing incremental deployments to be run automatically by a continuous integration server.

Next steps and conclusion
-------------------------

Some aspects of your site's configuration (what makes your site unique) still can't be exported via the config management system, for example enabling new modules; for that we'll use [update hooks](https://api.drupal.org/api/drupal/modules%21system%21system.api.php/function/hook_update_N/7) as in Drupal 7. As of this writing Drupal 8 update hooks can't be run with Drush on the command line due to [this issue](https://github.com/drush-ops/drush/issues/47).

Also, although a great GUI exists for importing and exporting configuration, I chose to do it on the command line so that I could easily create a Jenkins continuous integration job to deploy code to dev and run tests on each push.

For Drupal projects developed with a dev-stage-prod continuous integration workflow, the new config management system is a great productivity boost.
