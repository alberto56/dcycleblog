---
layout: post
title: Converting an array to PHP code
author: admin
id: 109
created: 1456268919
tags:
  - snippet
permalink: /blog/109/converting-array-php-code/
redirect_from:
  - /blog/109/
  - /node/109/
---
In Drupal, we sometimes need to mock some legacy code which calls functions which in turn return large structured arrays. If we want to mock these, we can run the code on the production site, then output the result as php code which we can put in a mock function. Typically you would enable the devel module on a production-like site and call the function you want to mock, with this code:

    $data = call_to_my_legacy_function_which_should_be_mocked();
    $code = var_export((array)$data, true);
    dpm("<?php\n return " . preg_replace('/stdClass::__set_state/', '(object)', $code) . ';');

This will give you some actual php code which you can use to simulate what call_to_my_legacy_function_which_should_be_mocked() would return.

The above code is taken from [Convert JSON data to valid PHP code on NABITO.NET](http://www.nabito.net/convert-json-data-to-valid-php-code/).
