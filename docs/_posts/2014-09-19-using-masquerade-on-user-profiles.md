---
layout: post
title: Using masquerade on user profiles
author: admin
id: 74
created: 1411165373
tags:
  - snippet
permalink: /blog/74/using-masquerade-user-profiles/
redirect_from:
  - /blog/74/
  - /node/74/
---
    // put this in your template.php's hook_preprocess_user_profile(&$variables)

    // admins can masquerade as specific users
    if (isset($_SESSION['masquerading'])) {
      $block = masquerade_block_1();
      $variables['masquerade'] = drupal_render($block);
    }
    elseif (isset($variables['elements']['masquerade']['#markup'])) {
      $variables['masquerade'] = $variables['elements']['masquerade']['#markup'];
    }

    // put this in your user profile template
    <?php if (isset($masquerade) && $masquerade): ?>
      <?php print $masquerade; /* lets admins simulate what it's like to be a specific user */ ?>
    <?php endif; ?>
