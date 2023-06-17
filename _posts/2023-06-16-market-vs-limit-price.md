---
layout: post
title: "Is it worth the hassle to convert currencies with a limit price, or is it better to use a spot price instead?"
date: 2023-06-16T14:43:30.853Z
id: 2023-06-16
author: admin
tags:
  - blog
permalink: /blog/2023-06-16/market-vs-limit-price-worth-it/
redirect_from:
  - /blog/2023-06-16/
  - /node/2023-06-16/
---

I do a lot of business in the U.S. but I live in Canada. I therefore need to convert funds from USD to CAD on a regular basis.

[Wise](http://wise.com) allows you to convert funds either immediately, or by "auto convert" based on a "desired rate".

For example, if the USD-CAD rate offered by Wise is 1.3190 when I want to perform a conversion, I can either convert 1,000.00 USD to 1,319.00 CAD right away, or I can specify that I would like to convert it if and when the rate gets to, say, 1.3210, thereby making a cool $20, enough for at least eight red peppers.

The downside, obviously, is that 1.3190 might be a market peak, so the rate might never get to 1.3210, in which case my conversion will never go through.

A similar choice presents itself if we are purchasing, say, the Cheesecake Factory (CAKE) stock, combining our love for a sweet snack with the allure of 3.20% dividend (disclaimer: that is just an example, and in no way should be construed as advice to purchase securities):

One could purchase the stock at its current price of, say, 33.75 USD; or, one could set a "limit" price of, say 33.50 USD, thereby saving 25 cents a stock.

Again, it is possible that the price of 33.50 never materializes.

Assumption: we want to perform the transaction; we just want the best price
-----

Let's assume for the sake of this article that we want CAKE, or Canadian dollars, or whatever it is we are buying. We just want the best price.

Therefore, if our desired (limit) price materializes within a given number of days, we will will convert the funds, or purchase the stock (because we really want it).

We will assume that after a given number of days, if our desired (limit) price does not materialize, we will buy our stock, or convert our funds anyway.

Step one: getting historical data
-----

I started by getting historical data for three types of transactions:

* Conversion of funds from CAD to USD;
* Conversion of funds from USD to CAD;
* Price history of the CAKE stock (using [Yahoo Finance](https://finance.yahoo.com/quote/CAKE/history?p=CAKE))

Step two: crunching the numbers
-----

I put the historical data into three tabs in [this Google spreadsheet](https://docs.google.com/spreadsheets/d/1VuDw0i0XrrWA5yEWHcetmdkIHxOhaBD6nKbZuFStFgc/edit#gid=0):

* CAD-USD
* USD-CAD
* CAKE

The reason I put both CAD-USD and USD-CAD is because I want to come up with a demonstration that a specific approach works whether or the market price is on an upward or downward tendancy. During the period covered by our historical data, USD got more expensive for buyers paying in CAD; and inversly, CAD got cheaper for buyers paying in USD. If we can find a way to make limit orders work for us in both cases, then we know that we are not simply winning because we happen to be riding the market.

Each of our tabs contains variables in blue (you can clone the spreadsheet and put your own numbers there if you want):

* How much to bid (what percentage to remove from the current market price).
* The total number of stocks, or currency, you want to purchase.
* How many days to wait for your order to go through before buying the currency, or stock, at market price

The columns, in each of the tabs, are:

* A: The date of the transaction
* B: The rate of the currency, or price of the stock
* C: The minimum price in the X days following the date
* D: The percentage diff
* E: Whether we have a hit or not. A hit is defined as our limit price going through in the number of days specified
* F: The price of the currency, or security, on the day after our limit order expires
* G: How much the security, or currency, would cost us at market rate
* H: How much the security, or currency, would cost us using the limit price if it's a hit, or using the price at the end of the limit period, if it's a miss

On the upper-right corner of each tab you will find a table that looks like this:

| If always using market price	    | 257,699.12		 |
| If always using limit price	      | 258,307.05		 |
| (gain) or loss (negative is good) | 607.92	    	 |
| % gain (negative is good)	        | 0.24%	         |

This table tells us we are losing .24% if we are consistently using limit orders.

This is an example from the [CAD-USD sheet](https://docs.google.com/spreadsheets/d/1VuDw0i0XrrWA5yEWHcetmdkIHxOhaBD6nKbZuFStFgc/edit#gid=0). In this case our variables (the blue cells) are:

* we always bid 0.50% lower than the market price
* we want to purchase a total of 200,000.00 USD
* our limit order lasts 20 days, after which we purchase USD at the market price

Conclusions
-----

Our exercice seems to indicate that using limit purchases generally results in investment losses, and in cases where we are riding the market (for example buying CAD with USD), can result in very minimal gains (less than 0.01%).

It therefore seems to be the case that partaking in limit orders is not only not worth the hassle, but also a sure way to lose time and money.

If any of my assumptions or formulae are wrong, please let me know in the comments.
