//
//  CSSocialTestFacebookFriends.m
//  CSSocial
//
//  Created by marko.hlebar on 11/1/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSSocialTestFacebookFriends.h"
#import "SocialFriendsTestResultsViewController.h"  

@implementation CSSocialTestFacebookFriends

-(void) performTest:(CSSocialResponseBlock)resultBlock
{
    [CSFacebook requestWithParameter:[CSFacebookParameter friends]
                            response:^(CSSocialRequest *request, id response, NSError *error)
     {
         if (!error) {
             self.passed = YES;
             self.results = response;
         }
         
         resultBlock(request, response, error);
     }];
}

-(NSString*) name
{
    return @"Facebook Friends";
}

-(UIViewController*) resultsViewController
{
    SocialFriendsTestResultsViewController *viewController = [[SocialFriendsTestResultsViewController alloc] init];
    viewController.modelArray = self.results;
    return viewController;
}

@end
