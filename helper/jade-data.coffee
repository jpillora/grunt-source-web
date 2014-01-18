fs = require "fs"
path = require "path"
hljs = require "highlight.js"
#grab grunt-jade's jade
jade = require '../node_modules/grunt-contrib-jade/node_modules/jade'
marked = require "marked"
marked.setOptions gfm:true

#custom jade data for config
module.exports = (grunt, env) ->

  read = (path) ->
    try return grunt.file.read path
    return ""

  #include directory helper
  includeDir = (dir) ->
    unless grunt.file.isDir dir
      grunt.log.writeln "Not a directory: #{dir}"
      return ""
    results = ""

    #needs a new 'includeDir'
    data = Object.create jadeData
    data.includeDir = (subdir) ->
      includeDir path.join dir, subdir

    fs.readdirSync(dir).forEach (file) ->
      return unless path.extname(file) is '.jade'
      full = path.join dir, file
      return if grunt.file.isDir(full)
      input = read full
      try
        output = jade.compile(input,{pretty:env is "dev",doctype:"5"})(data)
        results += output + "\n"
      catch e
        grunt.fail.fatal """
          Jade Compile Error: #{e.message}
          File: '#{full}'
          Stack: #{e.stack or '<missing>'}
        """
    return results

  jadeData = 
    JSON: JSON
    showCodeFile: (file) ->
      lang = switch path.extname(file)
        when ".js"
          "javascript"
        when ".coffee"
          "coffeescript"
        else
          "bash"
      code = jadeData.showFile file
      if grunt.source.name
        code = code.replace(/(require\(['"])([\.\/]+)(['"]\))/, "$1#{grunt.source.name}$3")
      html = jadeData.showCode lang, code
      html
    showCode: (lang, str) ->
      html = hljs.highlight(lang, str).value
      "<pre><code>#{html}</code></pre>"
    showFile: (file) ->
      read path.join "..", file
    source: grunt.source
    env: env
    min: if env is 'prod' then '.min' else ''
    dev: env is "dev"
    date: new Date()
    manifest: "<%= manifest.generate.dest %>"
    includeCSS: -> "<style>#{read(output.css)}</style>"
    includeJS: -> "<script>#{read(output.js)}</script>"
    includeDir: (dir) -> includeDir path.join "src", "views", dir

  return jadeData




