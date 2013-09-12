fs = require "fs"
path = require "path"

module.exports = (grunt) ->

  #load external tasks and change working directory
  grunt.source.loadAllTasks()

  gracefulRead = (path) ->
    try
      return grunt.file.read path
    return ""

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

  #initialise config
  grunt.initConfig
    #watcher
    watch:
      scripts:
        files: 'src/scripts/**/*.coffee'
        tasks: 'scripts'
      vendor:
        files: 'src/scripts/vendor/**/*.js'
        tasks: 'scripts-pack'
      views:
        files: 'src/views/**/*.jade'
        tasks: 'views'
      styles:
        files: 'src/styles/**/*.styl'
        tasks: 'styles'
      config:
        files: ['Gruntsource.json']
        tasks: 'default'

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
    ngmin:
      app:
        src: output.js
        dest: output.js
    uglify:
      compress:
        src: output.js
        dest: output.js
    jade:
      compile:
        src: "src/views/index.jade"
        dest: output.html
        options:
          pretty: dev
          data:
            JSON: JSON
            showFile: gracefulRead
            source: grunt.source
            env: env
            min: if env is 'prod' then '.min' else ''
            dev: dev
            date: new Date()
            manifest: "<%= manifest.generate.dest %>"
            css: "<style>#{gracefulRead(output.css)}</style>"
            js: "<script>#{gracefulRead(output.js)}</script>"
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

  #task groups
  grunt.registerTask "scripts-compile",      ["coffee"]
  grunt.registerTask "scripts-pack", ["concat:scripts"].
                                  concat(if not dev and grunt.source.angular then ["ngmin"] else []).
                                  concat(if dev then [] else ["uglify"])
  grunt.registerTask "scripts", ["scripts-compile","scripts-pack"]
  grunt.registerTask "styles",  ["stylus"].concat(if dev then [] else ["cssmin"])
  grunt.registerTask "views",   ["jade"]
  grunt.registerTask "build",   ["scripts","styles","views"]
  grunt.registerTask "default", ["build","watch"]
