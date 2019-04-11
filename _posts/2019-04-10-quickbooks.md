---
layout: post
title:  "Quickbooks usability issues"
date:   2019-04-10
id: 2019-04-10
permalink: /blog/2019-04-10/quickbooks/
redirect_from:
  - /blog/2019-04-10/
---

I've recently had to start using Quickbooks because it is required by my accountant to get verified financial statements for a nonprofit on whose board I serve. Here is a short description of my experience to date...

* I opened a company using the 30 day free trial, and after the trial is up, the company stays in my list of companies, and it is impossible to change its name because it is expired. I now have two companies with the same name and I can't change the expired company name to "My Company (expired)", so I had to change the name of my "live" company to "My Company (REAL!)".
* To do anything useful such as import CSV data or even batch-delete journal entries, I need to subscribe to an expensive a third-party application, TransactionPro, which seems to not have been updated in years. Because of the mix-up in company names (see above), I inadvertently connected TransactionPro to my expired company, then had to re-subscribe (at 20$/m) to change the company to "My Company (REAL!)".
* I figured I'd import a realistic number of journal entries (around 1500) using TransactionPro, see how it goes, delete the transactions, then try again until I get it right. Wrong! Batch-deleting journal entries is another 20$/month.
* Account names (such as "1100 My Bank Account") cannot be deleted and reinstated, or else I get the weird error: "Sorry cannot import data, because the account "1100 My Bank Account (deleted)" needs to be reinstated first. I had to delete all my accounts, then create new ones appended by "2", such as "1100 My Bank Account 2"
* I tried importing one journal entry and ran into issues right away. I'm no accountant so I figured I'd head straight to the Quickbooks Community and ask a question. But, using both Chrome and Safari, it has proved impossible to post to the Quickbooks community.

I will therefore post my question here in the hope that someone from Quickbooks might use the contact form on this site to get back to me with an answer, or else I'll just have to admit defeat in the face of Quickbooks, and go back to using Excel (my accountant will _not_ be happy).

So first of all, how do people post to the community site?
-----

Every time I try to post with exactly one attachment, I get the error:

> The maximum number of attachments per message is: 1.

I removed the attachment and figured I'd post the attachment to an image-sharing site. Then, upon saving a post, I get:

> There was an error while attempting to post your message. Try again in a few minutes.

I'll let you, the reader, imagine what happened after "a few minutes".

So here is my question, Quickbooks, is anybody out there?
-----

**Journal entry with three lines; only two show up in the Accounts overview.**

I have a journal entry with three lines:

* NEGATIVE 166950 HTG in account "1100 HTG petite-caisse"
* 33390 HTG in account "7900 amortissement equipements"
* 133560 HTG in account "1600 HTG immobilisations"

See image.

In my chart of accounts page, 

* 1100 HTG petite-caisse shows NEGATIVE 166950 HTG as expected
* 1600 HTG immobilisations shows 133560 HTG as expected
* 7900 amortissement equipements DOES NOT show 33390 HTG, it shows nothing at all 

See images.

My balance sheet completely ignores the "7900 amortissement equipements" account as well.

How can I get 33390 HTG to show in my 7900 amortissement equipements account and in my balance sheet?
