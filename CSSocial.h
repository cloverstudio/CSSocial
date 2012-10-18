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
@end
