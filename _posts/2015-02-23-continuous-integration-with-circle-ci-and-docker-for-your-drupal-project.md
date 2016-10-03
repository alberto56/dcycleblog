---
layout: post
title: Continuous integration with Circle CI and Docker for your Drupal project
author: admin
id: 92
created: 1424728709
tags:
  - blog
  - planet
permalink: /blog/92/continuous-integration-circle-ci-and-docker-your-drupal-project/
redirect_from:
  - /blog/92/
  - /node/92/
---
Continuous integration (CI) is the practice of running a series of checks on every push of your code, to make sure it is always in a potentially deployable state; and to make sure you are alerted as soon as possible if it is not.

Continuous integration and Drupal projects
-----

This blog post is aimed at module maintainers, and we'll look at how to use CI for modules hosted on Drupal.org. I'll use as an example a project I'm maintaining, [Realistic Dummy Content](https://www.drupal.org/project/realistic_dummy_content).

The good news is that Drupal.org has a built-in CI service for hosted modules: to use it, project maintainers need to click on the "Automated Testing" tab of their projects, enable automated testing, and make sure some tests are defined.

Once you have enabled automated testing, every submitted patch will be applied to the code and tested, and the main branches will be tested continually as well.

If you're not sure how to write tests, you can learn by example by looking at the test code of any module which has automated testing enabled.

Limitations of the Drupal.org QA system
-----

The system described above is great, and in this blog post we'll explore how to take it a bit further. Drupal's CI service runs your code on a new Drupal site with PHP 5.3 enabled. We know this by looking at [the log for a test on Realistic Dummy content](https://qa.drupal.org/pifr/test/787598), which contains:

    [13:50:02] Database backend [mysql] loaded.
    ...
    [simpletest.db] =>
    [test.php.version] => 5.3
    ...

For the sake of this article, let's say we want to use SQLite with php 5.5, and we also want to run checks from the [coder](https://www.drupal.org/project/coder) project's `coder_review` module. We can't achieve this within the Drupal.org infrastructure, but it is possible using [Docker](https://www.docker.com), [CircleCI](https://www.docker.com), and [GitHub](https://github.com). Here is how.

Step 1: get a local CoreOS+Docker environment
-----

Let's start by setting up a local development environment on which we can run Docker. Docker is a system which uses Linux containers to run your software and all its dependencies in an isolated environment.

If you need a primer on Docker, check out [Getting Started with Docker on Servers for Hackers (March 20, 2014)](https://serversforhackers.com/getting-started-with-docker/), and [A quick intro to Docker for a Drupal project](http://dcycleproject.org/blog/91/quick-intro-docker-drupal-project).

Docker works best on CoreOS, which you can install quite easily on any computer using Vagrant and VirtualBox, as explained at [Running CoreOS on Vagrant](https://coreos.com/docs/running-coreos/platforms/vagrant/).

Step 2: Add a Dockerfile to your project
-----

Because, in this example, we want to run tests which require changing things on the server, we'll use the Docker container management system to simulate a Ubuntu machine over which we have complete control.

To see how this works, download the latest dev version of `realistic_dummy_content` to your CoreOS VM, take a look at the included files `./Dockerfile` and `./scripts/test.sh` to see how they are structured, then run the test script:

    ./scripts/test.sh

Without any further configuration, you will see tests run on the desired environment: Ubuntu with the correct version of PHP, SQLite, and coder review. (You can also see the results on CircleCI [on the project's CI dashbaord](https://circleci.com/gh/alberto56/realistic_dummy_content/9) if you unfold the "test" section -- we'll see how to set that up for your project later on).

Setting up Docker for your own project is just a question of copy-pasting a few scripts.

Step 3: Make sure there is a mirror of your project on GitHub
-----

Having test results on your command line is nice, but there is no reason to run them yourself. For that we use continuous integration (CI) servers, which run the tests every time someone commits something to your codebase.

Some of you might be familiar with [Jenkins](https://jenkins-ci.org), which I use myself and which is great, but for open source projects, there are free CI services out there: the two I know of, [CircleCI](https://circleci.com) and [Travis CI](https://travis-ci.org), synchronize with GitHub, not with Drupal.org, so you need a mirror of your project on GitHub.

Note that it is possible, using the tool [HubDrop](http://hubdrop.org), to mirror your project on GitHub, but _it's not on your account_, whereas the CI tools sync only with projects on your own account. My solution has been to add a `./scripts/mirror.sh` script to Realistic Dummy Content, and call it once every ten minutes via a Jenkins job on my personal Jenkins server. If you don't have access to a Jenkins server you can also use a cron job on any server to do this.

The mirror of [Realistic Dummy Content](http://drupal.org/project/realistic_dummy_content) on GitHub is [here](https://github.com/alberto56/realistic_dummy_content).

Step 4: Open a CircleCI account and link it to your GitHub account
-----

As mentioned above, two of the CI tools out there are CircleCI and Travis CI. One of my requirements is that the CI tool integrate well with Docker, because that's my DevOps tool of choice.

As mentioned in [Faster Builds with Container-Based Infrastructure and Docker (Mathias Meyer, Travis CI blog, 17 Dec. 2014)](http://blog.travis-ci.com/2014-12-17-faster-builds-with-container-based-infrastructure/), it seems that Travis CI is moving towards Docker, but it seems that its new infrastructure is _based on Docker_, but does not let you run your own Docker containers.

Circle CI, on the other hand, seems to provide more flexibility with regards to Docker, as explained in the article [Continuous Integration and Delivery with Docker](https://circleci.com/docs/docker) on CircleCI's website.

Although Travis is a great, widely-used tool ([Drush uses it](https://travis-ci.org/drush-ops/drush)), we'll use CircleCI because I found it easier to set up with Docker.

Once you open a CircleCI account and link it to your GitHub account, you will be able to turn on CI for your mirrored project, in my case Realistic Dummy Content.

Step 5: Add a circle.yml file to your project
-----

In order for Circle CI to know what to do with your project, it needs a `circle.yml` file at the root of your project. If you look at the [`circle.yml` file at the root Realistic Dummy Content](http://cgit.drupalcode.org/realistic_dummy_content/tree/circle.yml), it is actually quite simple:

    machine:
      services:
        - docker

    test:
      override:
        - ./scripts/test.sh

That's it! Commit your circle.yml file, and if mirroring with GitHub works correctly, Circle CI will test your build. Debug any errors you may have, and _voilà!_

[Here is the result of a recent Realistic Dummy Content build on CircleCI](https://circleci.com/gh/alberto56/realistic_dummy_content/10): unfold the "test" section to see the complete output: PHP version, SQLite database, coder review...

Conclusion
-----

We have seen how you can easily add Docker support to make sure the tests and checks you run on your code are in a controlled environment, with the extensions you need (one could imagine a module which requires some external system like ApacheSolr installed on the server -- Docker allows this too). This is one concrete application of DevOps: reducing the risk of glitches where "tests pass on my dev machine but not on my CI server".
