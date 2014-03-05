grunt-source-web
====================

A premade Grunt environment to build optimized static websites,
utilizing [Grunt Source](https://github.com/jpillora/grunt-source).

## Features

* Development and Production builds with `--env dev|prod`
* Compile your [Java|Coffee]Script, Jade and Stylus
* Watch source each directory and compile only what is required
* Add a `config` object to have it merged into the grunt config
* Grunt source config available as the `source` variable in Jade and Stylus files
* Easily embed images in CSS as Data-URIs
* Add an `angular` flag to run `ng-min` over your files before minification
* Generate an Application Cache manifest file with the `manifest` task

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
      scripts/app.coffee
      styles/app.styl
      views/index.jade
  ```


* And compile these files to:

  ``` sh
  js/app.js
  css/app.css
  index.html
  ```

* And we're ready to host on Github Pages

## Grunt Options

#### `--env=<env>`

Can be `prod` or `dev` (defaults to `dev`).

`prod` will minify all JS, CSS, HTML

`dev` will leave the JS intact, create annotated CSS, prettify your HTML

#### `--server=<port>`

#### `--livereload=true`

## Grunt Source Config

* `angular` when `true`, will run `ng-min` before `uglify`

## Tasks

Below is the output from `grunt-source --help`

```
            init  Initialises a project with using a set of defaults
          stylus  Compile Stylus files into CSS *
          coffee  Compile CoffeeScript files into JavaScript *
            jade  Compile jade templates. *
          uglify  Minify files with UglifyJS. *
          cssmin  Minify CSS files *
          concat  Concatenate files. *
           ngmin  Annotate AngularJS scripts for minification *
        manifest  Generate HTML5 cache manifest *
            copy  Copy files. *
           watch  Run predefined tasks whenever watched files change.
           
 scripts-compile  Alias for "coffee" task.
    scripts-pack  Alias for "concat:scripts" task.
         scripts  Alias for "scripts-compile", "scripts-pack" tasks.
          styles  Alias for "stylus" task.
           views  Alias for "jade" task.
           build  Alias for "scripts", "styles", "views" tasks.
         default  Alias for "build", "watch" tasks.
```

Currently, the `default` task will build everthing then watch everything
for changes. In an effort to reduce the asset count, the build step
aims to construct 1 output file. So after build you should have 1 JS,
1 CSS, 1 HTML file.

You can use any number of `.coffee` files
as they will all be joined and wrapped in an IEFF. To attan a specific execution
sequence, `.coffee` files will be concatenated as follows:

```
	"src/scripts/init.coffee"
	"src/scripts/**/*.coffee"
	"src/scripts/run.coffee"
```

This way you can place all initialising code in `src/scripts/init.coffee` to be
run first and then all "boot" your code by creating a `src/scripts/run.coffee`
to be run last.

You can use more
`.styl` files by using the built-in `include` syntax, and similarly,
you can use the built-in `include` to split out your HTML into a
logical file structure of `.jade` files.

In your `.styl` files, you can swap out `url(...)` for `embedurl(...)` to embed those
images in place using data-URIs. Project root and `src/styles/embed/` have been set
as embed paths.

In your `.jade` files, for your convenience, the following variables have been set

``` coffee
    JSON: JSON
    showFile: (file) ->
      grunt.read.file path.join base, file
    source: grunt.source
    env: env
    min: if env is 'prod' then '.min' else ''
    dev: dev
    date: new Date()
    manifest: "<%= manifest.generate.dest %>"
```

See this [src](https://github.com/jpillora/verifyjs-com/tree/build-tool-refactor/src)
folder as an example set of files utilising this grunt source.

See this projects Gruntfile.coffee for more information.

## Todo

* Sourcemaps in development builds

## Customising

1. Fork [this repo](https://github.com/jpillora/grunt-source-web)
2. Edit your `GruntSource.json` file's `repo` to be the new Git URL
3. Edit your `GruntSource.json` file's `source` to reference a new directory
4. Rerun `grunt-source`
5. Push your changes
6. Pull-request for others to enjoy

