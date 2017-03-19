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

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# Overview

This Cordova/Phonegap plugin for iOS and Android launches the native store app in order for the user to leave a review.

On Android, the plugin opens the the app's storepage in the Play Store where the user can leave a review by pressing the stars to give a rating.

On iOS, the plugin opens the app's storepage in the App Store, focuses the Review tab, and automatically opens the dialog for the user to leave a rating or review.
On iOS 10.3 and above, there is also support for the in-app ratings dialog which allows a user to rate your app without needing to open the App Store.

The plugin is registered on [npm](https://www.npmjs.com/package/cordova-launch-review) (requires Cordova CLI 5.0.0+) as `cordova-launch-review`

# Installation

## Using the Cordova/Phonegap [CLI](http://docs.phonegap.com/en/edge/guide_cli_index.md.html)

    $ cordova plugin add cordova-launch-review
    $ phonegap plugin add cordova-launch-review

## PhoneGap Build
Add the following xml to your config.xml to use the latest version from [npm](https://www.npmjs.com/package/cordova-launch-review):

    <gap:plugin name="cordova-launch-review" source="npm" />

# Usage

The plugin is exposed via the `LaunchReview` global namespace.

## launch()

Launches the store app using the given app ID.
Supports both Android and iOS.

    LaunchReview.launch(appId, success, error);

### Parameters

- {string} appID - the platform-specific app ID to use to open the page in the store app
    - On Android this is the full package name of the app. For example, for Google Maps: `com.google.android.apps.maps`
    - On iOS this is the Apple ID of the app. For example, for Google Maps: `585027354`
- {function} success - Function to execute on successfully launching store app.
- {function} error - Function to execute on failure to launch store app. Will be passed a single argument which is the error message string.


### Example usage

    var appId, platform = device.platform.toLowerCase();

    switch(platform){
        case "ios":
            appId = "585027354";
            break;
        case "android":
            appId = "com.google.android.apps.maps";
            break;
    }

    LaunchReview.launch(appId, function(){
        console.log("Successfully launched store app");
    },function(err){
        console.log("Error launching store app: " + err);
    });

## rating()

Opens the in-app ratings dialogs introduced by iOS 10.3.
iOS only. Calling this on any platform other than iOS 10.3 or above will result in the error function being called.

    LaunchReview.rating(success, error);

### Parameters

- {function} success - Function to execute on successfully launching rating dialog.
- {function} error - Function to execute on failure to launch rating dialog. Will be passed a single argument which is the error message string.


### Example usage

    LaunchReview.rating(function(){
        console.log("Successfully opened rating dialog");
    },function(err){
        console.log("Error opening rating dialog: " + err);
    });

## isRatingSupported()

Indicates if the current platform supports in-app ratings dialog, i.e. calling `LaunchReview.rating()`.
Will return true if current platform is iOS 10.3 or above.

    LaunchReview.isRatingSupported();

### Example usage

    if(LaunchReview.isRatingSupported()){
        LaunchReview.rating();
    }else{
        LaunchReview.launch(myAppId);
    }

# Example project

An example project illustrating use of this plugin can be found here: [https://github.com/dpa99c/cordova-launch-review-example](https://github.com/dpa99c/cordova-launch-review-example)
