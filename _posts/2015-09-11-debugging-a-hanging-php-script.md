---
layout: post
title: Debugging a hanging PHP script
author: admin
id: 100
created: 1441994905
tags:
  - blog
permalink: /blog/100/debugging-hanging-php-script/
redirect_from:
  - /blog/100/
  - /node/100/
---
I installed a script called `test.php` on a Vagrant box with CentOS 6.x and PHP 5.3. I made my script available at `http://example.local/test.php` and it contains:

    <?php

    function whatever() {
      sleep(1);
    }

    while (TRUE) {
      whatever();
    }

When I access this page, it just loads forever, as would be expected.

Here is one way to debug this:

Start by downloading the Xdebug extension

    cd
    sudo pecl install xdebug-2.2.7

If you get "phpize not found", then run:

    yum install php-devel

and try installing again.

Figure out the path of your xdebug `.so` file, like this:

    find / -name 'xdebug.so' 2>/dev/null

This will give something like this:

    /usr/lib64/php/modules/xdebug.so

Now, figure out where your php.ini file is:

    php --ini|grep Loaded

This will give you something like:

    Loaded Configuration File:         /etc/php.ini

Add these lines to the end of that file:

    zend_extension=/usr/lib64/php/modules/xdebug.so
    xdebug.profiler_enable = 1;
    xdebug.profiler_output_dir = "/tmp"

Now restart Apache:

    sudo apachectl restart

Download Webgrind in the same directory as test.php.

    git clone https://github.com/jokkedk/webgrind.git

Now visit `http://example.local/test.php`, and it will hang.

To figure out why it's hanging, on another page go to `http://example.local/webgrind`, and click "Update" periodically. A list of costly functions (in this case `whatever()` and `sleep()`) will be shown.

<img src="http://dcycleproject.org/sites/dcycleproject.org/files/screen_shot_2015-09-11_at_1.09.25_pm.png" />
