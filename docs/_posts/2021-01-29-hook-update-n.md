---
layout: post
title:  "hook_update_N(), a powerful and dangerous tool to use sparingly"
author: admin
id: 2021-01-29
tags:
  - blog
  - planet
permalink: /blog/2021-01-29/hook_update_n/
redirect_from:
  - /blog/2021-01-29/
  - /node/2021-01-29/
---

What is hook_update_N()?
-----

Let's say you are developing a Drupal module (custom or contrib) which tracks how many visitors landed on specific node pages, version 1 of your code might track visitors by nid (node id) in the database using a table like this:

| nid       | visitors |
|-----------|----------|
| 1         | 4        |
| 13        | 22       |

Let's set aside the debate over whether the above is a good idea or not, but once your code has been deployed live to production sites, that's what the data will look like.

This module might work very well for a long time, and then you might have the need to track not only nodes but also, say, taxonomy term pages. You might reengineer to look like this:

| type   | id        | visitors |
|--------|-----------|----------|
| node   | 1         | 4        |
| node   | 13        | 22       |
| term   | 4         | 16       |

To achieve this change when the first version of your database is already out in the wild, you need to tell target environments to update the database schema. This is done using hook_update_N(), and you would replace the N() by incremental numbers, something like this:

    /**
     * Update database schema to allow for terms, not only nodes.
     */
    function hook_update_9001() {
      ...
    }

If this case 9 is the major version (Drupal 9) and 001 because this is the first update to your code.

Each module tracks which version it's using, so that if code introduces new hook_update_N() functions, it will know to run them only once. You can tell which schema version any installed module is using by running, for example:

    drush ev "print(drupal_get_installed_schema_version('webform'))"

This might tell you, for example, that Webform's current schema is 8621. This means that the latest update hook that was run is [Webform's `hook_update_8621()`](https://git.drupalcode.org/project/webform/-/blob/6.x/includes/webform.install.update.inc). If the codebase introduces `hook_update_8622()`, say, or `hook_update_8640()` (you can skip numbers if need to), then the database will be marked as out of date and running `drush updb` will run the the new hook and update the installed schema version.

If you ever need to re-run an update hook (which happens rather rarely), you can update the schema, like this:

    drush ev "drupal_set_installed_schema_version('webform', 8620)"

So what's wrong with this?
-----

This works well almost all the time, and you can automate your deployment process to update the database, making sure your schemas are always in sync. However as developers and site users it is important to be aware of certain drawbacks of hook_update_N(), which I'll get to in detail:

* `hook_update_N()` tightly couples the database to the code version;
* it makes gradual-deployment on multi-container setups such as Kubernetes fragile (or impossible);
* rollbacks are not possible;
* it can add considerable compexity to deployment of configuration.

The shaky foundation of database-driven websites
-----

The idea of version control is paramount to how we conceive of computer code. If you're following the precepts of continuous deployment, then every version of your code needs to "work" (that is, tests need to pass, or, at the very least, it needs to be installable).

For example, let's assume a bug makes it to your production envrionment for version 5 of your code, and you know this bug was not present on version 4 of your code, you should theoretically be able to check out version 4 and confirm it was working, then figure out what the difference it between version 4 and 5.

In fact this is exactly how things work on static sites such as Jekyll: all your data _and_ your functionality (Javascript) are in your codebase. Each version of your code will be internally coherent, and not rely on an external unversioned database to do something useful.

On database-driven projects based on Drupal or Wordpress, if you check out version 4 of your codebase, it will probably not do anything useful without a database dump _which was created using version 4 of your code_.

Therefore, although we all use version control for our code, in a way we are fooling ourselves, because critical parts of our project are not version-controlled: the database dump, the `./sites/default/files` folder, and the private files folder.

Although it makes sense for certain elements to be a database or on `./sites/default/files`, for example, an encrypted user account password or a user's avatar; for other elements such as your "About page" text, it would really make a lot more sense for this to be under version control.

In fact, the blog post you are reading right now is a [file under version control on Jekyll, which you can see using this link](https://github.com/alberto56/dcycleblog/edit/gh-pages/_posts/2021-01-29-hook-update-n.md), and not some collection of opaque, unversioned, entries in database tables with names like `node__body`, `node__field_tags`, `node_field_revision`, which can be changed at a moment's notice by any module's `hook_update_N()` functions.

Oh, did I mention that I love Drupal?

Tight code-database coupling
-----

Let's imagine a world where the database schema never changed. A world where `hook_update_N()` does not even exist.

In such a world, you could take any version of your code, and any version of your database dump (say, the latest version), combine the two on a test environment, and debug errors at will.

In the real world, every time any module updates the database schema, it makes the database more tightly coupled to the current version of the codebase.

Let's take our "number of visitors per entity" code we had earlier: if I use an old codebase which expects my table to contain fields "nid" and "visitors", but my only available database dump has fields "type" "id", "visitors", the history of my carefully version-controlled codebase will be useless, and old versions will fail with an error such as:

    ERROR 1054 (42S22): Unknown column 'id' in 'field list'.

Gradual deployments
-----

Mostly we think of Drupal sites as being on a server with one copy of the codebase, and one copy of the database. So the concept of keeping the database and code "in sync" makes sense.

But as more and more teams use containers and Kubernetes-type container-orchestration systems, high-traffic sites might have, say, one performance-optimized database, and then 5, 10 or 20 load-balanced copies of your PHP code.

Acquia uses such a setup behind the scenes for its cloud hosting, so it's good to develop with this in mind. On Acquia's setup, all PHP container use a single, shared database, as well as shared private and public files directories.

But the PHP containers _do not_ share the `/tmp` directory. This means that every time you perform a web request on a server, the load balancer might direct you to a container with its own `/tmp`, whose contents differ from other containers' `/tmp`.

It's important to realize this if your code stuff such as building large files over several web requests, and can lead to hard-to-diagnose bugs such as:

* [#2980276 Webform assumes the /tmp directory is always the same, but if there are multiple servers, each may have its own /tmp directory](https://www.drupal.org/project/webform/issues/2980276)
* [#3170504 On high-availabilities setups with multiple containers, the /tmp directory might differ between calls, make the error message more descriptive](https://www.drupal.org/project/csv_importer/issues/3170504)

But, in addition to providing you with headaches such as the above issues, multiple containers can also allow you to do **gradual deployments of new code**, reducing the cost of potential failure.

For example, let's say you have 20 Drupal containers with 20 copies of your codebase, and each Drupal container is connected to a shared database, and shared files and private files directories. If you are deploying a risky update to your code, you might want to start by deploying it to 25% of the containers (5). Then if there are no adverse effects, scale up to 10 the next day, then the entire 20 the day after.

Code that uses `hook_update_N()` can break this workflow: because all containers share the database, if container 1 has the new version of your code and updates the database accordingly (so that the new database fields are "type" "id", "visitors"); then container 10 (which uses the old version of your code) will fail when it looks up the database field "nid".

Rollbacks
-----

Let's forget about fancy container orchestration and just look at a typical Drupal website. A simple real-world site might have a "contact us" webform and some pages, plus some custom functionality.

Let's say you are deploying a change to your codebase which triggers a hook_update_N(). No matter the amount of unit tests and testing on stage, there is always the possibility that a deployment to production might trigger unforseen issues. Let's assume this is the case here.

A typical deployment-to-production scenario would be:

* You backup your production database.
* You install your new code.
* You run `drush updb` which updates the database schema based on your hook_update_N().
* A few hours pass. Several people fill in your contact form, which means now your database backup from step 1 is out of date.
* You realize your newly-deployed code breaks something which was not caught by your stage testing or your automated tests.

In a situation like this, if you did not have hook_update_N()s in your code, you could simply roll back your codebase on production to the previous version.

However, **this is no longer an option** because your database will not work with previous versions of your codebase: there is no hook_downgrade_N(). You are now forced to live with the latest version of your code, and all the benefits of version-controlling your code are for naught.

Config management
-----

Let us recall the elements which make up a Drupal website:

* Versioned code.
* Unversioned database and file directories.

If you are using configuration management and a dev-stage-production workflow, there is a third category:

* **Configuration, including the list enabled modules, defined node types and fields**, which exist both in the database _and_ in unversioned code.

It is worth recalling a typical workflow:

* add field_new_field to the article node type on your local machine.
* **the field is now in your local development database but not in your codebase**
* drush config-export
* **the field is now in your local development database and also in your codebase**
* do all your testing and push your code to production

At this point your field is in your production codebase _but not_ your production database.

You probably have a deployment script which includes a "drush updb" step. The question is: do you run "drush config-import" _before_ or _after_ "drush updb"?

It turns out this is not that easy a question to answer. (Drush also provides a `drush deploy` command which combines configuration import and database updates.)

Regardless of your deployment process, however, we need to take into account a more troubling possibility:

In addition to relatively benign database schema updates, hook_update_N() **can modify configuration as well**.

In such a case, if you are not careful to run **hook_update_N()** first on your development environment, then **export the resulting configuration**, then run your deployment, you may run into the following problem:

**[#3110362 If an update hook modifies configuration, then old configuration is imported, the changes made by the update hook are forever lost.](https://www.drupal.org/project/drupal/issues/3110362)**

Let's look at a real-world example using the Webform module. Let's install a new Drupal 8 site with Webform 5.23, then export our configuration, then upgrade to Webform 6.x and import our old configuration. We'll look at the kind of headache this can lead to (note to beginners: **do not** do this on a production site, it will completely erase your database).

    composer require drupal/webform:5.23
    drush site-install -y
    drush en webform_ui -y
    drush config-export -y

This puts your current site configuration into code. Among said configuration, let's focus on a single piece of configuration from Webform:

    drush config:get webform.settings settings.default_page_base_path
    # 'webform.settings:settings.default_page_base_path': form

The base path for webforms is "form". This tells Webform to build URLs with a structure such as https://example.com/form/whatever.

Let's now update webform, and our database.

    composer require drupal/webform:6
    drush updb -y
    drush config-import -y

In [Webform's `webform_update_8602()`](https://git.drupalcode.org/project/webform/-/blob/6.x/includes/webform.install.update.inc), the config item webform.settings:settings.default_page_base_path is changed from "form" to "/form".

**But we are re-importing old config, which overwrites this change and reverts webform.settings:settings.default_page_base_path to "form", not "/form"**

To see the type of hard-to-diagnose error to which this might lead, you can now log into your Drupal site, visit /admin/structure/webform, create a webform named "test", and click on the "View" tab.

Because the base path lack the expected leading prefix, you now get the "not found" URL /admin/structure/webform/manage/form/test, instead of the expected /form/test -- a critical bug if you are on a production site.

In addition, this has a number of cascading effects including the creation of badly-formatted URL aliases which you can see at /admin/config/search/path.

If you find yourself in this situation on production, you need to revert your Webform schema version on your development environment, export your config, reimport it on production, and resave your forms, and potentially fix all your paths starting with "form" on /admin/config/search/path so that they start with "/form".

To be fair, this is not the fault of the Webform maintainers. In my opinion it shows a fundamental frailty in hook_update_N() combined with lack of documentation on deployment best practices. However, if we strive for Drupal to be a robust framework, there should not be a single point of failure (in this case not strictly adhering to fickle, badly-documented deployment procedures) which can lead to major instability on production.

How do we fix hook_update_N()?
-----

Here are a few approaches to avoid the potential damage done by hook_update_N():

### Approach 1: don't use hook_update_N()

When possible, you might consider not using hook_update_N() at all. Consider our "number of visitors per node" module from earlier.

Instead of a hook_udate_N(), your code could do something like this:

* Do not change the field name from "nid" to "id". Even though "id" makes more sense, the field is called "nid", just leave it at that.
* Do not expect there to be a "type" field. If your code needs it, for example if creating an entry for the first visitor to a non-node entity, your code can create it.
* Assume an empty "type" means you are dealing with a node.

The above approach adds complexity to your code, which you can add to a "storage" abstraction class. Although not ideal, this does away with the need to use hook_update_N().

### Approach 2: Don't use hook_update_N() to update configuration

Updating configuration, as seen previously, is even more dangerous than updating non-configuration database tables. So if at all possible, avoid it.

In the Webform example given above, it might have been reasonable to consider keeping with the old non-leading-slash format for path prefixes, rather than update configuration.

When you absolutely must update configuration, you could consider the possibility that certain users might have reimported old configuration, and provide error-checking and hook_requirements() (displaying error messages on the /admin/reports/status page) accordingly.

### Approach 3: Robust exception handling

Do not assume that your database schema, or your configuration structure, is up-to-date. If you decide to provide a hook_update_N() to update the schema from, for example, "nid" and "visitors" to "type", "id", "visitors", when querying the database, you might want to consider the possibility that for whatever reason the database is not up-to-date. Here is some pseudo-code:

    public function num_visitors_for_entity($id, $type = 'node') : int {
      try {
        return $this->query_database($type, $id);
      }
      catch (\Exception $e) {
        $this->logAndDisplayException($e);
        return 0;
      }
    }

That way, if your database and code are not in sync, it's not going to break your entire site, but rather log an exception and fail gracefully.

### Approach 4: keep config changing logic idempotent and separate from update hooks

Let's look again at [Webform's `webform_update_8602()`](https://git.drupalcode.org/project/webform/-/blob/6.x/includes/webform.install.update.inc), the config item webform.settings:settings.default_page_base_path is changed from "form" to "/form".

I would recommend having a separate function to update config, and call that function from the update hook. That way, if a development team makes the mistake of not updating their configuration before importing it into production, it will become easier to run, say "my_module_update_configuration()".

Then, your hook_requirements() might perform some sanity checks to make sure your configuration is as expected (in this example, that the "webform.settings:settings.default_page_base_path" config item has a leading slash). If this smoke test fails, developers can be directed to run `my_module_update_configuration()` which will update all configuration to the required state.

In addition, `my_module_update_configuration()` can be made idempotent, meaning: no matter how often you run it, you will always end up with the desired state, and never get an error.

Resources
-----

* [hook_update_N() API documentation on drupal.org](https://api.drupal.org/api/drupal/core%21lib%21Drupal%21Core%21Extension%21module.api.php/function/hook_update_N/8.2.x)
