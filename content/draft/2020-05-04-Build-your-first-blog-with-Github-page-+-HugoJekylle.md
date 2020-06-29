---
title: 'Build your first data science blog with Github page + Hugo' 
date: 2020-05-04T15:58:26+08:00
lastmod: 2020-05-04T15:58:26+08:00
draft: true
author: "Nina"
description: ""

tags: [github, web]
categories: []
hiddenFromHomePage: false

featuredImage: ""
featuredImagePreview: ""
Toc:
  enable: true
math:
  enable: true
lightgallery: true
linkToMarkdown: true
share:
  enable: true
comment: 
  enable: true
---





I've tried Jekyll, Hexo and Hugo and my verdict goes to Hugo. It is **simple**, **boring**, **flexible**, and **fast**. The main reason is that it is **simple**. There’s not much you have to learn to get started.

Let's cut to the chase.



### Assumptions

1. You know how to open and run simple lines in the macOS or Windows terminal.
2. You will use `~/Sites` as the starting point for your site. (`~/Sites` is used for example purposes. If you are familiar enough with the command line and file system, you should have no issues following along with the instructions.)
3. You can write content in Markdown.



## 1. Install Hugo

Mac using home-brew:

```bash
brew install hugo
```

More operation systems and install methods can be found on install  [instructions](https://gohugo.io/getting-started/installing/) of Hugo. 



## 2. Create a New Site

Open terminal and navigate to the folder that you want to work on your blog and then:

```bash
# replace <hyper-potato.github.io> with <your-github-username.github.io>
hugo new site hyper-potato.github.io
```

This folder is the root directory for all activities after. **The best practice of naming is <your-github-username.github.io>** if you are going to use Github Pages to host the site.  

The directory structure should be like this

```
.
├── archetypes
├── config.toml
├── content
├── data
├── layouts
├── static
└── themes
```



Articles in markdown will be placed under `content` folder. Photos and favicon can be saved in `static`.

More details in each component is explained [here](https://gohugo.io/getting-started/directory-structure/). 



## 3. Pick a pretty theme

Note before you clone and use the theme you choose, make sure the theme supports math and code to avoid hassle later.  

 

###  1) Get the theme

Here is an awesome Hugo [theme compilation](https://github.com/gohugoio/hugoThemes).  Git clone your choice of theme. Here I use [Cupper](https://github.com/zwbetz-gh/cupper-hugo-theme) as an example.



You can download the theme manually by going to https://github.com/panr/hugo-theme-terminal.git and pasting it to `themes/terminal` in your root directory.



You can also clone it directly to your Hugo folder:

```bash
git clone https://github.com/jakewies/hugo-theme-codex.git themes/codex
```



If you don't want to make any radical changes, it's the best option, because you can get new updates when they are available. You can also include it as a git submodule:

```bash
git submodule add https://github.com/panr/hugo-theme-terminal.git themes/terminal
```





### 2) Quick config

You can also copy example content and default config file for a quick start

```bash
# Copy the default site config:
cp themes/meme/config-examples/en/config.toml ./
```

More details see [here](https://github.com/reuixiy/hugo-theme-meme/blob/master/config-examples/en/config.toml)

To configure your site according to your needs, just open the `config.toml` and adjust the settings. All options you should customize to yours. Make sure to read all the comments, as there a few nuances with Hugo themes that require some changes to that file.



### 3) Creating a post

```bash
hugo new posts/hotday.md # new post
```

You can now go ahead an edit the newly created file under the `content` directory. Once you are finished editing, to have hugo generate the page, set `draft = false` in the articles front matter.



### 4) Organizing pages

The above example demonstrates how to create a pages and posts. Hugo automatically applies the list templates for a directory of posts, which works well for blogs and posts. However, you may want at times want to override this behavior and create a standalone page (like an about page or projects page) or have more control of what content is listed from within the directory. In such cases, you can override the default behavior by placing an index.md file in the corresponding content directory.

```bash
hugo new projects/index.md
```



###  5) Test and configure your site

Start hugo server locally, 

```shell
hugo server
```

and visit http://localhost:1313/ to see your site. 

All options you can and should customize are commented. By default hugo will watch your files for any changes you make and **automatically** rebuild the site. It will then live reload any open browser pages and push the latest content to them. 

**Note: If you are seeing a blank page it is probably because you have nothing in your `content/` directory. Read on to fix that.**

Again, check out documentation and play around with features along the way. 

After the test is done,  kill the server by `ctrl + C`





## 4. Hosting a Hugo website

A Hugo blog is completely **static**. GitHub Pages is a great place where you can host a Hugo blog, for **free**. But `.github.io` site also looks okayish. 

Here I deploy Hugo as a GitHub personal site as an example. 



1. Create a Github repo

Create a new repo with the same name as the project folder (your-github-username.github.io) on Github website. This repo is used to store all the content in the project folder. 

Initialize the blog folder as a Github repository

```bash
git init
git add .
git commit -m "Initial commit"
```



After the repo is initialized, run the following command in the blog folder to push blog files.

```bash
git remote add origin https://github.com/your-github-username/your-github-username.github.io.git
git push -u origin master
```

For detailed instructions on how to host website on Github, go to [here](https://gohugo.io/hosting-and-deployment/hosting-on-github/)



2. Back up source code

   按照 Hugo 的生成规则，执行 `hugo` 命令后，网站静态文件将会生成在 `public` 文件夹。但由于我们使用 Github Pages 托管博客网站，该功能启用后 Github 仓库只会从 `master branch` 或 `master branch /docs folder` 读取网站源码。

   我们解决这一问题的方法是新建 `blog` 分支将博客源码放在该分支下，利用 Github Action 将 `public` 目录下的网站文件推送到 `master` 分支。首先在本地项目根目录下执行下列命令新建并切换到 `blog` 分支

   注：Github Action 的说明见附录I

   

   The `hugo` command will generate static files of the website in the `public` folder. However, Github will only load code and publish site from `master branch` or `master branch /docs` by default.

   

   One solution to this is to push only `public` directory to `master` branch, but create a `hugo` branch in the same repo to place source code.

   ```bash
   git checkout -b hugo
   git branch --set-upstream blog origin/blog # 查看分支跟踪关系 
   git branch -vv * blog   c63526c [origin/blog] Update posts`
   ```

   

   First execute the following command in the root directory of the local project to create a new and switch to the `blog` branch

按照 Hugo 的生成规则，执行 `hugo` 命令后，网站静态文件将会生成在 `public` 文件夹。但由于我们使用 Github Pages 托管博客网站，该功能启用后 Github 仓库只会从 `master branch` 或 `master branch /docs folder` 读取网站源码。

我们解决这一问题的方法是新建 `blog` 分支将博客源码放在该分支下，利用 Github Action 将 `public` 目录下的网站文件推送到 `master` 分支。首先在本地项目根目录下执行下列命令新建并切换到 `blog` 分支

注：Github Action 的说明见附录I

| ` 1 2 3 4 5 6 7 8 9 10 ` | `$ git checkout -b blog $ git branch * blog  master # 设置本地blog分支追踪远程blog分支 $ git branch --set-upstream blog origin/blog # 查看分支跟踪关系 $ git branch -vv * blog   c63526c [origin/blog] Update posts` |
| ------------------------ | ------------------------------------------------------------ |
|                          |                                                              |