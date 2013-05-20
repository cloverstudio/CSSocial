//
//  CSSocialTestTwitterShowDialog.m
//  CSSocial
//
//  Created by marko.hlebar on 3/14/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialTestTwitterShowDialog.h"

@implementation CSSocialTestTwitterShowDialog

-(void) performTest:(CSSocialResponseBlock)resultBlock
{
    [CSTwitter showDialogWithMessage:[CSKit loremIpsum]
                              photo:[UIImage imageNamed:@"test"]
                            handler:^(NSError *error)
     {
         if (!error) self.passed = YES;
         resultBlock(nil,nil,error);
     }];
}

-(NSString*) name
{
    return @"Twitter Show Dialog";
}

@end
