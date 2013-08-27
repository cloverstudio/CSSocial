//
//  CSTwitteriOS5Plugin.m
//  CSSocial
//
//  Created by Marko Hlebar on 11/26/12.
/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Clover Studio. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "CSTwitteriOS5Plugin.h"
#import <Twitter/Twitter.h>
#import "OAuth.h"
#import "CSSocial.h"

typedef void(^TWAPIHandler)(NSData *data, NSError *error);

@interface CSTwitteriOS5Plugin()
@property (nonatomic, strong) NSArray *accounts;
@end

@implementation CSTwitteriOS5Plugin

-(id) init
{
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"account" options:0 context:NULL];
    }
    return self;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{    
    ///do reverse auth every time you pick a new account
    if ([keyPath isEqualToString:@"account"])
    {
        [self performReverseAuth:^(NSDictionary *JSONDict, NSError *error) {
            if (error)
            {
                if(self.loginFailedBlock) self.loginFailedBlock(error);
            }
            else
            {
                if(self.loginSuccessBlock) self.loginSuccessBlock();
            }
        }];
    }
}

-(void) dealloc
{
    [self removeObserver:self forKeyPath:@"account"];
    CS_SUPER_DEALLOC;
}

-(void) authenticate
{
    if (!_accountStore) _accountStore = [[ACAccountStore alloc] init];
    if (!_accountType) _accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self presentTwitterAccountPicker];
}

-(void) logout
{
    [super logout];
    self.account = nil;
}

-(id) showDialogWithMessage:(NSString*) message
                      photo:(UIImage*) photo
                    handler:(CSErrorBlock) handlerBlock
{
    if([TWTweetComposeViewController class])
    {
        TWTweetComposeViewController *viewController = [[TWTweetComposeViewController alloc] init];
        [viewController setInitialText:message];
        [viewController addImage:photo];
        [viewController setCompletionHandler:^(TWTweetComposeViewControllerResult result)
         {
             switch (result) {
                 case TWTweetComposeViewControllerResultDone:
                     handlerBlock(nil);
                     break;
                 case TWTweetComposeViewControllerResultCancelled:
                     handlerBlock([self errorWithLocalizedDescription:@"User Cancelled" errorCode:CSSocialErrorCodeUserCancelled]);
                     break;
                 default:
                     break;
             }
             [[CSSocial viewController] dismissViewControllerAnimated:YES completion:nil];
         }];
        [[CSSocial viewController] presentViewController:viewController
                                                animated:YES
                                              completion:nil];
        return viewController;
    }
    return nil;
}

#pragma mark - Reverse Auth

-(void) performReverseAuth:(CSResponseBlock) responseBlock
{
    [self reverseAuthStepOne:responseBlock];
}

#define TW_API_ROOT                  @"https://api.twitter.com"
#define TW_X_AUTH_MODE_KEY           @"x_auth_mode"
#define TW_X_AUTH_MODE_REVERSE_AUTH  @"reverse_auth"
#define TW_X_AUTH_MODE_CLIENT_AUTH   @"client_auth"
#define TW_X_AUTH_REVERSE_PARMS      @"x_reverse_auth_parameters"
#define TW_X_AUTH_REVERSE_TARGET     @"x_reverse_auth_target"
#define TW_OAUTH_URL_REQUEST_TOKEN   TW_API_ROOT "/oauth/request_token"
#define TW_OAUTH_URL_AUTH_TOKEN      TW_API_ROOT "/oauth/access_token"
#define TW_HTTP_HEADER_AUTHORIZATION @"Authorization"


-(void) reverseAuthStepOne:(CSResponseBlock) responseBlock
{
    NSURL *url = [NSURL URLWithString:TW_OAUTH_URL_REQUEST_TOKEN];
    NSDictionary *params = [NSDictionary
                          dictionaryWithObject:TW_X_AUTH_MODE_REVERSE_AUTH
                          forKey:TW_X_AUTH_MODE_KEY];
    
    //  Build our parameter string
    NSMutableString *paramsAsString = [[NSMutableString alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop) {
         [paramsAsString appendFormat:@"%@=%@&", key, obj];
     }];
    
    NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authHeader = [self.oAuth oAuthHeaderForMethod:@"POST"
                                                     andUrl:[url absoluteString]
                                                  andParams:params];
        
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:authHeader forHTTPHeaderField:TW_HTTP_HEADER_AUTHORIZATION];
    [request setHTTPBody:bodyData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSString *signedReverseAuthSignature = CS_AUTORELEASE([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
         
         [self reverseAuthStepTwo:signedReverseAuthSignature
                    responseBlock:^(NSDictionary *JSONDict, NSError *error) {
                        responseBlock(JSONDict, error);
                    }];
     }];
}

-(void) reverseAuthStepTwo:(NSString*) signedReversSignature responseBlock:(CSResponseBlock) responseBlock
{
    NSDictionary *step2Params = [NSDictionary
                                 dictionaryWithObjectsAndKeys:
                                 [self consumerKey],
                                 TW_X_AUTH_REVERSE_TARGET,
                                 signedReversSignature,
                                 TW_X_AUTH_REVERSE_PARMS,
                                 nil];
    NSURL *authTokenURL = [NSURL URLWithString:TW_OAUTH_URL_AUTH_TOKEN];
    
    id request = nil;
    
    if ([SLRequest class])
    {
        request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                     requestMethod:SLRequestMethodPOST
                                               URL:authTokenURL
                                        parameters:step2Params];
    }
    else
    {
        request = [[TWRequest alloc] initWithURL:authTokenURL
                                      parameters:step2Params
                                   requestMethod:TWRequestMethodPOST];
    }

    [request setAccount:self.account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
    {
        if (error)
        {
            responseBlock(nil, error);
            return;
        }
        
        NSString *responseStr = CS_AUTORELEASE([[NSString alloc]
                                                initWithData:responseData
                                                encoding:NSUTF8StringEncoding]);
        
        NSArray *parts = [responseStr
                          componentsSeparatedByString:@"&"];
        
        NSString *oAuthToken = [parts[0] componentsSeparatedByString:@"="][1];
        NSString *oAuthTokenSecret = [parts[1] componentsSeparatedByString:@"="][1];
        self.oAuth.oauth_token = oAuthToken;
        self.oAuth.oauth_token_secret = oAuthTokenSecret;
        self.oAuth.oauth_token_authorized = YES;
        [self saveOAuth:self.oAuth];
        responseBlock(nil, nil);
    }];
}

#pragma mark - Authentication

-(void) canAccessTwitterAccounts:(CSErrorBlock) canAccessBlock
{
    [_accountStore requestAccessToAccountsWithType:_accountType
                             withCompletionHandler:^(BOOL granted, NSError *error)
    {
        canAccessBlock(error);
        ///TODO: if error, display error
    }];
}

-(NSArray *) accounts
{
    return [_accountStore accountsWithAccountType:_accountType];
}

#pragma mark - Select Account 

-(void) presentTwitterAccountPicker
{
    [self canAccessTwitterAccounts:^(NSError *error)
    {
        NSArray *accounts = [self accounts];

        if (error || accounts.count == 0)
        {
            if(self.loginFailedBlock) self.loginFailedBlock([self errorAccountNotFound]);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *viewController = [self presentingViewController];
            
            if (accounts.count < 4) {
                
                //if there are 2 or 3 accounts, present UIActionSheet
                UIActionSheet *sheet = CS_AUTORELEASE([[UIActionSheet alloc] init]);
                int i = 0;
                for (ACAccount *account in accounts) {
                    [sheet addButtonWithTitle:account.username];
                    i += 1;
                }
                [sheet addButtonWithTitle:@"Cancel"];
                [sheet setDelegate:self];
                sheet.cancelButtonIndex = i;
                
                [sheet showInView:viewController.view];
                
            } else {
                
                //if in rare case user has more then 4 accounts, present UIPickerView
                UIPickerView *picker = CS_AUTORELEASE([[UIPickerView alloc] init]);
                picker.delegate = self;
                picker.dataSource = self;
                [picker sizeToFit];
                picker.frame = CGRectMake(picker.frame.origin.x, CS_WINSIZE.height, picker.frame.size.width, 80);
                
                [viewController.view addSubview:picker];
                
                float navBarOffset = (viewController.navigationController.navigationBarHidden)?0:viewController.navigationController.navigationBar.frame.size.height;
                
                [UIView animateWithDuration:.3f animations:^{
                    picker.frame = CGRectMake(picker.frame.origin.x, picker.frame.origin.y - picker.frame.size.height - navBarOffset, picker.frame.size.width, picker.frame.size.height);
                }];
            }
        });
    }];
}

#pragma mark - UIAlertViewDelegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
    
    alertView.delegate = nil;
    alertView = nil;
}

#pragma mark - UIActionSheetDelegate

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSArray *accounts = [self accounts];
    if (buttonIndex == accounts.count)
    {
        //cancel pressed
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        
        if (self.loginFailedBlock) {
            self.loginFailedBlock([self errorWithLocalizedDescription:@"Twitter Login Failed"]);
        }
    }
    else
    {
        self.account = [accounts objectAtIndex:buttonIndex];
    }
}

#pragma mark - UIPickerViewDatasource

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self accounts].count;
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

#pragma mark - UIPickerViewDelegate

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[[self accounts] objectAtIndex:row] username];
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.account = [[self accounts] objectAtIndex:row];

    ///resign picker view
    UIViewController *viewController = [self presentingViewController];
    float navBarOffset = (viewController.navigationController.navigationBarHidden)?0:viewController.navigationController.navigationBar.frame.size.height;
    
    [UIView animateWithDuration:.3f animations:^{
        pickerView.frame = CGRectMake(pickerView.frame.origin.x, pickerView.frame.origin.y + pickerView.frame.size.height + navBarOffset, pickerView.frame.size.width, pickerView.frame.size.height);
    } completion:^(BOOL finished) {
        [pickerView removeFromSuperview];
        pickerView.delegate = nil;
        pickerView.dataSource = nil;
    }];
    
}

@end
