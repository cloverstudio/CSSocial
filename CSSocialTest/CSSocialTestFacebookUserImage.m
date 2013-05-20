//
//  CSSocialTestFacebookUserImage.m
//  CSSocial
//
//  Created by marko.hlebar on 2/27/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialTestFacebookUserImage.h"

@implementation CSSocialTestFacebookUserImage

-(void) performTest:(CSSocialResponseBlock)resultBlock
{
    [CSFacebook requestWithParameter:[CSFacebookParameter userImage]
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
    return @"Facebook User Image";
}

-(UIViewController*) resultsViewController
{
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view = [CSKit imageViewWithImage:self.results highlightedImage:nil];
    return viewController;
}

@end
