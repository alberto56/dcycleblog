---
layout: post
title: Two tips for debugging Simpletest tests
author: admin
id: 88
created: 1423234378
tags:
  - blog
  - planet
permalink: /blog/88/two-tips-debugging-simpletest-tests/
redirect_from:
  - /blog/88/
  - /node/88/
---
I have been using Simpletest on Drupal 7 for several years, and, used well, it can greatly enhance the quality of your code. I like to practice [test-driven development](http://en.wikipedia.org/wiki/Test-driven_development): writing a failing test first, then run it multiple times, each time tweaking the code, until the test passes.

Simpletest works by spawning a completely new Drupal site (ignoring your current database), running tests, and destroying the database. Sometimes, a test will fail and you're not quite sure why. Here are two tips to help you debug why your tests are failing:

Tip #1: debug()
------

The Drupal [`debug()` function](https://api.drupal.org/api/drupal/includes!common.inc/function/debug/7) can be placed _anywhere in your test or your source code_, and the result will appear on the test  results page in the GUI.

For example, if when you are playing around with the dev version of your site, things work fine, but in the test, a specific node contains invalid data, you can add this line anywhere in your test or source code which is being called during your test:

    ...
    debug($node);
    ...

This will provide formatted output of your `$node` variable, alongside your test results.

Tip #2: die()
------

Sometimes the temporary test environment's behaviour seems to make no sense. And it can be frustrating to not be able to simply log into it and play around with it, because it is destroyed after the test is over.

To understand this technique, here is quick primer on how Simpletest works:

 * In Drupal 7, running a test requires a host site and database. This is basically an installed Drupal site with Simpletest enabled, and your module somewhere in the `modules` directory (the module you are testing does not have to be enabled).
 * When you run a test, Simpletest creates a brand-new installation of Drupal using a special prefix `simpletest123456` where `123456` is a random number. This allows Simpletest to have an isolated environment where to run tests, but on the same database and with the same credentials as the host.
 * When your test does something, like call a function, or load a page with, for example, `$this->drupalGet('user')`, the host environment is ignored and temporary environment (which uses the prefixed database tables) is used. In the previous example, the test loads the "user" page using a real HTTP calls. Simpletest knows to use the temporary environment because the call is made using a specially-crafted user agent.
 * When the test is over, all tables with the prefix `simpletest123456` are destroyed.

If you have ever tried to run a test on a host environment which already contains a prefix, you will understand why you can get "table name too long" errors in certain cases: Simpletest is trying to add a prefix to another prefix. That's one reason to avoid prefixes when you can, but I digress.

Now you can try this: somewhere in your test code, add `die()`, this will kill Simpletest, leaving the temporary database intact.

Here is an example: a colleague recently was testing a feature which exported a view. In the dev environment, the view was available to users with the role `manager`, as was expected. However when the test logged in as a `manager` user and attempted to access the view, the result was an "Access denied" page.

Because we couldn't easily figure it out, I suggested adding `die()` to play around in the environment:

    ...
    $this->drupalLogin($manager);
    $this->drupalGet('inventory');
    die();
    $this->assertNoText('denied', 'A manager accessing the inventory page does not see "access denied"');
    ...

Now, when the test was run, we could:

 * wait for it to crash,
 * then examine our database to figure out which prefix the test was using,
 * change the database prefix in `sites/default/settings.php` from `''` to (for example) `'simpletest73845'`.
 * run `drush uli` to get a one-time login.

Now, it was easier to debug the source of the problem by visiting the views configuration for `inventory`: it turns out that features exports views with access by role using the role ID, not the role name (the role ID can be different for each environment). Simply changing the access method for the view from "by role" to "by permission" made the test pass, and prevented a potential security flaw in the code.

(Another reason to avoid "by role" access in views is that User 1 often does not have the role required, and it is often disconcerting to be user 1 and have "access denied" to a view.)

So in conclusion, Simpletest is great when it works as expected and when you understand what it does, but when you don't, it is always good to know a few techniques for further investigation.
