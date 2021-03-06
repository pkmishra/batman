glob = require 'glob'
fs = require 'fs'
path = require 'path'
# Load test runner
qqunit = require 'qqunit'

# Load jquery into window
jquerySource = fs.readFileSync(path.join(__dirname, 'lib', 'jquery.js')).toString()

qqunit.Environment.jsdom.jQueryify window, path.join(__dirname, 'lib', 'jquery.js'), (window, jQuery) ->
  global.jQuery = jQuery

  # Load test helper
  Helper = require './batman/test_helper'
  global[k] = v for own k,v of Helper

  global.Batman = require '../src/batman.node'
  Batman.exportGlobals(global)
  Batman.Request::send = -> throw new Error "Can't send requests during tests!"

  tests = glob.sync("#{__dirname}/batman/**/*_test.coffee").map (test) -> path.resolve(process.cwd(),test)

  console.log "Running Batman test suite. #{tests.length} files required."
  qqunit.Runner.run tests, (stats) ->
    process.exit stats.failed
