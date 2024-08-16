---
layout: post
title: "Limiter la taille d'une base de données dans Drupal"
date: 2024-08-16T14:43:30.853Z
id: 2024-08-16
author: admin
tags:
  - blog
permalink: /blog/2024-08-16/cache-drupal/
redirect_from:
  - /blog/2024-08-16/
  - /node/2024-08-16/
---

Si vous avez un site Drupal en production et que vos tables de base données débutant par `cache_` sont trop volumineuses, cet article examinera comment vous pouvez limiter leur taille.

Commençons par par regarder les tables de cache sur un site Drupal tout neuf:

    drush site:install
    drush sqlc
    ...
    show tables like 'cache_%';
    Empty set (0.003 sec)

Si nous visitons la page d'accueil

    curl -I "http://localhost"

Maintenant nos tables de cache ressemblent à:

    show tables like 'cache_%';
    +----------------------------+
    | Tables_in_drupal (cache_%) |
    +----------------------------+
    | cache_bootstrap            |
    | cache_config               |
    | cache_container            |
    | cache_data                 |
    | cache_default              |
    | cache_discovery            |
    | cache_dynamic_page_cache   |
    | cache_entity               |
    | cache_menu                 |
    | cache_page                 |
    | cache_render               |
    | cachetags                  |
    +----------------------------+

Et nous pouvons voir la taille des caches:

    select table_schema as database_name, table_name, round(sum((data_length + index_length)) / power(1024, 2), 2) as used_mb, round(sum((data_length + index_length + data_free)) / power(1024, 2), 2) as allocated_mb from information_schema.tables where table_schema = 'drupal' and table_type = 'BASE TABLE' and table_name like "cache_%" group by table_schema, table_name order by used_mb desc;
    +---------------+--------------------------+---------+--------------+
    | database_name | table_name               | used_mb | allocated_mb |
    +---------------+--------------------------+---------+--------------+
    | drupal        | cache_discovery          |    1.55 |         5.55 |
    | drupal        | cache_default            |    1.55 |         5.55 |
    | drupal        | cache_data               |    0.55 |         0.55 |
    | drupal        | cache_config             |    0.42 |         0.42 |
    | drupal        | cache_render             |    0.09 |         0.09 |
    | drupal        | cache_dynamic_page_cache |    0.08 |         0.08 |
    | drupal        | cache_bootstrap          |    0.06 |         0.06 |
    | drupal        | cache_entity             |    0.05 |         0.05 |
    | drupal        | cache_page               |    0.05 |         0.05 |
    | drupal        | cache_container          |    0.05 |         0.05 |
    | drupal        | cache_menu               |    0.05 |         0.05 |
    | drupal        | cachetags                |    0.02 |         0.02 |
    +---------------+--------------------------+---------+--------------+

Puisque, pour Drupal, http://example.com/ est une page différente de http://example.com/?query-param=1, nous pouvons très rapidement faire croître les tables de cache comme ceci:

    # Ceci qui suit prendra à peu près 15 minutes
    for i in {1..10000}; do echo "call $i"; curl -I "http://example.com?query-param=$i" > /dev/null; done

Maintenant on s'approche de 1Go de caches, surtout dans `cache_page`,  `cache_dynamic_page_cache` et `cache_render`:

    select table_schema as database_name, table_name, round(sum((data_length + index_length)) / power(1024, 2), 2) as used_mb, round(sum((data_length + index_length + data_free)) / power(1024, 2), 2) as allocated_mb from information_schema.tables where table_schema = 'drupal' and table_type = 'BASE TABLE' and table_name like "cache_%" group by table_schema, table_name order by used_mb desc;
    +---------------+--------------------------+---------+--------------+
    | database_name | table_name               | used_mb | allocated_mb |
    +---------------+--------------------------+---------+--------------+
    | drupal        | cache_dynamic_page_cache |  342.14 |       349.14 |
    | drupal        | cache_page               |  325.59 |       331.59 |
    | drupal        | cache_render             |  176.28 |       183.28 |
    | drupal        | cache_data               |   33.69 |        37.69 |
    | drupal        | cache_discovery          |    1.55 |         5.55 |
    | drupal        | cache_default            |    1.50 |         5.50 |
    | drupal        | cache_config             |    0.44 |         0.44 |
    | drupal        | cache_menu               |    0.28 |         0.28 |
    | drupal        | cache_bootstrap          |    0.11 |         0.11 |
    | drupal        | cache_entity             |    0.05 |         0.05 |
    | drupal        | cache_container          |    0.05 |         0.05 |
    | drupal        | cachetags                |    0.02 |         0.02 |
    +---------------+--------------------------+---------+--------------+
    12 rows in set (0.002 sec)

Nous pouvons voir combien de lignes chaque table contient:

    select table_name, sum(table_rows) from information_schema.tables where table_name like 'cache_%' group by table_name order by sum(table_rows) desc;
    +--------------------------+-----------------+
    | table_name               | sum(table_rows) |
    +--------------------------+-----------------+
    | cache_data               |           20027 |
    | cache_render             |           10479 |
    | cache_page               |            9428 |
    | cache_dynamic_page_cache |            8916 |
    | cache_config             |             186 |
    | cache_default            |              53 |
    | cache_discovery          |              47 |
    | cache_bootstrap          |               6 |
    | cache_menu               |               3 |
    | cache_entity             |               1 |
    | cache_container          |               1 |
    | cachetags                |               0 |
    +--------------------------+-----------------+

Selon [Database cache bins are now fixed size — no more unlimited growth, sur Drupal.org](https://www.drupal.org/node/2891281):

> we also limit the number of cache items in each database cache bin table to at most 5,000 rows by default

Nous pouvons voir ceci en action en faisant:

    drush cron

Ceci réduit le nombre d'entrées dans les tables de cache à près de 5000:

    select table_name, sum(table_rows) from information_schema.tables where table_name like 'cache_%' group by table_name order by sum(table_rows) desc;
    +--------------------------+-----------------+
    | table_name               | sum(table_rows) |
    +--------------------------+-----------------+
    | cache_data               |            5444 |
    | cache_dynamic_page_cache |            4930 |
    | cache_page               |            4426 |
    | cache_render             |            2137 |
    | cache_config             |             257 |
    | cache_default            |             137 |
    | cache_discovery          |              50 |
    | cachetags                |              14 |
    | cache_bootstrap          |               7 |
    | cache_menu               |               4 |
    | cache_entity             |               2 |
    | cache_container          |               1 |
    +--------------------------+-----------------+

Toutefois la base de données demeure passablement volumineuse:

    +---------------+--------------------------+---------+--------------+
    | database_name | table_name               | used_mb | allocated_mb |
    +---------------+--------------------------+---------+--------------+
    | drupal        | cache_page               |  330.59 |       476.59 |
    | drupal        | cache_dynamic_page_cache |  308.56 |       347.56 |
    | drupal        | cache_render             |   54.27 |       185.27 |
    | drupal        | cache_data               |   27.12 |        39.12 |
    | drupal        | cache_container          |    1.55 |         1.55 |
    | drupal        | cache_default            |    1.44 |         5.44 |
    | drupal        | cache_discovery          |    1.42 |         5.42 |
    | drupal        | cache_config             |    0.50 |         0.50 |
    | drupal        | cache_menu               |    0.09 |         0.09 |
    | drupal        | cache_bootstrap          |    0.08 |         0.08 |
    | drupal        | cache_entity             |    0.05 |         0.05 |
    | drupal        | cachetags                |    0.02 |         0.02 |
    +---------------+--------------------------+---------+--------------+


Nous pourrions vider la cache en faisant:

    drush cr

Toutefois vider l'ensemble de la cache manque de subtilité. Plutôt, nous aimerions limiter la croissance des tables de cache. D'autres techniques, comme par exemple utiliser Redis au lieu de la base de données, ou encore des couches de cache comme Cloudflare, sortent du cadre de cette discussion.

## Limiter le nombre de lignes dans les tables de cache

Selon [Database cache bins are now fixed size — no more unlimited growth, sur Drupal.org](https://www.drupal.org/node/2891281):

> we also limit the number of cache items in each database cache bin table to at most 5,000 rows by default

Nous pouvons voir ceci en action en faisant:

   drush cron
   drush sqlc
   select count(*) from cache_page;

Après un `cron`, le nombre d'entrées dans les tables de cache est limité à 5000.

Toutefois dans nos tests ceci est tout de même assez grand:

    +---------------+--------------------------+---------+--------------+
    | database_name | table_name               | used_mb | allocated_mb |
    +---------------+--------------------------+---------+--------------+
    | drupal        | cache_dynamic_page_cache |  310.53 |       347.53 |
    | drupal        | cache_page               |  293.91 |       448.91 |
    | drupal        | cache_render             |   52.20 |       185.20 |
    | drupal        | cache_data               |   28.16 |        39.16 |
    | drupal        | cache_default            |    2.45 |         6.45 |
    | drupal        | cache_discovery          |    2.36 |         6.36 |
    | drupal        | cache_config             |    0.48 |         0.48 |
    | drupal        | cache_container          |    0.39 |         0.39 |
    | drupal        | cache_menu               |    0.20 |         0.20 |
    | drupal        | cache_bootstrap          |    0.14 |         0.14 |
    | drupal        | cache_entity             |    0.05 |         0.05 |
    | drupal        | cache_toolbar            |    0.05 |         0.05 |
    | drupal        | cachetags                |    0.02 |         0.02 |
    +---------------+--------------------------+---------+--------------+
    13 rows in set (0.004 sec)

## Solution 1: limiter davatage les lignes de cache

La limite par défaut est de 5000 lignes. Nous pourrions la réduire à 1000 lignes en ajoutant ceci à `settings.php`:

    $settings['database_cache_max_rows']['bins']['dynamic_page_cache'] = 1000;
    $settings['database_cache_max_rows']['bins']['page'] = 1000;

(Nous ciblons `dynamic_page_cache` et `page` car ce sont les tables les plus volumineuses dans nos tests; mais rien ne nous empêche de cibler d'autres tables.)

Après un `drush cron`, nous voyons que l'espace utilisé est réduit considérablement pour ces deux tables:

    +---------------+--------------------------+---------+--------------+
    | database_name | table_name               | used_mb | allocated_mb |
    +---------------+--------------------------+---------+--------------+
    | drupal        | cache_page               |  189.42 |       481.42 |
    | drupal        | cache_dynamic_page_cache |  120.16 |       347.16 |

## Solution 2: utiliser le module Compressed Cache

Le module [Compressed Cache](https://www.drupal.org/project/compressed_cache) permet de réduire davantage la taille des caches.

Commençons par l'installer:

    composer require drupal/compressed_cache
    drush en compressed_cache

Ensuite, dans `settings.php`, nous ajoutons:

    $settings['cache']['default'] = 'cache.backend.database_compressed_cache';

Maintenant nous pouvons tout vider avec `drush cr`, et voir combien de place prennent à peu près 1000 entrées de cache.

    drush cr
    # Nous faisons 1000 appels, pas 10,000 comme plus tôt, donc ça devrait
    # prendre moins de 2 minutes.
    for i in {1..1000}; do echo "call $i"; curl -I "http://example.com?query-param=$i" > /dev/null; done

Avec à peu près 1000 lignes en cache, voyons comment ça se compare:

|            | Sans Compressed Cache  | Avec Compressed Cache  |
|------------|------------------------|------------------------|
| cache_dynamic_page_cache, cache_page et cache_render | 91.77Mo | 38.89Mo |
| Temps que ça prend pour visiter 1000 pages non-cachées | 2m23s | 2m23s |
| Temps que ça prend pour visiter 1000 pages cachées | 0m29s | 0m29s |

Dans nos tests, nous sauvons 57% de l'espace avec Compressed Cache, toutefois ça ne prend pas plus de place.

## Inconvénients de Compressed Cache

Parfois si vous déboguez quelque chose avec la cache, il peut être utile de faire une recherche dans les données de la cache, par exemple:

    select cid from page_cache were data like '%ceci-est-une-classe-css-quon-cherche%';

Avec Compressed Cache, ce genre de recherche n'est plus possible.

## Sources et ressources

* [List tables by their size in MariaDB database, Rene Castro, 21st January, 2019, Dataedo](https://dataedo.com/kb/query/mariadb/list-of-tables-by-their-size)
* [Issue Drupal #3011426: Page cache creates vast amounts of unneeded cache data](https://www.drupal.org/project/drupal/issues/3011426)
* [Change record Drupal: Database cache bins are now fixed size — no more unlimited growth](https://www.drupal.org/node/2891281)
* [The relationship between internal-page-cache and dynamic-page-cache by Atsu.S on 19 Jul 2022 at 03:55 EDT, Drupal.org](https://www.drupal.org/forum/support/post-installation/2022-07-19/the-relationship-between-internal-page-cache-and-dynamic-page-cache)
* [Module Page Cache Query Ignore](https://www.drupal.org/project/page_cache_query_ignore)
* [Module Compressed Cache](https://www.drupal.org/project/compressed_cache)
