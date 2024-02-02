---
layout: post
title: Adding profiling to your D7 simpletests
author: admin
id: 110
created: 1461592254
tags:
  - snippet
permalink: /blog/110/adding-profiling-your-d7-simpletests/
redirect_from:
  - /blog/110/
  - /node/110/
---
If your simpletest code is taking forever to load a page, for example with $this->drupalGet(...), you might want to add profiling to see what's going on:

(1) Install Xdebug. For example, for Centos 6.x, you can run the following(*) with sudo:

    # see https://gist.github.com/kramarama/9695033
    yum -y install php-devel
    yum -y install php-pear
    yum -y install gcc gcc-c++ autoconf automake
    cat /etc/php.ini|grep xdebug || (pecl install xdebug-2.2.7 && echo [xdebug] >> /etc/php.ini && echo 'zend_extension="/usr/lib64/php/modules/xdebug.so"' >> /etc/php.ini && echo 'xdebug.remote_enable = 1' && >> /etc/php.ini && echo 'xdebug.profiler_enable_trigger =1' >> /etc/php.ini)
    apachectl restart

(2) download Webgrind to the root of your project

    cd /path/to/drupal/root && git clone https://github.com/jokkedk/webgrind.git

(3) temporarily hack Drupal core by applying the following patch. This tells Simpletest to profile all calls to drupalGet() (if you want to profile only _some_ calls to Drupal get, you could add some more code to target only certain pages, but I haven't tried that).

    --- a/modules/simpletest/drupal_web_test_case.php
    +++ b/modules/simpletest/drupal_web_test_case.php
    @@ -1936,6 +1936,10 @@ class DrupalWebTestCase extends DrupalTestCase {
        *   The retrieved HTML string, also available as $this->drupalGetContent()
        */
       protected function drupalGet($path, array $options = array(), array $headers = array()) {
    +    if (!isset($options['query'])) {
    +      $options['query'] = array();
    +    }
    +    $options['query']['XDEBUG_PROFILE'] = 1;
         $options['absolute'] = TRUE;

         // We re-using a CURL connection here. If that connection still has certain

(4) Now run your tests as usual.

If you want an even faster testing cycle, consider using [simpletest_turbo](https://www.drupal.org/project/simpletest_turbo).
