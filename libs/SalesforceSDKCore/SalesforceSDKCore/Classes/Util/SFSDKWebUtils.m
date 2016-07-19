/*
 Copyright (c) 2012, salesforce.com, inc. All rights reserved.
 Author: Kevin Hawkins
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#import "SFSDKWebUtils.h"
#import "SFApplication.h"
#import <WebKit/WebKit.h>
//#import "WKWebView+SFWKWebView.h"
// Public constants
NSString * const kUserAgentPropKey = @"UserAgent";

static NSString *gUserAgentForApp = nil;

@interface SFSDKWebUtils ()

/**
 Stages the value of the user agent as defined by the iOS framework, in the static variable
 gUserAgentForApp.  This value will not change in the lifetime of the app process.
 */
+ (void)stageUserAgentForApp;

@end

@implementation SFSDKWebUtils

+ (void)configureUserAgent:(NSString *)userAgentString
{
    if (userAgentString != nil) {
        NSDictionary *dictionary = @{kUserAgentPropKey: userAgentString};
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    }
}

+ (NSString *)currentUserAgentForApp
{
    [self stageUserAgentForApp];
    
    return gUserAgentForApp;
}

+ (void)stageUserAgentForApp
{
    if (gUserAgentForApp != nil) return;
    
    if ([NSThread isMainThread]) {
        // Get the current user agent.  Yes, this is hack-ish.  Alternatives are more hackish.  WKWebView
        // really doesn't want you to know about its HTTP headers.
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero];
       
       // gUserAgentForApp = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
       [webView evaluateJavaScript:@"navigator.userAgent"
                 completionHandler:^(id _Nullable val, NSError * _Nullable error) {
                     gUserAgentForApp = val;
                 }];
        
    } else {
        // Needs to run on the main thread.
        dispatch_sync(dispatch_get_main_queue(), ^{
            WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero];
            //gUserAgentForApp = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
            [webView evaluateJavaScript:@"navigator.userAgent"
                      completionHandler:^(id _Nullable val, NSError * _Nullable error) {
                          gUserAgentForApp = val;
                      }];

        });
    }
}

@end
