---
layout: post
title: Basic test
id: 30
created: 1382646579
tags:
  - snippet
permalink: /blog/30/basic-test/
redirect_from:
  - /blog/30/
  - /node/30/
---
    <?php 
    /**
     * @file
     * mymodule.test
     * This file contains the testing code for this module
     */
    
    /**
     * The test case
     */
    class mymoduleTestCase extends DrupalWebTestCase {
      /**
       * Info for this test case.
       */
      public static function getInfo() {
        return array(
          'name' => t('mymodule: basic test'),
          'description' => t('describe test.'),
          'group' => 'mymodule',
        );
      }
    
      /*
       * Enable your module
       */
      public function setUp() {
        // set up a new site with default core modules, mymodule, and
        // dependencies.
        parent::setUp('mymodule');
      }
    
      /*
       * Test case for mymodule.
       */
      public function testModule() {
      }
    }
