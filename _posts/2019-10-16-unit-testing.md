---
layout: post
title:  "Start unit testing your Drupal and other PHP code today"
date:   2019-10-16
id: 2019-10-16
tags:
  - blog
  - planet
permalink: /blog/2019-10-16/unit-testing/
redirect_from:
  - /blog/2019-10-16/
  - /blog/2019-10-03/
---

Unit tests are the fastest, most reliable kinds of tests: they confirm that the smallest _units_ of your code, i.e. class methods, work as expected.

Unit tests do not require a full environment with a database and external libraries; this makes unit tests extremely fast.

In this article we will look at how to take any PHP code -- a Drupal site or module, or indeed any other PHP codebase unrelated to Drupal -- and start unit testing it _today_. We'll start by setting up tests which work for any PHP code, and then we'll see how to run your tests on the Drupal testbot if you so desire.

Before we start testing
-----

Unit tests are useless unless they are run on every change (commit) to a codebase through continuous integration (CI). And it's excruciatingly painful to make CI work without some sort of platform-agnostic DevOps setup (we'll use a Docker-based workflow), so before we even start testing, we'll set up CI and Docker.

Docker for all things
-----

In the context of this article, we'll define DevOps as a way to embed all dependencies within our code, meaning **we want to limit the number of dependencies on our computer or CI server** to run our code. To do this, we will start by installing and starting [Docker Desktop](https://www.docker.com/products/docker-desktop).

Once you've set it up, confirm you have Docker running:

    docker -v
    # Docker version 19.03.2, build 6a30dfc

At this point, we can be assured that any code we run through Docker will run on any machine which has Docker installed. In this article we'll use mostly PHPUnit, so instead of installing and configuring PHPUnit on our computer _and_ our CI server _and_ our colleagues' computers, we can simply make sure our computer and our CI server have Docker installed, and run:

    docker run --rm phpunit/phpunit --version

The first time this is run on an environment, it should result in:

    Unable to find image 'phpunit/phpunit:latest' locally
    latest: Pulling from phpunit/phpunit
    Digest: sha256:bbbb143951f55fe93dbfed9adf130cae8623a1948f5a458e1aabbd175f7cb0b6
    Status: Downloaded newer image for phpunit/phpunit:latest
    PHPUnit 6.5.13 by Sebastian Bergmann, Julien Breux (Docker) and contributors.

On subsequent runs it will result in:

    PHPUnit 6.5.13 by Sebastian Bergmann, Julien Breux (Docker) and contributors.

Installing PHPUnit can also be done through Composer. In this article we won't use Composer because

* that would require us to manage a specific version of PHP on each machine;
* Composer does not work for programming languages other than PHP (say, for example, we want to unit test Javascript or Python).

Let's get started!

Host your code on Github or Bitbucket
-----

We will avoid getting ahead of ourselves by learning and using Drupal's unit test classes (which are based on PHPUnit) and testing infrastructure (we'll do that below): we want to start by understanding how to unit test _any_ PHP code (Drupal or otherwise).

To that end, we will need to host our code (or a mirror thereof) on non-Drupal infrastructure. Github and Bitbucket both integrate with [CircleCI](http://circleci.com), a free, fast, and easy cloud continuous integration (CI) service with no vendor lock-in; we'll use CircleCI later on in this article. With understanding of general unit testing principles under your belt, you can later move on to use framework-specific (including Drupal-specific) testing environments if you deem it necessary (for example if you are a contributor to core or to contrib modules which follow Drupal's testing guidelines).

To demonstrate the principles in this article, I have taken a random Drupal 8 module which, at the time of this writing, has no unit tests, [Automatic Entity Label](https://www.drupal.org/project/auto_entitylabel). My selection is completely arbitrary, and I don't use this module myself, and I'm not advocating you use it or not use it.

So, as my first step, I have added [v. 8.x-3.0-beta1](https://www.drupal.org/project/auto_entitylabel/releases/8.x-3.0-beta1) of this module _as is_ to Github, and tagged it as "original".

[You can see the version I uploaded to Github, without tests, here](https://github.com/dcycle/unit-test-tutorial/tree/original). There are no unit tests -- yet.

Start continuous integration
-----

Because, as we mentioned above, automated testing is all but useless without continuous integration (CI) to confirm your tests are passing, the next step is to set up CI. Attaching CircleCI to Github repos is straightforward. I started by adding a test that simply confirms that we can access PHPUnit on our CI environment.

[Here is the changes I made to my code to add continuous integration](https://github.com/dcycle/unit-test-tutorial/compare/original...circle-ci). At this stage, this code only confirms that PHPUnit can be run via Docker, nothing else. If you want to follow along with your own codebase, you can add the same minor changes (in fact you are encouraged to do so). The change to the README.md document is a "Badge" which displays as green if tests pass, and red if they don't, on the project's home page. The rest is straightforward.

Once your code is set up for CI integration, create an account and log on to [CircleCI](http://circleci.com) using your Github account (Bitbucket works also), select your project from your list of projects ("Set Up Project" button), and start building it ("Start Building" button); that's it!

[Here is my very first build for my version of Auto Entity Label](https://circleci.com/gh/dcycle/unit-test-tutorial/1). It is worth unfolding the "Tests" section and looking at the test results:

    ./scripts/ci.sh
    Unable to find image 'phpunit/phpunit:latest' locally
    latest: Pulling from phpunit/phpunit
    Digest: sha256:bbbb143951f55fe93dbfed9adf130cae8623a1948f5a458e1aabbd175f7cb0b6
    Status: Downloaded newer image for phpunit/phpunit:latest
    PHPUnit 6.5.13 by Sebastian Bergmann, Julien Breux (Docker) and contributors.

You'll notice that you have output very similar to what you have on your own computer. That's the magic of Docker: build once, run anywhere. Without it, Continuous Integration is like pulling teeth.

Setting up PHPUnit to actually run tests
-----

Before we can test anything, PHPUnit needs to know where the tests reside, which tests to run, and how to autoload classes based on their namespace. Different frameworks, including Drupal, have recommendations on all this, but to get a good idea of how PHPUnit works, let's start from scratch by creating four new files in our project (keep them empty for now):

* ./phpunit.xml, at the root of our project, will define where are tests are located, and where our autoloader is located.
* ./phpunit-autoload.php, at the root of our project, is our autoloader; it tells PHPUnit that, for example, the namespace `Drupal\auto_entitylabel\AutoEntityLabelManager` corresponds to the file `src/AutoEntityLabelManager`.
* ./phpunit-bootstrap.php, we'll leave empty for now, and look at it later on.
* ./tests/AutoEntityLabelManagerTest.php, which will contain a test for the AutoEntityLabelManager class.

### phpunit.xml

In this file, we'll tell PHPUnit where to find our tests, and where the autoloader is. Different developers have their own preferences for what to put here, and Drupal has specific recommendations, but for now we'll just use a simple file declaring that our tests are in ./tests (although they could be anywhere), and that the file `phpunit-autoload.php` (you could name it anything) should be loaded before each test is run:

    <?xml version="1.0" encoding="UTF-8"?>
    <phpunit bootstrap="phpunit-autoload.php">
      <testsuites>
        <testsuite name="myproject">
          <directory>./tests</directory>
        </testsuite>
      </testsuites>
    </phpunit>

### phpunit-autoload.php

In this file, we'll tell PHPUnit how to find files based on namespaces. Different projects do this differently. For example, Drupal 7 has a custom Drupal-only way of autoloading classes; Drupal 8 uses the PSR-4 standard. In our example, we're telling PHPUnit that any code which uses the class `Drupal\auto_entitylabel\Something` will load the corresponding file `./src/Something.php`:

    <?php

    /**
     * @file
     * PHPUnit class autoloader.
     *
     * PHPUnit knows nothing about Drupal, so provide PHPUnit with the bare
     * minimum it needs to know in order to find classes by namespace.
     *
     * Used by the PHPUnit test runner and referenced in ./phpunit.xml.
     */

    spl_autoload_register(function ($class) {
      if (substr($class, 0, strlen('Drupal\\auto_entitylabel\\')) == 'Drupal\\auto_entitylabel\\') {
        $class2 = str_replace('Drupal\\auto_entitylabel\\', '', $class);
        $path = 'src/' . str_replace('\\', '/', $class2) . '.php';
        require_once $path;
      }
    });

### phpunit-bootstrap.php

(We'll leave that one empty for now, but later on we'll use it to put dummy versions of classes that Drupal code expects to find.)

### tests/AutoEntityLabelManagerTest.php

Here is our first test. Let's start with a very simple unit test: once which tests a pure function with no externalities.

Let's take AutoEntityLabelManager::auto_entitylabel_entity_label_visible().

[Here it is context](https://github.com/dcycle/unit-test-tutorial/blob/circle-ci/src/AutoEntityLabelManager.php#L359-L366), and here is the actual code we want to test:

    public static function auto_entitylabel_entity_label_visible($entity_type) {
      // @codingStandardsIgnoreEnd
      $hidden = [
        'profile2' => TRUE,
      ];
      return empty($hidden[$entity_type]);
    }

This is actual code which exists in the Auto Entity Label project; I have never tried this function in a running Drupal instance, I'm not even sure why it's there, _but I can still test it_. I assume that if I call `AutoEntityLabelManager::auto_entitylabel_entity_label_visible('whatever')`, I should get `TRUE` as a response. This is what I will test for in `./tests/AutoEntityLabelManagerTest.php`:

    <?php

    namespace Drupal\auto_entitylabel\Tests;

    use Drupal\auto_entitylabel\AutoEntityLabelManager;
    use PHPUnit\Framework\TestCase;

    /**
     * Test AutoEntityLabelManager.
     *
     * @group myproject
     */
    class AutoEntityLabelManagerTest extends TestCase {

      /**
       * Test for auto_entitylabel_entity_label_visible().
       *
       * @cover ::auto_entitylabel_entity_label_visible
       */
      public function testAuto_entitylabel_entity_label_visible() {
        $this->assertTrue(AutoEntityLabelManager::auto_entitylabel_entity_label_visible('whatever') === TRUE, 'Label "whatever" is visible.');
      }

    }

For test methods to be called by PHPUnit, they need to start with a lowercase `test`.

(If you have looked at other Drupal unit testing tutorials, you might have noticed that Drupal unit tests are based not on `PHPUnit\Framework\TestCase` but on `Drupal\Tests\UnitTestCase`. The latter provides some useful, but not critical, helper code. In our case, using PHPUnit directly without Drupal means we don't depend on Drupal to run our code; and we can better understand the intricacies of PHPUnit.)

### scripts/ci.sh

Finally we'll need to tweak ./scripts/ci.sh a bit:

    docker run --rm -v "$(pwd)":/app phpunit/phpunit \
      --group myproject

Adding `-v "$(pwd)":/app` shares our code on our host computer or server with a directory called `/app` on the PHPUnit Docker container, so PHPUnit actually has access to our code. `--group myproject` runs all tests in the "myproject" group (recall that in `tests/AutoEntityLabelManagerTest.php`, we have added `@group myproject` to the class comment).

[Here are the changes we made to our code](https://github.com/dcycle/unit-test-tutorial/compare/circle-ci...first-problem).

Running our first test... and running into our first problem
-----

With all those changes in place, if you run `./scripts/ci.sh`, you should have this output:

    $ ./scripts/ci.sh
    PHPUnit 6.5.13 by Sebastian Bergmann, Julien Breux (Docker) and contributors.

...and this Fatal error...

    PHP Fatal error:  Trait 'Drupal\Core\StringTranslation\StringTranslationTrait' not found in /app/src/AutoEntityLabelManager.php on line 16
    ...

So what's happening here? It turns out `AutoEntityLabelManager` [uses something called `StringTranslationTrait`](https://github.com/dcycle/unit-test-tutorial/blob/circle-ci/src/AutoEntityLabelManager.php#L16). A PHP trait is a code sharing pattern. It's a fascinating topic and super useful to write testable code (we'll get to it later); but right now we don't need it and don't really care about it, it's just getting in the way of our test. We somehow need to tell PHPUnit that [Drupal\Core\StringTranslation\StringTranslationTrait](https://github.com/dcycle/unit-test-tutorial/blob/first-problem/src/AutoEntityLabelManager.php#L5) needs to exist, _but we don't really care -- right now -- what it does_.

That's where our `phpunit-bootstrap.php` file comes in. In it, we can define `Drupal\Core\StringTranslation\StringTranslationTrait` so that PHP will not complain that it does not exit.

In phpunit-autoload.php, require phpunit-bootsrap.php:

    require_once 'phpunit-bootstrap.php';

And in phpunit-bootsrap.php, define a dummy version of Drupal\Core\StringTranslation\StringTranslationTrait:

    <?php

    /**
     * @file
     *
     * PHPUnit knows nothing about Drupal. Declare required classes here.
     */

    namespace Drupal\Core\StringTranslation {
      trait StringTranslationTrait {}
    }

[Here is the diff in our repo](https://github.com/dcycle/unit-test-tutorial/compare/first-problem...first-running-test).

Running our first passing test!
-----

This is a big day for you, it's _the day of your first passing test_:

    $ ./scripts/ci.sh
    PHPUnit 6.5.13 by Sebastian Bergmann, Julien Breux (Docker) and contributors.

    .                                                                   1 / 1 (100%)

    Time: 124 ms, Memory: 4.00MB

    OK (1 test, 1 assertion)

Because of the magic of Docker, the same output can be found on [our CI infrastructure's equivalent passing test](https://circleci.com/gh/dcycle/unit-test-tutorial/3) (by unfolding the "Tests" section) once we push our code to Github.

Introducing test _providers_
-----

OK, we're getting into the jargon of PHPUnit now. To introduce the concept of test providers, consider this: almost every time we run a test, we'd like to bombard our _unit_ (our PHP method) with a variety of inputs and expected outputs, and confirm our unit always works as expected.

The basic testing code is always the same, but the inputs and expected outputs change.

Consider our existing test:

    /**
     * Test for auto_entitylabel_entity_label_visible().
     *
     * @cover ::auto_entitylabel_entity_label_visible
     */
    public function testAuto_entitylabel_entity_label_visible() {
      $this->assertTrue(AutoEntityLabelManager::auto_entitylabel_entity_label_visible('whatever') === TRUE, 'Label "whatever" is visible.');
    }

Maybe calling our method with "whatever" should yield TRUE, but we might also want to test other inputs to make sure we cover every possible usecase for the method. In our case, looking at [the method](https://github.com/dcycle/unit-test-tutorial/blob/circle-ci/src/AutoEntityLabelManager.php#L359-L366), we can reasonably surmise that calling it with "profile2" should yield FALSE. Again, I'm not sure why this is; in the context of this tutorial, all I want to do is to make sure the method works as expected.

So the answer here is to serarate the testing code from the inputs and expected outputs. That's where the _provider_ comes in. We will add arguments to the test code, and define a separate function which calls our test code with different arguments. The end results looks like this (I also like to print_r() the expected and actual output in case they differ, but this is not required):

    /**
     * Test for auto_entitylabel_entity_label_visible().
     *
     * @param string $message
     *   The test message.
     * @param string $input
     *   Input string.
     * @param bool $expected
     *   Expected output.
     *
     * @cover ::auto_entitylabel_entity_label_visible
     * @dataProvider providerAuto_entitylabel_entity_label_visible
     */
    public function testAuto_entitylabel_entity_label_visible(string $message, string $input, bool $expected) {
      $output = AutoEntityLabelManager::auto_entitylabel_entity_label_visible($input);

      if ($output != $expected) {
        print_r([
          'output' => $output,
          'expected' => $expected,
        ]);
      }

      $this->assertTrue($output === $expected, $message);
    }

    /**
     * Provider for testAuto_entitylabel_entity_label_visible().
     */
    public function providerAuto_entitylabel_entity_label_visible() {
      return [
        [
          'message' => 'Label "whatever" is visible',
          'input' => 'whatever',
          'expected' => TRUE,
        ],
        [
          'message' => 'Label "profile2" is invisible',
          'input' => 'profile2',
          'expected' => FALSE,
        ],
        [
          'message' => 'Empty label is visible',
          'input' => '',
          'expected' => TRUE,
        ],
      ];
    }

[Here is the diff in GitHub](https://github.com/dcycle/unit-test-tutorial/compare/first-running-test...provider).

At this point, we have one test method being called with three different sets of data, so the same test method is being run three times; running the test now shows three dots:

    $ ./scripts/ci.sh
    PHPUnit 6.5.13 by Sebastian Bergmann, Julien Breux (Docker) and contributors.

    ...                                                                 3 / 3 (100%)

    Time: 232 ms, Memory: 4.00MB

    OK (3 tests, 3 assertions)

Breaking down monster functions
-----

It must be human nature, but over time, during development, functions tend to get longer and longer, and more and more complex. Functions longer than a few lines tend to be hard to test, because of the sheer number of possible execution paths, especially if there are several levels of control statements.

Let's take, as an example, [auto_entitylabel_prepare_entityform()](https://github.com/dcycle/unit-test-tutorial/blob/provider/auto_entitylabel.module#L69-L114). With its multiple switch and if statements, it has a [cyclomatic complexity](https://pdepend.org/documentation/software-metrics/cyclomatic-complexity.html) of 7, the highest in this codebase, according to the static analysis tool [Pdepend](https://pdepend.org/). If you're curious about finding your cyclomatic complexity, you can use the magic of Docker, run the following, and take a look at `./php_code_quality/pdepend_output.xml`:

    mkdir -p php_code_quality && docker run -it --rm -v "$PWD":/app -w /app adamculp/php-code-quality:latest php /usr/local/lib/php-code-quality/vendor/bin/pdepend --suffix='php,module' --summary-xml='./php_code_quality/pdepend_output.xml' .

See [adamculp/php-code-quality](https://hub.docker.com/r/adamculp/php-code-quality) for more details. But I digress...

Testing this completely would require close to 2 to the power 7 test providers, so the easiest is to break it down into smaller functions with a lower cyclomatic complexity (that is, fewer control statements). We'll get to that in a minute, but first...

Procedural code is not testable, use class methods
-----

For all but pure functions, procedural code like our `auto_entitylabel_prepare_entityform()`, as well as private and static methods, are untestable with mock objects (which we'll get those later). Therefore, any code you'd like to test should exist within a class. For our purposes, we'll put `auto_entitylabel_prepare_entityform()` within a [Singleton](https://en.wikipedia.org/wiki/Singleton_pattern) class, [like this](https://github.com/dcycle/unit-test-tutorial/compare/provider...procedural-to-class), and name it `prepareEntityForm()`. (You don't need to use a Singleton; you can use a Drupal service or whatever you want, as long as everything you want to test is a non-static class method.)

Our second test
-----

So we put our procedural code in a class. But the problem remains: it's too complex to fully cover with unit tests, so as a next step I recommend surgically removing only those parts of the method we want to test, and putting them in a separate method. Let's focus on [these lines of code](https://github.com/dcycle/unit-test-tutorial/blob/procedural-to-class/src/AutoEntityLabelSingleton.php#L52-L54), which can lead to [this change in our code](https://github.com/dcycle/unit-test-tutorial/compare/procedural-to-class...split-monster).

Object and method mocking, and stubs
-----

Let's consider a scenario where we want to add some tests to [EntityLabelNotNullConstraintValidator::validate()](https://github.com/dcycle/unit-test-tutorial/blob/split-monster/src/Plugin/Validation/EntityLabelNotNullConstraintValidator.php#L46-L61).

Let's start by splitting the validate method into smaller parts, [like this](https://github.com/dcycle/unit-test-tutorial/compare/split-monster...split-validate-method). We will now focus on testing a more manageable method with a lower cyclomatic complexity:

    /**
     * Manage typed data if it is valid.
     *
     * @return bool
     *   FALSE if the parent class validation should be called.
     */
    public function manageTypedData() : bool {
      $typed_data = $this->getTypedData();
      if ($typed_data instanceof FieldItemList && $typed_data->isEmpty()) {
        return $this->manageValidTypedData($typed_data);
      }
      return FALSE;
    }

Recall that in unit testing, **we are only testing single units of code**. In this case, the unit of code we are testing is manageTypedData(), above.

In order to test `manageTypedData() **and nothing else**, conceptually, **we need to assume that getTypedData() and manageValidTypedData() are doing their jobs, we will not call them, but replace them with stub methods within a mock object.**

We want to avoid calling getTypedData() and manageValidTypedData() because that would interfere with our testing of manageTypedData() -- we need to _mock_ getTypedData() and manageValidTypedData().

When we test `manageTypedData()` in this way, we need to replace the real `getTypedData()` and `manageValidTypedData()` with mock methods and make them return whatever we want.

PHPUnit achieves this by making a copy of our `EntityLabelNotNullConstraintValidator` class, where `getTypedData()` and `manageValidTypedData()` are replaced with our own methods which return what we want. So in the context of our test, we do not instantiate `EntityLabelNotNullConstraintValidator`, but rather, a mock version of that class in which we replace certain methods. Here is how to instantiate that class:

    $object = $this->getMockBuilder(EntityLabelNotNullConstraintValidator::class)
      ->setMethods([
        'getTypedData',
        'manageValidTypedData',
      ])
      ->disableOriginalConstructor()
      ->getMock();
    // We don't care how getTypedData() figures out what to return to
    // manageTypedData, but we do want to see how our function will react
    // to a variety of possibilities.
    $object->method('getTypedData')
      ->willReturn($input);
    // We will assume manageValidTypedData() is doing its job; that's not
    // what were are testing here. For our test, it will always return TRUE.
    $object->method('manageValidTypedData')
      ->willReturn(TRUE);

In the above example, our new object behaves exactly as `EntityLabelNotNullConstraintValidator`, except that `getTypedData()` returns $input (which we'll define in a _provider_); and `manageValidTypedData()` always returns TRUE.

Keep in mind that private methods cannot be mocked, so for that reason I generally avoid using them; use protected methods instead.

[Here is our initial test for this](https://github.com/dcycle/unit-test-tutorial/compare/split-validate-method...manageTypedData-test1).

Our provider, at this point, only makes sure that if `getTypedData()` returns a `new \stdClass()` **which is not an `instanceof` FieldItemList**, then the method we're testing will return FALSE.

[Here is how we could extend our provider](https://github.com/dcycle/unit-test-tutorial/compare/manageTypedData-test1...anon-class) to make sure our method reacts correctly if `getTypedData()` returns a **FieldItemList** whose `isEmpty()` method returns TRUE, and FALSE.

Testing protecting methods
-----

Let's say we want to (partially) test the protected [AutoEntityLabelManager::getConfig()](https://github.com/dcycle/unit-test-tutorial/blob/anon-class/src/AutoEntityLabelManager.php#L281-L295), we need to introduce a new trick.

[Start by taking a look at our test code which fails](https://github.com/dcycle/unit-test-tutorial/compare/anon-class...fail-protected). If you try to run this, you will get:

    There was 1 error:

    1) Drupal\auto_entitylabel\Tests\AutoEntityLabelManagerTest::testGetConfig
    Error: Cannot access protected property Mock_AutoEntityLabelManager_0f5704cf::$config

So we want to test a protected method (`getConfig()`), and, in order to test it, we need to modify a protected property (`$config`). These two will result in "Cannot access"-type failures.

The solution is to use a trick known as class reflection; it's a bit opaque, but it does allow us to access protected properties and methods.

[Take a look at some changes which result in a working version of our test](https://github.com/dcycle/unit-test-tutorial/compare/fail-protected...reflection).

Copy-pasting is perhaps your best fiend here, because this concept kind of plays with your mind. But basically, a ReflectionClass allows us to retrieve properties and methods _as objects_, then set their visibility using methods of those objects, then set their values or call them using their own methods... As I said, copy-pasting is good, sometimes.

A note about testing abstract classes
-----

There are no abstract classes in Auto Entity Label, but if you want to test an abstract class, here is how to create a mock object:

    $object = $this->getMockBuilder(MyAbstractClass::class)
      ->setMethods(NULL)
      ->disableOriginalConstructor()
      ->getMockForAbstractClass();

Using traits
-----

Consider the following scenario: a bunch of your code uses the legacy `drupal_set_message()` method. You might have something like:

    class a extends some_class {
      public function a() {
        ...
        drupal_set_message('hello');
        ...
      }
    }

    class b extends some_other_class {
      public function b() {
        ...
        drupal_set_message('world');
        ...
      }
    }

Your tests will complain if you try to call, or mock `drupal_set_message()` when unit-testing `a::a()` or `b::b()``, because `drupal_set_message()` is procedural and you can't do much with it (thankfully there is fewer and fewer procedural code in Drupal modules, but you'll still find a lot of it).

So in order to make `drupal_set_message()` mockable, you might want to something like:

    class a extends some_class {
      protected method drupalSetMessage($x) {
        drupal_set_message($x);
      }
      public function a() {
        ...
        $this->drupalSetMessage('hello');
        ...
      }
    }

    class b extends some_other_class {
      protected method drupalSetMessage($x) {
        drupal_set_message($x);
      }
      public function b() {
        ...
        $this->drupalSetMessage('world');
        ...
      }
    }

Now, however, we're in code duplication territory, which is not cool (well, not much of what we're doing is cool, not in the traditional sense anyway). We can't define a base class which has `drupalSetMessage()` as a method because PHP doesn't (and probably shouldn't) support multiple inheritance. That's where traits come in, it's a technique for code reuse which is exactly adapted to this situation:

    trait commonMethodsTrait {
      protected method drupalSetMessage($x) {
        drupal_set_message($x);
      }
    }

    class a extends some_class {
      use commonMethodsTrait;

      public function a() {
        ...
        $this->drupalSetMessage('hello');
        ...
      }
    }

    class b extends some_other_class {
      use commonMethodsTrait;

      public function b() {
        ...
        $this->drupalSetMessage('world');
        ...
      }
    }

Drupal uses this a lot: the `t()` method is peppered in most of core and contrib; earlier in this article we ran into [StringTranslationTrait](https://api.drupal.org/api/drupal/core%21lib%21Drupal%21Core%21StringTranslation%21StringTranslationTrait.php/trait/StringTranslationTrait/8.2.x); that allows developers to use `$this->t()` instead of the legacy `t()`, therefore making it mockable when testing methods which use it. The great thing about this approach is that we do not even need Drupal's `StringTranslationTrait` when running our tests, we can mock t() even if a [dummy version of `StringTranslationTrait`](https://github.com/dcycle/unit-test-tutorial/blob/reflection/phpunit-bootstrap.php#L10) is used.

[Check out this test for an example](https://github.com/dcycle/unit-test-tutorial/compare/reflection...test-t).

What about Javascript, Python and other languages?
-----

PHP has PHPUnit; other languages also have their test suites, and they, too, can run within Docker. Javascript has [AVA](https://github.com/avajs/ava); [Python has unittest](https://docs.python.org/2/library/unittest.html).

All unit test frameworks support mocking.

Let's look a bit more closely at [AVA](https://github.com/avajs/ava), but we do not want to install and maintain it on all our developers' machines, and on our CI server, so we'll use a [Dockerized version of AVA](https://github.com/dcycle/docker-ava). We can download that project and, specifically, run tests against  [example 3](https://github.com/dcycle/docker-ava/tree/master/example03):

    git clone git@github.com:dcycle/docker-ava.git
    docker run -v $(pwd)/example03/test:/app/code \
      -v $(pwd)/example03/code:/mycode dcycle/ava

The result here, again due to the magic of Docker, should be:

    1 passed

So what's going on here? We have [some sample Javascript](https://github.com/dcycle/docker-ava/blob/master/example03/code/dangerlevel.js) code which has a function we'd like to test:

    module.exports = {
      dangerlevel: function(){
        return this.tsunamidangerlevel() * 4 + this.volcanodangerlevel() * 10;
      },

      tsunamidangerlevel: function(num){
        // Call some external API.
        return this_will_fail_during_testing();
        // During tests, we want to ignore this function.
      },

      volcanodangerlevel: function(num){
        // Call some external API.
        return this_will_fail_during_testing();
        // During tests, we want to ignore this function.
      }
    }

In this specific case we'd like to mock `tsunamidangerlevel()` and `volcanodangerlevel()` during unit testing: we don't care that `this_will_fail_during_testing()` is unknown to our test code. Our test [could look something like this](https://github.com/dcycle/docker-ava/blob/master/example03/test/test.js):

    import test from 'ava'
    import sinon from 'sinon'

    var my = require('/mycode/dangerlevel.js');

    test('Danger level is correct', t => {
      sinon.stub(my, 'tsunamidangerlevel').returns(1);
      sinon.stub(my, 'volcanodangerlevel').returns(2);

      t.true(my.dangerlevel() == 24);
    })

What we're saying here is that if `tsunamidangerlevel()` returns 1 and `volcanodangerlevel()` returns 2, then `dangerlevel()` should return 24.

The Drupal testbot
-----

Drupal has its own Continuous Integration infrastructure, or testbot. It's a bit more involving to reproduce its results locally; still, you might want to use if you are developing a Drupal module; and indeed you'll have to use if it you are submitting patches to core.

In fact, it is possible to tweak our code a bit to allow it to run on the Drupal testbot _and_ CircleCI.

[Here are some changes to our code which allow exactly that](https://github.com/dcycle/unit-test-tutorial/compare/test-t...drupaltestbot). Let's go over the changes required:

* Tests need to be in `./tests/src/Unit`;
* The @group name should be unique to your project (you can use your project's machine name);
* The tests should have the namespace `Drupal\Tests\my_project_machine_name\Unit` or `Drupal\Tests\my_project_machine_name\Unit\Sub\Folder` (for example `Drupal\Tests\my_project_machine_name\Unit\Plugin\Validation`);
* The unit tests have access to Drupal code. This is actually quite annoying, for example, we can [no longer just create an anonymous class for FieldItemList](https://github.com/dcycle/unit-test-tutorial/compare/test-t...drupaltestbot#diff-5a0a42c64de5d295f959f87167210018R62-L87) but rather, we need to create a mock object using `disableOriginalConstructor()`; this is because, the unit test code being aware of Drupal, it knows that FieldItemList requires parameters to its constructor; and therefore it complains when we don't have any (in the case of an anonymous object).

To make sure this works, I created a project (it has to be a full project, as far as I can tell, can't be a sandbox project, or at least I didn't figure out to do this with a sandbox project) at [Unit Test Tutorial](https://www.drupal.org/project/unit_test_tutorial). I then activated automated testing under the [Automated testing tab](https://www.drupal.org/node/3088433/qa).

The results can be seen on [the Drupal testbot](https://dispatcher.drupalci.org/job/drupal_contrib/60976/console). Look for these lines specifically:

    20:32:38 Drupal\Tests\auto_entitylabel\Unit\AutoEntityLabelSingletonT   2 passes
    20:32:38 Drupal\Tests\auto_entitylabel\Unit\AutoEntityLabelManagerTes   4 passes
    20:32:38 Drupal\Tests\auto_entitylabel\Unit\Plugin\Validation\EntityL   1 passes
    20:32:38 Drupal\Tests\auto_entitylabel\Unit\Form\AutoEntityLabelFormT   1 passes

My main annoyance with using the Drupal testbot is that it's hard to test locally; you need to have access to a Drupal instance with PHPUnit installed as a dev dependency, and a database. To remedy this, the [Drupal Tester](http://github.com/dcycle/drupal-tester/blob/master/README.md) Docker project can be used to run Drupal-like tests locally, here is how:

    git clone https://github.com/dcycle/drupal-tester.git
    cd drupal-tester/
    mkdir -p modules
    cd modules
    git clone --branch 8.x-1.x https://git.drupalcode.org/project/unit_test_tutorial.git
    cd ..
    ./scripts/test.sh "--verbose --suppress-deprecations unit_test_tutorial"
    docker-compose down -v

This will give you more or less the same results as the Drupal testbot:

    Drupal\Tests\auto_entitylabel\Unit\AutoEntityLabelManagerTes   4 passes
    Drupal\Tests\auto_entitylabel\Unit\AutoEntityLabelSingletonT   2 passes
    Drupal\Tests\auto_entitylabel\Unit\Form\AutoEntityLabelFormT   1 passes
    Drupal\Tests\auto_entitylabel\Unit\Plugin\Validation\EntityL   1 passes

In conclusion
-----

Our promise, from the title of this article, is "Start unit testing your PHP code today". Hopefully the tricks herein will allow you to do just that. My advice to you, dear testers, is to **start by using Docker locally**, **then to make sure you have Continuous Integration set up (on Drupal testbot or CircleCI, or, as in our example, both)**, and **_only then_ start testing**.

Happy coding!


