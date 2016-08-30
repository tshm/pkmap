/*global require */
var sh = require('shelljs');
var version = require('./package.json').version;
var hash = sh.exec('git rev-parse HEAD').trim();
sh.echo(['var version="', version, '_', hash, '"'].join('')).to('version.js');

