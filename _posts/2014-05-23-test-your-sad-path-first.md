---
layout: post
title: Test your sad path first
id: 63
created: 1400863194
tags:
  - blog
  - planet
permalink: /blog/63/test-your-sad-path-first/
redirect_from:
  - /blog/63/
  - /node/63/
---
One of the techniques I use to make sure I write tests is to write them before I do anything else, which is known as test-driven development. If you develop your functionality before writing a test, in most cases you will never write the test to go with it, because you will be pressured to move on to new features.

I have found, though, that when writing tests, our team tends to think only about the happy path: what happens if everything goes according to plan.

Let me give an quick example: let's say you are developing a donation system for anonymous users to make donations on your site. The user story calls for a form where a donation amount can be entered before redirecting the user to the payment form. Using test-driven development and Drupal's Simpletest framework, we might start by writing something like this in our [site deployment module](http://dcycleproject.org/node/44)'s `.test` file:

    // @file mysite_deploy.test

    class MysiteDonate extends DrupalWebTestCase {

      ...

      public function testSite() {

        $edit = array(
          'amount' => 420,
        );
        ...
        $this->drupalPost('donate', $edit, 'Donate now!');
        ...
        $this->assertText('You are about to donate $420', 'The donation amount has been recorded');
      }

      ...
    }

When you first run this test it will fail, and your job as a developer will be to make this test pass. That's test-driven development.

The problem with this approach is that it only defines the happy path: what should happen when all goes according to plan. It makes no provision for the sad path: what happens if a user puts something other than a number? What happens if 0 is entered? These are known as sad paths, and most teams never think about them until they occur (human nature, I guess).

To make sure we think about the sad path, I start by making sure the right questions are asked during our Agile sprint planning sessions. In the case of the "donation" user story mentioned above, the following business questions should be asked during sprint planning:

 * What's the minimum donation? Obviously it should not be possible to donate $0, but is $0.01 OK?
 * Is there a maximum donation? Should the system bring you to the checkout page if you enter 1 billion dollars in the donation box?

Often, the client will not have thought of that, and will answer something like: sure there should be a minimum and a maximum, and we also want site administrators to be able to edit those. Let's say the team agrees on this (and the extra work it entails), the admin interface too should be tested.

Once the sprint planning session is over, I will start by writing the test based on business considerations above, and also integrating other sad paths I can think of, into my test.

Here is what our test might look like now, assuming we have a `setUp()` function which enables our [site deployment module](http://dcycleproject.org/node/44) and dependent features (including roles); and we are using the `loginAsRole()` method, [documented here](http://dcycleproject.org/blog/45):

    // @file mysite_deploy.test

    class MysiteDonate extends DrupalWebTestCase {

      ...

      public function testSite() {

        // Manage minimum and maximum donation amounts.
        $this->drupalGet('admin/options');
        $this->assertText('Access denied', 'Non-admin users cannot access the configuration page');
        $this->loginAsRole('administrator');
        $edit = array(
          'minimum' => '50',
          'maximum' => $this->randomName(),
        );
        $this->drupalPost('admin/option', $edit, 'Save');
        $this->assertText('Minimum and maximum donation amounts must be numeric');
        $edit['maximum'] = '40';
        $this->drupalPost('admin/option', $edit, 'Save');
        $this->assertText('Minimum amount must be equal to or less than maximum donation amount');
        $edit['maximum'] = '30';
        $this->drupalPost('admin/option', $edit, 'Save');
        $this->assertText('Minimum maximum donation amounts have been saved');
        $this->drupalLogout();

        // Make a donation, sad path
        $edit = array(
          'amount' => '<script>alert("hello!")</script>',
        );
        $this->drupalPost('donate', $edit, 'Donate now!');
        $this->assertText('Donation amount must be numeric', 'Intercept non-numeric input.');
        $edit['amount'] = 29;
        $this->drupalPost('donate', $edit, 'Donate now!');
        $this->assertText('Thanks for your generosity, but we do not accept donations below $30.');
        $edit['amount'] = 41;
        $this->drupalPost('donate', $edit, 'Donate now!');
        $this->assertText('Wow, $41! Do not do this through our website, please contact us and we will discuss this over the phone.');

        // Make a donation, happy path
        $edit['amount'] = 30;
        $this->drupalPost('donate', $edit, 'Donate now!');
        $this->assertText('You are about to donate $30', 'The donation amount has been recorded');
      }

      ...
    }

The above example is a much more complete portrait of what your site should do, and documenting everything in a failing test even before you or someone else starts coding ensures you don't forget validations and the like.

One interesting thing to note about our complete test is that sad paths actually take up _a lot_ more effort than the happy path. There are many advantages to thinking of them first:

 * The client can be involved in making business decisions which can affect the sad path.
 * The entire team (including the client) is made aware as early as possible about sad path considerations, and the extra work they entail.
 * Nothing is taken for granted as obvious: time is set aside for sad path development.
 * The sad path becomes an integral part of your user story which can be part of the demo. Often in Agile sprint reviews, if no one has ever thought of the sad path, only the happy path is demonstrated.
 * There is less technical debt associated with sad path development: you are less likely to get a panicked call from your client once your site goes live about getting dozens of 50 cent donations when the payment processor is taking a dollar in fees.
 * Your code will be more secure: you will think about how your system can be hacked and integrate hacking attempts (and the appropriate response) directly into your test.
 * You will be more confident putting a failing test on a feature branch and handing it to junior developers: they will be less likely to forget something.
 * Thinking of the sad path can make you reconsider how to define your features: a contact form or commenting system can seem trivial when you only think of the happy path. However, when you take into account how to deal with spam, you might decide to not allow comments at all, or to allow only authenticated users to post comments or use the contact form.

Note that as in all test-driven development, your test is not set in stone. It is like any other code: developers can modify it as long as they follow the spirit of your test. For example, maybe your config page is not `admin/option` but something else. Developers should feel that they own the test and can change it to fit the real system.
