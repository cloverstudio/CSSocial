//
//  CSSocialService.h
//  CSSocial
//
//  Created by Marko Hlebar on 6/21/12.
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

#import <UIKit/UIKit.h>
#import "CSConstants.h"
#import "CSRequests.h"
#import "CSSocialRequest.h"

@class OAToken;
@class OAConsumer;

@protocol CSSocialUser;
@protocol CSSocialParameter;

@protocol CSOAuthService <NSObject, UIWebViewDelegate>
-(NSString*) apiKey;
-(NSString*) secretKey;
-(NSString*) realm;
-(NSURL*) requestTokenURL;
-(NSURL*) accessTokenURL;
-(NSURL*) loginURL;
-(NSURL*) callbackURL;
-(OAConsumer*) consumer;
-(void) setAccessToken:(OAToken*) token;
@property (nonatomic, strong) OAToken *requestToken;
-(BOOL) isVerifierURL:(NSURL*) url error:(NSError**) error;
@end

///private protocol classes
@protocol CSSocialService <NSObject>
@optional
-(NSError*) errorWithLocalizedDescription:(NSString*) description;

@required
-(NSOperationQueue*) operationQueue;
-(void) login:(CSVoidBlock) success error:(CSErrorBlock) error;
-(CSSocialRequest*) constructRequestWithParameter:(id<CSSocialParameter>) parameter;
-(BOOL) permissionGranted:(NSString*) permission;
-(void) requestPermissionsForRequest:(CSSocialRequest*) request permissionsBlock:(CSErrorBlock) permissionsBlock;
-(BOOL) isAuthenticated;
-(void) logout;
-(NSString*) serviceName;

@optional
-(BOOL) openURL:(NSURL*) url sourceApplication:(NSString*) sourceApplication annotation:(id) annotation;
-(BOOL) handleOpenURL:(NSURL*)url;
@end

@interface CSSocialService : NSObject <CSSocialService>
@property (nonatomic, strong) NSOperationQueue *requestQueue;
@property (nonatomic, copy) CSErrorBlock permissionsBlock;
@property (nonatomic, copy) CSVoidBlock loginSuccessBlock;
@property (nonatomic, copy) CSErrorBlock loginFailedBlock;

-(CSSocialRequest*) requestWithParameter:(id<CSSocialParameter>) parameter
                                response:(CSSocialResponseBlock) responseBlock
__attribute__((deprecated));

///@abstract sends a request to a social service and handles a callback when the sevice has returned the result
///@param request a CSSocialRequest you constructed manually or by using requestWithParameter:
///@param responseBlock callback block with results
-(void) sendRequest:(CSSocialRequest*) request
           response:(CSSocialResponseBlock) responseBlock;

///@abstract this is a convenience method that you can use for automatic request construction based on the parameter object passed
///@param parameter an object that describes the main request details
///@return CSSocialRequest instance
-(CSSocialRequest*) requestWithParameter:(id<CSSocialParameter>)parameter;

///@abstract shows the dialog box of the service (where available) with initial message and photo parameters
///@param message initial message
///@param photo photo to upload
///@param handlerBlock callback block containing an error if one occured.
///@return instance od the dialog if available or nil if unavailable.
-(id) showDialogWithMessage:(NSString*) message
                      photo:(UIImage*) photo
                    handler:(CSErrorBlock) handlerBlock;

///@abstract shows the dialog box of the service (where available) with initial message and photo parameters
///@param message initial message
///@param url url to share
///@param photo photo to upload
///@param handlerBlock callback block containing an error if one occured.
///@return instance od the dialog if available or nil if unavailable.
-(id) showDialogWithMessage:(NSString*) message
                        url:(NSURL*) url
                      photo:(UIImage*) photo
                    handler:(CSErrorBlock) handlerBlock;

@end
