var system = require('system');
var imageName = system.args[1];
var page = require('webpage').create();
page.open('http://localhost:4040/streaming/', function() {
  page.render(imageName);
  phantom.exit();
});
