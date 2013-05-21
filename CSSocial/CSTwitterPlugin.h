//
//  CSTwitterPlugin.h
//  CSSocial
//
//  Created by Marko Hlebar on 11/26/12.
/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Clover Studio. All rights reserved.
 
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
 */

#import <Foundation/Foundation.h>

@class OAuth;
@class UIViewController;
@protocol CSTwitterPlugin <NSObject>
-(void) login:(CSVoidBlock)success error:(CSErrorBlock) error;
-(void) logout;
-(OAuth*) oAuth;
-(UIViewController*) presentingViewController;
-(BOOL) isAuthenticated;
-(void) authenticate;
-(id) showDialogWithMessage:(NSString*) message
                      photo:(UIImage*) photo
                    handler:(CSErrorBlock) handlerBlock;
@end

@interface CSTwitterPlugin : NSObject <CSTwitterPlugin>
@property(nonatomic, copy) CSVoidBlock loginSuccessBlock;
@property(nonatomic, copy) CSErrorBlock loginFailedBlock;
@property(nonatomic, strong) OAuth *oAuth;
@property(nonatomic, readonly, strong) NSString *consumerKey;
@property(nonatomic, readonly, strong) NSString *consumerSecret;

///chooses the correct plugin based on iOS version and config settings and instantiates it
///@return an instance of CSTwitterPlugin
+(CSTwitterPlugin*) plugin;

-(void) saveOAuth:(OAuth*) oAuth;
-(void) loadOAuth:(OAuth*) oAuth;
-(void) resetOAuth;

-(NSError*) errorWithLocalizedDescription:(NSString*) description errorCode:(NSInteger) errorCode;
-(NSError*) errorWithLocalizedDescription:(NSString*) description;
-(NSError*) errorInvalidReturnValue;
-(NSError*) errorAccountNotFound;
-(NSError*) errorUnsupportedSDK;
-(NSError*) errorTwitterLoginFailed;
-(NSError*) errorTwitterUserCancelled;

@end
