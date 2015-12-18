---
layout: page
title: About
permalink: /about/
---

My name is Bar. I have been using Emacs for several years, and I believe it is a
great editor and a great programming platform. I am also an author of one or two
Emacs packages. During this period, I enjoyed using Emacs a lot, but I have also
ran into a few problems.

The main problem is how do I, as a user and a developer, make the best use of
Emacs. Emacs has many features that are not very well known. As I user, I might
not know about a feature that is exactly what I need. For example, if I want
Emacs to restore my previous session when I launch it, I might not know about
[desktop-save-mode][desktop]. As a user, I can find other non-standard ways to
do it. But what happens when a package developer doesn't know about
desktop-save-mode? In the worst case, the package interferes with
desktop-save-mode and they can't work together - and this impacts anyone who
wants to use both features. For example, is [perspective.el][perspective]
compatible with desktop-save-mode? I hope so, but I don't know (yet).

Through this website, I want to provide information for both users and package
developers, so you can easily *learn* about standard features and popular
packages, how to *use* them, and how to *integrate* with them. The plan is
provide research articles, user guides, and advice on best practices.
Occasionally I will also write about Spacemacs, which I use.

# Why "Emacs Synergy"

[Synergy on Wikipedia][synergy]:

> Synergy is the creation of a whole that is greater than the simple sum of its
> parts.

Hopefully, this website will help you gain more out of Emacs.

[perspective]: https://github.com/nex3/perspective-el
[desktop]: http://www.gnu.org/software/emacs/manual/html_node/elisp/Desktop-Save-Mode.html
[synergy]: https://en.wikipedia.org/wiki/Synergy
