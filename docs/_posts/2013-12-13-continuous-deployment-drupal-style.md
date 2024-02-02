---
layout: post
title: Continuous deployment, Drupal style
id: 46
created: 1386978624
tags:
  - blog
  - planet
permalink: /blog/46/continuous-deployment-drupal-style/
redirect_from:
  - /blog/46/
  - /node/46/
---
Edit (2016-10-03): [This website is no longer Drupal-based](http://blog.dcycle.com/blog/2016-10-02/when-not-to-use-drupal/).

Deployments are often one of the most pain-inducing aspects of the Drupal development cycle. I have talked to Drupal developers in several shops, and have found that best practices are often ignored in favor of cloning databases downstream, manually reproducing content on prod environments, following a series of error-prone manual steps on each environment, and other bad practices, all of which should be thrown out the door.

In this article I am referring to deployment of site configuration (not content) on a Drupal 7 site. Configuration refers such aspects of your site as the default theme, CSS aggregation status, content types, views, vocabularies, and the like.

Taking best practices to the extreme, it is possible to deploy _continually_, dozens of times a day, automatically. The following procedure is a proof of concept, and you will probably want to adapt it to your needs, introducing a manual step perhaps, if only to make sure your deployments happen on fixed schedule.

Still, I have started using the exact procedure discussed herein to deploy the website you are currently reading, [blog.dcycle.com](http://blog.dcycle.com). Furthermore, [the code is on Github](https://github.com/alberto56/dcyclesite), so anyone can reproduce the dcycle project site, without the content (I'll detail how later on).

Initial goal
============

In an effort to demonstrate that the principles of the [Dcycle manifesto](http://blog.dcycle.com/) work well for a real — albeit simple — website, I have started to deploy changes to the Dcycle website itself via a [site deployment module](http://blog.dcycle.com/blog/44) with automatic testing, a continuous integration server (Jenkins), and continuous deployment. In fact, if you visit [the dcycle website](http://blog.dcycle.com/), you might come across a maintenance page. This is a deployment in action, and chances are it's happening automatically.

So what is continuous deployment? For our purposes, it is a site development method which follows these principles:

 * The site's code is under version control (we are using [Git](http://git-scm.com)).
 * Our site is deployed, initially and incrementally, via a [site deployment module](http://blog.dcycle.com/blog/44).
 * Automatic testing confirms that the features we have developed actually work.
 * Two branches exist: `master`, on which development occurs, and `prod`, considered stable, on which all tests have passed.
 * A continuous integration server (in our case [Jenkins](http://jenkins-ci.org)) monitors the `master` branch, and moves code to the `prod` branch only if automated tests pass.
 * The production site is never changed directly, but via a job in the continuous integration server.
 * Once the `prod` branch is updated, so is the production site.
 * Databases are never cloned, except to move legacy sites to your local development environment. (A legacy site, in the context of this article, is a site which you can't deploy (minus the content) without cloning the database).

A typical workflow happens like this:

 * Code is committed and pushed to the `master` branch in the git repo.
 * Jenkins picks up on the change, runs the tests, and they fail. The `prod` branch and the production site are untouched.
 * The problem leading to the failing test is fixed, and the code is pushed, again to the `master` branch in the git repo.
 * Jenkins picks up on the change, runs the tests, and this time they pass. The `prod` branch is updated automatically, and the production site itself is updated. _Automatically_.

Tools
=====

Before getting started, make sure you have the following.

 * A continuous integration server, which can be on your laptop if you wish. [Jenkins](http://jenkins-ci.org) is easy to set up, and took me five minutes to install on Mac OS, and another five minutes on CentOS. Just follow the instructions.
 * A central git repo. You can fork [the code for the blog.dcycle.com website](https://github.com/alberto56/dcyclesite) if you like.
 * A webserver on your laptop. I am using [MAMP](http://www.mamp.info/en/index.html).
 * Access to your production website on the command line via SSH.
 * SSH public-private key access to the production server, to avoid being asked for passwords. This is important for Jenkins to modify the production server automatically.

We won't be using git hooks or Drupal's GUI.

Step one: pick an issue
=======================

More often than not, we are working on _existing_ Drupal sites, not new ones, and we don't have the luxury of redeveloping everything with best practices. So we'll start with a single issue, either a bug or feature request. Here is a real-life example for the [Dcycle website](http://blog.dcycle.com):

I like the idea of each article having its ID reflected in the URL, as is the case with [Stack Overflow](http://stackoverflow.com/). I want the path of my articles to be in the format `blog/12345/title-of-the-post`. I also want it to be possible to shorten the path and have it redirect the full path, so for example `blog/12345` redirects to `blog/12345/title-of-the-post`, as is the case on Stack Overflow.

So, I started out with the goal of implementing this feature using continuous deployment and automated tests.

Step two: create a local version of the website
===============================================

If your site has a [site deployment module](http://blog.dcycle.com/blog/44) or something like it, download your code from git and deploy the site locally, using these commands, substituting your own site deployment module name and database credentials for those in the example:

    echo 'create database example' | mysql -uroot -proot
    drush si --db-url=mysql://root:root@localhost/example --account-name=root --account-pass=root
    drush en example_deploy -y

If you want to try this at home and create a local version of the [Dcycle website](http://blog.dcycle.com), make sure you have a webserver, PHP and MySQL installed, and run the following commands (if you want to actually modify the code, fork it first and use your project URL instead of mine). This example uses MAMP.

    cd /Applications/MAMP/htdocs
    git clone https://github.com/alberto56/dcyclesite.git dcyclesample
    cd dcyclesample
    echo 'create database dcyclesample' | mysql -uroot -proot
    drush si --db-url=mysql://root:root@localhost/dcyclesample --account-name=root --account-pass=root
    drush en dcycle_deploy -y

The above will yield an empty website. Adding some generated content will make development easier:

    drush en devel_generate -y
    drush generate-content 50

If there is no site deployment site, you can [clone the database](http://blog.dcycle.com/blog/33), but don't make a habit of it!

Step three: make sure you have a site deployment module
=======================================================

To work well with continuous deployment, your site needs to have a consistent way of being initially and incrementally deployed. To achieve this, I recommend the use of a [site deployment module](http://blog.dcycle.com/blog/44).

Create one for your site (one already exists for the Dcycle website code, if you are using that), and make sure the `.install` file contains everything necessary to deploy your site. To make sure initial deployment and incremental deployment result in the same state, I just call all my `update` hooks from my `install` hook, and that has worked fine for me. Your `.install` file might look something like:

    /**
     * @file
     * sites/default/modules/custom/dcycle_deploy/dcycle_deploy.install
     * Initial and incremental deployment of this website.
     */

    /**
     * Implements hook_install().
     */
    function dcycle_deploy_install() {
      for ($i = 7001; $i < 8000; $i++) {
        $candidate = 'dcycle_deploy_update_' . $i;
        if (function_exists($candidate)) {
          $candidate();
        }
      }
    }

    /**
     * Admin menu
     */
    function dcycle_deploy_update_7007() {
      module_enable(array('admin_menu_toolbar'));
      module_disable(array('toolbar'));
    }

    ...

    /**
     * Set dark_elegant as theme
     */
    function dcycle_deploy_update_7015() {
      theme_enable(array('dark_elegant'));
      variable_set('theme_default', 'dark_elegant');
    }

The above code sets the default theme and changes the toolbar to `admin_menu_toolbar`, which I prefer.

Because these features were deployed at different times (the theme was changed after the toolbar was changed), [numbered update hooks](https://api.drupal.org/api/drupal/modules!system!system.api.php/function/hook_update_N/7) are used.

Notice how the install hook cycles through all the update hooks, ensuring that our initial deployment and incremental deployments result in the same state. For any given environment, now, regardless of the previous state, bringing it up to date is simply a matter of updating the database. The following script can now be used on any environment:

    drush vset maintenance_mode 1
    drush updb -y
    drush cc all
    drush vset maintenance_mode 0

The above puts the site in maintenance mode, runs all the update hooks which have not yet been run, clears the caches and takes the site out of maintenance mode.

We now have standardized deployment, both initial and incremental.

Step four: write a failing test
===============================

For continuous deployment to be of any use, we need to have very high confidence in our tests. A good first step to that end is for our tests to actually exist. And a good way to ensure that your tests exist is to write them before anything else. This is [Test-driven development](http://en.wikipedia.org/wiki/Test-driven_development).

If you cloned my git repo for this site, the "short path" feature, introduced above, has already been implemented and tested, so the test passes. Still, here is the code I had written, which initially was failing. You might want to write something similar, or add a `test...()` function to your `.test` file, for another feature.

    /**
     * @file
     * sites/default/modules/custom/dcycle_deploy/dcycle_deploy.test
     * This file contains the testing code for this module
     */

    // Test should run with this number of blog posts.
    define('DCYCLE_DEPLOY_TEST_BLOG_COUNT', 5);

    /**
     * The test case
     */
    class dcyclesiteTestCase extends DrupalWebTestCase {
      /**
       * Info for this test case.
       */
      public static function getInfo() {
        return array(
          'name' => t('dcyclesite: basic test'),
          'description' => t('describe test.'),
          'group' => 'dcyclesite',
        );
      }

      /*
       * Enable your module
       */
      public function setUp() {
        // set up a new site with default core modules, dcyclesite, and
        // dependencies.
        parent::setUp('dcycle_deploy');
      }

      /*
       * Test case for dcyclesite.
       */
      public function testModule() {
        $this->loginAsRole('administrator');
        $blogs = array();
        for ($i = 1; $i <= DCYCLE_DEPLOY_TEST_BLOG_COUNT; $i++) {
          $this->drupalCreateNode(array('type' => 'article', 'title' => 'É' . $blogs[$i] = $this->randomName()));
          foreach (array('blog', 'node') as $base) {
            // passing alias => TRUE, otherwise, the test converts our call
            // to the alias before the query.
            $this->drupalGet($base . '/' . $i, array('alias' => TRUE));
            // assertUrl() does not work here, because the current url (node/1)
            // equals node/1 and equals also its alias. We want it to equal its
            // alias only.
            $url = $this->getUrl();
            global $base_url;
            $expected = $base_url . '/blog/' . $i . '/e' . strtolower($blogs[$i]);
            $this->assertEqual($url, $expected , format_string('Blog can be accessed using @base/x and will redirect correctly because the end url (@url) is equal to @expected.', array('@base' => $base, '@url' => $url, '@expected' => $expected)));
          }
        }
      }

      /*
       * Login as administrator role.
       *
       * This can be a useful for tests in your deployment module, especially
       * if you create several roles in a Feature dependency.
       *
       * @param $role = 'administrator'
       *   Log in as any role, or administrator by default.
       */
      public function loginAsRole($role = 'administrator') {
        // Get all of the roles in the system.
        $roles = user_roles();
        // Find the index for the role we want to assign to the user.
        $index = array_search($role, $roles);
        // Get the permissions for the role.
        $permissions = user_role_permissions(array(array_search($role, $roles) => $role));
        // Create the user with the permissions.
        $user = $this->drupalCreateUser(array_keys($permissions[$index]));
        // Assign the role.
        $user->roles[$index] = $role;
        // Log in as this user
        if (!($user = user_save($user))) {
          throw new Exception(format_string('cannot save user with role @r', array('@r' => $role)));
        }
        $this->drupalLogin($user);
      }

    }

Don't forget to reference your test in your .info file:

    ...
    files[] = dcycle_deploy.test
    ...

What are we doing in the automatic test, above?

Take a look at the `setUp()` function, which does everything required to create a new environment of this website. Because we have used a site deployment module, "everything" is simply a matter of enabling that module.

The key here is that whether the scenario works or not on any given environment (local, prod, etc.) is irrelevant: it needs to work based on a _known good starting point_. Databases are moving targets and it is thus irrelevant to test your code against an existing database (except if you want to monitor your production environment, which is a more advanced use case and outside the scope of this article). Therefore, we need to bring the throw-away testing database to a point where we can test run a test, and _know that our test will always yield the same result_. The concept of a known good starting point is discussed in the book [Continuous Delivery](http://www.amazon.com/Continuous-Delivery-Deployment-Automation-Addison-Wesley/dp/0321601912).

Given a new throw-away environment, `testModule()` now runs the test, defining a scenario which should work: we are logging in as an administrator, creating new blog posts (making sure to use foreign characters in the title), and then making sure the foreign characters are transliterated to ASCII characters and that our content redirects correctly when using only the ID. Let's enable Simpletest now and make sure our test is visible and fails:

    drush en simpletest -y

Now log into your site, and visit admin/config/development/testing, and run your test. If the desired functionality has not yet been developed, your test should fail.

Step five: make sure the test passes
====================================

At this point let's switch gears and focus our energy on making our test pass. This normally involves several code iterations, and running the test dozens of times, until it passes.

An important note for test-driven development: the initial test is an approximation, and may have to be modified during coding. The _spirit_ of the test, as opposed to the _letter_ of the test, should be conserved.

Test-driven development has the interesting side effect that it makes it easier for teams to collaborate: if I am working with a team in a different time zone, it is less error-prone for me to instruct them to "make the test work on branch xyz and then merge it to master", rather than explain everything I have in mind.

In the case of the task at hand, I wrote some custom code in a new module, `dcyclesite`, and then enabled some new modules and configuration. Don't forget, all operations which modify the database have to be done in update hooks. Here is a partial example of how my site deployment module's `.install` file looks after I made the test pass:

    /**
     * Enable some custom code
     */
    function dcycle_deploy_update_7022() {
      # this is where my custom code is; check my github code if you
      # are curious.
      module_enable(array('dcyclesite'));
    }

    /**
     * Pattern for articles
     */
    function dcycle_deploy_update_7023() {
      variable_set('pathauto_node_article_pattern', 'blog/[node:nid]/[node:title]');
    }

    /**
     * Enable transliteration
     */
    function dcycle_deploy_update_7024() {
      module_enable(array('transliteration'));
    }


Step six: make the test work _in the command line_
==================================================

Coming back to continuous deployment, we need our tests to be run every time code is pushed to our `master` branch, and running our tests will eventually be done by our Jenkins server.

The idea behind Jenkins is quite simple: run a script as a reaction to an event. The event is a change in the `master` branch. Jenkins, though, does not know how to fiddle around in a GUI. Therefore we must make it possible to run the tests in the command line. Fortunately this is quite easy:

    drush test-run dcyclesite

The above runs all tests in the test group "dcyclesite". Change "dcyclesite" to whatever your group name is. For tests to run correctly from the command line, you must make sure you `base_url` is set correctly in your `sites/default/settings.php` file. This depends on your environment but must reflect the URL at which your site is accessible, for example:

    $base_url = 'http://localhost:8888/mywebsite';

Now, running `drush test-run dcyclesite` should fail if there is a failing test. I normally develop code using Simpletest in the GUI, and use the command-line for regression testing in Jenkins.

Step seven: create a Jenkins job
================================

Now the fun starts: create a Jenkins job to continuously deploy. Simply put, we need our jenkins server to monitor the master branch of git, and if everything passes, move our code to the production branch, and, if we are feeling particularly confident in our tests, deploy to the production site.

Jenkins is one of the easiest pieces of software I have ever installed. You can probably get a CI server up and running in a matter of minutes by downloading the appropriate package on the [Jenkins website](http://jenkins-ci.org).

Once that is done, set up Jenkins:

 * Make sure the `jenkins` user on your Jenkins server has an SSH key pair, and has public-private SSH key access to both the git repo and the production server. Note that this will allow anyone with access to your Jenkins server to access your production server and your git repo, so apply security best practices to your Jenkins server!
 * In Jenkins's plugin manager page, install [the Git plugin](https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin) and the [post-build task plugin](http://wiki.hudson-ci.org/display/HUDSON/Post+build+task), which allows you to add a second script if the first script succeeds.

Now create a single job with the following attributes:

 * Source code management: git.
 * Source code repository URL: the complete URL to your git repo. If you get an error here, make sure you can access it via the command line (you might need to accept the server's fingerprint). In the "Advanced..." section, set the name of your repo to `origin`.
 * Branches to build: `master`.
 * Build triggers: Poll SCM every minute (type "* * * * *").
 * Add build step: execute shell: `drush test-run dcyclesite`. If you are on Mac OS X, you might have to add `[ $? = 0 ] || exit $?` as explained [here](http://mediatribe.net/en/node/79), otherwise your job will never fail.
 * Add post-build action "git publisher". Push only if build succeeds to the `prod` branch of your `origin`.
 * Add another action, "post-build task", selecting "Run script only if all previous steps were successful", and "Escalate script execution status to job status". This is a script to actually deploy your site.

In the last script, Jenkins will log into your remote site, pull the `prod` branch, and update your database. You might also want to backup your database here. In my case I have a separate job which periodically backs up my database. Here is some sample deployment code.

    # set the site to maintenance mode
    ssh me@example.com "cd /path/to/drupal && drush vset maintenance_mode 1 &&
    # get the latest version of the code
    git pull origin prod &&
    # update the database
    drush updb -y &&
    # set maintenance mode to off
    drush vset maintenance_mode 0 &&
    # finally clear the cache
    drush cc all"

Note that you can also use `rsync` if you don't want to have git on your production server. Whatever you use, the trick is for deployments to production to happen through Jenkins, not through a human.

Now save your job and run it. It won't work yet; don't worry, this is normal, we haven't finished yet.

Step Eight: make your Jenkins workspace a real Drupal site
==========================================================

To run tests, Jenkins will need a database, but we haven't yet set one up. It will also need HTTP access to its workspace. Let's do all this now.

Return to configure your Jenkins job, and in "Advanced project options", click "Advanced...". Click "Use custom workspace" and set a path which will be available via an URL. For example, if your Jenkins server is on your Mac and you are using MAMP, you can set this to `/Applications/MAMP/htdocs/mysite.jenkins`. This workspace will be available, for example, via `http://localhost:8888/mysite.jenkins/`.

Switch to your `jenkins` user and install a plain Drupal site with the Simpletest module:

    sudo su jenkins
    echo 'create database mysitejenkins' | mysql -uroot -proot
    drush si --db-url=mysql://root:root@localhost/mysitejenkins --account-name=root --account-pass=root

Note that you don't need to deploy your site here using `drush en example_deploy -y`: all this site really is needed for is hosting tests. So we just need a plain Drupal site, with simpletest enabled:

    drush en simpletest -y

Now set the base url of your workspace in `sites/default/settings.php`:

    $base_url = 'http://localhost:8888/mysite.jenkins';

Step Nine: Enjoy!
=================

That's basically all there is to it! However, because of the sheer number of steps involved, it is probable that you will run into a problem and need to debug something or other. I will appreciate hearing from you, noting any pitfalls and comments you may have. With the above steps in place, you will be able to make any change to the codebase, adding tests and function, test locally, and push to `master`. Then sit back and look at your Jenkins dashboard and your production site. If all goes well, you will see your job kick off, and after a few minutes, if you refresh your production site, you will see it is in maintenance mode. Some time later, your Jenkins job will end in success and your production site, _with your new code_, will be live again! Now bring your colleagues into the fold: this technique scales very well.
