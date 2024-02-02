---
layout: post
title: 'Case study: installing mock objects for testing Drupal-Nuxeo synchronisation'
id: 38
created: 1384357278
tags:
  - blog
  - planet
permalink: /blog/38/case-study-installing-mock-objects-testing-drupal-nuxeo-synchronisation/
redirect_from:
  - /blog/38/
  - /node/38/
---
I recently inherited a Drupal project which periodically imported content from a [Nuxeo](http://www.nuxeo.com/en) server, synchronizing it with Drupal nodes, thus creating, updating and deleting nodes as need be. Nuxeo content was in no case modified by Drupal.

The Nuxeo server was set up by a third-party provider with whom I had no contact.

The site was not using mock objects or automated testing. A custom Drupal module was used, which leveraged the [CMIS](https://drupal.org/project/cmis) module.

A series of problems were occurring with the setup, among them:

 * Nuxeo Categories were supposed to map to Drupal taxonomy terms, but if a category was deleted from Nuxeo, the corresponding taxonomy term was not removed from the node in Drupal
 * If more than one category was added to a Nuxeo content, only the first was imported to Drupal
 * The site used what seemed like a [custom implementation](http://stackoverflow.com/questions/19684281) of the Nuxeo API, so it was hard to get help from the community. The custom implementation returns Nuxeo content IDs for some contents and Nuxeo revision IDs for others. After some testing, I did not manage to figure out in which circumstances content IDs or revision IDs were used.
 * The Nuxeo server's clock was a few minutes late, and the custom module was comparing timestamps rather than revision numbers. As a result, if a Nuxeo content was modified less than five minutes after its previous modification, synchronisation did not occur correctly.

These problems had a common symptom from the client's perspective: "synchronisation does not happen correctly". They also caused a common emotion: frustration.

In order to implement a robust fix, trial and error was not enough. Here are the steps I followed to reproduce the problems, implement testing, and finally fix them.

Step 1: Have a staging environment on the remote system
=======================================================

Making sure I had access to a "staging" nuxeo folder allowed me do do testing without messing up production data; I could also control the number of content items, making testing that much faster. This was a convenient stop-gap measure until I could set up mock objects and internal testing.

Step 2: Have a local dev environment of the site
================================================

This might go without saying, but of course you should have a local environment before attempting to modify Drupal. We use git for version control, and I just grabbed a copy of the production database to my local dev site. Because Drupal is only reading Nuxeo data, not modifying it, this is not too risky.

Step 3: Create a level of abstraction between Drupal and Nuxeo
==============================================================

Before setting up a true mock object for interaction with Nuxeo, I first had to set up a level of abstraction, in effect a sort of switch, between Drupal and Nuxeo. Later on I would plug in a mock object.

The [CMIS](https://drupal.org/project/cmis) module is not using automated testing, and does not seem to allow for any form of mocking or simulation, from what I can tell (a search of the strings 'mock', 'simulate', or 'simulation' came up empty for that project's code).

So now I had to decide between these two approaches:

 * provide a patch for CMIS providing mock object functionality.
 * provide a level of abstraction between the custom code and CMIS itself.

Because there is no real standard way (yet) to provide mock object functionality in Drupal modules, I have been using my own solution for a few projects: the [Mockable](https://drupal.org/project/mockable) module. Although I have released a beta version, the module is not widely used and I would rather wait for this or some other solution to be more accepted before submitting patches for third-party modules. I therefore decided to use Mockable between my own module and CMIS.

The Mockable module is not meant to be active on production sites. Here is how I used it:

First, I downloaded Mockable and activate the mockable module (but not the other modules in the Mockable project) on the local development site.
 
Then, I identified the lines of code in my custom module which interacted with an external system (in this case the [CMIS](https://drupal.org/project/cmis) module). Here is one example:

    ...
    $object = cmisapi_getProperties('default',$document_id);
    ...

`cmisapi_getProperties()` is defined in CMIS and I did not want to modify that module, so I am going to mock it instead.

I started by installing [Devel](https://drupal.org/project/devel), and calling my custom code from the devel/php page with different sets of data on my Nuxeo staging environment. Adding a var dump or `dpm()` call helped me figure out the structure of the response from cmisapi_getProperties() in different circumstances:

    ...
    $object = cmisapi_getProperties('default',$document_id);
    // this should be removed after testing. dpm() is defined in the devel
    // module.
    dpm($object);
    ...

Once I had a good idea of how this function works, I defined a new set of functions instead of calling cmisapi_getProperties() directly:

    ...
    $object = cmis_ms_get_properties('default',$document_id);
    ...
    
    /**
     * Mockable version of CMIS's cmisapi_getProperties().
     */
    function cmis_ms_get_properties($type, $document_id) {
      if (module_exists('mockable')) {
        // if the Mockable function is active, as it might be on testing
        // and dev environments (not on prod), then call cmisapi_getProperties()
        // or cmisapi_getProperties_mock() (if it exists) depending on whether
        // mocking is turned on or not.
        $return = mockable('cmisapi_getProperties', $address, $document_id);
      }
      else {
        $return = cmisapi_getProperties($address, $document_id);
      }
      return $return;
    }

Step 4: Create mock objects to simulate the external system
============================================================

Now that my abstraction layer was in place, all I had to do was define some functions and objects to replace, in my developement and continuous environments, those used in production.

    /**
     * Mock version of CMIS's cmisapi_getProperties(), which will be called
     * instead of cmisapi_getProperties() if the Mockable version is installed
     * and mocking is turned on (using drush mockable-set).
     */
    function cmis_ms_get_properties_mockable_mock($type, $document_id) {
      $return = new stdClass;
      ...
    
      // Do whatever you want here to best simulate all possible responses of
      // the real cmisapi_getProperties()
    
      return $return;
    }

`cmisapi_getProperties()` was not the only function which interacted with the third-party system. `new SoapClient($address, $options)` and other such calls were scattered across my code. I had to figure out how each of these worked and
mock them appropriately.

Your mock objects or mock functions can be as simple or complex as you need them to be. In my case I am using variables to switch between different simulated behaviours. For example, I can easily simulate a timeout or 500 error on my remote system.

Step 5: Reproduce a problem
===========================

Now that my mock function is in place, I can turn on mocking. With the Mockable module, this can be done with a GUI or with Drush:

    drush mockable-set

Starting now, I need to understand and reproduce exactly, in my mock object, how each error occurs.

In the case of taxonomy import problems, I can set `cmis_ms_get_properties_mockable_mock()` to always return two categories, and confirm that they don't get imported into Drupal.

Step 6: Write a failing test
============================

Reproducing the problem manually with a mock object is a step in the right direction, but we need to make sure that once it's fixed, it stays fixed. To do that I added the following .test file to my custom module (and linked to it in my .info file).

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
        parent::setUp('mymodule', 'mockable');
      }
    
      /*
       * Test case for mymodule.
       */
      public function testModule() {
        // start using mock objects
        mockable_set();
      
        // sync with our mock version of Nuxeo, in which documents all have
        // two categories. Note that before adding this function to a test,
        // I had to modify it to use mockable functions and objects instead
        // of always interacting with external servers. Because we called
        // mockable_set(), above, if we have correctly defined mock objects,
        // the external server should not be hit at this point. A good way
        // of making sure is to deactivate internet access during the local
        // test.
        mymodule_sync_nuxeo();
      
        $node = node_load(1);
      
        $taxonomy_count = count($node->field_tags[LANGUAGE_NONE]);
        $this->assertTrue($taxonomy_count == 2, format_string('We were expecting 2 taxonomy terms and we have obtained @count', array('@count' => $taxonomy_count)));
      }
    }

When I ran this test, I could confirm that the test failed because even though my mock object was defining two categories, only the first ended up as a taxonomy term on my node.

Step 7: Fix the test
====================

Now that I had a failing test, my job was to make sure the test passed. Now the trial and error phase can really being:

 1. Try something in code (note: both your test and your logic are "code").
 2. Run the test.
 3. If the test still fails, make sure your test's logic makes sense and go back to step 1.
 4. Do a manual test. If it fails, go back to step 1.
 5. If the test passes, do a manual test, commit your code and push to master.

Continuous integration
======================

To avoid this test being broken by another change in the future, you can set up a Continous integration server ([Jenkins](http://jenkins-ci.org), for example), and set it up so that it runs your test, and indeed all tests for your project, on each commit:

    drush test-run mymodule

Conclusion: what do we mean by "fixed"?
=======================================

Only once all of this is done, can we be confident to show our fix to the client, and mark it as fixed. A bug should be marked as fixed, or a new feature marked as done, when:

 * A test exists.
 * Mock objects are used to define external system behaviour.
 * The test passes.
 * Ideally, the test is checked with every new commit to avoid regressions.
