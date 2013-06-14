grunt-source-ghpages
====================

A GruntSource project to build Github Pages websites

# Usage


* Install Grunt Source

  ``` shell
  npm install -g grunt-source
  ```

* Create a `GruntSource.json` in the root of your `gh-pages` branch

  ``` shell
  {
    "source": "~/Code/JavaScript/grunt-source-ghpages",
    "repo": "https://github.com/jpillora/grunt-source-ghpages.git"
  }
  ```

  *Note: You can change the destination path*

* Create the following directory structure:

  ```
  src/
    scripts/index.coffee
    styles/index.styl
    views/index.jade
  ```

* Run:

  ```
  grunt-source
  ```

* Poof:

  ```
  src ...
  js/app.js
  css/app.css
  index.html
  ```

# Customising

Replace the `source` directory with your fork of the
[grunt-source-ghpages repo](https://github.com/jpillora/grunt-source-ghpages) and
edit your `GruntSource.json` file's `repo` to be the new Git URL - then rerun `grunt-source`.

