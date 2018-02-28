/* Copyright (c) 2015 Dave Alden  (http://github.com/dpa99c)
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 */
var LaunchReview = {};

var isRatingSupported;

cordova.exec(function(_isRatingSupported){
    isRatingSupported = !!parseInt(_isRatingSupported);
}, null, 'LaunchReview', 'isRatingSupported', []);

/**
 * Launches App Store on current platform in order to leave a review for given app
 * @param {function} success (optional) -  function to be called when plugin call was successful.
 * @param {function} error (optional) - function to be called on error during plugin call.
 * Will be passed a single argument which is the error message string.
 * @param {string} appId (optional) - ID of app to open in App Store.
 * If not specified, the ID for the current app will be used.
 */
LaunchReview.launch = function(success, error, appId) {
    // backward compatibility shim for v1 & v2 where function signature was (appId, success, error)
    if(typeof success === "string"){
        console.warn("The launch function signature has been updated from (appId, success, error) to (success, error, appId) in v3 of the plugin. This deprecation shim will be removed in v4.");

        var _appId = arguments[0];
        var _success = arguments[1];
        var _error = arguments[2];

        success = _success;
        error = _error;
        appId = _appId;
    }
    cordova.exec(success, error, 'LaunchReview', 'launch', [appId]);
};

/**
 * Opens the in-app ratings dialogs introduced by iOS 10.3.
 * iOS only. Calling this on any platform other than iOS 10.3 or above will result in the error function being called.
 * @param {function} success (optional) -  function to be called when plugin call was successful.
 * @param {function} error (optional) - function to be called on error during plugin call.
 * Will be passed a single argument which is the error message string.
 */
LaunchReview.rating = function(success, error) {
    if(LaunchReview.isRatingSupported()){
        cordova.exec(success, error, 'LaunchReview', 'rating', []);
    }else{
        error("Rating dialog requires iOS 10.3+");
    }
};

/**
 * Indicates if the current platform supports in-app ratings dialog, i.e. calling LaunchReview.rating().
 * Will return true if current platform is iOS 10.3 or above.
 * @returns {boolean} true if the current platform supports in-app ratings dialog
 */
LaunchReview.isRatingSupported = function(){
    return isRatingSupported;
};

module.exports = LaunchReview;