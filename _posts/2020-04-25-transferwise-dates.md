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

My solution has been to implement a [custom function in Google Sheets](https://developers.google.com/apps-script/guides/sheets/functions):

    /*
     * Transferwise export statement as CSV uses the date format DD-MM-YYYY, which Google 
     * Sheets does not understand, if the day is less than or equal to 12, it thinks the day 
     * is the month; if it more than 12, it does not know how to parse this. This function
     * will transform the Transferwise Date to a date which is in a format that Google Sheets
     * understands.
     * 
     * Usage: =TW_CALCDATE(TO_TEXT(H4))
     *
     * (where H4 is a cell containing a "transferwise"-type date string)
     */
    function TW_CALCDATE(date, timezone = 'America/New_York') {
     if (typeof date != 'string') {
       return date.toString();
       return Utilities.formatDate(date, 'America/New_York', 'yyyy-dd-mm');
     }
     day = date.substring(0, 2);
     month = date.substring(3, 5) - 1;
     year = date.substring(6);
     date = new Date(year, month, day);
     return Utilities.formatDate(date, timezone, 'MMMM dd, yyyy HH:mm:ss Z')
    }
