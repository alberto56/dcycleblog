---
layout: post
title:  "Filters on Blended Data in Google Data Studio"
date:   2019-06-01
id: 2019-06-01
tags:
  - blog
permalink: /blog/2019-06-01/data-studio-filters/
redirect_from:
  - /blog/2019-06-01/
---

[Google Data Studio](https://datastudio.google.com/) is a free service which allows you to create dashboards based on multiple data sources, especially Google-centric ones but also databases. The data can be filtered by date and other so-called dimensions.

Previous knowledge
-----

This article assumes you have some previous knowledge of how to create databases, of how to connect them to Google Data Studio dashboards; and how display data and filters on Google Data Studio.

Premise
-----

Consider this database table:

    Table "Pies_Sold"

    | State | Amount |
    |-------|--------|
    | MA    | 200    |
    | LA    | 140    |
    | AZ    | 45     |
    | Other | 300    |

If we provided the above data source to a Google Data Studio, we could display a "scorecard" indicating that a total of 685 pies have been sold (200 + 140 + 45 + 300), but we could also provide a "State" filter which would display "MA", "LA", "AZ" and "Other".

Selecting "LA", for example, would display 140.

Now consider this second table:

    Table "Subcontractors"

    | Province_or_state | Count |
    |-------------------|-------|
    | Massachusetts     | 2     |
    | Connecticut       | 1     |
    | OTHER             | 2     |

We could now display a second "scorecard" displaying a total of 5 subcontractors, and filter it by "Massachusetts", "Connecticut" or "OTHER".

To follow along
-----

To follow along, you can create a virtual machine with MySQL and add the above data:

    create database datablending;
    use datablending;
    CREATE TABLE Pies_Sold (State VARCHAR(6), Amount INT);
    CREATE TABLE Subcontractors(Province_or_state VARCHAR(16), Count INT);
    INSERT INTO Pies_Sold VALUES ('MA', 200);
    INSERT INTO Pies_Sold VALUES ('LA', 140);
    INSERT INTO Pies_Sold VALUES ('AZ', 45);
    INSERT INTO Pies_Sold VALUES ('Other', 300);
    INSERT INTO Subcontractors VALUES ('Massachusetts', 2);
    INSERT INTO Subcontractors VALUES ('Connecticut', 1);
    INSERT INTO Subcontractors VALUES ('OTHER', 2);

Make sure this database is accessible to the world (on a temporary virtual machine for example), go to [Google Data Studio](https://datastudio.google.com/), and create a new blank report called "datablending".

In that report, add your two tables as two datasources, and add them to your report (The "Add to report" button might take a minute appear).

Build your report
-----

At this point, we can use the "Add a chart" function to add two "Scorecards":

* "Amount" from "Pies_Sold"
* "Count" from "Subcontractors"

We now want to filter these by state, so we can click on the inverted pyramid "Add a filter" button, and create two filters:

* "State" which filters "Pies_Sold"
* "Province_or_state" which filters "Subcontractors"

The problem
-----

When you "View" your report now, you can filter Pies Sold by State, and you can filter Subcontractors by Province or State, _but not both at the same time_.

We would like a filter that combines the two, a "blended" filter which would allow us to select "Massachusetts (MA)" and display 200 pies sold, and 2 subcontractors, for example.

Of course, we must imagine that we did not create this data ourselves, indeed that we don't even have write access to this data; perhaps we are an employee of a company which just acquired another company and have been asked to provide a dashboard for our jet-setting CEO. Perhaps we want to combine data from several data sources, spanning several systems such as Google Analytics and Databases.

Adding fields to our data sources
-----

The first issue is that our "State" fields (corresponding to MySQL columns) are incompatible:

* they have different names (State, and Province_or_state);
* the same values are labelled differently ("MA" vs "Massachusetts");
* both fields have values which do not exist in the corresponding field of the other table (Pies Sold has LA (Louisiana), and Subcontractors has Connecticut).

First step, select your base data source
-----

In an ideal world, we'd like to design a blended filter which would provide the following data (spoiler: it's not possible):

| State | Pies sold | Subcontractors |
|-------|-----------|----------------|
| MA    | 200       | 2              |
| CT    | 0         | 1              |
| LA    | 140       | 0              |
| AZ    | 45        | 0              |
| Other | 300       | 2              |

This takes data from two data sources, "Pies sold" the first or "left" one, and "Subcontractors", the second or "right" one.

What we'd like to do is to fetch states from both data sources and blend them, whether the columns exist in both sources (such as Massachusetts/MA, Other); in the "left" one (AZ); or in the right one only (Connecticut/CT).

What we just described is known as an _outer join_ because we are using data from the intersection of the left and right sources, then _moving outward_ to those columns which exist only in the left source, or only in the right source.

The Google Data Studio Left Join Only Limitation
-----

Contrary to an _outer join_ which uses columns from both the left and right data sources, a _left join_ uses only those columns which are in the left data source, and if they also happen to be exist in the right data source, will use them also, _but will completely ignore all data which is in the right data source only_ (such as Connecticut/CT in this example, if our right source is the "Subcontractors" table).

At the time of this writing, [Google Data Studio only seems to support left joins](https://support.google.com/datastudio/answer/9061420?hl=en).

(A post on AdvertiseCommunity, [Is there no way to do any other table join than a Left Join?](https://www.en.advertisercommunity.com/t5/Data-Studio/Is-there-no-way-to-do-any-other-table-join-than-a-Left-Join/td-p/1771962), has an accepted answer from July, 2018, suggesting Google's "BigQuery" be used as a middleware between your data sources and Google Data Studio; you could also build your own middleware to get around the Google Data Studio Left Join Only Limitation; however these solutions are outside of the scope of the current article.)

First step, choose your base data source and how to represent your data
-----

Because the following columns are shared by both your "Pies sold" and "Subcontractors" tables, we can make them appear in your blended data regardless of what you do:

* Massachusetts (MA)
* Other

Because life is about choices, now you will need to choose whether your blended data will include Louisiana (LA) and Arizona (AZ) (Pies) **or** Connecticut (CT) (Subcontractors). If you choose Pies as your base data source, Connecticut (CT) will need to bundled with "Other"; if you choose Subcontractors, Louisiana (LA) and Arizona (AZ) will need to be bundled with "Other".

In our example, we will sacrifice Connecticut and bundle its data with "Other".

Step 2, create calculated fields which have the same name and values as your base fields
-----

Let's edit our first data source, "Pies sold", and **add a calculated field** called "Standard State". Let's say we want our states to be displayed in the format "State name (abbreviation)", our formula might be:

    CASE
      WHEN State IN ("MA") THEN "Massachusetts (MA)"
      WHEN State IN ("LA") THEN "Louisiana (LA)"
      WHEN State IN ("AZ") THEN "Arizona (AZ)"
      ELSE "Other"
    END

In "Subcontractors", we'll also need a calculated field with the same name and values, so we'll create a "Standard State" field, and give it the formula:

    CASE
      WHEN Province_or_state IN ("Massachusetts") THEN "Massachusetts (MA)"
      ELSE "Other"
    END

As mentioned above, we _had to sacrifice Connecticut and put its data with "Other"_ to get around the Google Data Studio Left Join Only Limitation.

Now the magic of blended filters
-----

* Your filter, and both your scorecards, now needs to use Blended data with a left data source of "Pies Sold" with the "Amount" metric, and right data source of "Subcontractors", using the "Count" metric.
* Your Filter should not use a metric.
* Your "Pies Sold" scorecard should use the "Amount" metric.
* Your "Subcontractors" scorecard should use the "Count" metric.

Trying it
-----

With your dashboard in view mode, it should now be possible to filter your data with a single unified filter:

    | Selection          | Pies Sold | Subcontractors |
    |--------------------|-----------|----------------|
    | (All)              | 685       | 5              |
    | Massachusetts (MA) | 200       | 2              |
    | Louisiana (LA)     | 140       | No data        |
    | Arizona (AZ)       | 45        | No data        |
    | Other              | 300       | 3              |

The 3 in "Other" for Subcontractors includes Connecticut data because we "sacrificed" Connecticut due to the The Google Data Studio Left Join Only Limitation.

Have fun!

Resources
-----

* [About data blending, Join information from multiple sources to get a more unified view of your data, Data Studio Help](https://support.google.com/datastudio/answer/9061420?hl=en)
* [In Google Data Studio, can I simulate an outer join for blended data by creating a dummy datasource with all my values?, StackOverflow, June 1st, 2019](https://stackoverflow.com/questions/56406917/in-google-data-studio-can-i-simulate-an-outer-join-for-blended-data-by-creating)
* [Is there no way to do any other table join than a Left Join?, AdvertiserCommunity](https://www.en.advertisercommunity.com/t5/Data-Studio/Is-there-no-way-to-do-any-other-table-join-than-a-Left-Join/td-p/1771962)


