---
layout: post
title:  "Altering a list view in drupal, using an example with Webform"
author: admin
id: 2022-02-07
tags:
  - blog
  - planet
permalink: /blog/2022-02-07/alter-list-view/
redirect_from:
  - /blog/2022-02-07/
  - /node/2022-02-07/
---

In some cases administrative lists are actually views using the core Views module, as is the case with content. These are quite easy to modify in a development environment, export as config, then import in a production environment. How to do so is outside the scope of this article, though.

However, certain administrative views do not use views; rather they use an entity's list view.

For example the [Webform](https://www.drupal.org/project/webform) module does not use Views to built its administrative list of webforms. So how can we alter it?

Follow along, this article will show you how!

### Basic setup

In our example we will use [Webform](https://www.drupal.org/project/webform) 6.1.2 on Drupal 9.3.4. The general idea should apply regardless of the version though.

We will start with a standard installation along with webform_ui and webform.

### Our goal

Our goal will be to add a column to /admin/structure/webform showing the last submission.

### How the Webform administrative list works

[webform.routing.yml](https://git.drupalcode.org/project/webform/-/blob/6.1.2/webform.routing.yml#L96-102) defines the /admin/structure/webform path as follows:

    entity.webform.collection:
      path: '/admin/structure/webform'
      defaults:
        _entity_list: 'webform'
        _title: 'Webforms'
      requirements:
        _custom_access: '\Drupal\webform\Access\WebformAccountAccess::checkOverviewAccess'

This means we using the Webform entity's list view to display a list of webforms. In turn, the Webform entity [defines its list_builder as \Drupal\webform\WebformEntityListBuilder](https://git.drupalcode.org/project/webform/-/blob/6.1.2/src/Entity/Webform.php#L53).

The code list builder itself is at [./src/WebformEntityListBuilder.php](https://git.drupalcode.org/project/webform/-/blob/6.1.2/src/WebformEntityListBuilder.php).

The [buildHeader() and buildRow()](https://git.drupalcode.org/project/webform/-/blob/6.1.2/src/WebformEntityListBuilder.php#L219-362) methods are what need to overridden if we want to add a column.

### Creating our subclass of \Drupal\webform\WebformEntityListBuilder

THe first thing we need to do is create a subclass of WebformEntityListBuilder. We can create our own custom module, and in it, at ./my_custom_module/src/MyCustomWebformEntityListBuilder.php, create our class, overriding WebformEntityListBuilder's buildHeader() and buildRow().

    <?php
    # ./my_custom_module/src/MyCustomWebformEntityListBuilder.php

    namespace Drupal\my_custom_module;

    use Drupal\webform\WebformEntityListBuilder;
    use Drupal\webform\Entity\WebformSubmission;
    use Drupal\Core\Entity\EntityInterface;
    use Drupal\Core\StringTranslation\StringTranslationTrait;
    use Symfony\Component\DependencyInjection\ContainerInterface;
    use Drupal\Core\Entity\EntityTypeInterface;

    class MyCustomWebformEntityListBuilder extends WebformEntityListBuilder {

      /**
       * @var \Drupal\Core\Datetime\DateFormatterInterface
       */
      protected $dateFormatter;

      /**
       * {@inheritdoc}
       */
      public static function createInstance(ContainerInterface $container, EntityTypeInterface $entity_type) {
        $instance = parent::createInstance($container, $entity_type);

        $instance->dateFormatter = $container->get('date.formatter');

        return $instance;
      }

      /**
       * {@inheritdoc}
       */
      public function buildHeader() {
        return parent::buildHeader() + [
          'last_submission' => [
            'data' => $this->t('Latest submission'),
            'specifier' => 'latest',
            'field' => 'latest',
            'sort' => 'desc',
          ],
        ];
      }

      /**
       * {@inheritdoc}
       */
      public function buildRow(EntityInterface $entity) {
        return parent::buildRow($entity) + [
          'last_submission' => $this->lastSubmission($entity),
        ];
      }

      /**
       * Get the last submission for a webform.
       *
       * @param \Drupal\Core\Entity\EntityInterface $entity
       *   A webform.
       *
       * @return string
       *   Either a formatted date, or the translated string "No submission".
       */
      public function lastSubmission(EntityInterface $entity) : string {
        $query = $this->submissionStorage
          ->getQuery()
          ->accessCheck(TRUE)
          ->condition('webform_id', 'contact')
          ->sort('completed', 'DESC')
          ->range(0,1);

        $results = $query->execute();

        if ($row = array_pop($results)) {
          $submission = WebformSubmission::load(intval($row));
          return $this->dateFormatter->format($submission->completed->value);
        }
        else {
          return $this->t('No submission');
        }
      }

    }

### Altering the list builder for webforms

According to [this DrupalAnswers thread](https://drupal.stackexchange.com/a/192813/13414) we can alter the list builder for webform by adding this hook to our .module file:

    <?php
    # ./my_custom_module/my_custom_module.module

    /**
     * Implements hook_entity_type_alter().
     *
     * See https://drupal.stackexchange.com/a/192813/13414.
     */
    function my_custom_module_entity_type_alter(array &$entity_types) {
      /** @var $entity_types \Drupal\Core\Entity\EntityTypeInterface[] */
      $entity_types['webform']->setListBuilderClass('Drupal\my_custom_module\MyCustomWebformEntityListBuilder');
    }

You will now see the latest submission in the list of webforms.

Happy coding!
