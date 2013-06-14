module.exports = (grunt) ->

  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-jade"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-stylus"

  #above here the working directory is the grunt directory
  base = grunt.option "basedir"
  throw "Missing 'basedir' option" unless base
  grunt.file.setBase base
  #below here the working directory is the project directory

  grunt.initConfig
    #watcher
    watch:
      coffee:
        files: 'src/scripts/*.js'
        tasks: 'coffee'
        options:
          nospawn: true
      jade:
        files: 'src/views/**/*.jade'
        tasks: 'jade'
        options:
          nospawn: true
      stylus:
        files: 'src/styles/**/*.styl'
        tasks: 'stylus'
        options:
          nospawn: true
    #tasks
    coffee:
      compile:
        files:
          "js/app.js": "src/scripts/**/*.coffee"
        options:
          bare: false
    jade:
      compile:
        files:
          "index.html": "src/views/index.jade"
        options:
          pretty: true
    stylus:
      compile:
        files:
          "css/app.css": "src/styles/app.styl"

  #task groups
  grunt.registerTask "build",   ["coffee","jade","stylus"]
  grunt.registerTask "default", ["build","watch"]
