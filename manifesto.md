---
layout: default
title: About Long Haul
---

Dcycle is a building code for Drupal.

Dcycle defines standards for achieving a dev-stage-production workflow for Drupal development, through proper deployment, test coverage, and continuous integration.

## 1. Standardize your deployment ##

### 1.1. All configuration should be in code. ###

In Drupal 7 this can be achieved using [Features](https://drupal.org/project/features), [Strongarm](https://drupal.org/project/strongarm) and [Context](https://drupal.org/project/context). In Drupal 8 the [Configuration Management System](https://drupal.org/documentation/administer/config) is used.

### 1.2. Initial deployment must be standardized and predictable ###

Initial deployment refers to installing a new environment without data. New environments are installed:

* When the production site comes online
* When your continuous integration system installs a new environment for testing purposes
* When a new team member joins the development team
* When Simpletest installs a new database for testing purposes

Thus, far from being a rare occurrence, initial deployment should happen dozens of times a day in an actively developed project.

A standardized initial deployment limits possible errors. Dcycle initial deployment requires that:

* A deployment module be defined for your site and be placed in `sites/*/modules/custom/[namespace]_deploy` where `[namespace]` is an all-lowercase name relating to your project.
* The deployment module, when enabled on a new Drupal installation, is responsible for setting up the entire environment: the default theme, all dependencies, [features](https://drupal.org/project/features) (in Drupal 7) or config files (in Drupal 8).
* Devel Generate (devel_generate), part of [devel](https://drupal.org/project/devel) can be used to generate dummy content for your new environment for development purposes.
* It is possible to set up a new functional environment with dummy _without_ cloning any database.

Assuming the namespace `demo` and mysql credentials `root/root`, it should be possible to set up a complete working site in a few minutes with the following commands:

    NAMESPACE=demo
    git clone [my git repo]
    cd $NAMESPACE
    echo "create database $NAMESPACE" | mysql -uroot -proot
    drush site-install --db-url="mysql://root:root@localhost/$NAMESPACE" --account-name=root --account-pass=root -y
    drush en "$NAMESPACE"_deploy -y

If [devel](https://drupal.org/project/devel) is present in your git repo, you can create dummy content by:

    drush en devel_generate -y
    drush generate-content

Importantly, your initial deployment procedure must not require database cloning, manual clicking in the interface, or commands other than of the above.

Note that Dcycle does not define any procedure for content staging.

### 1.3. Incremental deployment must be standardized and predictable ###

Incremental deployment refers to changes to your site after it has been deployed. For test or development environments, it is possible to discard them and restart anew with initial deployment. However it is important to use incremental deployment as much as possible during development and testing, because once you have live data on your production site, incremental deployment is the only way to deploy changes.

As with initial deployment, it is important not to define manual procedures or non-standard commands in the command line for incremental deployment. Rather, if your incremental deployment requires changes to your database, these should be implemented via [hook_update_n()](https://api.drupal.org/api/drupal/modules!system!system.api.php/function/hook_update_N/7). Here is an example of what your demo_deploy.install file might look like if you enable a new module and modify a view after your initial deployment.

    demo_deploy_update_7001() {
      # Reverting a feature should not be done in the visual interface
      # or using drush fr, but should rather be done in the hook_update_n().
      # To determine the component name (example views_view), make sure you are
      # using version 2.x of Features, and visit the page for your features.
      # In parentheses you will see the machine name for each component.
      features_revert(array('demo_feature' => array('views_view')));
      module_enable(array('new_module'));
    }

It is important to remember that `hook_update_n()`s will be _not_ be called during initial deployment. It is important, therefore, that whatever takes place in update hooks also takes place during initial deployment. In the above example, it is not necessary to revert features during initial deployment, because features are installed in their most up-to-date status automatically. However `new_module` will not be enabled during initial deployment unless you specifically add it to the list of dependencies in your `.info` file:

    dependencies[] = new_module

Any other code (database queries for modules which do not support Features, for example) must also be called in your deployment module's [hook_install()](https://api.drupal.org/api/drupal/modules%21system%21system.api.php/function/hook_install/7).

Now, whenever your incrementally deploy new code via git, the procedure should always be the same: run your update hooks and clear your cache. Dcycle also requires that you run cron after incremental deployments.

    drush vset maintenance_mode 1
    drush updb -y
    drush cc all
    drush cron
    drush vset maintenance_mode 0

## 2. Test coverage ##

### 2.1. A development policy ###

Dcycle requires that your site define a development _policy_, and that that policy be automatically tested on the command line where possible.

An example policy for Drupal sites developed by your organization might be:

* The PHP module should never be a dependency for any site
* Simpletest coverage should cover all crucial usecases
* [Coder](https://drupal.org/project/coder)'s Code review should find no errors.

For some projects, your policy might also include such rules as javascript testing with Behat/Mink/Selenium, Internet Explorer testing via remote selenium for Windows, code quality metrics, Vagrant/Puppet DevOps installation testing, or anything else.

### 2.2. Validate your policy as part of your automated tests ###

Dcycle requires that as many rules as possible be tested automatically using the command-line. For example, in the above example, it is possible to automate most of the testing. Your simpletest might confirm that PHP module is disabled after your deployment module has been enabled, and then you can run the following in the command line, where demo is the test group:

    drush test-run demo

    # make sure we have a nice coding style
    drush coder-review --minor --comment demo_custom_module1 demo_custom_module2

Those parts of your policy which are not automatically testable, such as manual code review, should be under the responsibility of a designated team or person who can review changes before pushing them to the production site.

### 2.3. How to determine your test policy ###

Your test policy is a trade-off between the ideal of 100% test coverage, and the reality of business considerations.

Dcycle states that your test policy should satisfy the following criteria:

* You are confident that, if all your automated tests pass, code can be moved to a stable branch and demo environment.
* You are confident that, once your demo environment and stable branch have been manually reviewed in accordance with your test policy, your code can be pushed to the production environment.

It is up to your organization and your client to determine which policy is best for you.

## 3. Continuous integration ##

### 3.1. Using git: keep it simple ###

Dcycle defines a simple, basic usage of git.

At a minimum, these branches should be defined for your project:

* master: all development happens here.
* prod: updated, manually or automatically, upon manual review of the stage site.

Even though prod is technically a branch, it should never diverge from master. Merging master into prod should always be a [fast-forward](http://git-scm.com/book/en/Git-Branching-Basic-Branching-and-Merging) merge. This means that code in master is more advanced than that in prod.

Diverging branches, or feature branches, are unsupported by Dcycle. Generally they are used outside of the Dcycle continuous integration workflow, and merged into master once development is done.

Specifically, Dcycle does not define a procedure for dealing with hotfixes, or changes to the production branch without merge master into prod. If your project is of sufficient complexity to warrent hotfixes, make sure you have a procedure for testing changes first, and propagating them to the master branch.

Dcycle requires, also, that certain environments be defined for your project:

* stage: always reflects the latest commit in master, and may be unstable. If you need to demo your work, the stage environment may be used, in which case you may want to turn off, in your continuous integration server, automatic updating of the stage environment.
* prod: reflects the latest commit to the prod branch..

### 3.2. Set up a continuous integration server ###

Dcycle requires that a Continuous integration (CI) server such as [Jenkins](http://jenkins-ci.org) be set up and visible to your entire team. Only the master branch may be changed directly by developers.

### 3.3. Set up CI jobs to update your branches and environments ###

Dcycle requires that the following CI jobs be set up:

#### *master job* ####

The master job monitors the master branch, and, when it has changed, runs a build which does the following:

* updates the stage site using `hook_update_n()`
* runs your tests on the command-line
* if your tests pass, pushes new code to the prod branch.
* if tests fail, mark the build as failed.

The code for the master job will look something like this:

    # make sure we have access to drush
    export PATH=/path/to/drush:$PATH

    # update the dev site
    drush vset maintenance_mode 1
    drush updb -y
    drush cc all
    drush cron
    drush vset maintenance_mode 0

    # run our tests
    drush cc all
    drush test-run demo

    # make sure we have a nice coding style (optional)
    drush coder-review --minor --comment demo_deploy

Failed master build are owned by the entire team working on a Dcycle project and fixing them should be a top priority.

#### *prod job* ####

This job should:

* update the prod site, and updates the database based on the prod branch.

Dcycle states that this job should not be run automatically, but rather triggered manually after a review of the stage site and code. However, if you are particularly confident in your automated tests, and you can live with the risks of continuous deployment, this job can be automated.

The code for this job might look something like this:

    ssh me@example.com "/path/to/drush -r /path/to/drupal vset maintenance_mode 0"
    ssh me@example.com "git --git-dir=/path/to/drupal/.git --work-tree=/path/to/drupal pull origin master"
    ssh me@example.com "/path/to/drush -r /path/to/drupal updb -y"
    ssh me@example.com "/path/to/drush -r /path/to/drupal cc all"
    ssh me@example.com "/path/to/drush -r /path/to/drupal cron"
    ssh me@example.com "/path/to/drush -r /path/to/drupal vset maintenance_mode 1"

Note that you might also want to limit access to this job to certain members of your team.

### 3.4. Cloning the production database upstream ###

For critical projects you might need to clone your production site into a pre-production environment, for testing. This, too, can be done with a CI job:

    ssh me@example.com "/path/to/drush -r /path/to/drupal sql-dump" > database.sql
    drush sqlc < database.sql

Dcycle states that cloning the database only be done for pre-production testing and that developers not depend on database cloning to set up their local site, but rather use a deployment module.
