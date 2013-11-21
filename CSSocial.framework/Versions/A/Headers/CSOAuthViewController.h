//
//  CSOAuthViewController.h
//  CSSocial
//
//  Created by marko.hlebar on 6/28/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAToken.h"
#import "OAConsumer.h"

@protocol CSOAuthService;
@interface CSOAuthViewController : UIViewController <UIWebViewDelegate>

+(id) viewControllerWithService:(id<CSOAuthService>) service
                   successBlock:(CSVoidBlock) successBlock
                     errorBlock:(CSErrorBlock) errorBlock;
@end
