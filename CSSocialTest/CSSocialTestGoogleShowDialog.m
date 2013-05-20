//
//  CSSocialTestGoogleShowDialog.m
//  CSSocial
//
//  Created by marko.hlebar on 3/3/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialTestGoogleShowDialog.h"
//#import "GPPShare.h"

@implementation CSSocialTestGoogleShowDialog

-(void) performTest:(CSSocialResponseBlock)resultBlock
{
    [CSGoogle showDialogWithMessage:[CSKit loremIpsum]
                              photo:[UIImage imageNamed:@"test"]
                            handler:^(NSError *error)
     {
         if (!error) self.passed = YES;
         resultBlock(nil,nil,error);
     }];
}

-(NSString*) name
{
    return @"Google Show Dialog";
}

@end
