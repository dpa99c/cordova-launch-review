Cordova Launch Review plugin [![Latest Stable Version](https://img.shields.io/npm/v/cordova-launch-review.svg)](https://www.npmjs.com/package/cordova-launch-review) [![Total Downloads](https://img.shields.io/npm/dt/cordova-launch-review.svg)](https://npm-stat.com/charts.html?package=cordova-launch-review)
============================

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Overview](#overview)
- [Installation](#installation)
  - [Using the Cordova/Phonegap CLI](#using-the-cordovaphonegap-cli)
  - [PhoneGap Build](#phonegap-build)
- [Usage](#usage)
  - [launch()](#launch)
  - [rating()](#rating)
  - [isRatingSupported()](#isratingsupported)
- [Example project](#example-project)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# Overview

Cordova/Phonegap plugin for iOS and Android to assist in leaving user reviews/ratings in the App Stores.

- Launches the platform's App Store page for the current app in order for the user to leave a review.
- On iOS 10.3 and above, invokes the [native in-app rating dialog](https://developer.apple.com/documentation/storekit/skstorereviewcontroller/2851536-requestreview) which allows a user to rate your app without needing to open the App Store.
- On Android, invokes the [native in-app review dialog](https://developer.android.com/guide/playcore/in-app-review)

The plugin published to [npm](https://www.npmjs.com/package/cordova-launch-review) as `cordova-launch-review`

<!-- DONATE -->
[![donate](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG_global.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ZRD3W47HQ3EMJ&source=url)

I dedicate a considerable amount of my free time to developing and maintaining this Cordova plugin, along with my other Open Source software.
To help ensure this plugin is kept updated, new features are added and bugfixes are implemented quickly, please donate a couple of dollars (or a little more if you can stretch) as this will help me to afford to dedicate time to its maintenance. Please consider donating if you're using this plugin in an app that makes you money, if you're being paid to make the app, if you're asking for new features or priority bug fixes.
<!-- END DONATE -->


# Installation

## Using the Cordova/Phonegap [CLI](http://docs.phonegap.com/en/edge/guide_cli_index.md.html)

    $ cordova plugin add cordova-launch-review

# Usage

The plugin is exposed via the `LaunchReview` global namespace.

## launch()

Platforms: Android and iOS

Launches the App Store page for the current app in order for the user to leave a review.

- On Android, opens the app's in the Play Store where the user can leave a review by pressing the stars to give a rating.
- On iOS, opens the app's page in the App Store and automatically opens the dialog for the user to leave a rating or review.

    LaunchReview.launch(success, error, appId);

### Parameters

- {function} success - (optional) function to execute on successfully launching store app.
- {function} error - (optional) function to execute on failure to launch store app. Will be passed a single argument which is the error message string.
- {string} appID - (optional) the platform-specific app ID to use to open the page in the store app
    - If not specified, the plugin will use the app ID for the app in which the plugin is contained.
    - On Android this is the full package name of the app. For example, for Google Maps: `com.google.android.apps.maps`
    - On iOS this is the Apple ID of the app. For example, for Google Maps: `585027354`


### Simple usage

    LaunchReview.launch();
    
### Advanced usage

    var appId, platform = device.platform.toLowerCase();

    switch(platform){
        case "ios":
            appId = "585027354";
            break;
        case "android":
            appId = "com.google.android.apps.maps";
            break;
    }

    LaunchReview.launch(function(){
        console.log("Successfully launched store app");
    },function(err){
        console.log("Error launching store app: " + err);
    }, appId);

## rating()

Platforms: Android and iOS

- On iOS 10.3 and above, invokes the [native in-app rating dialog](https://developer.apple.com/documentation/storekit/skstorereviewcontroller/2851536-requestreview) which allows a user to rate your app without needing to open the App Store.
- On Android, invokes the [native in-app review dialog](https://developer.android.com/guide/playcore/in-app-review) which allows a user to rate/review your app without needing to open the Play Store.


    LaunchReview.rating(success, error);
      
**iOS notes** 
- The Rating dialog will not be displayed every time `LaunchReview.rating()` is called - iOS limits the frequency with which it can be called ([see here](https://daringfireball.net/2017/01/new_app_store_review_features)).
- The Rating dialog may take several seconds to appear while iOS queries the Apple servers before displaying the dialog.
- The success function will be called up to 3 times:
    - First: after `LaunchReview.rating()` is called and the request to show the dialog is successful. Will be passed the value `requested`.
    - Second: if and when the Rating dialog is actually displayed.  Will be passed the value `shown`.
    - Third: if and when the Rating dialog is dismissed.  Will be passed the value `dismissed`.
- Detection of the display of the Rating dialog is done using [inspection of the private class name](https://github.com/dpa99c/cordova-launch-review/blob/master/src/ios/UIWindow+DismissNotification.m#L25). 
    - This is not officially sanctioned by Apple, so while it **should** pass App Store review, it may break if the class name is changed in a future iOS version.
- Since there's no guarantee the dialog will be displayed, and even then it may take several seconds before it displays, the only way to determine if it has **not** be shown is to set a timeout after successful requesting of the dialog which is cleared upon successful display of the dialog, or otherwise expires after a pre-determined period (i.e. a few seconds).
    - See the Advanced usage below and the [example project code](https://github.com/dpa99c/cordova-launch-review-example/blob/master/www/js/index.js#L22) for an illustration of this approach.
    
**Android notes**
- Be sure to follow the [Android guidelines on when to request an in-app review](https://developer.android.com/guide/playcore/in-app-review#when-to-request)
- Google Play [enforces a quota](https://developer.android.com/guide/playcore/in-app-review#quotas) on how often a user can be shown the review dialog which means the dialog might not display after you call this method. 
- The user must first rate your app in the native dialog before being shown the review textarea input.
  

### Parameters

- {function} success - (optional) function to execute on requesting and successful of launching rating dialog.
    - iOS 
        - Will be passed a single string argument which indicates the result: `requested`, `shown` or `dismissed`.
        - Will be called the first time after `LaunchReview.rating()` is called and the request to show the dialog is successful with value `requested`.
        - *May* be called a second time if/when the rating dialog is successfully displayed with value `shown`.
        - *May* be called a third time if/when the rating dialog is dismissed with value `dismissed`.
    - Android
        - Will not be passed any callback arguments
        - Will not be called if dialog was not shown due to rate limiting
- {function} error - (optional) function to execute on failure to launch rating dialog. 
    - Will be passed a single argument which is the error message string.


### Simple usage

    LaunchReview.rating();
    
### Advanced usage

    var MAX_DIALOG_WAIT_TIME = 5000; //max time to wait for rating dialog to display
    var ratingTimerId;

    LaunchReview.rating(function(result){
        if(cordova.platformId === "android"){
            console.log("Rating dialog displayed");
        }else if(cordova.platformId === "ios"){
            if(result === "requested"){
                console.log("Requested display of rating dialog");
                
                ratingTimerId = setTimeout(function(){
                    console.warn("Rating dialog was not shown (after " + MAX_DIALOG_WAIT_TIME + "ms)");
                }, MAX_DIALOG_WAIT_TIME);
            }else if(result === "shown"){
                console.log("Rating dialog displayed");
                
                clearTimeout(ratingTimerId);
            }else if(result === "dismissed"){
                console.log("Rating dialog dismissed");
            }
        }
        
    },function(err){
        console.log("Error opening rating dialog: " + err);
    });
   

## isRatingSupported()

Platforms: Android and iOS

Indicates if the current platform/version supports in-app ratings dialog, i.e. calling `LaunchReview.rating()`.
Will return `true` if current platform is Android or iOS 10.3+.

    var isSupported = LaunchReview.isRatingSupported();

### Example usage

    if(LaunchReview.isRatingSupported()){
        LaunchReview.rating();
    }else{
        LaunchReview.launch();
    }

# Example project

An example project illustrating use of this plugin can be found here: [https://github.com/dpa99c/cordova-launch-review-example](https://github.com/dpa99c/cordova-launch-review-example)


# License
================

The MIT License

Copyright (c) 2015-2020 Working Edge Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
