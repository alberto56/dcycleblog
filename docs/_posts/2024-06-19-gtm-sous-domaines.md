---
layout: post
title: "GTM et les cookies sur les sous-domaines"
date: 2024-06-19T14:43:30.853Z
id: 2024-06-19
author: admin
tags:
  - blog
permalink: /blog/2024-06-19/gtm-sous-domaines/
redirect_from:
  - /blog/2024-06-19/
  - /node/2024-06-19/
---

C'est quoi GTM?
-----

Historiquement, pour associer un site web avec des service externes tels Google Analytics, il suffisait d'ouvrir un compte sur ce service et de coller un peu de JavaScipt sur votre site web. Ces bouts de JavaScript sont appelés des "tags".

Pour éviter de devoir changer le code source de notre site web chaque fois qu'on veut ajouter ou retirer un service externe, est apparu le concept d'un gestionnaire de tags, et le produit GTM (Google Tag Manager), comme intermédiaire entre votre site web et les services externes.

En soi, GTM ne fait rien du tout, c'est simplement une interface permettant de gérer des tags sans toucher au code source de votre site web. Le seul bout de JavaScript qui doit paraître sur votre site est le JavaScript de GTM lui-même.

GTM est conçu pour être configurée sur le tableau de bord GTM à <https://tagmanager.google.com/> et non sur le site web
-----

La philosophie même de GTM est de permettre à la personne spécialisée dans les tags de faire des changements directement sur le tableau de bord GTM et non dans le code source du site web.

Ma compréhension est donc que, de par sa conception, il semble impossible de configurer GTM directement sur le code source du site web.

Pour moi, les deux minutes au début de [la vidéo "Google Tag Manager Tutorial for Beginners (2024) with New Google Tag" de @AnalyticsMania sur YouTube (en anglais)](https://youtu.be/DiAgCihHW58?si=y36nPuxQZgYkAxmL&t=46), entre le code temporel 0:51 et 2:20, expliquent très bien la philosophie de GTM.

Ceci est une approche qui peut convenir à certaines équipes mais ce n'est pas nécessairement une meilleure approche par rapport à mettre les tags directement dans le code source du site web.

Par exemple, si vous êtes une petite équipe de développeurs qui gère les tags et le code source d'un site web, vous pourriez décider qu'il est préférable pour vous de gérer les tags dans le code de votre site et de ne pas utiliser GTM. Il peut y avoir plusieurs avantages à cela, dont la possibilité de garder toute votre configuration de tags dans le système de versionnage avec le code de votre site.

Si toutefois, une équipe séparée gère les tags et le code source du site, il peut être plus efficace d'utiliser GTM comme niveau d'abstration entre le code source du site web et la gestion des tags.

Google Analytics (GA) vs GTM et les cookies
-----

Par défaut, [selon le guide "Configure and customize cookies" publié par Google](https://developers.google.com/tag-platform/security/guides/customize-cookies):

> By default, Google tags use automatic cookie domain configuration. Cookies are set on the highest level of domain possible. For example, if your website address is blog.example.com, cookies are set on the example.com domain.

Selon mes tests, la même politique sur les cookies est appliquée à Google Analytics (GA).

Ainsi, sur site-1.example.com, que vous installiez GA directement sur ou en passant par GTM, et que vous ne changez aucun paramètre, les cookies agiront de façon suivante:

* Sur une page incognito de Chromium (ou sur un autre fureteur sur lequel vous vous assurez qu'il n'y a pas de mécanisme de blocage de trackers ou de cookies), vous téléchargez la page site-2.example.com *qui n'a aucun code GTM*.
* Vous vérifiez dans l'onglet Application &gt; cookies
* Aucun cookie n'apparaît (c'est normal!)
* Sur la même session incognito, vous téléchargez site-1.example.com qui a votre code GA directement ou via GTM.
* Vous vérifiez dans l'onglet Application &gt; cookies
* Vous aurez maintenant des cookies qui ressemblent à:

| Nom      | Domaine      |
|----------|--------------|
| _ga      | .example.com |
| _ga_XYZ  | .example.com |

* Toujours dans la même session incognito, téléchargez maintenant site-2.example.com *qui n'a aucun code GTM*.
* Vous vérifiez dans l'onglet Application &gt; cookies
* Vous aurez maintenant les mêmes cookies que dans site-1.example.com.

### Pourquoi est-ce un problème?

En soi, un cookie qui est visible à un sous-domaine qui n'a pas de code GTM associé ne semble rien faire du tout. Toutefois, certaines organisations pourrait avoir les problèmes suivants:

* Lorsqu'un utilisateur accepte les cookies sur site-1.example.com, il peut ne pas être clair pour cette personne qu'elle accepte aussi les cookies sur site-2.example.com, site-3.example.com, site-4.example.com. Imaginons un TLD comme .gouv.qc.ca, où des sites complètement différents pourraient être implémentés comme sous-domaines. Il est possible que nous voulions éviter que les cookies d'un sous-domaine ne s'activent sur d'autres sous-domaines, même s'ils ne sont pas utilisés.
* Tel que décrit dans le [issue 3438528 sur Drupal.org](https://www.drupal.org/project/google_tag/issues/3438528), dans le cas où un organisme tel une université (dans cet exemple `yale.edu`) a des centaines de sites web, des cookies d'un sous-domaine peuvent "polluer" tous les autres sous-domaines allant jusqu'à causer des erreurs de types "400 Bad Request: Request Header Or Cookie Too Large".

Comment limiter les cookies à un seul sous-domaine du TLD?
-----

Le TLD ou top-level domain, c'est le domaine que vous avez achetez chez un fournisseur de nom de domaine. Ça ressemble à `example.com` ou `example.qc.ca`.

Comment nous n'avons vu plus, Google associe par défaut les cookies aux TLD, et elle a le droit de le faire selon [la spécification RFC-6265](https://www.rfc-editor.org/rfc/rfc6265) qui indique:

> if the value of the Domain attribute is "example.com", the user agent will include the cookie in the Cookie header when making HTTP requests to example.com, www.example.com, and www.corp.example.com

Pour limiter les cookies à un seul sous-domaine du TLD, le guide "Configure and customize cookies" publié par Google contient [une section "Change cookie domain"](https://developers.google.com/tag-platform/security/guides/customize-cookies#tag-manager) qui elle-même a deux sections:

### gtag.js

Nous connaissons déjà GA et GTM, mais qu'est-ce que ce `gtag.js`? Selon ma compréhension (je ne l'ai jamais utilisé),

* il s'agit d'une sorte d'hybride entre l'approche de mettre les tags directement sur votre site et l'approche GTM;
* `gtag.js` n'est pas nécessaire sur vous utilisez GTM;
* l'utilisation de `gtag.js` (contrairement à GTM) permet de faire certaines configurations directement sur le code source de votre site web.

Selon ma compréhension, la configuration qu'on peut faire sur `gtag.js` est très proche des configurations qu'on peut faire si on inclut directement le code GA sur notre code source. Notamment, cela permet la configuration suivante:

    gtag('config', 'TAG_ID', {
        'cookie_domain': 'site-1.example.com'
    });

En d'autres termes, si vous utilisez `gtag.js` et non GTM, vous pouvez modifier le code source de votre site web pour y ajouter ce code. Et, en effet, c'est ce que le [module Drupal, maintenant obsolète, Google Analytics](https://www.drupal.org/project/google_analytics) semble [faire dans son code source](https://git.drupalcode.org/project/google_analytics/-/blob/4.x/src/EventSubscriber/GoogleAnalyticsConfig/DefaultConfig.php?ref_type=heads#L83-89).

### GTM

Nous avons déjà vu que l'approche GTM vise à migrer toute la configuration des tags du code source du site web vers le tableau de bord GTM. Ainsi, selon mes recherches, il semble impossible _via le code source du site web_ de forcer les cookies à apparaître uniquement sur tel ou tel sous-domaine. Plutôt, c'est au responsable GTM de se connecter à le tableau de bord GTM et de faire le changement suivant _dans toutes les instances du tag "Google Tag"_:

**Dans la section configuration, ajouter la variable cookie_domain ayant pour valeur sous-domaine.example.com**.

Pour tester que ça marche, j'ai créé deux sites:

| Répertoire GitHub                              | Domaine                                        |
|------------------------------------------------|------------------------------------------------|
| <https://github.com/dcycle/gtm-sous-domaine-1> | <https://gtm-sous-domaine-1.dcycleproject.org> |
| <https://github.com/dcycle/gtm-sous-domaine-2> | <https://gtm-sous-domaine-2.dcycleproject.org> |

Notons que les cookies semblent apparaître uniquement lorsque je teste les domaines avec [Tag Assistant](http://tagassistant.google.com) en étant connecté, donc il est probable que si vous téléchargiez le premier site, vous ne verrez pas de cookie. Je ne comprends pas pourquoi, mais la solution semble tout de même valide.

Le premier site est géré par GTM, et le deuxième ne l'est pas. Pour éviter la propagation de cookies d'un site à l'autre, j'ai ajouté, dans la section "Google Tag" de GTM, la variable cookie_domain avec la valeur gtm-sous-domaine-1.dcycleproject.org.

<img src="/assets/uploads/variable-cookie-domain-gtm.jpg" alt="Tableau de bord GTM montrant, sur le tag Google Tag, une variable cookie_domain avec la valeur gtm-sous-domaine-1.dcycleproject.org"/>

Dès que j'ai fait ça, les cookies sur gtm-sous-domaine-1.dcycleproject.org sont maintenant:

| Nom      | Domaine      |
|----------|--------------|
| _ga      | .gtm-sous-domaine-1.dcycleproject.org |
| _ga_XYZ  | .gtm-sous-domaine-1.dcycleproject.org |

et plus aucun cookie n'appraît sur https://gtm-sous-domaine-2.dcycleproject.org, ce qui est le comportement désiré.
