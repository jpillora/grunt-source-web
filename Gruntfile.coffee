fs = require "fs"
path = require "path"

module.exports = (grunt) ->

  #resolve options
  env = grunt.option "env"
  env = "dev" unless env in ["dev","prod"]
  dev = env is "dev"

  #load external tasks and change working directory
  grunt.source.loadAllTasks()

  #load project specific custom tasks
  grunt.loadTasks "./tasks" if grunt.file.isDir "./tasks"

  source = grunt.file.readJSON "./Gruntsource.json"

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
        files:
          #init then all then run
          "js/app.js": [
            "src/scripts/init.coffee",
            "src/scripts/**/*.coffee",
            #remove and re-add to insert at bottom
            "!src/scripts/run.coffee",
            "src/scripts/run.coffee"
          ]
        options:
          bare: false
          join: true
    concat:
      scripts:
        files:
          "js/app.js": ["src/scripts/vendor/*.js", "js/app.js"]
    ngmin:
      app:
        files:
          "js/app.js": "js/app.js"
    uglify:
      compress:
        files:
          "js/app.js": "js/app.js"
    jade:
      compile:
        files:
          "index.html": "src/views/index.jade"
        options:
          pretty: dev
          data:
            JSON: JSON
            showFile: (file) ->
              fs.readFileSync(path.join base, file).toString()
            source: source
            env: env
            min: if env is 'prod' then '.min' else ''
            dev: dev
            date: new Date()
            manifest: "<%= manifest.generate.dest %>"
    stylus:
      compile:
        files:
          "css/app.css": "src/styles/app.styl"
        options:
          urlfunc: 'embedurl'
          define:
            source: source
          compress: not dev
          linenos: dev
          'include css': true
          paths: ["src/styles/embed/","../"]
    cssmin:
      compress:
        files:
          "css/app.css": "css/app.css"

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
          'css/app.css'
          'js/app.js'
        ]
        dest: 'appcache'

  #task groups
  grunt.registerTask "scripts-compile",      ["coffee"]
  grunt.registerTask "scripts-pack", ["concat:scripts"].
                                  concat(if not dev and source.angular then ["ngmin"] else []).
                                  concat(if dev then [] else ["uglify"])
  grunt.registerTask "scripts", ["scripts-compile","scripts-pack"]
  grunt.registerTask "styles",  ["stylus"].concat(if dev then [] else ["cssmin"])
  grunt.registerTask "views",   ["jade"]
  grunt.registerTask "build",   ["scripts","styles","views"]
  grunt.registerTask "default", ["build","watch"]
