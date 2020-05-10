---
title: "Build data science website with Github page and Hugo"
subtitle: Bye Bye, Jekyll. Hello, Hugo.
Description: Jack of all trades, master of none
date: 2020-05-09
draft: true
toc:
  enable: true
  auto: true
tags: [blogging, Hugo, web dev]
categories: [blog]
author: Nina
---





- Tried Jekyll. Easy to use with Github,  honestly, not much to complain except that good-looking themes are so limited. :neutral_face:
- 
- Tried Hexo. Because 
- Created a website with RMarkdown. Getting setup was a breeze but found the blogging capability to be lacking





## Creating Your Blog

Once I was up and running, it felt only natural to write my first post about creating a blog with `blogdown`. Thus, this post is a step-by-step guide to creating a blog with `blogdown` by explaining *how* to do the following:

- Setup a GitHub repository for your new site
- Install `blogdown` and Hugo
- Create a Hugo website in your new repository
- Understand the structure of your new site
- Create new content
- Publish your site online using either [GitHub Pages](https://pages.github.com/) or [Netlify](https://www.netlify.com/)

This post assumes you already have R/RStudio installed on your machine, a basic familiarity with the command line, a GitHub account, and an internet connection. Importantly, you do **not** need to have advanced R or web design skills.

### Create a GitHub Repository

The first step towards building your new blog is to create a GitHub repository for your blog (we’ll call it `blogdown_source` here for reasons explained later). Initialize the repository with a `README.md` file.



## Let's dive in!



### Install Hugo

Mac OS X: `brew install hugo`



### Setting up repositories

Create a GitHub repository to set up blog in GitHub pages, the name of rep should be `<your username>.github.io` (not necessay but safe) 



1. `-hugo` : For Hugo project
2. `.github.io` : For hosting the blog

Clone the repo to your local machine using below command `git clone git@github.com:/-hugo.git`

then setup `.github.io` as submodule `git submodule add git@github.com:/.github.io.git`. Whatever the thing goes here can be accessed through `http://.github.io`.



