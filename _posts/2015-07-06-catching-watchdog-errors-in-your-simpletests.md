---
layout: post
title: Catching watchdog errors in your Simpletests
author: admin
id: 96
created: 1436205896
tags:
  - blog
  - planet
permalink: /blog/96/catching-watchdog-errors-your-simpletests/
redirect_from:
  - /blog/96/
  - /node/96/
---
If you are using a [site deployment module](http://dcycleproject.org/blog/44/what-site-deployment-module), and running simpletests against it in your continuous integration server using `drush test-run`, you might come across Simpletest output like this in your Jenkins console output:

    Starting test MyModuleTestCase.                                         [ok]
    ...
    WD rules: Unable to get variable some_variable, it is not           [error]
    defined.
    ...
    MyModuleTestCase 9 passes, 0 fails, 0 exceptions, and 7 debug messages  [ok]
    No leftover tables to remove.                                           [status]
    No temporary directories to remove.                                     [status]
    Removed 1 test result.                                                  [status]
     Group  Class  Name

In the above example, the Rules module is complaining that it is misconfigured. You will probably be able to confirm this by installing a local version of your site along with `rules_ui` and visiting the rules admin page.

Here, it is `rules` which is logging a watchdog error, but it could by any module.

However, this will not necessarily cause your test to fail (see `0 fails`), and more importantly, your continuous integration script will not fail either.

At first you might find it strange that your console output shows `[error]`, but that your script is still passing. You script probably looks something like this:

    set -e
    drush test-run MyModuleTestCase

So: `drush test-run` outputs an `[error]` message, but is still exiting with the normal exit code of `0`. How can that be?

Well, your test is doing exactly what you are asking of it: it is asserting that certain conditions are met, but you have never explicitly asked it to fail when a watchdog error is logged within the temporary testing environment. This is normal: consider a case where you want to assert that a given piece of code logs an error. In your test, you will create the necessary conditions for the error to be logged, and then you will assert that the error has in fact been logged. In this case your test will fail if the error has not been logged, but will succeed if the error has been logged. This is why the test script should not fail every time there is an error.

But in our above example, we have no way of knowing when such an error is introduced; to ensure more robust testing, let's add a `teardown` function to our test which asserts that no errors were logged during any of our tests. To make sure that the tests don't fail when errors are expected, we will allow for that as well.

Add the following code to your Simpletest (if you have several tests, consider creating a base test for all of them to avoid reusing code):

    /**
     * {inheritdoc}
     */
    function tearDown() {
      // See http://dcycleproject.org/blog/96/catching-watchdog-errors-your-simpletests
      $num_errors = $this->getNumWatchdogEntries(WATCHDOG_ERROR);
      $expected_errors = isset($this->expected_errors) ? $this->expected_errors : 0;
      $this->assertTrue($num_errors == $expected_errors, 'Expected ' . $expected_errors . ' watchdog errors and got ' . $num_errors . '.');

      parent::tearDown();
    }

    /**
     * Get the number of watchdog entries for a given severity or worse
     *
     * See http://dcycleproject.org/blog/96/catching-watchdog-errors-your-simpletests
     *
     * @param $severity = WATCHDOG_ERROR
     *   Severity codes are listed at https://api.drupal.org/api/drupal/includes%21bootstrap.inc/group/logging_severity_levels/7
     *   Lower numbers are worse severity messages, for example an emergency is 0, and an
     *   error is 3.
     *   Specify a threshold here, for example for the default WATCHDOG_ERROR, this function
     *   will return the number of watchdog entries which are 0, 1, 2, or 3.
     *
     * @return
     *   The number of watchdog errors logged during this test.
     */
    function getNumWatchdogEntries($severity = WATCHDOG_ERROR) {
      $results = db_select('watchdog')
          ->fields(NULL, array('wid'))
          ->condition('severity', $severity, '<=')
          ->execute()
          ->fetchAll();
      return count($results);
    }

Now, all your tests which have this code will fail if there are any watchdog errors in it. If you are actually expecting there to be errors, then at some point in your test you could use this code:

    $this->expected_errors = 1; // for example
