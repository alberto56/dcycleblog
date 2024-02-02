---
layout: post
title: Making Transferwise CSV import correctly into Google Sheets
id: a22db44a
tags:
  - snippet
permalink: /blog/a22db44a/transferwise-dates/
redirect_from:
  - /blog/a22db44a/
  - /node/a22db44a/
---
[Transferwise](https://transferwise.com/ca) is a cost-effective way to manage money in multiple currencies. There is unfortunately a small glitch in the date format it uses when exporting transactions as CSV.

It exports dates as DD-MM-YYYY, which is not understandable by Google Spreadsheets. This has caused me numerous headaches and calls from my accountant which could be traced back to, say a transaction having taken place on January 7th to appear on July 1st. 

Let's say my Transferwise date is in cell A1, here is how I transform it, in another cell:

    =DATE(RIGHT(A1,4),MID(A1,4,2),LEFT(A1,2))

(At first I tried using [a custom function in Google Sheets App Scripts](https://github.com/alberto56/dcycleblog/blame/d9ed430036a1f5b2296a2caa365191103cfe4106/_posts/2020-04-25-transferwise-dates.md#L18-L39), but I'm moving away from those as too complex.)
