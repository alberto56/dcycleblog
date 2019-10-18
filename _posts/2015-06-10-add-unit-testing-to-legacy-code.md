---
layout: post
title: Add unit testing to legacy code
author: admin
id: 94
created: 1433947259
tags:
  - blog
  - planet
permalink: /blog/94/add-unit-testing-legacy-code/
redirect_from:
  - /blog/94/
  - /node/94/
---

**Edit, this blog post is deprecated, see [blog.dcycle.com/unit](https://blog.dcycle.com/unit) instead!**

To me, modern code must be tracked by a continuous integration server, and must have automated tests. Anything else is legacy code, even if it was rolled out this morning.

In the last year, I have adopted a policy of never modifying any legacy code, because even a one-line change can have unanticipated effects on functionality, plus there is no guarantee that you won't be re-fixing the same problem in 6 months.

This article will focus on a simple technique I use to bring legacy Drupal code under a test harness (hence transforming it into modern code), which is my first step before working on it.

Unit vs. functional testing
-----

If you have already written automated tests for Drupal, you know about Simpletest and the concept of functional web-request tests with a temporary database: the vast majority of tests written for Drupal 7 code are based on the `DrupalWebTestCase`, which builds a Drupal site from scratch, often installing something like a [site deployment module](http://dcycleproject.org/blog/44/what-site-deployment-module), using a temporary database, and then allows your test to make web requests to that interface. It's all automatic and temporary environments are destroyed when tests are done.

It's great, it really simulates how your site is used, but it has some drawbacks: first, it's a bit of a pain to set up: your continuous integration server needs to have a LAMP stack or spin up Vagrant boxes or Docker containers, you need to set up virtual hosts for your code, and most importantly, it's very time-consuming, because each test case in each test class creates a brand new Drupal site, installs your modules, and destroys the environment.

(I even had to [write a module, Simpletest Turbo](https://www.drupal.org/project/simpletest_turbo), to perform some caching, or else my tests were taking hours to run (at which point everyone starts ignoring them) -- but that is just a stopgap measure.)

Unit tests, on the other hand, don't require a database, don't do web requests, and are lightning fast, often running in less than a second.

This article will detail how I use unit testing on legacy code.

Typical legacy code
-----

Typically, you will be asked to make a "small change" to a function which is often 200+ lines long, and uses global variables, performs database requests, and REST calls to external services. But I'm not judging the authors of such code -- more often than not, `git blame` tells me that I wrote it myself.

For the purposes of our example, let's imagine that you are asked to make change to a function which returns a "score" for the current user.

    function mymodule_user_score() {
      global $user;
      $user = user_load($user->uid);
      $node = node_load($user->field_score_nid['und'][0]['value']);
      return $node->field_score['und'][0]['value'];
    }

This example is not too menacing, but it's still not unit testable: the function calls the database, and uses global variables.

Now, the above function is not very elegant; our first task is to ignore our impulse to improve it. Remember: we're not going to even touch any code that's not under a test harness.

As mentioned above, we could write a subclass of `DrupalWebTestCase` which provisions a database, we could create a node, a user, populate it, and then run the function.

But we would rather write a unit test, which does not need externalities like the database or global variables.

But our function _depends_ on externalities! How can we ignore them? We'll use a technique called *dependency injection*. There are several approaches to dependency injection; and Drupal 8 code supports it very well with PHPUnit; but we'll use a simple implementation which requires the following steps:

 * Move the code to a class method
 * Move dependencies into their own methods
 * Write a subclass replaces dependencies (not logic) with mock implementations
 * Write a test
 * Then, _and only then_, make the "small change" requested by the client

Let's get started!

Move the code to a class method
-----

For dependency to work, we need to put the above code in a class, so our code will now look like this:

    class MyModuleUserScore {
      function mymodule_user_score() {
        global $user;
        $user = user_load($user->uid);
        $node = node_load($user->field_score_nid['und'][0]['value']);
        return $node->field_score['und'][0]['value'];
      }
    }

    function mymodule_user_score() {
      $score = new MyModuleUserScore();
      return $score->mymodule_user_score();
    }


That wasn't that hard, right? I like to keep each of my classes in its own file, but for simplicity's sake let's assume everything is in the same file.

Move dependencies into their own methods
-----

There are a few dependencies in this function: `global $user`, `user_load()`, and `node_load()`. All of these are not available to unit tests, so we need to move them out of the function, like this:

    class MyModuleUserScore {
      function mymodule_user_score() {
        $user = $this->globalUser();
        $user = $this->user_load($user->uid);
        $node = $this->node_load($user->field_score_nid['und'][0]['value']);
        return $node->field_score['und'][0]['value'];
      }

      function globalUser() {
        return global $user;
      }

      function user_load($uid) {
        return user_load($uid);
      }

      function node_load($nid) {
        return node_load($nid);
      }

    }

Your dependency methods should generally only contain one line. The above code should behave in exactly the same way as the original.

Override dependencies in a subclass
-----

Our next step will be to provide mock versions of our dependencies. The trick here is to make our mock versions return values which are expected by the main function. For example, we can surmise that our user is expected to have a `field_score_nid`, which is expected to contain a valid node id. We can also make similar assumptions about how our node is structured. Let's make mock responses with these assumptions:

    class MyModuleUserScoreMock extends MyModuleUserScore {
      function globalUser() {
        return (object) array(
          'uid' => 123,
        );
      }

      function user_load($uid) {
        if ($uid == 123) {
          return (object) array {
            field_score_nid => array(
              LANGUAGE_NONE => array(
                array(
                  'value' => 234,
                ),
              ),
            ),
          }
        }
      }

      function node_load($nid) {
        if ($nid == 234) {
          return (object) array {
            field_score => array(
              LANGUAGE_NONE => array(
                array(
                  'value' => 3000,
                ),
              ),
            ),
          }
        }
      }

    }

Notice that our return values are not meant to be complete: they only contain the minimal data expected by our function: our mock user object does not even contain a `uid` property! But that does not matter, because our function is not expecting it.

Write a test
-----

It is now possible to write a unit test for our logic without requiring the database. You can copy the contents of [this sample unit test](http://dcycleproject.org/blog/basic-unit-test) to your module folder as mymodule.test, add `files[] = mymodule.test` to your `mymodule.info`, enable the `simpletest` modules and clear your cache.

There remains the task of actually writing the test: in your `testModule()` function, the following lines will do:

    public function testModule() {
      // load the file or files where your classes are located. This can
      // also be done in the setUp() function.
      module_load_include('module', 'mymodule');

      $score = new MyModuleUserScoreMock();
      $this->assertTrue($score->mymodule_user_score() == 3000, 'User score function returns the expected score');
    }

Run your test
-----

All that's left now is to run your test:

    php ./scripts/run-tests.sh --class mymoduleTestCase

Then add above line to your continuous integration server to make sure you're notified when someone breaks it.

Your code is now ready to be fixed
-----

Now, when your client asks for a small or big change, you can use test-driven development to implement it. For example, let's say your client wants all scores to be multiplied by 10 (30000 should be the score when 3000 is the value in the node):

 * First, modify your unit test to make sure it fails: make the test expect 30000 instead of 3000
 * Next, change your code iteratively until your test passes.

What's next
-----

This has been a very simple introduction to dependency injection and unit testing for legacy code: if you want to do even more, you can make your Mock subclass as complex as you wish, simulating corrupt data, nodes which don't load, and so on.

I highly recommend getting familiar with PHPUnit, which is part of Drupal 8, and which takes dependency injection to a whole new level: Juan Treminio's ["Unit Testing Tutorial Part I: Introduction to PHPUnit", March 1, 2013](https://jtreminio.com/2013/03/unit-testing-tutorial-introduction-to-phpunit/) is the best introduction I've found.

I do not recommend doing away entirely with functional, database, and web tests, but a layered approach where most of your tests are unit tests, and you limit the use of functional tests, will allow you to keep your test runs below an acceptable duration, making them all the more useful, and increasing the overall quality of new and even legacy code.
