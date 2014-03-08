//
//  CSSocialTestOAuthViewController.m
//  CSSocial
//
//  Created by marko.hlebar on 6/28/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialTestOAuthViewController.h"
#import "CSOAuthViewController.h"

@implementation CSSocialTestOAuthViewController

-(void) performTest:(CSSocialResponseBlock)resultBlock {
    
    CSOAuthViewController *viewController = (CSOAuthViewController*)[CSKit viewControllerFromString:@"CSOAuthViewController"];
    [[CSSocial viewController] presentViewController:viewController
                                            animated:NO
                                          completion:nil];
}

@end
