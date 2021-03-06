{Repository} = require '../src/repository'
Tempdir = require 'temporary/lib/dir'
fs = require 'fs'

repo = (callback) ->
  tmpdir = new Tempdir
  config =
    url: "./example"
    branch: 'master'
    dir: tmpdir.path
  logger =
    info: (data) ->
    error: (data) ->
  callback new Repository(config, logger), tmpdir.path
  tmpdir.rmdir()

exports.testConfigruation = (test) ->
  repo (repository) ->
    test.equal(repository.config.url, "./example")
    test.equal(repository.config.branch, 'master')
    test.done()

exports.testCloneArgs = (test) ->
  repo (repository, tmppath) ->
    repository.config.dir = 'tmpdir'
    test.deepEqual repository.cloneArgs(), [
      'git'
      'clone'
      '-b'
      'master'
      '--'
      "./example"
      'tmpdir'
    ]
    test.done()

exports.testCloneArgsWithoutBranch = (test) ->
  repo (repository, tmppath) ->
    repository.config.dir = 'tmpdir'
    repository.config.branch = null
    test.deepEqual repository.cloneArgs(), [
      'git'
      'clone'
      '--'
      "./example"
      'tmpdir'
    ]
    test.done()

exports.testPullArgs = (test) ->
  repo (repository, tmppath) ->
    test.deepEqual repository.pullArgs(), ['git', 'pull']
    test.done()

exports.testClone = (test) ->
  repo (repository, tmppath) ->
    repository.on 'cloned', ->
      fs.exists tmppath + '/.git', (exists) ->
        test.ok exists
        test.done()
    repository.sync()
      
exports.testPull = (test) ->
  repo (repository, tmppath) ->
    repository.on 'cloned', ->
      fs.exists tmppath + '/.git', (exists) ->
        test.ok exists
        repository.sync()
    repository.on 'pulled', ->
      test.done()
    repository.sync()
