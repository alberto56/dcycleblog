---
layout: post
title:  "Verifying telephone numbers in Drupal"
author: admin
id: 2022-04-19
tags:
  - blog
  - planet
permalink: /blog/2022-04-19/phone-verification-drupal/
redirect_from:
  - /blog/2022-04-19/
  - /node/2022-04-19/
---

When allowing users to input phone numbers in Drupal, you might want to make sure that they actually have access to phone number they are using, rather than being allowed to input any random phone number.

In practice, when a user claims to have access to a phone number, we want to design a system that sends a one-time code to the user by SMS, and for the user to enter that code on our site, telling us that the user's phone number has been verified as belonging to them.

In this article we will choose an SMS provider, introduce a series of modules which allow phone number verification, and make sure we store our provider API keys in a relatively secure way.

Choosing an SMS Framework gateway
-----

You will need to set up an account with a third-party provider of SMS services; this requires setting up an account and getting an API key, potentially a phone number and other API information.

Providers that can currently integrate into Drupal's [SMS Framework (smsframework)](https://www.drupal.org/project/smsframework) (which we will will use) [are listed on the Gateways for SMS Framework page](https://www.drupal.org/node/2641028).

There are several, and I have only tested a single one, which works for me. However this article is not an indorsement of a particular service. You are encouraged to do your own research and find the one which is best for you.

In this example, we will use [Twilio](https://www.twilio.com). If you want to follow along, start by opening an account there and getting the following information at <https://console.twilio.com/> in the "account info" section:

* Account SID
* Auth token
* From number (this is a phone number in the format +15555555555)

Installation
-----

We will install and enable the following modules to set up phone number verification:

* [Mobile Number (mobile_number)](https://www.drupal.org/project/mobile_number)
* [SMS Framework (smsframework)](https://www.drupal.org/project/smsframework)
* [Twilio SMS Integration (sms_twilio)](https://www.drupal.org/project/sms_twilio) _or the module corresponding to whichever provider you have chosen_.

Assuming you have a brand new working Drupal site and you opened an account with Twilio, you can install your modules in the standard Drupal way. In my tests SMS has a dependency on [Dynamic Entity Reference (dynamic_entity_reference)](https://www.drupal.org/project/dynamic_entity_reference) which needs to be explicitly required:

    composer require \
      drupal/mobile_number \
      drupal/sms_twilio \
      drupal/sms:^2.1@beta \
      drupal/dynamic_entity_reference
    drush en sms_twilio sms mobile_number sms_sendtophone -y
    drush cr

Field Configuration
-----

In this example we will add a Phone Number field to user profile pages; this can be done by logging in as user 1 (`drush uli` will give you a link), going to `/admin/config/people/accounts/fields/add-field`, selecting a new field of type "Mobile Number" (**not** "Telephone number") with the label "Phone Number" (machine name field_phone_number),

In the field settings page, you can check "Yes, only verified numbers" in the "Unique" section, then click "Save field settings".

In the following pae, you can select "Required" in the "Verification" section.

Finally click "Save settings".

SMS gateway configuration
-----

We now need to tell Mobile Number to use the SMS gateway (and in our example Twilio) to send SMS messages to phone numbers.

Visit `/admin/config/smsframework/gateways/add` and select the gateway "Twilio". Name it "My Gateway" (the name is important for a further step), then save. New fields will appear allowing you to enter API information from Twilio. I recommend not entering the information here because then it will be in your database, and can potentially be compromised. In the "Account SID", "Auth token" and "From number" fields, you can enter "See unversioned settings.php".

Save your settings.

Securing Twilio API information by keeping it out of version control
-----

Any API information is sensitive. I think these should never be in code, or in your database.

If they're in code, any person with even read-only access to your codebase; or indeed any person with access to any of your continuous integration platforms, will have immediate access to your full Twilio account.

If the API info is in your database, you run the risk of future developers doing a non-sanitized database dump of your production database for local development for an unrelated feature, then leaving that database lying around on their non-encrypted computer, which they will eventually forget at a Dunkin' Donuts.

As with any sensitive information, these should be in in an unversioned settings file or environment variable. In this example we'll use an unversioned settings file.

Depending on your setup, this can be either the `./sites/default/settings.php` file itself, which is often unversioned. If you are using a codebase where `./sites/default/settings.php` is versioned, such as Acquia, you might want to include reference to a separate unversioned file therein, something like:

    if (file_exists('/path/to/unversioned/directory/unversioned.php')) {
      require('/path/to/unversioned/directory/local-settings/unversioned.php');
    }

We use such an approach in the [Dcycle Drupal Starterkit project](https://github.com/dcycle/starterkit-drupalsite).

So in your unversioned code, you can enter this information:

    $config['sms.gateway.my_gateway']['settings'] = [
      'account_sid' => 'MY_ACCOUNT_SID',
      'auth_token' => 'MY_AUTH_TOKEN',
      'from' => '+15555555555',
    ];

(Of course, enter your own information instead of the dummy information provided in the example.)

Setting the fallback gateway
-----

Now go to /admin/config/smsframework/settings and set the fallback logger to My Gateway, and save.

Testing the system
-----

Now you can go to `/user/1/edit` and enter your phone number in the Phone Number field, the click "Send verification code".

If you receive a verification code by SMS on your phone, congratulations! Otherwise, happy debugging!

Caveat: administrators always bypass phone number verification
-----

Mobile Number defines a permission allowing certain roles to bypass verification; and since administrators, including user 1, always have all permissions, all administrators will be able to enter unverified phone numbers anywhere.

Resources
-----

* [Mobile Number (mobile_number)](https://www.drupal.org/project/mobile_number)
* [SMS Framework (smsframework)](https://www.drupal.org/project/smsframework)
* [Gateways for SMS Framework page, Drupal.org, last updated on 5 June 2021](https://www.drupal.org/node/2641028)
* [Twilio](https://www.twilio.com)
* [Twilio SMS Integration (sms_twilio)](https://www.drupal.org/project/sms_twilio)
