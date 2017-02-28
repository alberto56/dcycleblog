---
layout: post
title: Can the exact same module code run on Drupal 7 and 8?
author: admin
id: 7b285da4
tags:
  - planet
  - blog
permalink: /blog/7b285da4/same-module-drupal-7-and-8
redirect_from:
  - /blog/7b285da4/
  - /node/7b285da4/
---
As the maintainer of [Realistic Dummy Content](http://drupal.org/project/realistic_dummy_content), having procrastinated long and hard before releasing a Drupal 8 version, I decided to leave my (admittedly inelegant) logic intact and abstract away the Drupal 7 code, with the goal of plugging in Drupal 7 or 8 code at runtime.

Example original Drupal 7 code
-----

    // Some logic.
    $updated_file = file_save($drupal_file);
    // More logic.

Example updated code
-----

Here is a simplified example of how the updated code might look:

    // Some logic.
    $updated_file = Framework::instance()->fileSave($drupal_file);
    // More logic.

    abstract class Framework {

      static function instance() {
        if (!$this->instance) {
          if (defined('VERSION')) {
            $this->instance = new Drupal7();
          }
          else {
            $this->instance = new Drupal8();
          }
        }
        return $this->instance;
      }

      abstract function fileSave($drupal_file);

    }

    class Drupal8 extends Framework {
      public function fileSave($drupal_file) {
        $drupal_file->save();
        return $drupal_file;
      }
    }

    class Drupal7 extends Framework {
      public function fileSave($drupal_file) {
        return file_save($drupal_file);
      }
    }

Once I have defined fileSave(), I can simply replace every instance of file_save() in my legacy code with Framework::instance()->fileSave().

In theory, I can then identify all Drupal 7 code my module and abstract it away.

Automated testing
-----

As long as I _surgically_ replace Drupal 7 code such as `file_save()` with "universal" code such `Framework::instance()->fileSave()`, _without doing anything else, without giving in the impulse of "improving" the code_, I can theoretically only test `Framework::instance()->fileSave()` itself on Drupal 7 and Drupal 8, and as long as both versions are the same, my underlying code should work. My approach to automated tests is: if it works and you're not changing it, there is no need to test it.

Still, I want to make sure my framework-specific code works as expected. To set up my testing environment, I have used Docker-compose to set up three containers: Drupal 7, Drupal 8; and MySQL. I then have a script which builds the sites, installs my module on each, then run a `selftest()` function which can test the abstracted function such as `fileSave()` and make sure they work.

This can then be run a continuous integration platform such as Circle CI and get a cool badge:

[![CircleCI](https://circleci.com/gh/dcycle/realistic_dummy_content.svg?style=svg)](https://circleci.com/gh/dcycle/realistic_dummy_content)

Extending to Backdrop
-----

Once your module is structured in this way, it is relatively easy to add new related frameworks, and I'm much more comfortable releasing a Drupal 9 update in 2021 (or whenever it's ready).

I have included experimental Backdrop code in Realistic Dummy Content to prove the point. [Backdrop](https://backdropcms.org) is a fork of Drupal 7.

    abstract class Framework {
      static function instance() {
        if (!$this->instance) {
          if (defined('BACKDROP_BOOTSTRAP_SESSION')) {
            $this->instance = new Backdrop();
          }
          elseif (defined('VERSION')) {
            $this->instance = new Drupal7();
          }
          else {
            $this->instance = new Drupal8();
          }
        }
        return $this->instance;
      }
    }

    // Most of Backdrop's API is identical to D7, so we can only override
    // what differs, such as fileSave().
    class Backdrop extends Drupal7 {
      public function fileSave($drupal_file) {
        file_save($drupal_file);
        // Unlike Drupal 7, Backdrop returns a result code, not the file itself,
        // in file_save(). We are expecting the file object.
        return $drupal_file;
      }
    }

Disadvantages of this approach
-----

Having just released [Realisic Dummy Content](http://drupal.org/project/realistic_dummy_content) 7.x-2.0-beta1 and 8.x-2.0-beta1 (which are identical), I can safely say that this approach was a lot more time-consuming than I initially thought.

**Drupal 7 class autoloading** is incompatible with Drupal 8 autoloading. In Drupal 7, classes cannot (to my knowledge) use namespaces, and must be added to the `.info` file, like this:

    files[] = includes/MyClass.php

Once that is done, you can define MyClass in `includes/MyClass.php`, then use `MyClass` anywhere you want in your code.

Drupal 8 uses [PSR-4 autoloading with namespaces](https://www.drupal.org/docs/develop/coding-standards/psr-4-namespaces-and-autoloading-in-drupal-8), so I decided to create my own autoloader to use the same system in Drupal 7, something like:

    spl_autoload_register(function ($class_name) {
      if (defined('VERSION')) {
        // We are in Drupal 7.
        $parts = explode('\\', $class_name);
        // Remove "Drupal" from the beginning of the class name.
        array_shift($parts);
        $module = array_shift($parts);
        $path = 'src/' . implode('/', $parts);
        if ($module == 'MY_MODULE_NAME') {
          module_load_include('php', $module, $path);
        }
      }
    });

**Hooks** have different signatures in Drupal 7 and 8; in my case I was lucky and the only hook I need for Drupal 7 and 8 is `hook_entity_presave()` which has a similar signature and can be abstracted.

**Deeply-nested associative arrays** are a staple of Drupal 7, so a lot of code expects this type of data. Shoehorning Drupal 8 to output something like Drupal 7's `field_info_fields()`, for example, was a painful experience:

    public function fieldInfoFields() {
      $return = array();
      $field_map = \Drupal::entityManager()->getFieldMap();
      foreach ($field_map as $entity_type => $fields) {
        foreach ($fields as $field => $field_info) {
          $return[$field]['entity_types'][$entity_type] = $entity_type;
          $return[$field]['field_name'] = $field;
          $return[$field]['type'] = $field_info['type'];
          $return[$field]['bundles'][$entity_type] = $field_info['bundles'];
        }
      }
      return $return;
    }

Finally, making Drupal 8 work like Drupal 7 makes it hard to use Drupal 8's advanced features such as Plugins. However, once your module is "universal", adding Drupal 8-specific functionality might be an option.

Using this approach for website upgrades
-----

This approach might remove a lot of the risk associated with complex site upgrades. Let's say I have a Drupal 7 site with a few custom modules: each module can be made "universal" in this way. If automated tests are added for all subsequent development, migrating the functionality to Drupal 8 might be less painful.

A fun proof of concept, or real value?
-----

I've been toying with this approach for some time, and had a good time (yes, that's my definition of a good time!) implementing it, but it's not for everyone or every project. If your usecase includes preserving legacy functionality without leveraging Drupal 8's modern features, while reducing risk, it can have value though. The jury is still out on whether maintaining a single universal codebase will really be more efficient than maintaining two separate codebases for Realistic Dummy Content, and whether the approach can reduce risk during site upgrades of legacy custom code, which I plan to try on my next upgrade project.
