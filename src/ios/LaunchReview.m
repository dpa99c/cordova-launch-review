/*
 * Copyright (c) 2015 Dave Alden  (http://github.com/dpa99c)
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
#import "LaunchReview.h"
#import "StoreKit/StoreKit.h"
#import "UIWindow+DismissNotification.h"

#define REQUEST_TIMEOUT 60.0

@implementation LaunchReview

- (void)pluginInitialize {
    [super pluginInitialize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowDidBecomeVisibleNotification:)
                                                 name:UIWindowDidBecomeVisibleNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowDidBecomeHiddenNotification:)
                                                 name:UIWindowDidBecomeHiddenNotification
                                            object:nil];
    self.appStoreId = nil;
    self.launchRequestCallbackId = nil;
    self.ratingRequestCallbackId = nil;
    
    // Try to pre-fetch the App ID at app startup
    [self.commandDelegate runInBackground:^{
        [self fetchAppIdFromBundleId];
    }];
}

- (void) launch:(CDVInvokedUrlCommand*)command;
{
    @try {
        self.launchRequestCallbackId = command.callbackId;
        
        NSString* appId = [command.arguments objectAtIndex:0];
        if([self isNull:appId]){
            [self retrieveAppIdAndLaunch];
        }else{
            [self launchAppStore:appId];
        }
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command.callbackId];
    }
}

- (void) rating:(CDVInvokedUrlCommand*)command;
{
    @try {
        if ([SKStoreReviewController class]) {
            self.ratingRequestCallbackId = command.callbackId;
            [SKStoreReviewController requestReview];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"requested"];
            [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }else{
            [self handlePluginError:@"Rating dialog requires iOS 10.3+" :command.callbackId];
        }
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :command.callbackId];
    }
}

- (void) isRatingSupported:(CDVInvokedUrlCommand*)command;
{
    NSString* isSupported;
    if ([SKStoreReviewController class]) {
        isSupported = @"1";
    }else{
        isSupported = @"0";
    }
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:isSupported] callbackId:command.callbackId];
}

- (void) handlePluginException: (NSException*) exception :(NSString*)callbackId
{
    [self handlePluginError:exception.reason :callbackId];
}

- (void) handlePluginError: (NSString*) errorMsg :(NSString*)callbackId
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMsg];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}


- (void)windowDidBecomeVisibleNotification:(NSNotification *)notification
{
    @try {
        if([notification.object class] == [MonitorObject class]){
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"shown"];
            [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.ratingRequestCallbackId];
        }
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :self.ratingRequestCallbackId];
    }
}

- (void)windowDidBecomeHiddenNotification:(NSNotification *)notification
{
    @try {
        if([notification.object class] == [MonitorObject class]){
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"dismissed"];
            [pluginResult setKeepCallback:[NSNumber numberWithBool:NO]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.ratingRequestCallbackId];
        }
    }
    @catch (NSException *exception) {
        [self handlePluginException:exception :self.ratingRequestCallbackId];
    }
}

- (BOOL) isNull:(NSString*) string
{
    return string == nil || string == (NSString*)[NSNull null];
}

- (void) launchAppStore:(NSString*) appId
{
    NSString* iTunesLink;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 11){
        iTunesLink = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/xy/app/foo/id%@?action=write-review", appId];
    }else{
        iTunesLink = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@&action=write-review", appId];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:self.launchRequestCallbackId];
}

- (void) retrieveAppIdAndLaunch
{
    [self fetchAppIdFromBundleId];
    if(self.appStoreId != nil){
        [self launchAppStore:self.appStoreId];
    }
}

- (void) fetchAppIdFromBundleId
{
    if(self.appStoreId != nil) return;
    
    NSString* bundleId = [NSBundle mainBundle].bundleIdentifier;
    NSString* iTunesServiceURL = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", bundleId];
    
    NSString* errorMsg = nil;
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSURL *url = [NSURL URLWithString:iTunesServiceURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:REQUEST_TIMEOUT];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
    if (data && statusCode == 200){
        //in case error is garbage...
        error = nil;
        
        id json = nil;
        if ([NSJSONSerialization class]){
            json = [[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:&error][@"results"] lastObject];
        }
        else{
            //convert to string
            json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        
        if (!error){
            //check bundle ID matches
            NSString* responseBundleId = [self valueForKey:@"bundleId" inJSON:json];
            if (responseBundleId){
                self.appStoreId = [self valueForKey:@"trackId" inJSON:json];
            }else{
                errorMsg = @"The application could not be found on the App Store.";
            }
        }else{
            errorMsg = [error localizedDescription];
        }
    }else if (statusCode >= 400){
        //http error
        errorMsg = [NSString stringWithFormat:@"The server returned a %@ error", @(statusCode)];
    }else{
        errorMsg = @"An unknown server error occurred";
    }
    
    if(errorMsg != nil && self.launchRequestCallbackId != nil){
        [self handlePluginError:errorMsg :self.launchRequestCallbackId];
    }
}

- (NSString *)valueForKey:(NSString *)key inJSON:(id)json
{
    if ([json isKindOfClass:[NSString class]])
    {
        //use legacy parser
        NSRange keyRange = [json rangeOfString:[NSString stringWithFormat:@"\"%@\"", key]];
        if (keyRange.location != NSNotFound)
        {
            NSInteger start = keyRange.location + keyRange.length;
            NSRange valueStart = [json rangeOfString:@":" options:(NSStringCompareOptions)0 range:NSMakeRange(start, [(NSString *)json length] - start)];
            if (valueStart.location != NSNotFound)
            {
                start = valueStart.location + 1;
                NSRange valueEnd = [json rangeOfString:@"," options:(NSStringCompareOptions)0 range:NSMakeRange(start, [(NSString *)json length] - start)];
                if (valueEnd.location != NSNotFound)
                {
                    NSString *value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    while ([value hasPrefix:@"\""] && ![value hasSuffix:@"\""])
                    {
                        if (valueEnd.location == NSNotFound)
                        {
                            break;
                        }
                        NSInteger newStart = valueEnd.location + 1;
                        valueEnd = [json rangeOfString:@"," options:(NSStringCompareOptions)0 range:NSMakeRange(newStart, [(NSString *)json length] - newStart)];
                        value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    }
                    
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                    value = [value stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                    value = [value stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\f" withString:@"\f"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\b" withString:@"\f"];
                    
                    while (YES)
                    {
                        NSRange unicode = [value rangeOfString:@"\\u"];
                        if (unicode.location == NSNotFound || unicode.location + unicode.length == 0)
                        {
                            break;
                        }
                        
                        uint32_t c = 0;
                        NSString *hex = [value substringWithRange:NSMakeRange(unicode.location + 2, 4)];
                        NSScanner *scanner = [NSScanner scannerWithString:hex];
                        [scanner scanHexInt:&c];
                        
                        if (c <= 0xffff)
                        {
                            value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C", (unichar)c]];
                        }
                        else
                        {
                            //convert character to surrogate pair
                            uint16_t x = (uint16_t)c;
                            uint16_t u = (c >> 16) & ((1 << 5) - 1);
                            uint16_t w = (uint16_t)u - 1;
                            unichar high = 0xd800 | (w << 6) | x >> 10;
                            unichar low = (uint16_t)(0xdc00 | (x & ((1 << 10) - 1)));
                            
                            value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C%C", high, low]];
                        }
                    }
                    return value;
                }
            }
        }
    }
    else
    {
        return json[key];
    }
    return nil;
}

@end