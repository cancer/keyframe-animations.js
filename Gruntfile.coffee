
module.exports = (grunt) ->
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee:
      compile:
        files: 'keyframe-animations.js' : [
          'lib/css_property.coffee'
          'lib/keyframe_animation.coffee'
        ]

    watch:
      coffee:
        files: ['lib/*.coffee']
        tasks: ['coffee']

    connect:
      server:
        options:
          port: '9000'
          base: '.'

  grunt.registerTask 'default', ['connect', 'watch']

