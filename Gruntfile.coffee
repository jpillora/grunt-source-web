module.exports = (grunt) ->

  #resolve options
  env = grunt.option "env"
  env = "dev" unless env in ["dev","prod"]
  dev = env is "dev"

  #load external tasks
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-jade"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-stylus"

  #above here the working directory is the grunt directory
  gruntdir = process.cwd()
  base = grunt.option "basedir"
  throw "Missing 'basedir' option" unless base
  grunt.file.setBase base
  #below here the working directory is the project directory

  source = grunt.file.readJSON "./GruntSource.json"

  grunt.initConfig
    #watcher
    watch:
      options:
        nospawn: true
      scripts:
        files: 'src/scripts/**/*.coffee'
        tasks: 'scripts'
      views:
        files: 'src/views/**/*.jade'
        tasks: 'views'
      styles:
        files: 'src/styles/**/*.styl'
        tasks: 'styles'
      config:
        files: ['GruntSource.json', "#{gruntdir}/Gruntfile.coffee"]
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
            source: source
            env: env
            dev: dev
            date: new Date()
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
          paths: ["src/styles/"]

  #task groups
  grunt.registerTask "scripts", ["coffee"].concat(if dev then [] else ["uglify"])
  grunt.registerTask "styles",  ["stylus"]
  grunt.registerTask "views",   ["jade"]
  grunt.registerTask "build",   ["scripts","styles","views"]
  grunt.registerTask "default", ["build","watch"]
