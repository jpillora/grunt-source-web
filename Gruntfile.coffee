fs = require "fs"
path = require "path"

module.exports = (grunt) ->

  #load external tasks and change working directory
  grunt.source.loadAllTasks()

  #output files
  output = grunt.source.output or {}
  grunt.util._.defaults output,
    js: "js/app.js"
    css: "css/app.css"
    html: "index.html"

  #check options
  env = grunt.option "env"
  env = "dev" unless env in ["dev","prod"]
  dev = env is "dev"

  port = grunt.option('server')

  if port
    port = 3000 unless typeof port is 'number'
    grunt.log.ok "Static file server enabled (http://0.0.0.0:#{port})"

  livereload = grunt.option('livereload')
  if livereload
    grunt.log.ok "LiveReload enabled"

  #initialise config
  grunt.initConfig

    #watcher
    watch:
      options:
        livereload: livereload
      scripts:
        files: 'src/scripts/**/*.coffee'
        tasks: 'scripts'
      vendor:
        files: 'src/scripts/vendor/**/*.js'
        tasks: 'scripts'
      views:
        files: 'src/views/**/*.jade'
        tasks: 'views'
      styles:
        files: 'src/styles/**/*.{styl,css}'
        tasks: 'styles'
      config:
        files: ['Gruntsource.json']
        tasks: 'default'

    connect:
      server:
        options:
          base: path.dirname output.html
          directory: path.dirname output.html
          hostname: "0.0.0.0"
          port: port

    #tasks
    coffee:
      compile:
        src: [
          "src/scripts/init.coffee",
          "src/scripts/**/*.coffee",
          #remove and re-add to insert at bottom
          "!src/scripts/run.coffee",
          "src/scripts/run.coffee"
        ]
        dest: output.js
        options:
          bare: false
          join: true
    concat:
      scripts:
        src: ["src/scripts/vendor/*.js", output.js]
        dest: output.js
      styles:
        src: ["src/styles/vendor/*.css", output.css]
        dest: output.css
    ngmin:
      app:
        src: output.js
        dest: output.js
    uglify:
      compress:
        src: output.js
        dest: output.js
    jade:
      options:
        pretty: dev
        doctype: "5"
        data: require("./helper/jade-data")(grunt,env)
      index:
        src: "src/views/index.jade"
        dest: output.html
      templates:
        expand: true
        cwd: "src/views/templates/"
        src: "**/*.jade"
        dest: path.join path.dirname(output.html), 'templates'
        ext: ".html"
    stylus:
      compile:
        src: "src/styles/app.styl"
        dest: output.css
        options:
          urlfunc: 'embedurl'
          define:
            source: grunt.source
          compress: not dev
          linenos: dev
          'include css': true
          paths: ["src/styles/embed/","../"]
    cssmin:
      compress:
        src: output.css
        dest: output.css

    #appcache
    manifest:
      generate:
        options:
          # basePath: '../',
          network: ['*']
          # fallback: ['/ /offline.html'],
          preferOnline: true
          verbose: false
          timestamp: true
        src: [
          'css/img/**/*.*'
          output.css
          output.js
        ]
        dest: 'appcache'

  #external aws credentials
  try
    aws = grunt.file.readJSON "./aws.json"
    throw "Missing 'accessKeyId'" unless aws.accessKeyId
    grunt.config 's3.options.accessKeyId', aws.accessKeyId
    throw "Missing 'secretAccessKey'" unless aws.secretAccessKey
    grunt.config 's3.options.secretAccessKey', aws.secretAccessKey
  catch e
    grunt.renameTask "s3", "__s3"
    grunt.registerTask "s3", ->
      grunt.fail.warn "Error reading 'aws.json' file: #{e}"

  #conditional tasks
  templates = grunt.file.isDir "src/templates"

  #task groups
  grunt.registerTask "scripts", ["coffee", "concat:scripts"].
                                  concat(if not dev and grunt.source.angular then ["ngmin"] else []).
                                  concat(if dev then [] else ["uglify"])
  grunt.registerTask "styles",  ["stylus", "concat:styles"].
                                  concat(if dev then [] else ["cssmin"])
  grunt.registerTask "views",   ["jade:index"].
                                  concat(if templates then ["jade:templates"] else [])
  grunt.registerTask "build",   ["scripts","styles","views"]
  grunt.registerTask "default", ["build"].
                                  concat(if port then ["connect"] else []).
                                  concat("watch")
