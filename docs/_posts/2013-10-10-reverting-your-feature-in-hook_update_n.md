---
layout: post
title: Reverting your feature in hook_update_n
id: 29
created: 1381432440
permalink: /blog/reverting-your-feature-hookupdaten/
redirect_from:
  - /blog/29/
  - /node/29/
---
/**
 * Revert the feature for stm_nav
 */
function mysite_deploy_update_7018() {
  features_revert(array('mysite_feature' => array('context')));
}

Go to admin/structure/features/mysite_feature/recreate
to figure ou the machine name (e.g. context)
