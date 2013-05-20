//
//  CSSocialTestShowDialog.m
//  CSSocial
//
//  Created by marko.hlebar on 3/1/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialTestFacebookShowDialog.h"

@implementation CSSocialTestFacebookShowDialog

-(void) performTest:(CSSocialResponseBlock)resultBlock
{
    [CSFacebook showDialogWithMessage:[CSKit loremIpsum]
                                photo:[UIImage imageNamed:@"test"]
                              handler:^(NSError *error)
    {
        if (!error) self.passed = YES;
                                  resultBlock(nil,nil,error);
                              }];
}

-(NSString*) name
{
    return @"Facebook Show Dialog";
}

@end
