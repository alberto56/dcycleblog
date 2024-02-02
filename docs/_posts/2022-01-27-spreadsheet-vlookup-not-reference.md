---
layout: post
title:  "In a spreadsheet, do not reference a cell calculated using UNIQUE() or FILTER()"
author: admin
id: 2022-01-27
tags:
  - blog
permalink: /blog/2022-01-27/spreadsheet-reference-unique-fiter/
redirect_from:
  - /blog/2022-01-27/
  - /node/2022-01-27/
---

If you are using Google Sheet's `=UNIQUE()` or `=FILTER()` functions (or both) to generate values in cells, you should never reference those cells directly.

Example
-----

If you have these cells in `sh1`:

|   | A      | B     | C     |
|---|--------|-------|-------|
| 1 | Bikes  | TRUE  | 1     |
| 2 | Bikes  | TRUE  | 2     |
| 3 | Skates | FALSE | 3     |
| 4 | Boards | FALSE | 4     |
| 5 | Skates | TRUE  | 5     |

And you put the following formula in `sh2`'s cell A1:

    =UNIQUE(sh1!A1:A)

You will get:

|   | A      |
|---|--------|
| 1 | Bikes  |
| 2 | Skates |
| 3 | Boards |

With this formula:

    =FILTER(sh1!A1:A, sh1!B1:B)

You will get:

|   | A      |
|---|--------|
| 1 | Bikes  |
| 2 | Bikes  |
| 3 | Skates |

Let's imagine we want to calculate the sum of unique filtered items in `sh1`, we'd combine `UNIQUE()`, `FILTER()`, and `SUMIF()` in `sh2`, like this:

|   | A                                   | B                                |
|---|-------------------------------------|----------------------------------|
| 1 | =unique(FILTER(sh1!A1:A, sh1!B1:B)) | =SUMIF(sh1!A$1:A, A1, sh1!C$1:C) |
| 2 |                                     | =SUMIF(sh1!A$1:A, A2, sh1!C$1:C) |

This yeilds the following results in `sh2`:

|   | A     | B |
|---|-------|---|
| 1 | Bikes | 3 |
| 2 | Skates| 8 |

(This calculates the sum in column C of `sh1` of all lines which, at column A, are "Bikes" (1+2) and "Skates" (3+5) whether column B is TRUE or not. Line 4 ("Boards") is ommitted because "Boards" has no lines where column B are TRUE.)

What not to do: Referencing a cell in `sh2`
-----

Now let's say you want to reference the value of "Skates" (8), you might be tempted to use the following basic formula:

    =sh2!B2

This is risky, because any time the underlying data in `sh1` changes, the data in `sh2` will change as well. Let's change the data in `sh1` to the following:

|   | A     | B     | C     |
|---|-------|-------|-------|
| 1 | Bikes | FALSE | 1     |
| 2 | Bikes | FALSE | 2     |
| 3 | Skates| TRUE  | 3     |
| 4 | Boards| TRUE  | 4     |
| 5 | Skates| FALSE | 5     |

This causes `sh2` to become:

|   | A     | B |
|---|-------|---|
| 1 | Skates| 8 |
| 2 | Boards| 4 |

Now, `sh2!B2` refers no longer the value of "Skates" but to the value of "Boards".

This might affect the logic of your spreadsheet.

An alternate approach: VLOOKUP
-----

Instead of

    =sh2!B2

If we know we want to reference the value of "Skates", the following formula is more logical (albeit a bit more complex):

    =VLOOKUP("Skates",sh2!A1:B,2,FALSE)

This will look up the value "Skates" in the first column (VLOOKUP always looks up a value in the first column, you can't change that), then finds the row (in our first example it was row 2, and in our last example it is row 1), and finds the associated value in the second column (in this case column B).

The last argument to VLOOKUP is important: if the lookup values are fuzzy (such as dates), you will use TRUE here; if the values are non-fuzzy (Skates, Bikes are Boards), you will use FALSE here.

Now, whether "Skates" is in row 1 or row 2, the result will always be 8.

A much more robust spreadsheet. Just don't corner people at parties with this information! 
