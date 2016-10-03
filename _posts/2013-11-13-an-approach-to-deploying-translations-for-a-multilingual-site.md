---
layout: post
title: An approach to deploying translations for a multilingual site
id: 28
created: 1384365195
tags:
  - blog
  - planet
permalink: /blog/28/approach-deploying-translations-multilingual-site/
redirect_from:
  - /blog/28/
  - /node/28/
---
Let's say you are working locally and you need to add a new module to the site. Here is an example with [Login Toboggan](https://drupal.org/project/logintoboggan):

Let's start by downloading the module to our local dev site

    
    drush dl logintoboggan
    

Instead of enabling it outright, we'll want to add it as a dependency to our deploy module, and define a `hook_update_n()` to enable it on existing environments.

    ; in your deploy module's .info file
    dependencies[] = logintoboggan

    /**
     * Enable logintoboggan in our deploy module's .install file
     */
    function mysite_deploy_update_7001() {
      module_enable(array('logintoboggan'));
    }

Deployable module settings need to be in code as well, so we can have the same configuration on all environments (local, development, stage, production). Here is an example with Login Toboggan's user login form on Access Denied:

    /**
     * Set logintoboggan to put login form on 403 pages
     */
    function mysite_deploy_update_7002() {
      variable_set('site_403', 'toboggan/denied');
    }

Make sure the above is also called during initial deployment, in your deployment module's .install file (don't forget: your continuous integration server and new members of the team will need to deploy new environments for your site):

    /**
     * Implements hook_install().
     */
    function mysite_deploy_install() {
      mysite_deploy_update_7002();
    }

Now, you can enjoy this new functionality either on a new site environment by enabling mysite_deploy, or an an existing environment by updating your database:

    drush updb -y

However, if you are running a multilingual site, the newly-added Login Toboggan module will not be translated. I avoid fetching the translations from localize.drupal.org in the update hook, because you can't be sure it will work on all environments (for example, some clients disable internet access on their web servers for security reasons).

Rather, I prefer to download the translations myself and import them from the local repo in the update hook. Here's how:

 * Start by visiting http://localize.drupal.org and finding your project
 * In the export tab, I like to check the Add Suggestions box, so, in the case of strings without "official" translations, at least I have something.
 * Click Export Gettext file, which will save a .po or .po.txt file to your computer, for example, for Login Toboggan in French, the file is logintoboggan-all.fr.po.txt
 * I put this file in my deployment module, for example sites/all/modules/custom/mysite_deploy/translations/ (if you have a .txt extension you can remove it)

Next, import in an install hook

    /**
     * Import translations for Login Toboggan.
     */
    function mysite_deploy_update_7003() {
      _mysite_deploy_import_po('logintoboggan-all.fr.po');
    }
    
    /**
     * Import translation po file
     *
     * @param $filename
     *   A filename in mysite_deploy/translations/
     */
    function _mysite_deploy_import_po($file) {
      try {
        // Figure out the full filepath
        $filepath = DRUPAL_ROOT . '/' . drupal_get_path('module', 'mysite_deploy') . '/translations/' . $file;
        // move the contents of the file to the public stream. I can't get
        // _locale_import_po() to work with the file directly.
        $contents = file_get_contents($filepath);
        // In some cases the destination file might already exist, so I'll create a
        // random name; there probably is a better way of doing this...
        $random = md5($filepath) . rand(1000000000, 9999999999);
        $file = file_save_data($contents, 'public://po-import' . $random . '.po');
        // finally import the file from the public stream.
        _locale_import_po($file, 'fr', LOCALE_IMPORT_OVERWRITE, 'default');
      }
      catch (Exception $e) {
        // don't break the update process for translations.
        drupal_set_message(t('Oops, could not import the translation @f. Other updates will still take place (@r).', array('@f' => $filename, '@r' => $e->getMessage())));
      }
    }

Don't forget to call `mysite_deploy_update_7003()` from `mysite_install()`, to make sure that the translations are available to new deployments as well.

There is room for improvement in the above code, I admit, but I like this approach because it's testable and does not depend on internet access during updates. Also, the same approach can be used to translate your custom modules.

Update: thanks to mikran for implementing [a module](https://www.drupal.org/node/2371049) (for now in sandbox mode) which expands on this idea.
