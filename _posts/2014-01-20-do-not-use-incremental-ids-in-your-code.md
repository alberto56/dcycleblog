---
layout: post
title: Do not use incremental IDs in your code
id: 50
created: 1390230486
tags:
  - blog
  - planet
permalink: /blog/50/do-not-use-incremental-ids-your-code/
redirect_from:
  - /blog/50/
  - /node/50/
---
Drupal uses incremental IDs for such data as taxonomy terms and nodes, but not content types or vocabularies. If, like me, you believe your site's codebase should work with different environments and different databases, your incremental IDs can be different on each environment, causing your code to break.

But wait, you are thinking, I have only one environment: my production environment. 

Even if such is the case, there are advantages to be able to spawn new environments independently of the production environment [without cloning the database upstream](http://dcycleproject.org/blog/48):

 * Everything you need to create your website, minus the content, is under version control. The production database, being outside version control, should not be needed to install a new environment. See also "[what is a deployment module?](http://dcycleproject.org/blog/44)".
 * New developers can be up and running with a predictable environment and dummy content.
 * Your automated tests, using Drupal's Simpletest, by default deploy a new environment without cloning the database.
 * For predictable results in your continuous integration server, it is best to deploy a new envrionment. The production database is unpredictable and unversioned. If you test it, your test results will be unpredictable as well.
 * Maybe in the future you'll need a separate version of your site with different data (for a new market, perhaps).

Even if you choose to clone the database upstream for development, testing and continuous integration, it is still a good idea to avoid referencing incremental IDs of a particular database, because at some point you might decide that it is important to be able to have environments with different databases.

Example #1: using node IDs in CSS and in template files
-------------------------------------------------------

I have often seen this: particular pages (say, nodes 56 and 400) require particular markup, so we see template files like `page--node--56.tpl.php` and css like this:

    .page-node-56 #content,
    .page-node-400 #content {
       ...
    }

When, as developers, we decide to use this type of code on a website, we are tightly coupling our code, which is under version control, to our database, which is not under version control. In other words our project as a whole can no longer be said to be versioned as it requires a database clone to work correctly.

Also, this creates all sorts of problems: if, for example, a new node needs to be created which has the same characteristics as nodes 56 and 400, one must fiddle with the database (to create the node) _and_ the code. Also, creating automatic tests for something like this is hard because the approach is not based on underlying logic.

A better approach to this problem might be to figure out _why_ nodes 56 and 400 are somehow different than the others. The solution will depend on your answer to that question, and maybe these nodes need to be of a different content type; or maybe some other mechanism should be used. In all cases, though, their ID should be irrelevant to their specificity.

Example #2: filtering a view by taxonomy tag
--------------------------------------------

You might have a website which uses Drupal's default implementation of articles, with a tag taxonomy field. You might decide that all articles tagged with "blog" should appear in your blog, and you might create a new view, filtered to display all articles with the "blog" tag.

Now, you might export your view into a [feature](https://drupal.org/project/features) and, perhaps, make your feature a dependency of a [site deployment module](http://dcycleproject.org/blog/44) (so that enabling this module on a new environment will deploy your blog feature, and do everything else necessary to make your site unique, such as enabling the default theme, etc.).

It is important to understand that with this approach, you are in effect putting an incremental ID into code. You view is in fact filtering by the _ID of the "blog" taxonomy term as it happens to exist on the site used to create the view_. When creating the view, we have no idea what this ID is, but we are saying that in order for our view to work, the "blog" taxonomy term needs to be identical on all environments.

Here is an example of how this bug will play out:

 * This being the most important feature of your site, when creating new environments, the "blog" taxonomy term might always have the ID 1 because it is the first taxonomy term created; you might also be in the habit of cloning your database for new environments, in which case the problem will remain latent.
 * You might decide that such a feature is too "simple" to warrant automated testing; but even if you do define an automated test, your test will run on a new database and will need to create the "blog" taxonomy term in order to validate. Because your tests are separate and simple, the "blog" taxonomy term is probably the only term created during testing, so it, too will have ID 1, and thus your test will pass.
 * Your continuous integration server which monitors changes to your versioned code will run tests against every push, but, again, on a new database, so your tests will pass and your code will be fine.

This might go on for quite some time until, on a given environment, someone decides to create another term _before_ creating the "blog" term. Now the "blog" term will have ID #2 which will break your feature.

Consider, furthermore, that your client decides to create a new view for "jobs" and use the same tag mechanism as for the blog; and perhaps other tags as well. Before long, your entire development cycle becomes dependent on database cloning to work properly.

To come up with a better approach, it is important to understand what we are trying to accomplish; and what taxonomy terms are meant to be used for:

 * The "blog" category here is somehow, logically, immutable and means something very specific. Furthermore, the existence of the blog category is required for our site. Even if its name changes, the _key_ (or underlying identity) of the blog category should always be the same.
 * Taxonomy terms are referenced with incremental IDs (like nodes) and thus, when writing our code, their IDs (and even their existence) cannot be counted upon. 

In this case, we are using taxonomy terms for the wrong purpose. Taxonomy terms, like nodes, are meant to be potentially different for each environment: _our code should not depend on them_.

A potential solution in this case would be to create a new field for articles, perhaps a multiple selection field, with "blog" as one of the possible values. Now, when we create a view filtered by the value "blog" in our new field, we are no longer referencing an incremental ID in our code.

I myself made this very mistake with my own website code without realizing it. The code for this website (the one you are reading) is available on Github and the issue for this problem is [documented here](https://github.com/alberto56/dcyclesite/issues/3) (I'll try to get around to fixing it soon!).

Deploying a fix to an existing site
-----------------------------------

If you apply these practices from the start of a project, it is relatively straightforward. However, what if a site is already in production with several articles already labelled "blog" (as is the case on the Dcycle website itself)? In this case we need to incrementally deploy the fix. For this, a [site deployment module](http://dcycleproject.org/blog/44) can be of use: in your site deployment module's `.install` file, you can add a new update hook to update all your existing articles labelled "blog", something like:

    /**
     * Use a machine name rather than an incremental ID to display blog items.
     */
    function mysite_deploy_update_7010() {
      // deploy the new version of the view to the target site
      features_revert(array('mysite_feature' => array('views_view')));
      ...
      // cycle through your nodes and add "blog" to your new field for any
      // content labelled "blog".
    }

Of course, you need to test this first with a clone of your production site, perhaps even adding an automatic test to make sure your function works as expected. Also, if you have _a lot_ of nodes, you might need to use the "sandbox" feature of [hook_update_n()](https://api.drupal.org/api/drupal/modules!system!system.api.php/function/hook_update_N/7), to avoid timeouts.

Once all is tested, all that needs to be done, on each environment (production, every developer's laptop, etc.), is run `drush updb -y` on the command line.

Conclusion
----------

Drupal makes it very easy to mix incremental IDs into views and code, and this will work well if you always use the same database on every environment. However, you will quickly run into problems if you want to write automated tests or deploy new sites without cloning the database. Being aware of this can help you write more logical, consistent and predictable code.
