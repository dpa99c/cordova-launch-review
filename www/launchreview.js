
var exec = require('cordova/exec');

var LaunchReview = function() {};

/**
 * Launches iTunes store on review page in order to leave a review for given app
 * @param appId Apple ID of app to open in iTunes Store
 * @param successCallback function to be called when plugin call was successful
 * @param errorCallback function to be called if the plugin call failed
 */
LaunchReview.prototype.launch = function(appId, successCallback,failureCallback) {
    exec(successCallback, failureCallback, 'LaunchReview', 'launch', [appId]);
}
var launchreview = new LaunchReview();
module.exports = launchreview;
