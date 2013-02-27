//
//  CSSocial.h
//  CSCocialManager2.0
//
//  Created by marko.hlebar on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CSConstants.h"
#import "CSSocialServiceFacebook.h"
#import "CSSocialServiceTwitter.h"
#import "CSSocialConstants.h"
#import "CSSocialUser.h"
#import "CSSocialRequest.h"
#import "CSSocialService.h"
#import "CSRequests.h"
#import "CSFacebookParameter.h"
#import "CSTwitterParameter.h"

#define CSSocialServiceResponse @"CSSocialServiceResponse"

@protocol CSSocialService;
@protocol CSSocialManagerDataSource <NSObject>
@required
-(UIViewController*) presentingViewController;
@end

@interface CSSocial : NSObject
@property (nonatomic, assign) id<CSSocialManagerDataSource> dataSource;

+(CSSocial*) sharedManager;
+(CSSocialService*) facebook;
+(CSSocialService*) twitter;
//+(CSSocialService*) mixi;
+(BOOL) handleOpenURL:(NSURL *)url;
+(void) setDataSource:(id<CSSocialManagerDataSource>) dataSource;
+(NSDictionary*) configDictionary;
@end


@interface CSSocialServiceFacebook (Helper)
///postToWall:completionBlock:
///posts a simple message to the facebook wall
///@param message message to post to wall
///@param responseBlock contains error if there was an error when posting or nil if all went OK
-(void) postToWall:(NSString*) message completionBlock:(CSSocialResponseBlock) responseBlock;

///postPhoto:completionBlock:
///posts a photo to facebook photo album
///@param photo photo to post to album
///@param responseBlock contains error if there was an error when posting or nil if all went OK
-(void) postPhoto:(UIImage*) photo completionBlock:(CSSocialResponseBlock) responseBlock;
@end

@interface CSSocialServiceTwitter (Helper)
///tweet:completionBlock:
///posts a simple tweet to selected Twitter account
///@param tweet tweet to post
///@param responseBlock contains error if there was an error when posting or nil if all went OK
-(void) tweet:(NSString*) tweet  completionBlock:(CSSocialResponseBlock) responseBlock;
@end    
