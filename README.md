# sawtooth-website

## Preview and Review

You'll need to install
[Docker and Compose](https://docs.docker.com/compose/install/)

From a local clone of
[the repository](https://github.com/hyperledger/sawtooth-website), run

```
docker-compose up
```

Pay attention to the output for markdown syntax errors. Errors will appear on lines beginning with `linter_1`.

The site will be available at [`http://localhost:8000`](http://localhost:8000)

To stop the site, type `[Ctrl]+C` then run

```
docker-compose down -v
```

## Adding a Post

To add a post, create a
[markdown file](https://kramdown.gettalong.org/quickref.html)
in `generator/source/_posts`

To create a post, add a file to the `generator/source/_posts` directory with the
following format:

```
YEAR-MONTH-DAY-title.MARKUP
```

Where `YEAR` is a four-digit number, `MONTH` and `DAY` are both two-digit
numbers, and `MARKUP` is the file extension representing the format used in the
file. For example, the following are examples of valid post filenames:

```
2019-04-23-hyperledger-is-awesome.md
2019-09-12-how-to-write-a-how-to.md
```

All post files must begin with front matter which is typically used to set a
layout or other meta data.

```
---
layout: post
title: Hyperledger Fabric & Sawtooth Certification Exams Coming Soon!
categories: [certification, hyperledger]
tags: [cert, calendar]
---

Excerpt from [hyperledger.org](https://www.hyperledger.org/blog/2018/09/05/hyperledger-fabric-sawtooth-certification-exams-coming-soon)

We strongly believe in helping organizations and developers overcome obstacles
to blockchain adoption by investing in training and certification courses for
Hyperledger. That’s why we’re thrilled to announce that Certified Hyperledger
Fabric Administrator and Certified Hyperledger Sawtooth Administrator exams will
be released later this year!
...
```

## Editing Site Content

Change the content of `/info/index.html`, `/info/contact/`, `/info/about/`,
etc., by editing the files in `/generator/source/`.

E.g., `/generator/source/index.md`, `/generator/source/contact.md` and
`/generator/source/about.md`