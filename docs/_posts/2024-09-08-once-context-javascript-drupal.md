---
layout: post
title: "C'est quoi once() et context dans le Javascript Drupal"
date: 2024-09-08T14:43:30.853Z
id: 2024-09-08
author: admin
tags:
  - blog
permalink: /blog/2024-09-08/once-context-javascript-drupal/
redirect_from:
  - /blog/2024-09-08/
  - /node/2024-09-08/
---

Si nous voulons ajouter un comportement à un élément du DOM dans Drupal, il peut être utile de comprendre comment `once()` et `context` fonctionnent.

Prenons un exemple où un bloc affiche un bouton et que du Javascript ajoute un comportement (event handler) lorsque le bouton est cliqué affichant un message dans la console.

Pour commencer, sur une installation Drupal toute neuve, créons un module minimal `exemple_context` qui fait ce qu'on veut.

### `exemple_context.info.yml`

    name: Exemple de contexte
    type: module
    core_version_requirement: ^10 || ^11

### `exemple_context.libraries.yml`

    mon-js:
      js:
        js/mon-js.js: {}
      dependencies:
      - core/jquery

### `js/mon-js.js`

    (function ($) {
      Drupal.behaviors.ExempleContext = {
        attach: function () {
          $('button.exemple-context').click(function () {
            console.log("Ceci est déclanché lorsqu'on clique le bouton");
          });
        }
      };
    })(jQuery);

### `exemple_context.module`

    <?php

    function exemple_context_theme() {
      return [
        'exemplecontext' => [
          'variables' => [],
        ],
      ];
    }

### `templates/exemplecontext.html.twig`

    <button type="button" class="exemple-context">Cliquez-moi</button>

### `src/Plugin/Block/ExempleContext.php`

    <?php

    namespace Drupal\exemple_context\Plugin\Block;

    use Drupal\Core\Block\Attribute\Block;
    use Drupal\Core\Block\BlockBase;
    use Drupal\Core\StringTranslation\TranslatableMarkup;

    #[Block(
      id: "exemplecontext",
      admin_label: new TranslatableMarkup("Un exemple de context"),
    )]

    class ExempleContext extends BlockBase {
      public function build() {
        return [
          '#attached' => [
            'library' => ['exemple_context/mon-js'],
          ],
          '#theme' => 'exemplecontext',
        ];
      }
    }

## Installez votre bloc

Commencez par installer votre module:

    drush en -y exemple_context

Ensuite voyons notre bloc:

* Aller au /admin/structure/block
* Dans Content, cliquer sur "Place block"
* Placer "Un exemple de context"
* Visitez la page d'accueil

## Testez votre bouton

Sur Safari sur Mac, en cliquant sur "Cliquez-moi", vous verrez que l'alerte "Ceci est déclanché lorsqu'on clique le bouton" apparaît plus d'une fois, ce qui n'est pas le comportement désiré! (Sur Chrome sur Mac, du moins pour moi, le message "Ceci est déclanché lorsqu'on clique le bouton" n'apparaît qu'une seule fois, donc faisons nos tests sur Safari. Je présume que Chrome évite d'insaller le même click handler plus d'une fois même.)

## Une correction possible (à ne pas faire!): off()

Un petit hack au `js/mon-js.js` semble régler le problème:

    (function ($) {
      Drupal.behaviors.ExempleContext = {
        attach: function () {
          $('button.exemple-context')
            // off() enlève tous les événements click, pas juste le nôtre!
            .off()
            .click(function () {
              alert('Ceci est déclanché lorsqu'on clique le bouton');
            });
        }
      };
    })(jQuery);

Maintenant, si vous faites un refresh en dur (commande-option-R sur Safari sur Mac, commande-shift-R sur Chrome sur Mac...), votre fureteur chargera cette dernière version du JavaScript, et votre problème _semblera_ réglé: l'alerge n'apparaîtra qu'une seule fois.

Pour comprendre pourquoi ceci est une mauvaise idée, imaginez que d'autres librairies veulent aussi ajouter des événements sur clic pour votre bouton:

* Ajoutez un nouveau document `js/mon-js2.js`, identique à `mon-js.js` mais en remplaçant 'Drupal.behaviors.ExempleContext' par 'Drupal.behaviors.ExempleContext2'; et en remplaçant "Ceci est déclanché lorsqu'on clique le bouton" par "Ceci est aussi déclanché lorsqu'on clique le bouton".
* Dans `exemple_context.libraries.yml`, clônez mon-js et déclarez une librairie mon-js2 en plus de mon-js (identique mais déclarant `js/mon-js2.js` plutôt que `js/mon-js.js`).
* Dans `src/Plugin/Block/ExempleContext.php`, au lieu de `'library' => ['exemple_context/mon-js']`, mettez `'library' => ['exemple_context/mon-js', 'exemple_context/mon-js2']`.

Ce que nous venons de faire vise à déclancher deux alertes en cliquant sur notre bouton: "Exemple de contexte" et "Exemple de contexte 2".

Suite à un `drush cr`, rechargez votre page et cliquez sur votre bouton.

Vous aurez uniquement une des deux alertes, pas les deux. C'est parce que `off()` retire _tous les événements sur clic_, pas juste celui dans le document actuel.

Retirons `.off()` de notre code dans `js/mon-js.js` et `js/mon-js2.js`, faisons un refresh en dur, et maintenant nous devrions avoir, à nouveau, une dizaine d'alertes, du moins sur Safari sur Mac.

## once(), une autre solution à utiliser avec précaution

Drupal inclut la librairie [`once()`](https://github.com/drupal/drupal/blob/bf4ae811643c6e50e5263e19f8eb28e123e4d855/core/assets/vendor/once/once.js) qui permet de sélectionner des items une seule fois. Voyons comment ça marche.

Dans `exemple_context.libraries.yml`, ajoutez aux librairies (mon-js et mon-js2) une nouvelle dépendance: `core/once`. Lorsque nous sélectionnonons 'button.exemple-context', nous pouvons préciser que nous voulons le sélectionner une seule fois dans un contexte donné. Changeons nos documents JavaScript pour y ajouter `once()`;

### `js/mon-js.js` avec once()

    (function ($) {
      Drupal.behaviors.ExempleContext = {
        attach: function () {
          // once() est à utiliser avec précaution!
          $(once('mon-js', 'button.exemple-context'))
            .click(function () {
              console.log("Ceci est déclanché lorsqu'on clique le bouton");
            });
        }
      };
    })(jQuery);

### `js/mon-js2.js` avec once()

    (function ($) {
      Drupal.behaviors.ExempleContext2 = {
        attach: function () {
          // once() est à utiliser avec précaution!
          $(once('mon-js2', 'button.exemple-context'))
            .click(function () {
              console.log("Ceci est aussi déclanché lorsqu'on clique le bouton");
            });
        }
      };
    })(jQuery);

## Testons le résultat dans Safari

Le premier arguemnt de `once()` est une identité arbitraire. Cela veut dire que si nous appelons:

    $(once('ceci-peut-etre-nimporte-quoi', 'button.exemple-context'))

la première fois, nous aurons un résultat. Toutefois, les fois subséquentes, nous aurons un résultat vide.

Ainsi, le fait que nous utilisons une identité de once() différente dans `mon-js.js` et `mon-js2.js`, fait que les deux click handlers seront appelés une seule fois chaque.

En cliquant sur notre bouton sur Safari, nous aurons deux phrases dans notre console JavaScript:

    [Log] Ceci est déclanché lorsqu'on clique le bouton (mon-js.js, line 6)
    [Log] Ceci est aussi déclanché lorsqu'on clique le bouton (mon-js2.js, line 6)

## Qu'arrive-t-il lorsqu'on manipule dynamiquement le markup?

### Modifions `templates/exemplecontext.html.twig`:

    <div class="exemple-context-group">
      <button type="button" class="ajouter-un-bouton">Ajouter un bouton</button>
      <button type="button" class="exemple-context">Cliquez-moi</button>
    </div>

### Modifions `js/mon-js.js`

    (function ($) {
      Drupal.behaviors.ExempleContext = {
        attach: function () {
          $(once('ajouter-un-bouton', 'button.ajouter-un-bouton'))
            .click(function() {
              var $button = $('<button type="button" class="exemple-context">Cliquez-moi</button>');
              $button.appendTo('.exemple-context-group');
            });
          // once() est à utiliser avec précaution!
          $(once('mon-js', 'button.exemple-context'))
            .click(function () {
              console.log("Ceci est déclanché lorsqu'on clique le bouton");
            });
        }
      };
    })(jQuery);

Après un `drush cr`, rafraîchissons notre page.

Maintenant, nous pouvons ajouter autant de boutons qu'on veut. Ceci est pour illustrer ce qui arrive lorsqu'on modifie le markup de façon dynamique.

Le premier bouton "Cliquez-moi" déclanche nos actions (deux phrases dans notre console), mais les boutons que nous ajoutons dynamiquement avec le bouton "Ajouter un bouton" n'ont pas le comportement désiré.

## Réglons ça avec Drupal.attachBehaviors()

Lorsque le DOM est modifié, notre JavaScript custom n'y est pas attaché automatiquement. Nous devons en informer Drupal. Voici comment:

### Modifions, à nouveau  `js/mon-js.js`

    (function ($) {
      Drupal.behaviors.ExempleContext = {
        attach: function () {
          console.log('Attaching ExempleContext');
          $(once('ajouter-un-bouton', 'button.ajouter-un-bouton'))
            .click(function() {
              const button = $('<button type="button" class="exemple-context">Cliquez-moi</button>');
              button.appendTo('.exemple-context-group');
              const buttonGroupJustModified = $('.exemple-context-group .exemple-context').last()[0];
              Drupal.attachBehaviors(buttonGroupJustModified);
            });
          $(once('mon-js', 'button.exemple-context'))
            .click(function () {
              console.log("Ceci est déclanché lorsqu'on clique le bouton");
            });
        }
      };
    })(jQuery);

C'est quoi `buttonGroupJustModified`? On trouve l'élément du DOM qui correspond au groupe de bouton qu'on vient tout juste de modifier et on passe ça à `Drupal.attachBehaviors`.

Cela indique aux comportements Javascript de Drupal que seulement le bouton a changé de ne pas considérer l'ensemble du markup, mais uniquement ce qui a changé.

Encore faut-il que notre JavaScript tienne compte de cette information.

### Modifions, à nouveau  `js/mon-js2.js`

Ajoutons le contexte à `Drupal.behaviors.ExempleContext2`:

    (function ($) {
      Drupal.behaviors.ExempleContext2 = {
        attach: function (context) {
          $(once('mon-js2', 'button.exemple-context', context))
            .click(function () {
              console.log("Ceci est aussi déclanché lorsqu'on clique le bouton");
            });
        }
      };
    })(jQuery);

Maintenant, qu'on soit sur Safari ou sur Chrome, nous aurons, chaque fois que nous cliquons un bouton "Cliquez-moi", deux messages dans notre console, exactement ce que nous voulons!
