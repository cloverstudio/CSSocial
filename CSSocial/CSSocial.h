//
//  CSSocial.h
//  CSCocialManager2.0
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CSConstants.h"
#import "CSBlocks.h"
#import "CSArcMacros.h"

#import "CSSocialServiceFacebook.h"
#import "CSSocialServiceTwitter.h"
#import "CSSocialServiceGoogle.h"
#import "CSSocialServiceLinkedin.h"
#import "CSSocialServiceTumblr.h"
#import "CSSocialServiceEvernote.h"

#import "CSSocialConstants.h"
#import "CSSocialUser.h"
#import "CSSocialRequest.h"
#import "CSSocialOAuthRequest.h"
#import "CSSocialService.h"
#import "CSOAuthService.h"
#import "CSRequests.h"
#import "CSFacebookParameter.h"
#import "CSTwitterParameter.h"
#import "CSSocialError.h"
//#import "CSSocialRequestEvernote.h"

@protocol CSSocialService;
@protocol CSSocialManagerDataSource <NSObject>
@required
-(UIViewController*) presentingViewController;
@end

@interface CSSocial : NSObject
//@property (nonatomic, assign) id<CSSocialManagerDataSource> dataSource;

+(CSSocial*) sharedManager;
+(CSSocialService*) facebook;
+(CSSocialService*) twitter;
+(CSSocialService*) google;
+(CSSocialService*) linkedin;
+(CSSocialService*) tumblr;

+(BOOL) openURL:(NSURL*) url sourceApplication:(NSString*) sourceApplication annotation:(id) annotation;
+(BOOL) handleOpenURL:(NSURL *)url;
+(UIViewController*) viewController;
+(void) setViewController:(UIViewController*) viewController;
+(NSDictionary*) configDictionary;
- (CSSocialService *)serviceWithClass:(Class)class;
@end


@interface CSSocialServiceFacebook (Helper)
///postToWall:completionBlock:
///posts a simple message to the facebook wall
///@param message message to post to wall
///@param responseBlock contains error if there was an error when posting or nil if all went OK
-(CSSocialRequest*) postToWall:(NSString*) message completionBlock:(CSSocialResponseBlock) responseBlock;

///postPhoto:completionBlock:
///posts a photo to facebook photo album
///@param photo photo to post to album
///@param responseBlock contains error if there was an error when posting or nil if all went OK
-(CSSocialRequest*) postPhoto:(UIImage*) photo completionBlock:(CSSocialResponseBlock) responseBlock;

///postPhoto:caption:completionBlock:
///posts a photo to facebook photo album
///@param photo photo to post to album
///@param caption album caption of the image
///@param responseBlock contains error if there was an error when posting or nil if all went OK
-(CSSocialRequest*) postPhoto:(UIImage*) photo
                      caption:(NSString*) caption
              completionBlock:(CSSocialResponseBlock) responseBlock;
@end

@interface CSSocialServiceTwitter (Helper)
///tweet:completionBlock:
///posts a simple tweet to selected Twitter account
///@param tweet tweet to post
///@param responseBlock contains error if there was an error when posting or nil if all went OK
-(CSSocialRequest*) tweet:(NSString*) tweet  completionBlock:(CSSocialResponseBlock) responseBlock;
@end

@interface CSSocialServiceLinkedin (Helper)
///comment:completionBlock:
///posts a simple tweet to selected LinkedIn account
///@param comment comment to post
///@param responseBlock contains error if there was an error when posting or nil if all went OK
-(CSSocialRequest*) comment:(NSString*) comment completionBlock:(CSSocialResponseBlock) responseBlock;
@end

@interface CSSocialServiceEvernote (Helper)
///createNote:completionBlock:
///creates a note on the selected Evernote account
///@param note note to create
///@param responseBlock contains error if there was an error when posting or nil if all went OK
-(CSSocialRequest*) createNote:(NSString*) comment completionBlock:(CSSocialResponseBlock) responseBlock;
@end


