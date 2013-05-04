//
//  CSTwitteriOS6Plugin.m
//  CSSocial
//
//  Created by marko.hlebar on 12/5/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import "CSTwitteriOS6Plugin.h"
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import "CSSocial.h"

@implementation CSTwitteriOS6Plugin

-(void) canAccessTwitterAccounts:(CSErrorBlock) canAccessBlock
{
    [_accountStore requestAccessToAccountsWithType:_accountType
                                           options:nil
                                        completion:^(BOOL granted, NSError *error)
    {
                                            canAccessBlock(error);
                                        }];
}

-(id) showDialogWithMessage:(NSString*) message
                      photo:(UIImage*) photo
                    handler:(CSErrorBlock) handlerBlock
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *viewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [viewController setInitialText:message];
        [viewController addImage:photo];
        [viewController setCompletionHandler:^(SLComposeViewControllerResult result)
        {
            switch (result) {
                case SLComposeViewControllerResultDone:
                    handlerBlock(nil);
                    break;
                case SLComposeViewControllerResultCancelled:
                    handlerBlock([self errorWithLocalizedDescription:@"User Cancelled" errorCode:CSSocialErrorCodeUserCancelled]);
                default:
                    break;
            }
         }];
        
        [[CSSocial viewController] presentViewController:viewController
                                                animated:YES
                                              completion:nil];
        return viewController;
    }
    return nil;
}

@end
