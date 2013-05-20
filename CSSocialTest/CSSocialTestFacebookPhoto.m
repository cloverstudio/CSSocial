//
//  CSSocialTestFacebookPhoto.m
//  CSSocial
//
//  Created by marko.hlebar on 10/18/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialTestFacebookPhoto.h"

@implementation CSSocialTestFacebookPhoto
-(void) performTest:(CSSocialResponseBlock)resultBlock
{
    /*
    CSFacebookParameter *parameter = [CSFacebookParameter photo:[UIImage imageNamed:@"test"]
                                                        message:[CSKit loremIpsum]];
    [[CSSocial facebook] requestWithParameter:parameter
                                     response:^(CSSocialRequest *request, id response, NSError *error)
     {
         if(!error) self.passed = YES;
         else CSLog(@"%@\n%@", [error localizedDescription], [error description]);
         resultBlock(request, response, error);
     }];
     */
    NSLog(@"Post Photo");
    [CSFacebook postPhoto:[UIImage imageNamed:@"test.jpg"]
          completionBlock:^(CSSocialRequest *request, id response, NSError *error)
     {
         if(!error) {
             self.passed = YES;
             CSLog(@"Done");
         }
         else CSLog(@"%@\n%@", [error localizedDescription], [error description]);
         resultBlock(request, response, error);
     }];

}

-(NSString*) name
{
    return @"Facebook Photo";
}

@end
