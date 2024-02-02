---
layout: post
title:  "Fast-track local Drupal 8 core patch development and testing"
date:   2018-04-07
tags:
  - blog
  - planet
id: 2018-04-07
permalink: /blog/2018-04-07/fast-local-d8-core-patch-dev-testing/
redirect_from:
  - /blog/2018-04-07/
---

The process documented process for [setting up a local environment](https://www.drupal.org/dev-env) and [running tests locally](https://www.drupal.org/docs/8/phpunit/running-phpunit-tests) is, in my opinion, so complex that it can be a barrier to even determined developers.

For those wishing to locally test and develop core patches, I think it is possible to automate the process down to a few steps and few minutes; here is an example with a core issue, [#2273889 Don't use one language's plural index formula with another language's string in the case of untranslated strings using format_plural()](https://www.drupal.org/project/drupal/issues/2273889), which, at the time of this writing, results in the number 0 being displayed as 1 in certain cases.

Is it possible to start useful local development on this within 10 minutes on a computer with nothing installed except Docker? Let's try...

Step 1: install Docker
-----

Install and launch [Docker](https://store.docker.com/search?offering=community&type=edition). Everything we need, Apache web server, MySql server, Drush, Drupal, will reside on Docker containers, so we won't need to install anything locally except Docker.

Step 2: launch a dev environment
-----

I have create a [project hosted on GitHub](https://github.com/dcycle/drupal8_core_dev_helper) which will help you set up everything you need in Docker contains without local dependencies other than Docker, or any manual steps. Set it up by running:

    git clone https://github.com/dcycle/drupal8_core_dev_helper.git && \
      cd drupal8_core_dev_helper && \
      ./scripts/deploy.sh`

This will create everything you need: a webserver container and database container, and your Drupal core code which will be placed in ./drupal8_core_dev_helper/drupal; near the end of the output of ./scripts/deploy.sh, you will see **a login link to your development environment**. Confirm you can access that local development environment at an address like http://0.0.0.0:SOME-PORT. (The port is random.)

The first time you run this, it will have to download Docker images with Drupal, MySQL, and install everything you need for local development. Future runs will be a lot faster.

See the [project's README](https://github.com/dcycle/drupal8_core_dev_helper) for more details.

In your dev environment, you can confirm that the problem exists (provided the issue has not yet been fixed) by **following the instructions in the ["To reproduce this problem:"](https://www.drupal.org/project/drupal/issues/2273889) section of the issue description on your local development environment**.

Any calls to **drush** can be run on the Docker container like so:

    docker-compose exec drupal /bin/bash -c 'drush ...'

For example:

    docker-compose exec drupal /bin/bash -c 'drush en locale language -y'

If you want to run drush directly, you can connect to your container like so:

    docker-compose exec drupal /bin/bash

This will result in the following prompt _on the container_:

    root@4744431352a1:/var/www/html#

Now you can run drush commands directly on the container:

    drush eval "print_r(\Drupal::translation()->formatPlural(0, '1 whatever', '@count whatevers', array(), array('langcode' => 'fr')) . PHP_EOL);"

Because the drupal8_core_dev_helper project also pre-installs [devel](https://www.drupal.org/project/devel) on your environment, you can also confirm the problem exists by visiting /devel/php and executing:

    dpm((string) (\Drupal::translation()->formatPlural(0, '1 whatever', '@count whatevers', array(), array('langcode' => 'fr'))));

Whether you do this by Drush or /devel/php, the result should be the same if the issue has not been resolved: **1 whatever** instead of **0 whatevers**.

Step 3: get a local version of the patch and apply it
-----

In this example, we'll look at the patch [in comment #32 of our formatPlural issue, referenced above](https://www.drupal.org/project/drupal/issues/2273889#comment-12561748). If the issue has been resolved since this blog post has been written, follow along with another patch.

    cd drupal8_core_dev_helper
    curl https://www.drupal.org/files/issues/2018-04-07/2273889-31-core-8.5.x-plural-index-no-test.patch -O
    cd ./drupal && patch -p1 < ../2273889-31-core-8.5.x-plural-index-no-test.patch

You have now patched your local version of Drupal. You can try the "0 whatevers" test again and the bug should be fixed.

Running tests
-----

Now the real fun begins... and the "fast-track" ends.

For any patch to be considered for inclusion in Drupal core, it will need to (a) not break existing tests; and (b) provide a test which, without the patch, confirms that the problem exists.

Let's [head back to comment #32 of issue #2273889](https://www.drupal.org/project/drupal/issues/2273889#comment-12561748) and see if our patch is breaking anything. Clicking on "PHP 7 & MySQL 5.5 23,209 pass, 17 fail" will bring us to the [test results page](https://www.drupal.org/pift-ci-job/933418), which at first glance seems indecipherable. You'll notice that [our seemingly simple change to the PluralTranslatableMarkup.php file](https://www.drupal.org/files/issues/2018-04-07/2273889-31-core-8.5.x-plural-index-no-test.patch) is causing a number of tests to fail: HelpEmptyPageTest, EntityTypeTest...

Let's start by finding the test which is most likely to be directly related to our change by searching on the [test results page](https://www.drupal.org/pift-ci-job/933418) for the string "PluralTranslatableMarkupTest" (this is name of the class we changed, with the word Test appended), which shows that it is failing:

    Testing Drupal\Tests\Core\StringTranslation\PluralTranslatableMarkupTest
    .E

We need to figure out where that file resides, by typing:

    cd /path/to/drupal8_core_dev_helper/drupal/core
    find . -name 'PluralTranslatableMarkupTest.php'

This tells us it is at ./tests/Drupal/Tests/Core/StringTranslation/PluralTranslatableMarkupTest.php.

Because we have a predictable Docker container, we can relatively easily run this test locally:

    cd /path/to/drupal8_core_dev_helper
    docker-compose exec drupal /bin/bash -c 'cd core && \
      ../vendor/bin/phpunit \
      ./tests/Drupal/Tests/Core/StringTranslation/PluralTranslatableMarkupTest.php'

You should now see the test results for only PluralTranslatableMarkupTest:

    PHPUnit 6.5.7 by Sebastian Bergmann and contributors.

    Testing Drupal\Tests\Core\StringTranslation\PluralTranslatableMarkupTest
    .E                                                                  2 / 2 (100%)

    Time: 16.48 seconds, Memory: 6.00MB

    There was 1 error:

    1) Drupal\Tests\Core\StringTranslation\PluralTranslatableMarkupTest::testPluralTranslatableMarkupSerialization with data set #1 (2, 'plural 2')
    Error: Call to undefined method Mock_TranslationInterface_4be32af3::getStringTranslation()

    /var/www/html/core/lib/Drupal/Core/StringTranslation/PluralTranslatableMarkup.php:150
    /var/www/html/core/lib/Drupal/Core/StringTranslation/PluralTranslatableMarkup.php:121
    /var/www/html/core/tests/Drupal/Tests/Core/StringTranslation/PluralTranslatableMarkupTest.php:31

    ERRORS!
    Tests: 2, Assertions: 1, Errors: 1.

How to fix this, indeed _whether_ this will be fixed, is a whole nother story, a story fraught with dependency injection, mock objects, method stubs... More an adventure, really, than a story. An adventure which deserves to be told, just not right now.
