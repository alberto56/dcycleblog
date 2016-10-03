---
layout: post
title: Develop locally with rich dummy content
id: 24
created: 1378490687
permalink: /blog/develop-locally-rich-dummy-content/
redirect_from:
  - /blog/24/
  - /node/24/
---
See https://drupal.org/node/1748302#comment-7834865

    function devel_generate_extras_node_presave($node) {
      if (isset($node->devel_generate)) {
        switch ($node->type) {
          case 'article':
            // on my site articles are in the default filtered_html, and
            // have a few hyperlinks
            $all_matches = array();
            preg_match_all('/[^ \.][^ \.]* [^ \.][^ \.]*/', $node->body[LANGUAGE_NONE][0]['value'], $all_matches);
            $matches = $all_matches[0];
            for ($i = 0; $i < 3; $i++) {
              if (count($matches)) {
                $match = $matches[rand(0, count($matches) - 1)];
                $node->body[LANGUAGE_NONE][0]['value'] = str_replace($match, '<a href="http://example.com/">' . $match . '</a>', $node->body[LANGUAGE_NONE][0]['value']);
              }
            }
            break;
    
          case 'page':
            // on my site pages generally have paragraphs and code, and are in the
            // markdown text format
            $all_matches = array();
            preg_match_all('/[A-Za-z].*/', $node->body[LANGUAGE_NONE][0]['value'], $all_matches);
            $matches = $all_matches[0];
            foreach ($matches as $match) {
              // paragraphs are 4 times more common than code
              $tags = array('p', 'p', 'p', 'p', 'code');
              $tag = $tags[rand(0,count($tags)-1)];
              $node->body[LANGUAGE_NONE][0]['value'] = str_replace($match, '<' . $tag . '>' . (($tag == 'code')?devel_generate_extras_generate_code():$match) . '</' . $tag . '>', $node->body[LANGUAGE_NONE][0]['value']);
            }
            $node->body[LANGUAGE_NONE][0]['format'] = 'markdown';
            break;
    
          default:
            // other node types can be lorem ipsum
            break;
        }
      }
    }
