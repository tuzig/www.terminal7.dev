---
title: "Static Site Generation with Hugo and LLaMa"
date: 2024-06-10T12:33:12+03:00
---

Setting up static sites and weblogs has been a chore that's been  hunting me since the last millennium.
This site is the latest in a long line of web sites I've set up and I've tried many tools and platforms. 
Luckily, we live in the future and we have static site generators like Hugo and large language models that make it easier to learn new tools.

The concept of static site generators is simple: You write the content in
Markdown and the generator mixes it with a template to produce a static
HTML site. This has many advantages over dynamic sites, such as speed,
security, and simplicity.

All processing is done on the build phase and the result is a set of HTML,
css and static files that you can upload to any hosting service.
Instead of storing the meta data in a database, it's stored in the header
of the markdown files. This simplifies updates as adding a new post is just
adding a new file, comitting and pushing. 
Thanks to github integration Netlify will pick up the changes and rebuild the site.

Hugo is just one of many static site generators.
Notable alternatives include Jekyll, Pelican, and Gatsby.
I chose Hugo because it's simple, very active and written in Go.

When it comes to tools, I like to have them in binary form.
Python is acceptable, but I'll prefer an alternative written in Go or Rust
even if its less popular. When it comes to javascript,
I very rarely install tools from npm as its a cesspool.
I can't have my tools break on me and npm break too often.

So Hugo it is. It's a single binary that you can download and has all the commands I need.
It's fast, has a lot of themes and is easy to use.
You can install it on any platform and it's easy to update.

The only issue is that I don't want to learn it. 
Developing a site is a chore that comes up once in a while and
I want to minimize the time I spend on it.
I don't want to read the docs and build a mental model of how it works.
I just want to write my content and have it appear on the web - as promised.

This is where the LLaMa helps. I let it carry the load
of learning Hugo and feed it with prompts to get the changes I want.
It's not easy - like real LLaMas, they can be stubborn and have a mind of their own. It takes training, stringing the right sentences and getting the
LLaMa to grok the task at hand.

As I prefer to work in the terminal, the first thing I did was to install the
llm command line tool. It supports 
[many kinds of LLaMas](https://llm.datasette.io/en/stable/plugins/directory.html) (including local ones), it's in python so I have my reservations,
but it's written by Simon Willison and as I've known Simon for 15 years, I trust it.

It has a simple interface and smart options and it deserves a clip of its own.
Once you run `pip install llm` you need to configure the LLaMa keys.
If your using ChatGPT things are a bit simpler as it's baked in.
For other models, like Claude, you'll need a few commands:

```bash
$ llm install llm-calude-3 
$ llm keys set calude
$ llm models default calude-opus
```

Now that we have our LLaMa installed and configured,
we can use it so we don't have to learn Hugo.

## Getting started

```bash
$ llm "How do I generate a static site using Hugo?"
```

### Claude Response

To generate a static site using Hugo, follow these steps:

1. Install Hugo:
   - Download the appropriate version of Hugo for your operating system from the official Hugo website (https://gohugo.io/getting-started/installing/).
   - Follow the installation instructions provided for your operating system.

2. Create a new Hugo site:
   - Open your terminal or command prompt.
   - Navigate to the directory where you want to create your Hugo site.
   - Run the command: `hugo new site mysite` (replace "mysite" with your desired site name).
   - This will create a new directory with the specified name containing the basic structure of a Hugo site.

3. Add a theme:
   - Navigate to your site's directory: `cd mysite`
   - Choose a theme from the Hugo themes website (https://themes.gohugo.io/) or create your own.
   - Clone the theme repository into the `themes` directory of your site. For example, if you chose the "Ananke" theme, run:
     `git clone https://github.com/theNewDynamic/gohugo-theme-ananke.git themes/ananke`
   - Open the `config.toml` file in your site's root directory and add or modify the `theme` parameter to specify the theme you just added. For example: `theme = "ananke"`
...

For more detailed information and advanced usage, refer to the Hugo documentation (https://gohugo.io/documentation/).

This is a great start. I created a new site, chose the gokarna theme and got the development server running with `hugo server -D`

## Making changes
Now I wanted to add text to the home page. This is dependent on the theme
so I had to feed the LLaMa source code ask for help:

```bash
$ find . -type f -name "*.toml" -o -name "*.html" -o -name "*.md" -print0 \
| xargs -0 -I{} sh -c 'echo "## {}" ; cat {}' \
| llm "How do we add text to the home page of the gokarna based site that follows?"

```

This 3 step pipeline that does:
- use `find` to get all the important files in the directory. `-print0` gets the output in a format that can be used by `xargs`
- use `xargs` to print the file name and content for each file
- use `llm` to pipe the output to the LLaMa and include the task

### response

To add text to the home page of the Gokarna theme, you can create a file called `index-about.md` in the `content` directory of your Hugo site. The contents of this file will be rendered below the social icons on the home page.

Here's how you can do it:

1. Navigate to the `content` directory of your Hugo site.

2. Create a new file named `index-about.md`.

3. Open the `index-about.md` file in a text editor.

4. Write your desired content in Markdown format. For example:

...

5. Save the `index-about.md` file.

6. Rebuild your Hugo site using the `hugo` command or `hugo server` if you're running it locally.

The content you wrote in the `index-about.md` file will now appear on the home page of your Gokarna-themed Hugo site, below the social icons.

Note that you don't need to add any front matter (metadata) to the `index-about.md` file. The content will be automatically rendered on the home page.

Remember to use valid Markdown syntax to format your content, and you can include links, images, and other elements as needed.

That's it! You've successfully added text to the home page of your Gokarna-themed Hugo site.

### It worked!

I now add a markdown file whose content appears on the home page.
Just the look of it was a bit off.

## Adding Lipstick

I've added an unordered list and it looked cramped.
I wanted more space between the items so I asked the LLaMa how to do it>
This time, I used the `-c` option to continue the conversation and have access
to the source from the first question.

```bash
$ llm -c "Thanks! I've added an unordered list in index-about.md and we need to change it's line hight to 1.5"
```

### Claude Response

To change the line height of the unordered list in the `index-about.md` file, you can use custom CSS. Here's how you can do it:

1. Open your Hugo site's configuration file (`config.toml` or `config.yaml`) in a text editor.

2. Locate the `[params]` section in the configuration file.

3. Add the following line under the `[params]` section to specify the custom CSS:

```toml
[params]
  customCSS = "css/custom.css"
```

4. Save the configuration file.

...

## WRONG!

I tried the above and it didn't work.
custom.css was not being loaded by the browser and the line height was not changing.
I googled around and found that customCSS is not a Hugo parameter. Some themes support it but Gokarna does not.
Time to go back the LLaMa and direct it at the theme to get a better answer:


```bash
$ llm -c "Are you sure gokarna has support for customCSS? please review the gokarna theme sources I gave you early on and check if it's the right way to add a custom css file"

```

### Claude Response:

I apologize for the confusion. After reviewing the Gokarna theme sources you provided earlier, I couldn't find a specific configuration option for adding a custom CSS file.

However, Gokarna does support adding custom HTML in the head section of the site, which allows you to include custom CSS styles or link to an external CSS file.

To add custom CSS styles or link to a custom CSS file, you can follow these steps:

1. Open the `config.toml` file in the root directory of your Hugo project.

2. Add the following line to the `[params]` section of the `config.toml` file:

   ```toml
   [params]
     customHeadHTML = '''
       <style>
         /* Your custom CSS styles go here */
         .beliefs-list {
           line-height: 1.8;
         }
       </style>
     '''
   ```

   Alternatively, if you want to link to an external CSS file, you can use:

   ```toml
   [params]
     customHeadHTML = '''
       <link rel="stylesheet" href="/path/to/your/custom.css">
     '''
   ```

   Make sure to replace `/path/to/your/custom.css` with the actual path to your custom CSS file.

3. Save the changes to the `config.toml` file.

4. If you're linking to an external CSS file, create the CSS file in the specified location within your Hugo project's directory structure.

5. Update your `index-about.md` file to apply the CSS class to the list:

   ```markdown
   ## Our Beliefs

   <div class="beliefs-list">

    - We believe in the power of open source software
    - We believe in the power of community
    - We believe in the power of collaboration

   </div>
   ```
...

## A c is not a C

This didn't work either. The customHeadHTML was not being added to the head of the page.
It was time to go grepping:

```bash

$ rg -i customh 

themes/gokarna/layouts/partials/head.html:    {{ if .Site.Params.CustomHeadHTML }}
themes/gokarna/layouts/partials/head.html:    {{ .Site.Params.CustomHeadHTML | safeHTML }}
themes/gokarna/exampleSite/config.toml:  customHeadHTML = """
...

```

The docs says the param starts with a lower c and the template uses a capital C.
That's a bug in the theme that confused the LLaMa and I can't hold it against it.

For now, I used a capital C and it worked.
I asked the LLaMa where is the best place for a the file and got
`static/css/style.css`. I added the file and now not only was the site
looking better, I had a place for all future styling.

## Adding a post

Now that the home page was looking good, I wanted to add a post.
It was a task Hugo got covered later in the first response:

### Claude 1st Response Continued

4. Create content:
   - Use the `hugo new` command to create new pages or blog posts. For example, to create a new blog post, run:
     `hugo new posts/my-first-post.md`
   - This will create a new Markdown file in the `content/posts` directory with some default front matter.
   - Open the newly created file and add your content using Markdown syntax.

5. Preview your site:
   - Run the command: `hugo server -D`
   - This will start a local development server and provide you with a URL to preview your site in the browser.
   - Any changes you make to your content or theme will be automatically refreshed in the browser.

6. Build and deploy your site:
   - Once you're satisfied with your site, stop the development server.
   - Run the command: `hugo`
   - This will generate the static files for your site in the `public` directory.
   - You can then deploy the contents of the `public` directory to your web hosting provider or use platforms like GitHub Pages or Netlify for easy deployment.

That's it! You now have a basic static site generated using Hugo. You can further customize your site by modifying the theme, adding more content, and configuring additional settings in the `config.toml` file.

---

## It worked!

I've added a new post, commited and pushed and deployed the site (thanks Netlify!).
This round of LLaMa driven development was a success. 

## Conclusion

Hugo delivers. It's simple and fast and has ton of themes.
Maybe too many themes as it's hard to choose and quality varies.
It can be confusing as the theme defines many of the parameters and the docs are not always clear.

The LLaMa, claude3 opus in this case, helped me finish this ahead of schedule.
It guided me through the setup, the theme and the customizations.
It's answers where clear and concise and it was able to follow up on my questions.

It did have a bit of trouble with the custom css part. 
It seems that when the going gets tough the LLaMa goes lazy.
It's not the good kind of lazy Linus likes - using other people
code as much as possible - but the bad one of not being thorough.
My question dug up the `customCSS` parameter which is
used in some themes but not in Gokarna.

It happened twice, with the customCSS and the customHeadHTML.
In the case of the customHeadHTML it was a bit more confusing as the LLaMa found it in the docs but it wasn't part of the theme's source.
In both cases I used follow up input to hold the LLaMa's feet to the fire to get a better answer.

This is becoming a familiar pattern:
My prompts are not detailed enough and the LLaMa finds an answer that's
close but not quite right.
