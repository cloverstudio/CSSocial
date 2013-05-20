//
//  CSSocialTestFacebookMessage.m
//  CSSocial
//
//  Created by marko.hlebar on 10/18/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialTestFacebookMessage.h"
//#import "CSSocial.h"
//#import "CSFacebookParameter.h"
//#import "CSSocialServiceFacebook.h"

@implementation CSSocialTestFacebookMessage
-(void) performTest:(CSSocialResponseBlock)resultBlock
{
    /* use this test if you want more control over variables
    [[CSSocial facebook] requestWithParameter:[CSFacebookParameter message:[CSKit loremIpsum]
                                                                      name:@"TestName"
                                                                      link:@"www.test.com"
                                                                pictureURL:@"www.pictureurl.com"
                                                                   caption:@"TestCaption"
                                                               description:@"TestDescription"
                                                                      icon:@"icon"]
                                     response:^(CSSocialRequest *request, id response, NSError *error)
    {
        if(!error) self.passed = YES;
        else CSLog(@"%@\n%@", [error localizedDescription], [error description]);
        resultBlock(request, response, error);
    }];
     */
    

    [CSFacebook postToWall:[CSKit loremIpsum]
           completionBlock:^(CSSocialRequest *request, id response, NSError *error)
     {
         if(!error) self.passed = YES;
         else CSLog(@"%@\n%@", [error localizedDescription], [error description]);
         resultBlock(request, response, error);
     }];
}

-(NSString*) name
{
    return @"Facebook Message";
}
@end
