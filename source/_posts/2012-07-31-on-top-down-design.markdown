---
layout: post
title: "On Top-down Design"
date: 2012-07-31 20:54
comments: true
categories:
---

There are many strategies for writing software.

Some like writing tests first, letting your tests drive the implementation, essentially becoming the first clients of your software. Others like writing production code first and kind of figure out how it works, and then they apply some tests after the fact. I am convinced that writing tests in this way is far less effective, but this is not an article on the merits of TDD. Others don't like writing tests at all, so it's a varying scale.

You can write software from the bottom up, where you are forced figure out what the data model should be and how it is to support all known use cases. This is hard, particularly in this day and age where software requirements are unpredictable and are meant to change very rapidly - at least in the fun industries.

You can also write software from the top down. In this case you let the outer shell of your software dictated what the inner layers need. For example, start all the way on the user interactions via some sketches and HTML/CSS in a web app. Or think through the CLI that you want. Readme driven development can help with this, too.

Outside-in development puts you in a great position to practice top-down design.

The advantage of Outside-In development is twofold. Not only are you left with acceptance tests that will catch regressions and help refactor later. But also, *the top layers of your software becomes a client of the code you are about to write, helping define its interface* in a similar way that practicing TDD for your unit tests help guide the design of software component at a very granular level.

These practices will help you define internal APIs that feel good faster, because you will notice cumbersome interfaces sooner, and are therefore given the opportunity to fix them when they have the least possible number of dependencies.

I know of many developers who prefer writing no tests, or prefer a bottom-up strategy. This does not mean that their software is of poor quality, by no means. But I will observe that I can't ship software of the quality standard that I put myself to unless I write tests first and follow outside-in methodologies. Indeed, this seems to indicate they are smarter than me.
