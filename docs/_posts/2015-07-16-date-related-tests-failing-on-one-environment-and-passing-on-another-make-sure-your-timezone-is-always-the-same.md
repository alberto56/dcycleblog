---
layout: post
title: Date-related tests failing on one environment and passing on another? Make
  sure your timezone is always the same
author: admin
id: 98
created: 1437063892
tags:
  - blog
permalink: /blog/98/date-related-tests-failing-one-environment-and-passing-another-make-sure-your-timezone/
redirect_from:
  - /blog/98/
  - /node/98/
---
PHPUnit tests, or Drupal simpletests, are sometimes used to make sure your functions calculating date and times work correctly.

I recently had a failure on my continuous integration server where a year was one day more than it was supposed to be. On this environment, I was using PHPUnit directly on the server, not on a Vagrant VM or Docker container.

The problem turned out to be that the timezone setting was different on that environment.

Here is how to check and change the timezone settings in php.ini:

(1) start by locating your `php.ini` file:

    php --ini|grep Loaded
    Loaded Configuration File:         /etc/php.ini

In this case it's `/etc/php.ini`.

(2) figure out which timezone is being used:

    cat /etc/php.ini|grep timezone
    ; Defines the default timezone used by the date functions
    ; http://www.php.net/manual/en/datetime.configuration.php#ini.date.timezone
    date.timezone = UTC

In this case it's UTC. Note that the date.timezone line should not have a semi-colon (`;`) in front of it -- that's a comment, and in that case PHP will complain when you run time-related tests.

(3) do the above on all your environments, and if one is different from the others, change it to reflect the value on your production environment.

Of course, ideally you will have a "test" version of your production container or VM which contains PHPUnit or whatever testing tools you need, so you won't have different environments.
