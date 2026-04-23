---
layout: post
title: "Ddev, Drupal and Playwright"
date: 2026-04-23T14:43:30.853Z
id: 2026-04-23
author: admin
tags:
  - blog
permalink: /blog/2026-04-23/ddev-drupal-playwright/
redirect_from:
  - /blog/2026-04-23/
  - /node/2026-04-23/
---

This article will show how to integrate:

* [Drupal](https://www.drupal.org), a web platform
* [Ddev](https://ddev.com), a tool for local development, based on [Docker](https://www.docker.com)
* [Playwright](https://playwright.dev), a testing tool

Our goal
-----

Our goal is to ingrate automating end-to-end testing via to our web project. By that we mean:

* Developers should be able to define tests along with new functionality
* Teams should be able to set up continuous integration to run tests automatically, and pass or fail
* Tests should take less than fifteen minutes to run (or else teams tend to ignore them)

Accompanying git repo
-----

See <https://github.com/dcycle/starterkit-drupal-ddev/>.

An example
-----

* 1. We have a codebase for a blog website.
* 2. The client requests a new feature: "Anonymous users should see all published blog posts, by reverse published date, on the home page; administrators should see all articles, whether published or unpublished, there should be 5 articles per page."
* 3. Developer implements the feature along with a test, a new branch
* 4. The continuous integration server runs the tests on the new branch. If the tests pass, you are done; if the tests fail, back to step 3.

Prerequisites
-----

You will need a solid internet connection capable of downloading gigabytes of data (for example don't do this on an overnight ferry, as I learned the hard way). A VPN is also recommended if you are using public internet as some providers might block some of the necessary traffic.

Have a basic understanding of

* git
* the command line
* containers and Docker
* Drupal development
* The [Drush](https://www.drush.org/) command line tool

Additionnally, you will need to have ddev installed and at the latest available version:

Follow the [Ddev installation instructions](https://docs.ddev.com/en/stable/users/install/), after which you should be able to run:

    ddev -v

The version shown should be the [latest version on the GitHub repo](https://github.com/ddev/ddev/releases).

You should see something like:

    > ddev -v
    ddev version v1.25.1

But with the latest available version instead of 1.25.1.

*Not using the latest version of Ddev will probably cause all kinds of problems.*

Initial setup
-----

### Step 1: create a new Drupal project

Many teams will already have existing Drupal projects; if you'd like to follow along and understand the basic concepts, you might want to create a new project:

    mkdir /path/to/myproject
    cd /path/to/myproject
    ddev config --project-type drupal --docroot web

This creates a directory /path/to/myproject/.ddev which contains information about which containers are necessary to run your project, as well as other information about your project.

### Step 2: start your ddev containers

    cd /path/to/myproject
    ddev start

This uses the information in /path/to/myproject/.ddev to download the appropriate Docker images (such as the webserver and database server) and run your project.

See the "Troubleshooting" section if you are having issues.

### Step 3: install Drupal

    cd /path/to/myproject
    ddev composer create-project drupal/recommended-project

This fetches the Drupal source code and dependencies.

### Step 4: install Drush

    cd /path/to/myproject
    ddev composer require --dev drush/drush

This fetches the [Drush](https://www.drush.org/) command line tool for Drupal.

### Step 5: create your Drupal database

This creates a brand new Drupal installation. (See also "Using different databases", below.)

    cd /path/to/myproject
    ddev drush site:install -y

### Step 6: view your site locally

    cd /path/to/myproject
    ddev describe

You should see something like:

    https://myproject.ddev.site

Make sure you can see a Drupal site at that address with https enabled (although the certificate might be invalid). If not, or if you would like to have a valid certificate, follow the instructions to [configure browsers for ddev](https://docs.ddev.com/en/stable/users/install/configuring-browsers/).

Let's commit to git
-----

First, we need to determine what should not get committed to git by creating a file called /path/to/myproject/.gitignore.

Your team might have its own policies about what to ignore, but typically your /path/to/myproject/.gitignore file might contain:

    # Created by composr
    vendor
    # Created by composr
    web/core
    # Environment-specific
    web/sites/default/settings.php
    # Environment-specific
    web/sites/default/files
    # Created by composr
    web/modules/contrib
    # Created by composr
    web/themes/contrib
    # mac OS-specific
    .DS_Store
    # Anything else we don't want to commit can go in a
    # do-not-commit folder
    do-not-commit

Now you can create your first commit:

    git init
    git add .
    git commit -am 'Initial commit'

You can test what it's like to fetch a brand new version of your project by removing ignored files:

    git clean -dfX

At this point, your website will stop working until you install everything again:

    cd /path/to/myproject
    ddev start
    ddev composer install
    ddev drush site:install -y

See also "Using different databases", below.

Our first test
-----

Our first test should be as simple as possible, and should serve the purpose of making sure the site is deployed and that the testing system works.

In our case, we'll *make sure the words "Log in" appear on the home page of our site.

### Step 1: install Lullabot ddev-playwright

We will use [Lullabot ddev-playwright](https://github.com/Lullabot/ddev-playwright) to integrate Playwright tests into ddev.

    cd /path/to/myproject
    ddev add-on get Lullabot/ddev-playwright
    mkdir -p test/playwright
    ddev exec -d /var/www/html/test/playwright npm init playwright@latest

It will now ask you a bunch of questions. Let's use the defaults everywhere for this project. This will download some browsers such as Firefox and Chrome used for testing.

This next step installs Playwright:

    ddev install-playwright

If you are getting the error "sury.org signatures were invalid", see "Troubleshooting", below.

    git add .
    git commit -am 'Added Lullabot/ddev-playwright'

### Step 2: run the tests that ship with Lullabot/ddev-playwright

    ddev test

If all went well, this should give you a message to the effect that all tests passed.

The tests are in the /path/to/myproject/test/playwright/tests directory and all relate to the https://playwright.dev/ domain, so they are not testing our Drupal site yet.

/path/to/myproject/test/playwright/tests/example.spec.ts is just an example, so you can delete it if it works; in the next step we will create our own test.

### Step 3: create a test making sure the words "Log in" appear

Create a file /path/to/myproject/test/playwright/tests/login.spec.ts with the following content:

    import { test, expect } from '@playwright/test';

    test.use({
      ignoreHTTPSErrors: true,
    });

    test('home page has "Log in"', async ({ page }) => {
      await page.goto('https://myproject.ddev.site');
      await expect(page.locator('text=Log in')).toBeVisible();
    });

Run:

    ddev test

And confirm all is working locally, then commit everything:

    git add .
    git commit -am 'Added our test'

Continuous integration (CI)
-----

Whether you are using GitLab Actions, GitHub Actions, CircleCI, Jenkins or other CI tools, the concepts are the same, although the implementation will be different.

If this example we will use GitHub Actions.

The idea is for our test to be run every time we push any commit on any branch to our remote reposity, and to get feedback on whether a specific commit passes or fails.

A CI environment generally starts with a clean slate: just your code and some instructions on what to do with it. Specifically, it will not have a database set up or any composer dependencies installed.

## Step 1: have a script to deploy our site

Before running tests, CI must be able to locally deploy our site. To do that, let's create a script in /path/to/myproject/scripts/deploy.sh:

    #!/bin/bash
    ddev start
    ddev composer install
    ddev drush site:install -y
    ddev describe

For now this will create a brand new database, which we will eventually want to change (see "Using different databases" later on in this article).

## Step 2: tell GitHub actions how to run our tests

We also need to tell GitHub actions how to run our tests. For that we will create a file called /path/to/myproject/.github/workflows/test.yml:

    on: [push, pull_request]

    jobs:
      test:
        runs-on: ubuntu-latest
        steps:
          # Checkout the code
          - uses: actions/checkout@v5
          # Use https://github.com/ddev/github-action-setup-ddev
          # to set up Ddev on GitHub Actions.
          - name: Setup DDEV
            uses: ddev/github-action-setup-ddev@v1
          # Run our deploy script, which starts Ddev and installs Drupal
          - run: ./scripts/deploy.sh
          # Install playwright and browsers
          - run: ddev install-playwright
          # Run our tests
          - run: ddev playwright test

This file tells GitHub actions to perform a series of steps every time we push a commit or create a pull request, and they are described in the comments or are self-explanatory.

*It is important that your GitHub repo be named exactly as your local directory, in this example "myproject", otherwise our test will not be able to find the site at https://myproject.ddev.site.*

## Step 3: run the test on GitHub

Commit the above and push the whole thing to GitHub:

    git add .
    git commit -am 'Added CI configuration'
    git push

Now, on the GitHub interface, in the actions tab, you should see that the test is running. If all goes well, you should see that the test passed.

In our example the test took about 5 minutes, which is within the 15 minutes threshold that we set as a goal.

If it fails, happy debugging!

Using different databases
-----

Until now, our pipeline is the following:

* install the code via composer
* install a brand new database using `ddev drush site:install -y`
* test that (brand new site) site

However, our concept of a website is not a brand new Drupal site; rather, it is a combination of:

* code
* configuration (for example: module x should be active)
* the database (which can be upated with the latest configuration; and which also has content such as nodes and users)

Our feature defined in "An example", above, contains all three:

* the code is Drupal itself and views, or perhaps some custom code.
* the configuration is the blog content type and the views definition
* the database contains the blog posts themselves, some of which are published and others not

Our test needs all of the above to run.

We have three options to get there:

* Option 1: use a production database
* Option 2: rebuild the site from scratch for the test
* Option 3: include a stripped-down version of a database in git

All options are viable and can be useful for different teams. We will use Option 3 but here are the pros and cons of each:

### Option 1: use a production database

*Pros*:

* Our testing environment resembles production.

*Cons*:

* We need a safe mechanism for developers and a CI environment to fetch the production database.
* The state of the production database is not version-controlled and can change at any time.
* Our code is not very useful without access to an external non-version-controlled database; the code is not self-contained.

### Option 2: rebuild the site from scratch for the test

*Pros*:

* Our code is self-contained and can be tested without any external resource.

*Cons*:

* It can be hard to set up the system for testing, requiring multiple steps, and creating content and users before our test can be run.
* Slow

### Option 3: include a stripped-down version of a database in git

*Pros*:

* Our code is self-contained and can be tested without any external resource.
* Importing a database contained within git is fast

*Cons*:

* The database file can become large and unwieldy, and may need to be updated regularly to reflect changes in the code.

Keeping a stripped-down minimal starter database in git
-----

Because our code will change over time, we need an easy method to export our database from our codebase to our git repo.

Let's create a script to do that:

    mkdir -p ./scripts
    touch ./scripts/export-data.sh
    chmod +x ./scripts/export-data.sh

Here is a possible implementation of ./scripts/export-data.sh:

    #!/bin/bash
    rm -rf ./starter-data
    mkdir -p ./starter-data
    ddev drush sql:dump \
      --skip-tables-list=cache,cache_*,watchdog,search_index \
      --structure-tables-list=cache,cache_*,watchdog,search_index \
      >> ./starter-data/initial.sql
    docker cp ddev-starterkit-drupal-ddev-web:/var/www/html/web/sites/default/files ./starter-data/files
    # Get rid of stuff we don't want in our starter data
    rm -rf ./starter-data/files/.htaccess
    rm -rf ./starter-data/files/css
    rm -rf ./starter-data/files/js
    rm -rf ./starter-data/files/php
    rm -rf ./starter-data/files/styles
    rm -rf ./starter-data/files/sync

Let's go ahead and run that:

    ./scripts/export-data.sh

This is meant for developers who want to update the starter database. In theory, you don't need to do it that often, because most of the changes to the database will be configuration changes, which can be exported and imported via the Drupal configuration management system, and not content changes, which are what we are exporting here.

However, let's say you want to test a system which requires there to be blog posts in the database, you could use this script.

Modifying our deploy script to use the starter database, not create a new database
-----

./scripts/deploy.sh currently has this line:

    ddev drush site:install -y

Let's change that to use our starter database.

    ddev drush site:install minimal -y
    ddev drush sqlc < ./starter-data/initial.sql

Now let's deploy again:

    ./scripts/deploy.sh

At this point your site should be up and running with the content from your starter database.

Coding part of our example feature, and its test
-----

In "An example", above, we defined our feature as "A* 2. The client requests a new feature: "Anonymous users should see all published blog posts, by reverse published date, on the home page; administrators should see all articles, whether published or unpublished, there should be 5 articles per page.""

OK, so let's code this:

### Step 1: write a failing test

In good "test-driven-development" fashion, we will start by writing the test before writing the code: add a file called ./test/playwright/tests/article-list.spec.ts:

    import { test, expect } from '@playwright/test';

    test.use({
      ignoreHTTPSErrors: true,
    });

    test('Anonymous users see 5 latest published articles.', async ({ page }) => {
      await page.goto('https://starterkit-drupal-ddev.ddev.site');
      // Article 7 is unpublished, so it should not be visible to anonymous
      // users.
      await expect(page.locator('text=ArticleSeven')).toHaveCount(0);
      await expect(page.locator('text=ArticleSix')).toBeVisible();
      await expect(page.locator('text=ArticleTwo')).toBeVisible();
      // Only five articles per page, so article one should not be visible.
      await expect(page.locator('text=ArticleOne')).toHaveCount(0);
    });

Now let's run our test and make sure it fails:

    ddev playwright test

You might want to commit this on a new branch and push it to your CI server, making sure the branch fails there too.

### Step 2: creating the configuration and content for your feature

Start by adding 7 articles in order of creation date, with the following published status:

* ArticleOne (published)
* ArticleTwo (published)
* ArticleThree (published)
* ArticleFour (published)
* ArticleFive (published)
* ArticleSix (published)
* ArticleSeven (unpublished)

### Step 3: update our starter database with this mock content

    ./scripts/export-data.sh

### Step 4: implement the feature

This example is meant to be simple, so we will implement it with the Drupal core "views" module:

* Modify /admin/structure/views/view/frontpage/edit/page_1
* Remove the published filter and put the "Published or admin" instead
* Make sure we show 5 items per page

### Step 5: start using config management

You can store your config anywhere you like, but for this example we will store in in ./web/config, which, on your container, is the /var/www/html/web/config directory.

Let's create a script called ./scripts/export-config.sh:

    touch ./scripts/export-config.sh
    chmod +x ./scripts/export-config.sh

    #!/bin/bash
    mkdir -p ./web/config
    ddev drush config:export --destination=/var/www/html/web/config

We also need to import our config in our deploy script, so let's modify ./scripts/deploy.sh and add the following line to it, just after we import our database:

    ddev drush config:import -y --source=/var/www/html/web/config

### Step 6: confirm everything works for anonymous users

    ddev playwright test
    git add .
    git commit -am 'Anonymous users see the latest 5 published articles'

### Step 7: make sure our GitHub action passes

Pushing this now to GitHub, your GitHub action should pass. If not, happy debugging!

How does our test log in as an administrator?
-----

We could put a password like "admin" in our starter database, then have our test log in with that password. This poses the following security threat: Let's say we use the starter database to deploy a staging environment, and that staging environment is accessible from the internet. Then anyone could log in as administrator on that staging environment with the password "admin", which is not good. Even if the password is more complex, it is still against best practices to have it in our codebase.

So instead of running our tests like this:

    ddev playwright test

Let's create a new file which will modify the admin user's password just before running the tests, and then run the tests with that password:

    touch ./scripts/playwright-test.sh
    chmod +x ./scripts/playwright-test.sh

In that file:

    #!/bin/bash
    # Get a random password
    PASSWORD=$(openssl rand -base64 12)
    ddev drush upwd admin $PASSWORD
    # https://github.com/Lullabot/ddev-playwright/issues/77
    ddev exec -s web /bin/bash -c "export ADMIN_PASSWORD=$PASSWORD && cd test/playwright && yarn && yarn playwright test"

Finally, in .github/workflows/test.yml, replace:

    - run: ddev playwright test

with:

    - run: ./scripts/playwright-test.sh

Now let's modify ./test/playwright/tests/article-list.spec.ts and add this to it:

    test('Admins users see 5 latest articles, whether they are published or not.', async ({ page }) => {
      await page.goto('https://starterkit-drupal-ddev.ddev.site/user/login');
      await page.fill('input[name="name"]', 'admin');
      console.log('Using the password from the environment variable ADMIN_PASSWORD: ' + process.env.ADMIN_PASSWORD);
      await page.fill('input[name="pass"]', process.env.ADMIN_PASSWORD!);
      await page.click('input.form-submit');
      await page.click('text=Home');
      // Article 7 is unpublished, so it should not be visible to anonymous
      // users.
      // In admin mode there might be several items with the text ArticleSeven,
      // for example, which Playwright does not like. So we'll target instead
      // the link to the article, which is unique.
      await expect(page.locator('h2 a[href="/node/7"]')).toBeVisible();
      await expect(page.locator('h2 a[href="/node/6"]')).toBeVisible();
    });

Update your .gitignore, commit and push:

    echo "node_modules" >> .gitignore
    echo "yarn.lock" >> .gitignore
    git add .
    git commit -am 'Admins users see the latest 5 articles, whether they are published or not.'

Conclusion
-----

We have seen one approach to integrating Ddev, Drupal and Playwright, and how to set up a continuous integration pipeline to run our tests on GitHub actions. We have also seen how to keep a starter database in git, and how to use it in our deploy script.

The full code accompanying this blog post is at <https://github.com/dcycle/starterkit-drupal-ddev/>.

Troubleshooting
-----

### failed to CreateOrResumeMutagenSync on Mutagen sync

*First, make sure you are on the latest version of Ddev*.

[Mutagen](https://ddev.com/blog/mutagen-functionality-issues-debugging/) is a performance tool which excludes certain files from synchronization. It is designed to be transparent, but can sometimes cause issues. If you are getting this problem, try running:

    ddev mutagen reset
    ddev start

If this is still causing issues, you can can disable mutagen:

    ddev mutagen reset
    ddev config --performance-mode=none
    ddev start

Although I have found that to cause major performance issues. If you have done that and want to revert, you can run:

    ddev config --performance-mode=mutagen

to have a more verbose view of what is going on.

### sury.org signatures were invalid

This can happen during the "ddev install-playwright" step (see above).

https://github.com/Lullabot/ddev-playwright/issues/75

### Building project images takes forever

This can happen if you run `ddev install-playwright` in one terminal window, and `ddev start` in another terminal window at the same time. The solution is to run `ddev install-playwright` and wait for it to finish before running `ddev start`.

If `ddev start` still takes forever, you can run:

    ddev debug rebuild

In my case a slow internet connection was causing issues.

But the system also sometimes downloads all browsers even if they should theoretically have also been downloaded, not sure why.

See <https://github.com/ddev/ddev/issues/782> for fore info.

### Disk space warnings

`Your Docker install has only 2179480 available disk space, less than 5000000 warning level` or `no space left on device`.

If you get this, try:

   docker system prune

I have to do this regularly to avoid issues.

Resources
-----

* [Ddev installation instructions](https://docs.ddev.com/en/stable/users/install/)
* [Install Drupal Locally with DDEV for Drupal 7, 8, 9, 10, and 11, Drupalize Me; June 3, 2025](https://drupalize.me/tutorial/install-drupal-locally-ddev)
* [Lullabot ddev-playwright](https://github.com/Lullabot/ddev-playwright)
