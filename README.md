grunt-source-ghpages
====================

A GruntSource project to build static websites.

## Usage

* Install Grunt Source

	http://github.com/jpillora/grunt-source
  
* When we run:

  ``` sh
  grunt-source
  ```

* It will create the following directory structure:

  ``` sh
  src/
    scripts/index.coffee
    styles/index.styl
    views/index.jade
  ```


* And compile these files to:

  ``` sh
  js/app.js
  css/app.css
  index.html
  ```

* And we're ready to host on Github Pages

## Features

The default task will:

* Development and Production builds with `--env dev|prod`
* Compile your CoffeeScript, Jade and Stylus
* Watch source each directory and compile only what is required
* Add a `config` object to have it merged into the grunt config
* Add an `angular` flag to run `ng-min` over your files before minification 

The current setup will create 1 JS, 1 CSS, 1 HTML in an effort to reduce the asset count. You can use any number of `.coffee` files as they will all be joined and wrapped in an IEFF, you can use more `.styl` files by using the built-in `include` syntax, and similarly, you can use the built-in `include` to split out your HTML into a logical file structure of `.jade` files.

## Customising

Replace the `source` directory with your fork of the
[grunt-source-ghpages repo](https://github.com/jpillora/grunt-source-ghpages) and
edit your `GruntSource.json` file's `repo` to be the new Git URL - then rerun `grunt-source`.

