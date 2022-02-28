---
layout: post
title:  "Translating a Drupal user interface (PHP and Javascript): a workflow"
author: admin
id: 2022-02-27
tags:
  - blog
  - planet
permalink: /blog/2022-02-27/drupal-translation-workflow/
redirect_from:
  - /blog/2022-02-27/
  - /node/2022-02-27/
---

So you find yourself, as one does, building a complete user interface with PHP and Javascript buildings for Drupal 9; and you'd like to delegate the translation of the front-end to a non-developer. (You want the client to be empowered to change the UI strings in English or any other language; do _don't_ want to be a bottleneck for string translations).

### Three types of translations

Translations can be done in PHP, like this:

    use Drupal\Core\StringTranslation\StringTranslationTrait;

    class MyClass {

      use StringTranslationTrait;

      function foo() {
        return $this->t('Hello, @n', [
          '@n' => 'world',
        ]);
      }
    }

They can also be done in JavaScript, like this:

    ...
    function foo() {
      return Drupal.t('Hello @n', {
        '@n': 'world',
      });
    }
    ...

Finally you can translate strings directly in twig template files, like this:

    ...
    <div>{{ "Hello World" | trans }}</div>
    ...

### Starting from be beginning

Let's take a concrete example: we will provide code for a very simple application which shows a pseudo-dashboard.

If you start with a standard Drupal installation, and an empty module named `my_custom_module`, here is some convoluted code which uses the three types of translations above to achieve a dashboard which does nothing useful:

./my_custom_module.routing.yml:

    my_custom_module.dashboard:
      path: '/my-dashboard'
      defaults:
        _controller: '\Drupal\my_custom_module\Controller\MyDashboard::content'
      requirements:
        _permission: 'administer site configuration'

./my_custom_module.libraries.yml

    current_time:
      js:
        current_time.js: {}
      dependencies:
        - core/jquery

./my_custom_module.module

    <?php
    function my_custom_module_theme() {
      return [
        'my_custom_module_dashboard' => [
          'template' => 'dashboard',
          'variables' => [
            'admin_page_link' => '',
          ],
        ],
      ];
    }

./templates/dashboard.html.twig

    {{ attach_library('my_custom_module/current_time') }}
    <h3>{{ "Welcome to your Dashboard" | trans }}<h3>
    <div>
      <div>{{ admin_page_link }}</div>
      <div class="current-time"></div>
    </div>

./current_time.js:

    (function ($, Drupal, drupalSettings) {
      Drupal.behaviors.MyCustomModuleCurrentTime = {
        attach: function (context, settings) {
          $('.current-time').html(Drupal.t('This page was generated on @t', {
            '@t': Date(),
          }));
        }
      };
    })(jQuery, Drupal, drupalSettings);

./src/Controller/MyDashboard.php

    <?php

    namespace Drupal\my_custom_module\Controller;

    use Drupal\Core\Controller\ControllerBase;
    use Drupal\Core\StringTranslation\StringTranslationTrait;
    use Drupal\Core\Url;
    use Drupal\Core\Link;

    class MyDashboard extends ControllerBase {

      use StringTranslationTrait;

      public function content() {
        $return = [
          '#theme' => 'my_custom_module_dashboard',
          // Don't ask me why making links is so complicated in Drupal.
          '#admin_page_link' => Link::fromTextAndUrl($this->t('Go to admin'), Url::fromRoute('system.admin'))->toString(),
        ];

        return $return;
      }

    }

### Enabling your custom module and some translation-specific modules:

Once your module has an info file (read up on how to build a custom module if you're not sure how), you can enable your custom module and the config_translation module:

    drush en -y config_translation my_custom_module
    chown www-data:www-data sites/default/files/translations

### Adding a language

For this demo we'll add French. To do that,

* Go to /admin/config/regional/language
* Select Add Language, then French. This should update Drupal for French.

### Making English strings overridable

Base English strings are hard-coded, but administrators can override them. This will free your time for development. To enable admins to override strings:

* Go to /admin/config/regional/language/edit/en
* Check "Enable interface translation to English", then save.

Let's visit our dashboard
-----

If you have correctly created your my_custom_module, above, you will be able to log in as user, visit /my-dashboard, and see the following:

> Welcome to your Dashboard<br/>
> Go to admin<br/>
> This page was generated on Sun Feb 27 2022 23:11:08 GMT-0500 (EST)

This dashboard is useless, except in that it demonstrates how to translate strings in three different ways.

Translating our strings to French
-----

So let's see if we can use a nice admin interface to translate our strings to French. Go to /admin/config/regional/translate?langcode=fr, and in the search box, enter:

* Welcome to your Dashboard
* Go to admin
* This page was generated

Translate each of those to French:

* Bienvenue à votre tableau de bord
* Allez à la page admin
* Cette page a été générée le @t

The idea is that this is something non-developers can do with a bit of training (especially for string parameters such as '@t').

Testing the French version
-----

Visit:

* /fr/my-dashboard
* /my-dashboard

You will now see the dashboard in both French and English.

Overriding English strings
-----

It can be inefficient to modify code every time an English string is modified. So we can also "translate" English strings to English. Let's say you don't like the base strings, you can translate them, in English, to:

* Welcome to your great Dashboard
* Go to the admin page
* This page was viewed on @t

The good news is that this can be done exactly the same way for English as for non-English languages:

* go to /admin/config/regional/translate?langcode=en
* search for the base strings
* override them

Empowering non-developers to translate strings: a time-saver
-----

I have found that most clients will send unversioned Excel files or (ugh!) Word documents with string modification or translation requests. Dealing with these is time-consuming for developers, and expensive for clients.

After a 30-minute traning on how to translate strings, perhaps shortcuts (links on a wiki page, perhaps) to the string-translation pages, clients are empowered to do their own translation, and developers are not distracted.

An added bonus of string overrides is that you can write your end-to-end tests based on unchanging strings, [for example here we are asserting that the string "Log In" is on the /user page](https://github.com/dcycle/starterkit-drupal8site/blob/9/tests/browser-tests/testLogInAndEdit.js), regardless of whether your site-editors decide to change, say, "Log In" to "Log in" (with a lower-case i) or whatever else.

Happy coding!
