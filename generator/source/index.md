---
hide: true
layout: page
permalink: /
feature-img: "examples/img/hero-bg.jpg"
# Copyright (c) 2018 Bitwise IO, Inc.
# Licensed under Creative Commons Attribution 4.0 International License
# https://creativecommons.org/licenses/by/4.0/
---

# Hyperledger Sawtooth

Hyperledger Sawtooth is an enterprise solution for building, deploying, and
running distributed ledgers (also called blockchains). It provides an extremely
modular and flexible platform for implementing transaction-based updates to
shared state between untrusted parties coordinated by consensus algorithms.

# Project Status

This project is an _active_ Hyperledger project. It was proposed to the
community and documented
[here](https://docs.google.com/document/d/1j7YcGLJH6LkzvWdOYFIt2kpkVlLEmILErXL6t-Ky2zU).
Information on what _Active_ entails can be found in the
[Hyperledger Project Lifecycle document](https://wiki.hyperledger.org/community/project-lifecycle).

# Posts

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>