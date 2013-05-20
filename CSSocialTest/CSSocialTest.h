//
//  CSSocialTest.h
//  CSSocial
//
//  Created by marko.hlebar on 10/18/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSocialRequest.h"

@interface CSSocialTest : NSObject
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, strong) UIView *accessoryView;
@property (nonatomic) BOOL passed;
@property (nonatomic, strong) id results;
-(void)performTest:(CSSocialResponseBlock) resultBlock;
-(UIViewController*) resultsViewController;
+(id) test;
@end
