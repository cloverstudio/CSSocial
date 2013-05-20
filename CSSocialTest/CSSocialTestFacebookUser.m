//
//  CSSocialTestFacebookUser.m
//  CSSocial
//
//  Created by marko.hlebar on 2/28/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "CSSocialTestFacebookUser.h"

@implementation CSSocialTestFacebookUser
{
    NSString *_userID;
    NSString *_name;
}

-(id) initWithName:(NSString*) name userID:(NSString*) userID
{
    self = [super init];
    if (self)
    {
        _userID = [userID copy];
        _name = [name copy];
    }
    return self;
}

-(void) performTest:(CSSocialResponseBlock)resultBlock
{

    /*
    [CSFacebook request:<#(CSSocialRequest *)#>
               response:^(CSSocialRequest *request, id response, NSError *error) {
        
    }];
     */
}

-(NSString*) name
{
    return _name;
}

-(UIViewController*) resultsViewController
{
    /*
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view = [CSKit imageViewWithImage:self.results highlightedImage:nil];
    return viewController;
     */
    return nil;
}


@end
