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

/**
 * Launches App Store on current platform in order to leave a review for given app
 * @param {function} success (optional) -  function to be called when plugin call was successful.
 * @param {function} error (optional) - function to be called on error during plugin call.
 * Will be passed a single argument which is the error message string.
 * @param {string} appId (optional) - ID of app to open in App Store.
 * If not specified, the ID for the current app will be used.
 */
LaunchReview.launch = function(success, error, appId) {
    cordova.exec(success, error, 'LaunchReview', 'launch', [appId]);
};

/**
 * Opens the in-app ratings dialog on iOS 10.3+ or the in-app review dialog on Android.
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
 * Will return true if current platform is Android or iOS 10.3 or above.
 * @returns {boolean} true if the current platform supports in-app ratings dialog
 */
LaunchReview.isRatingSupported = function(){
    return cordova.platformId === 'android' || (cordova.platformId === 'ios' && parseFloat(device.version) >= 10.3)
};

module.exports = LaunchReview;
