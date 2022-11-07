---
layout: post
title: What is content? What is configuration?
author: admin
id: 83
created: 1417619932
tags:
  - blog
  - planet
permalink: /blog/83/what-content-what-configuration/
redirect_from:
  - /blog/83/
  - /node/83/
---
What is content? What is configuration? At first glance, the question seems simple, almost quaint, the kind one finds oneself patiently answering for the benefit of Drupal novices: content is usually information like nodes and taxonomy terms, while  content types, views and taxonomy vocabularies are usually configuration.

Content lives in the database of each environment, we say, while configuration is exportable via Features or other mechanisms and should live in the Git repo (this has been called code-driven development).

Still, a definition of content and configuration is naggingly elusive: why "usually"? Why are there so many edge cases? We're engineers, we need precision! I often feel like I'm trying to define what a bird is: every child knows what a bird is, but it's hard to define it. Ostriches can't fly; platypuses lay eggs but aren't birds.

Why the distinction?
--------------------

I recently saw an interesting comment titled "[A heretic speaks](http://agaric.com/comment/1499#comment-1499)" on a blog post about code-driven development. It sums up some of the uneasiness about the place of configuration in Drupal: "Drupal was built primarily with site builders in mind, and this is one reason [configuration] is in the database".

In effect, the primary distinction in Drupal is between code (Drupal core and config), and the database, which contains content types, nodes, and everything else.

As more complex sites were being built, a new distinction had to be made between two types of information in the database: configuration and content. This was required to allow development in a dev-stage-production workflow where _features_ being developed outside of a production site could be deployed to production without squashing the database (and existing comments, nodes, _and the like_). We needed to move those features into code and we called them "configuration".

Thus the [features](https://www.drupal.org/project/features) module was born, allowing views, content types, and vocabularies (but not nodes and taxonomy terms) to be developed outside of the database, and then deployed into production.

Drupal 8's [config management system](http://blog.dcycle.com/blog/68/approach-code-driven-development-drupal-8) takes that one step further by providing a mature, central API to deal with this.

The devil is in the details
---------------------------

This is all fine and good, but edge cases soon begin to arise:

 * What about an "About us" page? It's a menu item (deployable) linking to a node (content). Is it config? Is it content?
 * What about a "Social media" menu and its menu items? We want a Facebook link to be deployable, but we don't want to hard-code the actual link to our client's Facebook page (which _feels_ like content) -- we probably don't even know what that link is during development.
 * What about a block whose placement is known, but whose content is not? Is this content? Is it configuration?
 * What about a view which references a taxonomy term id in a hard-coded filter. We can export the view, but the taxonomy term has an incremental ID ans is not guaranteed to work on all environments.

The wrong answer to any of these questions can lead to a misguided development approach which will come back to haunt you afterward. You might wind up using [incremental IDs in your code](http://blog.dcycle.com/blog/50/do-not-use-incremental-ids-your-code) or deploying something as configuration which is, in fact, content.

Defining our terms
------------------

At the risk of irking you, dear reader, I will suggest doing away with the terms "content" and "configuration" for our purposes: they are just too vague. Because we want a formal definition with no edge cases, I propose that we use these terms instead (we'll look at each in detail a bit further on):

 * **Code**: this is what our deliverable is for a given project. It should be testable, versioned, and deployable to any number of environments.
 * **Data**: this is whatever is potentially different on each environment to which our code is deployed. One example is comments: On a dev environment, we might generate thousands of dummy comments for theming purposes, but on prod there might be a few dozen only.
 * **Placeholder content**: this is any data which should be created as part of the installation process, meant to be changed later on.

Code
----

This is what our deliverable is _for a given project_. This is important. There is no single answer. Let's take the following examples:

 * If I am a contributor to the [Views](https://www.drupal.org/project/views) contrib project, my _deliverable_ is _a system which allows users to create views in the database_. In this case I will not export many particular views.

 * For another project, my deliverable may be _a website which contains a set number of lists (views)_. In this case I may use [features](https://www.drupal.org/project/features) (D7) or [config management](http://blog.dcycle.com/blog/68/approach-code-driven-development-drupal-8) (D8) to export all the views my client asked for. Furthermore, I may enable views_ui (the Views User interface) only on my development box, and disable it on production.

 * For a third project, my deliverable may a website with a number of set views, _plus the ability for the client to add new ones_. In this only certain views will be in code, and I will enable the views UI as a dependency of my [site deployment module](http://blog.dcycle.com/blog/44/what-site-deployment-module). The views my client creates on production will be data.

Data
----

A few years ago, I took a step back from my day-to-day Drupal work and thought about what my main pain points were and how to do away with them. After consulting with colleagues, looking at bugs which took longest to fix, and looking at major sources of regressions, I realized that the one thing all major pain points had in common were our deployment techniques.

It struck me that [cloning the database from production to development was wrong](http://blog.dcycle.com/blog/48/do-not-clone-database). Relying on production data to do development is sloppy and will cause problems. It is better to invest in [realistic dummy content](https://www.drupal.org/project/realistic_dummy_content) and a good [site deployment module](http://blog.dcycle.com/blog/44/what-site-deployment-module), allowing the standardized deployment of an environment in a few minutes from any commit.

Once we remove data from the development equation in this way, it is easier to define what data is: anything which can differ from one environment to the next without overriding a feature.

Furthermore, I like to think of _production_ as just another environment, there is nothing special about it.

A new view or content type created on production outside of our development cycle resides on the database, is never used during the course of development, and is therefore data.

Nodes and taxonomy terms are data.

What about a view which is deployed through features and later changed on another environment? That's a tough one, I'll get to it (See _Overriden features_, below).

Placeholder content
-------------------

Let's get back to our "About us" page. Three components are involved here:

 * The menu which contains the "About us" menu item. These types of menus are generally deployable, so let's call them code.
 * The "About us" node itself which has an incremental `nid` which can be different on each environment. On some environments it might not even exist.
 * The "About us" menu item, which should link to the node.

Remember: we are not cloning the production database, so the "About us" does not exist anywhere. For situations such as this, I will suggest the use of Placeholder content.

For sake of argument, let's define our _deliverable_ for this sample project as follows:

    "Define an _About us_ page which is modifiable".

We might be tempted to figure out a way to assign a unique ID to our "About us" node to make it deployable, and devise all kinds of techniques to make sure it cannot be deleted or overridden.

I have an approach which I consider more logical for these situations:

First, in my [site deployment module](http://blog.dcycle.com/blog/44/what-site-deployment-module)'s `hook_update_N()`, create the node and the menu item, bypassing features entirely. Something like:

    function mysite_deploy_update_7023() {
      $node = new stdClass();
      $node->title = 'About us';
      $node->body[LANGUAGE_NONE][0]['format'] = 'filtered_html';
      $node->body[LANGUAGE_NONE][0]['value'] = 'Lorem ipsum...';
      $node->type = 'page';
      node_object_prepare($node);
      $node->uid = 1;
      $node->status = 1;
      $node->promote = 0;
      node_save($node);

      $menu_item = array(
        'link_path' => 'node/' . $node->nid,
        'link_title' => 'About us',
        'menu_name' => 'my-existing-menu-exported-via-features',
      );

      menu_link_save($item);
    }

If you wish, you can also implement [`hook_requirements()`](https://api.drupal.org/api/drupal/modules%21system%21system.api.php/function/hook_requirements/7) in your custom module, to check that the About us page has not been accidentally deleted, that the menu item exists and points to a valid path.

What are the advantages of placeholder content?

 * It is deployable in a standard manner: any environment can simply run `drush updb -y` and the placeholder content will be deployed.
 * It can be changed without rendering your features (D7) or configuration (D8) overriden. This is a good thing: if our incremental deployment script calls [`features_revert()`](http://drupalcontrib.org/api/drupal/contributions!features!features.module/function/features_revert/7) or `drush fra -y` (D7) or `drush cim -y` (D8), all changes to features are deleted. We do not want changes made to our placeholder content to be deleted.
 * It can be easily tested. All we need to do is make sure our site deployment module's [`hook_install()` calls all `hook_update_N()`s](http://blog.dcycle.com/blog/65/basic-install-file-deployment-module); then we can enable our site deployment module [within our simpletest](http://blog.dcycle.com/blog/30/basic-test), and run any tests we want against a known good starting point.

Overriden features
------------------

Although it is easy to override features on production, I would not recommend it. It is important to define with your client and your team what is code and what is data. Again, this depends on the project.

When a feature gets overridden, it is a symptom that someone does not understand the process. Here are a few ways to mitigate this:

 * Make sure your features are reverted (D7) or your configuration is imported (D8) as part of your deployment process, and [automate that process](http://blog.dcycle.com/blog/46/continuous-deployment-drupal-style) with a continuous integration server. That way, if anyone overrides a feature on a production, it won't stay overridden long.
 * Limit administrator permissions so that only user 1 can override features (this can be more trouble than it's worth though).
 * Implement [`hook_requirements()`](https://api.drupal.org/api/drupal/modules%21system%21system.api.php/function/hook_requirements/7) to check for overridden features, warning you on the environment's dashboard if a feature has been overridden.

Some edge cases
---------------

Now, with our more rigorous approach, how do our edge cases fare?

**Social media menu and items**: Our deliverable here is the existence of a social media menu with two items (twitter and facebook), but whose links can be changed at any time on production without triggering an overridden feature. For this I would use placeholder content. Still, we need to theme each button separately, and our css does not know the incremental IDs of the menu items we are creating. I have successfully used the [menu attributes](https://www.drupal.org/project/menu_attributes) module to associate classes to menu items, allowing easy theming. Here is an example, assuming `menu_attributes` exists and `menu-social` has been exported as a feature.

    /**
     * Add facebook and twitter menu items
     */
    function mysite_deploy_update_7117() {
      $item = array(
        'link_path' => 'http://twitter.com',
        'link_title' => 'Twitter',
        'menu_name' => 'menu-social',
        'options' => array(
          'attributes' => array(
            'class' => 'twitter',
          )
        )
      );
      menu_link_save($item);
      $item = array(
        'link_path' => 'http://facebook.com',
        'link_title' => 'Facebook',
        'menu_name' => 'menu-social',
        'options' => array(
          'attributes' => array(
            'class' => 'facebook',
          )
        )
      );
      menu_link_save($item);
    }

The above code creates the menu items linking to Facebook and Twitter home pages, so that content editors can put in the correct links directly on production when they have them.

Placeholder content is just like regular data but it's created as part of the deployment process, as a service to the webmaster.

**A block whose placement is known, but whose content is not**. It may be tempting to use the [box](http://drupal.org/project/box) module which makes blocks exportable with feature. But in this case the block is more like placeholder content, so it should be deployed outside of features. And if you create your block programmatically, its id is incremental and it cannot be deployed with [context](https://www.drupal.org/project/context), but should be placed in a region directly, again, programmatically in a hook_update_N().

Another approach here is to create a content type and a view with a block display, fetching the last published node of that content type and displaying it at the right place. If you go that route (which seems a bit overengineered to me), you can then place your block with the context module and export it via features.

**A view which references a taxonomy term id in its filter**: If a view requires access to a taxonomy term nid, then perhaps taxonomy is the wrong tool here. Taxonomy terms are data, they can be deleted, their names can be changed. It is not a good idea for a view to reference a specific taxonomy term. (Your view can use taxonomy terms for contextual filters without a problem, but we don't want to hard-code a specific term in a non-contextual filter -- See [this issue](https://github.com/alberto56/dcyclesite/issues/3) for an example of how I learned this the hard way, I'll get around to fixing that soon...).

For this problem I would suggest rethinking our use of a taxonomy term. Rather I would define a select field with a set number of options (with defined keys and values). These are deployable and guaranteed to not change without triggering a features override. Thus, our views can safely use them. If you are implementing this change on an existing site, you will need to update all nodes from the old to the new technique in a hook_update_N() -- and probably add an automated test to make sure you're updating the data correctly. This is one more reason to think things through properly at the onset of your project, not midway through.

In conclusion
-------------

Content and configuration are hard to define, I prefer the following definitions:

 * **Code**: deployable, deliverable, versioned, tested piece of software.
 * **Data**: anything which can differ from one environment to the next.
 * **Placeholder content**: any data which should be created as part of the deployment process.

In my experience, what fits in each category _depends on each project_. Defining these with your team as part of your sprint planning will allow you create a system with less edge cases.
