---
layout: post
title: Basic Unit test
id: 37
created: 1383583055
tags:
  - snippet
permalink: /blog/basic-unit-test/
redirect_from:
  - /blog/37/
  - /node/37/
---

**Edit, this blog post is deprecated, see [blog.dcycle.com/unit](https://blog.dcycle.com/unit) instead!**

Unit tests are faster than functional tests and don't require the database.

    <?php 
    /**
     * @file
     * This file contains the testing code for this module
     */
    
    /**
     * The test case
     */
    class mymoduleTestCase extends DrupalUnitTestCase {
      /**
       * Info for this test case.
       */
      public static function getInfo() {
        return array(
          'name' => t('mymodule: basic unit test'),
          'description' => t('describe test.'),
          'group' => 'mymodule',
        );
      }
    
      public function setUp() {
        // specifically include files which contain functions to test.
        module_load_include('module', 'mymodule');
        parent::setUp();
      }
    
      /*
       * Test case for mymodule.
       */
      public function testModule() {
      }
    }
