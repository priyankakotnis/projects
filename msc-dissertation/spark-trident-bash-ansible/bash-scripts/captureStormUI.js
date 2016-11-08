var system = require('system');
var address = system.args[1];
var imageName = system.args[2];
var page = require('webpage').create();
page.open(address,function (status) {
        waitForPageLoad();
});
function waitForPageLoad() {
    setTimeout(function() {
            page.render(imageName);
            phantom.exit();
    }, 10000);
}
