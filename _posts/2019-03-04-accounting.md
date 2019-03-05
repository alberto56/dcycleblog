---
layout: post
title:  "What if accounting worked like software development? Command-line, double-entry accounting for agencies"
date:   2019-03-04
tags:
  - blog
id: 2019-03-04
permalink: /blog/2019-03-04/accounting/
redirect_from:
  - /blog/2019-03-04/
---

I've always fled my accounting responsibilities, or did the bare minimum, using inadequate tools like spreadsheets, only to be caught up yearly at tax time having to apologize to my dumbfounded accountant.

My situation at Dcycle is typical: multiple freelancers, multiple clients and projects, multiple accounts in multiple currencies, services paid in advance, sales taxes, prepaid credit cards, expense accounts, salaries with payroll deductions, employer-paid payroll taxes...

My accountant has tried to get me to use one of the software-as-a-service proprietary, paid, GUI-based software packages which promise to make things quick and easy, but I just can't get my head around those: their file structures don't seem to adhere to open standards, they seem very opinionated and their APIs sometimes seem like an afterthought.

I've always been telling myself there has to be a better way, and I think I just might have found it.

My accounting software requirements
-----

I started out with a shopping list of requirements for accounting software:

* **Open source**: as a Drupal developer, I am used to working within the context of open source communities, even getting my hands dirty and proposing fixes to functionality which doesn't fit my needs.
* **Command-line or API-first**: As a developer, I often feel lost in graphical user interfaces. Those are fine as long as they are built on the foundation of a well-documented API or command line tools, but any software with a GUI-first interface is not for me.
* **Double-entry**: I think of my accounting as a series of sum-zero journal entries. This, in my experience, is extremely flexible and scalable. The Ledger-Cli software which I will introduce below has [a good introduction to double-entry accounting](https://www.ledger-cli.org/3.0/doc/ledger3.html#Fat_002dfree-Accounting).
* **Unopinionated**: I want my accounting software to make no assumptions about currencies, inventories, accounts, or naming. All I want to do is make a series of sum-zero journal entries to any arbitrary account (CAD bank account, USD prepaid visa, Client X prepaid services, Taxes owed to the government...), define the exchange rate into my home currency, and get an error only if things don't balance out.
* **Invoicing and reporting automation between parties**: longer-term, I'm looking for a system which scales enough to allow my freelancers and employees to submit invoices, hourly reports and expense accounts in a format which can automate much of the accounting process: if sub-contractor A submits an hourly report for Client X, I want to automatically generate an invoice for Client X with few (if any) manual steps. Similarly, when I get an invoice from sub-contractor A, my accounting software should confirm it's for the correct number of hours.

Ledger-Cli
-----

[Ledger-Cli](https://github.com/ledger/ledger) seems to be a good candidate for all of the above requirements. I [dockerized it here](http://hub.docker.com/r/dcycle/ledger) to be able to use it on any machine with Docker installed, without further dependencies or steps.

Ledger-Cli is actively maintained with many contributors, users, and commits.

The lowdown
-----

Ledger-Cli does not have a database, it simply validates input files and displays their data as reports. The is great because:

* Accounting files can pass or fail, just like code.
* Accounting files can be version-controlled in git repos.
* Changes to git repos can trigger continuous integration tests, just like code.
* Multiple collaborators can work on the files, using the same techniques used to collaborate on computer code.

Basic accounting principles
-----

We will use the following principles in our accounting (some examples follow):

* Assets should equal liabilities plus income minus expenses.
* Reporting is done in a single currency.
* Every journal entry should even out.
* Income includes accounts receivable.
* Expenses include accounts payable.

This will be clearer with a simple example:

* Your income is 5,000USD plus 5,000CAD (where 1CAD = 0.75USD), or which you still are expecting 2,500USD.
* Your only expense is 500USD for hosting fees, of which you paid 250USD; the remainder (250USD) being payable.
* Your assets are 2,500USD accounts receivable.
* Your liabilities are 250USD for hosting.

Here is what this looks like in a balance sheet:

    Balance sheet (all amounts in USD)

    * Income *

    USA income           5,000
    Canadian income      3,750
    --------------------------
    Total                8,750

    * Expenses *

    Hosting                500

    * Assets *

    Bank account         6,000
    Accounts receivable  2,500
    --------------------------
    Total                8,500

    * Liabilities *

    Accounts payable       250

In this example, your bank account contains what you were actually paid for your services minus the portion of your hosting bill you paid (5,000CAD @ $.75 + $2,500 - $250 = $6,000) . Assets ($8,500) should equal liabilities ($250) plus income  ($8,750) minus expenses ($500).

Getting this to work with Ledger-Cli
-----

The only requirements to follow along are:

* you should have [Docker Desktop](https://www.docker.com/products/docker-desktop) installed and running on your machine;
* you should be comfortable using the command line (Terminal in mac OS), or at least willing to try.
* you should use some sort of plain text editor (not Microsoft Word!).

Let's get started!

The basic building blocks for a balance sheet like the one in the above example are **journal entries**. Each journal entry is a list 2 or more operations which equal zero.

In Ledger-Cli, your journal entries reside in one or more file. Let's create a journal entries file:

    mkdir -p ~/Desktop/ledger-cli-demo/my-company
    touch ~/Desktop/ledger-cli-demo/my-company/journal.dat

The above code creates an empty file called `journal.dat`. In that file, use your plain-text editor to put the following:

    2019/01/01 * Invoice 1
        Assets:receivable     $5,000.00
        Income:income

    2019/01/01 * Invoice 2
        Assets:receivable     5000 CAD @ $.75
        Income:income

    2019/01/12 * Payment
        Assets:receivable     -5000 CAD @ $.75
        Assets:bankAccount

    2019/01/12 * Payment
        Assets:receivable     -$2500
        Assets:bankAccount

    2019/01/15 * Hosting
        Liabilities:payable   -$500
        Expenses:hosting

    2019/01/15 * Hosting
        Liabilities:payable   $250
        Assets:bankAccount

We mentioned earlier that each journal entry must equal zero, so how does this work here? The system will automatically calculate what it takes to balance the amounts if you leave an entry blank. For example, our entries for invoice 1 and invoice 2 could well be written:

    2019/01/01 * Invoice 1
        Assets:receivable     $5,000.00
        Income:income        -$5,000.00

    2019/01/01 * Invoice 2
        Assets:receivable     5000 CAD @ $.75
        Income:income        -$3,750
    ...

So what are we saying in this file? We have six journal entries:

First, we issued Invoice 1 which adds $5,000 to a category called Assets and a subcategory called receivables, and _removes_ $5,000 from a category called Income and sub-category called Income.

One thing to note here is that you can call your categories whatever you want, and have as many levels of subcategories as you want. "Assets" and "Income" might mean something to us, but for the application, it's just another word. If we want to further fine-tune our "receivable" subcategory, we could have something like `Assets:receivable:client1:invoice2` or whatever we want.

So we were saying that Invoice 1 adds $5,000 to our assets and removes $5,000 from our income. _Wait a minute? Removes incomes?_  This is well explained in the [Ledger-Cli documentation](https://www.ledger-cli.org/3.0/doc/ledger3.html):

_"Why is the Income a negative figure? When you look at the balance totals for your ledger, you may be surprised to see that Expenses are a positive figure, and Income is a negative figure. It may take some getting used to, but to properly use a general ledger you must think in terms of how money moves. Rather than Ledger “fixing” the minus signs, let’s understand why they are there._

_"When you earn money, the money has to come from somewhere. Let’s call that somewhere “society”. In order for society to give you an income, you must take money away (withdraw) from society in order to put it into (make a payment to) your bank. When you then spend that money, it leaves your bank account (a withdrawal) and goes back to society (a payment). This is why Income will appear negative—it reflects the money you have drawn from society—and why Expenses will be positive—it is the amount you’ve given back."_

A second invoice is much the same but removes $3,750 from our income and adds the equivalent 5000 CAD to our receivables.

Our fictional Canadian client then paid 5000 CAD in full, which removes 5000 CAD from our receivables and adds the equivalent $3,750 to our bank account (this is not explicitly specified, but is calculated from the exchange rate).

Our U.S. client pays _part_ of their invoice, $2,500, removing $2,500 from our receivables and adding $2,500 to our bank account, leaving $2,500 in our receivables.

Our last two journal entries are $500 going from our liabilities to our hosting expenses; and then half of that is taken from our bank account and added back to our liabilities.

Let's see this in action!

    cd ~/Desktop/ledger-cli-demo && docker run --rm -v $PWD:/data dcycle/ledger -f /data/my-company/journal.dat balance
           $8,500.00  Assets
           $6,000.00    bankAccount
           $2,500.00    receivable
             $500.00  Expenses:hosting
          $-8,750.00  Income:income
            $-250.00  Liabilities:payable
    --------------------
                   0

Great, everything balances out!

There is a bunch of other commands you can experiment with to get different reports:

    docker run --rm -v $PWD:/data dcycle/ledger:1 -f /data/my-company/journal.dat register
    docker run --rm -v $PWD:/data dcycle/ledger:1 -f /data/my-company/journal.dat register hosting
    docker run --rm -v $PWD:/data dcycle/ledger:1 -f /data/my-company/journal.dat balance hosting

Your accounting files are your source of the truth
-----

One thing I love about Ledger-Cli is that it does not attempt to track your data, modify it, or indeed help you in any way. Your files _are_ your data. There is no database! This means that your accounting files _act just like computer code_:

* You can track them in a version control system, but you don't have to;
* You can collaborate on them with a team, but you don't have to;
* You can use continuous integration to confirm they balance at every commit on every branch, but you don't have to.

Collaborating between parties (slaying the dreaded PDF file)
-----

If you work with several freelancers, chances are they are sending you their timetracking and invoices in PDF, Word or Excel files. There is no way to automate the management of these, you need to manually enter that data into your accounting software. Urgh!

Instead, we can benefit from one of Ledger-Cli's features: _the abitility to generate reports based on more than one input_.

Let's come back to our company's `journal.dat` example. This is probably something you want to version-control and give access to different people in your organization, and your accountant. However, there might be some sensitive data in there that you don't want your freelancers to have access to.

Imagine, then, that each of your freelancers has their own git repo which represents their relationship with your organization, and in it, their own journal:

    mkdir -p ~/Desktop/ledger-cli-demo/jane-doe
    touch ~/Desktop/ledger-cli-demo/jane-doe/journal.dat

In our example, people in your organization might have access to ~/Desktop/ledger-cli-demo/my-company _and_ ~/Desktop/ledger-cli-demo/jane-doe, and your freelancer would only have access to ~/Desktop/ledger-cli-demo/jane-doe (in addition to `journal.dat`, that repo might also contain the freelancer's tax numbers, coordinates, and any other information pertaining to their relationship with your organization).

Now what if you _required_ that anyone working with you logged their hours and provided their invoices in a specific format? In `~/Desktop/ledger-cli-demo/jane-doe/journal.dat`, put:

    2019/01/01
        Client1:ticket1          8 HOURS
        jane-doe:hours-due

In this file, our freelancer just reported working 8 hours for ticket 1 for Client1.

So now we can generate a report for our dedicated freelancer Jane Doe (who works on New Year's Day, no less):

    docker run --rm -v $PWD:/data dcycle/ledger -f /data/jane-doe/journal.dat balance
             8 HOURS  Client1:ticket1
            -8 HOURS  jane-doe:hours-due
    --------------------
                   0

We can see that you have worked 8 hours for Client1, and 8 hours payable to your freelancer.

I'll leave it as an exercise for the reader to imagine how you manage several freelancers, clients, and projects.

When your freelancer invoices you and you pay her, that information can be added to ./jane-doe/journal.dat:

    2019/01/01
        Client1:ticket1          8 HOURS
        jane-doe:hours-due

    2019/02/01 * Invoice 123456
        jane-doe:hours-due       8 HOURS @ $50
        jane-doe:amount-due

    2019/03/01 * Payment by transfer 234567
        jane-doe:amount-due      400$
        jane-doe:amount-paid

Running this through a report will tell you that you've paid your freelancer $400 for 8 hours of work:

    $ docker run --rm -v $PWD:/data dcycle/ledger -f /data/jane-doe/journal.dat balance
                 8 HOURS  Client1:ticket1
                   -400$  jane-doe:amount-paid
    --------------------
                   -400$
                 8 HOURS

The result corresponds exactly to the reality here: you're out $400 but you have 8 hours which you can charge to your client.

When you invoice and get paid by your client (forget not, we are in the realm of the hypothetical here), you can add that information to ./my-company/journal.dat:

    2019/02/01 * Invoice XYZ-123
        Income:client-1                -$600
        Assets:receivable:client-1

    2019/02/01 * Invoice XYZ-123
        Client1:ticket1                -8 HOURS
        Client1:invoiced

    2019/03/01 * Payment by transfer 234567
        jane-doe:amount-paid          400$
        Assets:bankAccount

    2019/03/01 * Payment by transfer 98765
        Assets:receivable:client-1     -600$
        Assets:bankAccount

Let's build a report _combining_ your main journal and the one sent to you by your freelancer:

    cd ~/Desktop/ledger-cli-demo && docker run --rm -v $PWD:/data dcycle/ledger -f /data/jane-doe/journal.dat -f /data/my-company/journal.dat balance
               8,700.00$  Assets
               6,200.00$    bankAccount
               2,500.00$    receivable
                 8 HOURS  Client1:invoiced
                 500.00$  Expenses:hosting
              -9,350.00$  Income
                -600.00$    client-1
              -8,750.00$    income
                -250.00$  Liabilities:payable
    --------------------
                -400.00$
                 8 HOURS

There's a lot going on this report, but it tells us a lot about our business:

* We now have $6200 in the bank.
* We have invoiced Client1 for 8 HOURS.
* Our income from client 1 is $600.
* We don't see any trace of Jane Doe in the report, that's because she has been paid for everything she did.
* Over the course of period, a total of 8 HOURS were worked.

Conclusion
-----

The above is just an example, and could probably benefit from better categorization; however, we can see the power of a having a simple system with clear rules, along with a tight process.

This type of setup can be scalable as well: if dozens of freelancers use the same system, as well as clients and partners, using a clear naming scheme, productivity gains could be obtained, freeing us from the opportunity cost and potential errors associated with highly manual accounting a lot of us do now.

Furthermore, because this is all command-line based, it is highly scriptable, and nothing would prevent a decent developer with time on their hands to add a snazzy GUI on top of it.
