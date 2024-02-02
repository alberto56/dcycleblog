---
layout: post
title: A typical update script
id: 26
created: 1379601066
permalink: /blog/typical-update-script/
redirect_from:
  - /blog/26/
  - /node/26/
---
    SITE=mysite
    drush vset maintenance_mode 1
    drush cc all
    drush sql-dump > ~/$SITE.sql
    # to restore later on:
    # drush sqlc < ~/$SITE.sql
    drush en $SITE\_deploy
    drush updb -y
    drush cc all
    drush cron
    drush vset maintenance_mode 0
