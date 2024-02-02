---
layout: post
title:  "Caching a Drupal 8 REST resource"
date:   2018-01-24
tags:
  - planet
  - blog
id: 2018-01-24
permalink: /blog/2018-01-24/caching-drupal-8-rest-resource/
redirect_from:
  - /blog/2018-01-24/
---

Here are a few things I learned about caching for REST resources.

There are probably better ways to accomplish this, but here is what works for me.

Let's say we have a REST resource that looks something like this in `.../my_module/src/Plugin/rest/resource/MyRestResource.php` and we have enabled it using the [Rest UI](https://www.drupal.org/project/restui) module and given anonymous users permission to view it:

    <?php

    namespace Drupal\my_module\Plugin\rest\resource;

    use Drupal\rest\ResourceResponse;

    /**
     * This is just an example.
     *
     * @RestResource(
     *   id = "this_is_just_an_example",
     *   label = @Translation("Display the title of node 1"),
     *   uri_paths = {
     *     "canonical" = "/api/v1/get"
     *   }
     * )
     */
    class MyRestResource extends ResourceBase {

      /**
       * {@inheritdoc}
       */
      public function get() {
        $node = node_load(1);
        $response = new ResourceResponse(
          [
            'title' => $node->getTitle(),
            'time' => time(),
          ]
        );
        return $response;
      }

    }

Now, we can visit http://example.localhost/api/v1/get?_format=json and we will see something like:

    {"title":"Some Title","time":1516803204}

Reloading the page, 'time' stays the same. That means caching is working; we are not re-computing our Json output each time someone requests it.

How to invalidate the cache when the title changes.
-----

If we edit node 1 and change its title to, say, "Another title", and reload http://example.localhost/api/v1/get?_format=json, we'll see the old title. To make sure the cache is invalidated when this happens, we need to provide **cacheability metadata** to our response telling it when it needs to be recomputed.

Our node, when it's loaded, contains within it all the caching metadata needed to describe when it should be recomputed: when the title changes, when new filters are added to the text format that's being used, etc. We can add this information to our ResourceResponse like this:

    ...
    $response->addCacheableDependency($node);
    return $response;
    ...

When we clear our cache with `drush cr` and reload our page, we'll see something like:

    {"title":"Another title","time":1516804411}

Even more fun is changing the title of node 1 and reloading our Json page, and seeing the title and time change _without clearing the cache_:

    {"title":"Yet another title","time":1516804481}

How to set custom cache invalidation events
-----

Let's say you want to trigger a cache rebuild for some reason other than those defined by the node itself (title change, etc.).

A real-world example might be events: an "upcoming events" page should only display events which start later than now. If we invalidate the cache every day, then we'll never show yesterday's events in our events feed. Here, we need to add our custom cache invalidation event, in this case "rebuild events feed".

For the purpose of this demo, we won't actually build an events feed, but we'll see how cron might be able to trigger cache invalidation.

Let's add the following code to our response:

    ...
    use Drupal\Core\Cache\CacheableMetadata;
    ...
    $response->addCacheableDependency($node);
    $response->addCacheableDependency(CacheableMetadata::createFromRenderArray([
      '#cache' => [
        'tags' => [
          'rebuild-events-feed',
        ],
      ],
    ]));
    return $response;
    ...

This uses Drupal's [cache tags](https://www.drupal.org/docs/8/api/cache-api/cache-tags) concept and tells Drupal that when the cache tag 'rebuild-events-feed' is invalidated, all cacheable responses which have that cache tag should be invalidated as well. I prefer this to the 'max-age' cache tag because it allows us more fine-grained control over when to invalidate our caches.

On cron, we could only invalidate 'rebuild-events-feed' if events have passed since our last invalidation of that tag, for example.

For this example, we'll just invalidate it manually. Clear your cache to begin using the new code (`drush cr`), then load the page, you will see something like:

    {"hello":"Yet another title","time":1516805677}

As always, the time remains the same no matter how many times you reload the page.

Let's say you are in the midst of a cron run and you have determined that you need to invalidate your cache for response which have the cache tag 'rebuild-events-feed', you can run:

    \Drupal::service('cache_tags.invalidator')->invalidateTags(['rebuild-events-feed'])

Let's do it in Drush to see it in action:

    drush ev "\Drupal::service('cache_tags.invalidator')->\
      invalidateTags(['rebuild-events-feed'])"

We've just invalidated our 'rebuild-events-feed' tag and, hence, Responses that use it.

The dreaded "leaked metadata" error
-----

This one is beyond my competence level, but I wanted to mention it anyway.

Let's say you want to output your node's URL to Json, you might consider computing it using `$node->toUrl()->toString()`. This will give us "/node/1".

Let's add it to our code:

    ...
    'title' => $node->getTitle(),
    'url' => $node->toUrl()->toString(),
    'time' => time(),
    ...

This results in a very [ugly error which completely breaks your site (at least at the time of this writing)](https://www.drupal.org/project/drupal/issues/2638686): "The controller result claims to be providing relevant cache metadata, but leaked metadata was detected. Please ensure you are not rendering content too early.".

The problem, it seems, is that Drupal detects that the [URL object](https://api.drupal.org/api/drupal/core%21lib%21Drupal%21Core%21Url.php/class/Url/8.2.x), like the node we saw earlier, contains its own internal information which tells it when its cache should be invalidated. Converting it to a string prevents the Response from being informed about that information somehow (again, if someone can explain this better than me, please leave a comment), so an exception is thrown.

The ['toString()' function](https://api.drupal.org/api/drupal/core%21lib%21Drupal%21Core%21Url.php/function/Url%3A%3AtoString/8.4.x) has an optional parameter, "$collect_bubbleable_metadata", which can be used to get not just a string, but also information about when its cache should be invalidated. In Drush, this will look like something like:

    drush ev 'print_r(node_load(1)->toUrl()->toString(TRUE))'
    Drupal\Core\GeneratedUrl Object
    (
        [generatedUrl:protected] => /node/1
        [cacheContexts:protected] => Array
            (
            )

        [cacheTags:protected] => Array
            (
            )

        [cacheMaxAge:protected] => -1
        [attachments:protected] => Array
            (
            )

    )

This changes the return type of toString(), though: toString() no longer returns a string but a [GeneratedUrl](https://api.drupal.org/api/drupal/core%21lib%21Drupal%21Core%21GeneratedUrl.php/class/GeneratedUrl/8.2.x), so this won't work:

    ...
    'title' => $node->getTitle(),
    'url' => $node->toUrl()->toString(TRUE),
    'time' => time(),
    ...

It gives us the error "Could not normalize object of type Drupal\Core\GeneratedUrl, no supporting normalizer found".

ohthehugemanatee [commented on Drupal.org](https://www.drupal.org/project/drupal/issues/2638686#comment-12282657) on how to fix this. Integrating his suggestion, our code now looks like:

    ...
    $url = $node->toUrl()->toString(TRUE);
    $response = new ResourceResponse(
      [
        'title' => $node->getTitle(),
        'url' => $url->getGeneratedUrl(),
        'time' => time(),
      ]
    );
    $response->addCacheableDependency($node);
    $response->addCacheableDependency($url);
    ...

This will now work as expected.

With all the fun we're having, though, let's take this a step further, let's say we want to export the feed of frontpage items in our Response:

    $url = $node->toUrl()->toString(TRUE);
    $view = \Drupal\views\Views::getView("frontpage"); 
    $view->setDisplay("feed_1");
    $view_render_array = $view->render();
    $rendered_view = render($view_render_array);

    $response = new ResourceResponse(
      [
        'title' => $node->getTitle(),
        'url' => $url->getGeneratedUrl(),
        'view' => $rendered_view,
        'time' => time(),
      ]
    );
    $response->addCacheableDependency($node);
    $response->addCacheableDependency($url);
    $response->addCacheableDependency(CacheableMetadata::createFromRenderArray($view_render_array));

You will not be surpised to see the "leaked metadata was detected" error again... In fact you have come to love and expect this error at this point.

Here is where I'm completely out of my league; according to Crell, ["[i]f you [use render() yourself], you're wrong and you should fix your code "](https://www.drupal.org/project/drupal/issues/2450993#comment-10084498), but I'm not sure how to get a rendered view without using render() myself... I've implemented a variation on a [comment on Drupal.org by mikejw](https://www.drupal.org/project/drupal/issues/2638686#comment-12381959) suggesting using different _render context_ to prevent Drupal from complaining.

    $view_render_array = NULL;
    $rendered_view = NULL;
    \Drupal::service('renderer')->executeInRenderContext(new RenderContext(), function () use ($view, &$view_render_array, &$rendered_view) {
      $view_render_array = $view->render();
      $rendered_view = render($view_render_array);
    });

If we check to make sure we have this line in our code:

    $response->addCacheableDependency(CacheableMetadata::createFromRenderArray($view_render_array));

we're telling our Response's cache to invalidate whenever our view's cache invaliates. So, for example, if we have several nodes promoted to the front page in our view, we can modify any one of them and our entire Response's cache will be invalidated and rebuilt.

Resources and further reading
-----

* [Stack Exchange Drupal Answers: How can I use the same render cache but for json?](https://drupal.stackexchange.com/questions/219239/how-can-i-use-the-same-render-cache-but-for-json)
* [Cached JSON responses in Drupal 8, Aaron Crosman, May 6, 2017, Spinning Code blog](https://spinningcode.org/2017/05/cached-json-responses-in-drupal-8/)
* [Drupal.org issue: Generating cacheable responses results in Logic Exception](https://www.drupal.org/project/drupal/issues/2745475)
* [Drupal.org Issue: Exception in EarlyRenderingControllerWrapperSubscriber is a DX nightmare, remove it](https://www.drupal.org/project/drupal/issues/2638686)
* [Cache tags explained](https://www.drupal.org/docs/8/api/cache-api/cache-tags)
* [Using normalizers to alter REST JSON structure in Drupal 8,, Edward Chan, March 22, 2017, Mediacurrent](http://www.mediacurrent.com/blog/using-normalizers-alter-rest-json-structure-drupal-8)
* [ModifiedResourceResponse](https://api.drupal.org/api/drupal/core!modules!rest!src!ModifiedResourceResponse.php/8.2.x), to return responses which are never cached.
