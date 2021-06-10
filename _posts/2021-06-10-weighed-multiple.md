---
layout: post
title:  "Weighted average is bad; weighted average from multiple sources is worse"
author: admin
id: 2021-06-10
tags:
  - blog
permalink: /blog/2021-06-10/weighed/
redirect_from:
  - /blog/2021-06-10/
  - /node/2021-06-10/
---

I've already written about why I hate the "weighted average" accounting method for foreign funds in [Producing an expense report in foreign funds using the weighted average method (May 12, 2020)](https://blog.dcycle.com/blog/2020-05-12/weighted/).

In this post I'll take a hypothetical example of having two different funding partners, each requiring the weighted average method.

Let's say for example both funding partners provide funding in CAD (Canadian dollars) to a project whose expenses are in HTG (Haitian Gourdes).

To recap what weighted average is: a weighted average funder-specific exchange rate is calculated each time money is sent over. For example:

|Date      |CAD sent  |HTG in (out)|CAD reported|Rate|Weighted avg|CAD left|
|----------|----------|------------|------------|----|------------|--------|
|2020-01-01|10000     |650,000     |            |65  |65 (1)      |10000   |
|2020-01-15|          |(325,000)   |5000        |    |65          |5000    |
|2020-02-01|5000      |375,000     |            |75  |70 (2)      |10000   |

Note 1: the first time funding is sent, the weighted average is equal to the operation rate (in this example 65).
Note 2: the second time funding is sent, the weighted average is calculated thus: (p/t * pr) + (n/t * nr), where

* p = previous amount, in this case 5000, which is the amount left over from the previous transfer.
* t = the total amount in our account after the new transfer, in this case 10000.
* pr = the previous weighted rate, in this case 65.
* n = the newly transferred amount, in this case 5000.
* nr = the new operation rate, in this case 75.

So after 2020-02-01, we have a weighted average exchange rate of 70. This does require going through some accounting hoops and I don't like it.

This gets exponentially more complicated once we have two, three, or heaven forbid, four funders, all requiring weighted average reporting, with two, three, or (in a real world example I'm working on) FOUR currencies (CAD, HTG, USD, and EUR in case you're wondering).

Let's just imagine we have a new funding source who requires that we use weighted average, and that funding source is also CAD to HTG. But this second funding source sends us money on the 15th of each month:

|Date      |CAD sent  |HTG in (out)|CAD reported|Rate|Weighted avg|CAD left|
|----------|----------|------------|------------|----|------------|--------|
|2020-01-15|10000     |700,000     |            |70  |70          |10000   |
|2020-01-31|          |(350,000)   |5000        |    |70          |5000    |
|2020-02-15|5000      |400,000     |            |80  |75          |10000   |

On 2020-02-15, our organization has the following on its books:

375,000 HTG which have an assigned exchange rate of 70 HTG for 1 CAD.
400,000 HTG which have an assigned exchange rate of 75 HTG for 1 CAD.

At this point if we buy, say, two fans, for 5,250 HTG apeice (it gets hot in Haiti), one for each project, our first fan is reported as 75 CAD (5250/70) to funder number 1, and our second fan is reported as 70 CAD (5250/75) to funder number two.

Now imagine we have four or more income sources, in several currencies, and imagine our entire project budget is less than a million dollars, you can see how accounting and reporting can get very complex, and unintuitive, very quickly: every unit of currency needs to be assigned a "rate".

In the context of countries with inadequate banking infrastructure, and countries that have dual currency situations (like Haiti with HTG and USD, and I will not even get into the "Haitian Dollar" which is another way of calculating prices), organizations need to deal mostly with petty cash accounts and cash payments for almost everything.

This means:

* we have a USD bank account
* we have HTG petty cash account
* we have USD petty cash account
* our funding comes in in EUR and CAD
* every HTG in our petty cash, every USD in our bank account, and every USD in our petty cash, are "assigned" a weighed average, which is different depending on the number of funding sources

Off-the-shelf accounting software such as Quickbooks simply cannot deal with these situations, in my experience anyway, meaning we need complex Excel spreadsheets and the knowledge to use them.

Dcycle has documented and published its solution at https://accounting.dcycle.com, which is currently being used in projects in Haiti and Togo, to address some of these issues.

An even better way to address them would be to do away with weighted averages entirely and use each day's published exchange rate for calculations, and accounting for exchange gains and losses, and bank transfer fees, as we would any other expense or gain.
