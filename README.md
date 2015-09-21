Cordova Launch Review plugin
============================

* [Overview](#overview)
* [Installation](#installation)
* [Usage](#usage)
    * [Android and iOS](#android-and-ios)
    * [Android only](#android-only)
    * [iOS only](#ios-only)
* [Example project](#example-project)
* [Credits](#credits)

# Overview

This Cordova/Phonegap plugin for iOS and Android launches the native store app in order for the user to leave a review.

On Android, the plugin opens the the app's storepage in the Play Store where the user can leave a review by pressing the stars to give a rating.

On iOS, the plugin opens the app's storepage in the App Store and focuses the Review tab, where the user can leave a review by pressing "Write a review".

The plugin is registered on [npm](https://www.npmjs.com/package/cordova-launch-review) (requires Cordova CLI 5.0.0+) as `cordova-launch-review`

# Installation

## Using the Cordova/Phonegap [CLI](http://docs.phonegap.com/en/edge/guide_cli_index.md.html)

    $ cordova plugin add cordova-launch-review
    $ phonegap plugin add cordova-launch-review

## Using [Cordova Plugman](https://github.com/apache/cordova-plugman)

    $ plugman install --plugin=cordova-launch-review --platform=<platform> --project=<project_path> --plugins_dir=plugins

For example, to install for the Android platform

    $ plugman install --plugin=cordova-launch-review --platform=android --project=platforms/android --plugins_dir=plugins

## PhoneGap Build
Add the following xml to your config.xml to use the latest version from [npm](https://www.npmjs.com/package/cordova-launch-review):

    <gap:plugin name="cordova-launch-review" source="npm" />

# Usage

The plugin is exposed via the `LaunchReview` object and provides a single function `launch()` which launches the store app using the given app ID:

    LaunchReview.launch(appId, successCallback);

## Parameters

- {string} appID - the platform-specific app ID to use to open the page in the store app
    - On Android this is the full package name of the app. For example, for Google Maps: `com.google.android.apps.maps`
    - On iOS this is the Apple ID of the app. For example, for Google Maps: `585027354`
- {function} successCallback - The callback which will be called when diagnostic of location is successful. This callback function have a boolean param with the diagnostic result.


## Example usage

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
    });

# Example project

An example project illustrating use of this plugin can be found here: [https://github.com/dpa99c/cordova-launch-review-example](https://github.com/dpa99c/cordova-launch-review-example)
