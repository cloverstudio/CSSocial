//
//  CSSocialServiceTwitter.m
//  CSCocialManager2.0
//
//  Created by Luka Fajl on 21.6.2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import "CSSocialServiceTwitter.h"
#import "CSConstants.h"
#import "CSSocial.h"
#import "CSSocialConstants.h"
#import "CSRequests.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

static NSString * const CSTweetLastAccountIdentifier = @"CSTweetLastAccountIdentifier";

#pragma mark - CSSocialUserTwitter

@interface CSSocialUserTwitter : CSSocialUser
@end

@implementation CSSocialUserTwitter
-(id) initWithResponse:(id) response
{
    self = [super init];
    if (self)
    {        
        if ([response isKindOfClass:[NSArray class]])
        {
            NSDictionary *dict = [response objectAtIndex:0];
            if ([dict isKindOfClass:[NSDictionary class]])
            {
                self.name = [dict objectForKey:@"screen_name"];
                self.ID = [dict objectForKey:@"id_str"];
            }
        }
        else
        {
            self.ID = [response stringValue];
        }
    }
    return self;
}

+(NSArray*) usersFromResponse:(id) response
{
    NSMutableArray *array = [NSMutableArray array];
    if ([response isKindOfClass:[NSDictionary class]])
    {
        for (NSDictionary *userDict in [response objectForKey:@"ids"])
        {
            [array addObject:[CSSocialUserTwitter userWithResponse:userDict]];
        }
    }
    return (NSArray*)array;
}

@end

#pragma mark - CSSocialRequestTwitter

@interface CSSocialRequestTwitter : CSSocialRequest
-(id) parseResponseData:(id)response error:(NSError**) error; 
-(NSString*) paramsString;
@end

@implementation CSSocialRequestTwitter
-(void) dealloc
{
    CS_SUPER_DEALLOC;
}

-(void) start
{
    [super start];

    [NSURLConnection sendAsynchronousRequest:[self request]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error)
         {
             self.responseBlock(self, nil, error);
             return;
         }
         
         id parsedResponse = [self parseResponseData:data error:&error];
         if (!parsedResponse || error)
         {
             self.responseBlock(self, nil, error);
             return;
         }
         
         self.responseBlock(self, parsedResponse, nil);
    }];
}

-(NSMutableURLRequest*) request
{
    NSString *urlString = [NSString stringWithFormat:@"%@?%@", [self APIcall], [self paramsString]];
    return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
}

///parse JSON by default.
-(id) parseResponseData:(id)responseData error:(NSError**) error
{
    if (responseData) 
    {
        return [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:error];
    }
    else
    {
        return nil;
    }
}

-(NSString*) paramsString
{
    NSMutableString *paramsString = [NSMutableString string];
    NSInteger keyCount = 0;
    NSArray *keys = [self.params allKeys];
    for (NSString *key in keys)
    {
        keyCount++;
        [paramsString appendFormat:@"%@=%@", key, [self.params objectForKey:key]];
        if (keyCount != keys.count) [paramsString appendString:@"&"];
    }
    return [NSString stringWithString:paramsString];
}

@end

@interface CSSocialRequestTwitterMessage : CSSocialRequestTwitter
@end

@implementation CSSocialRequestTwitterMessage
-(NSString*) APIcall {return @"https://api.twitter.com/1/statuses/update.json";}

-(NSMutableURLRequest*) request
{
    NSString *params = [self paramsString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self APIcall]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:[NSData dataWithBytes:[params UTF8String] length:params.length]];
    return request;
}
@end

@interface CSSocialRequestTwitterGetUserImage : CSSocialRequestTwitter
@end

@implementation CSSocialRequestTwitterGetUserImage
-(NSString*) APIcall { return @"https://api.twitter.com/1/users/profile_image"; }
-(id) method { return [NSNumber numberWithInteger:TWRequestMethodGET]; }
-(id) parseResponseData:(id)responseData error:(NSError**) error 
{
    UIImage *image = [UIImage imageWithData:responseData];
    if (!image) {
        *error = [NSError errorWithDomain:@"com.clover-studio" code:100 userInfo:nil];
        return nil;
    }
    return image;
}
@end

@interface CSSocialRequestTwitterFriends : CSSocialRequestTwitter
@end

@implementation CSSocialRequestTwitterFriends
-(NSString*) APIcall { return @"https://api.twitter.com/1/friends/ids.json"; }
-(id) method { return [NSNumber numberWithInteger:TWRequestMethodGET]; }
-(id) parseResponseData:(id)responseData error:(NSError**) error
{
    return [CSSocialUserTwitter usersFromResponse:responseData];
}
@end

@interface CSSocialServiceTwitter()
@property (nonatomic, retain) ACAccountStore *accountStore;
@property (nonatomic, retain) ACAccount *twitterAccount;
@property (nonatomic, retain) NSArray *accounts;
@end

#pragma mark - CSSocialServiceTwitter

@interface CSSocialServiceTwitter () <CSSocialService>
@end

@implementation CSSocialServiceTwitter
{
    BOOL waitingForAccess;
}
@synthesize accountStore = _accountStore;
@synthesize twitterAccount = _twitterAccount;
@synthesize accounts = _accounts;

-(void) dealloc
{
    CS_RELEASE(_accountStore);
    CS_RELEASE(_twitterAccount);
    CS_RELEASE(_accounts);
    CS_SUPER_DEALLOC;
}

-(id) init {
    if ((self=[super init])) 
    {
        self.twitterAccount = [self obtainAccountWithIdentifier:[[NSUserDefaults standardUserDefaults] stringForKey:CSTweetLastAccountIdentifier]];
        self.accountStore = CS_AUTORELEASE([[ACAccountStore alloc] init]);
    }
    return self;
}

-(void) login:(CSVoidBlock) success error:(CSErrorBlock) error
{
    self.loginSuccessBlock = success;
    self.loginFailedBlock = error;
    
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) 
    {
        self.loginFailedBlock([self errorUnsupportedSDK]);
        return;
    }
    
    [self checkTwitterCredentials];
    if ([self selectTwitterAccount])
    {
        [self presentTwitterAccountPicker];
    }
    else
    {
        _twitterAccount ?
        self.loginSuccessBlock() :
        self.loginFailedBlock([NSError errorWithDomain:nil
                                                  code:0
                                              userInfo:[NSDictionary dictionaryWithObject:@"No twitter account available" forKey:NSLocalizedDescriptionKey]]);
    }
}

-(void) logout
{
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
    {
        //self.logoutBlock([self response:kCSSocialResponseError]);
        return;
    }
    
    self.twitterAccount = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CSTweetLastAccountIdentifier];
}

-(BOOL) isAuthenticated
{
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) return NO;
    return [self obtainAccount] != nil ? YES : NO;
}

-(CSSocialRequest*) constructRequestWithParameter:(id<CSSocialParameter>)parameter
{
    CSSocialRequest *request = nil;
    
    switch (parameter.requestName) {
        case CSRequestLogin:
            break;
        case CSRequestLogout:
            break;
        case CSRequestUser:
            //request = [CSSocialRequestTwitterUser requestWithService:nil parameters:[parameter parameters]];
            break;
        case CSRequestFriends:
            request = [CSSocialRequestTwitterFriends requestWithService:nil parameters:[parameter parameters]];
            break;
        case CSRequestPostMessage:
            request = [CSSocialRequestTwitterMessage requestWithService:nil parameters:[parameter parameters]];
            break;
        case CSRequestGetUserImage:
            request = [CSSocialRequestTwitterGetUserImage requestWithService:nil parameters:[parameter parameters]];
            break;
        default:
            break;
    }
    
    return request;

}


-(void) request:(CSSocialRequest*) request response:(CSSocialResponseBlock) responseBlock
{
 
    /*
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) 
    {
        responseBlock(request, nil, [self errorUnsupportedSDK]);
        return;
    }
    
    self.twitterAccount = [self obtainAccount];
    if (self.twitterAccount == nil) {
        CSLog(@"Account not found!");
        responseBlock(request, nil, [self errorAccountNotFound]);
        return;
    }
    
    request.responseBlock = responseBlock;
    
    if ([request isKindOfClass:[CSSocialRequestTwitterFriends class]])
    {
        [self.requestQueue addOperation:request];

    }
    else if ([request isKindOfClass:[CSSocialRequestTwitterGetUserImage class]])
    {
        NSString *body = [NSString stringWithFormat:@"%@?screen_name=%@&size=original", request.APIcall, self.twitterAccount.username];
        NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:body]];
        [NSURLConnection sendAsynchronousRequest:mutableRequest 
                                           queue:self.requestQueue 
                               completionHandler:^(NSURLResponse * response, NSData * data, NSError *error) 
        {
            if (error) 
            {
                request.responseBlock(request, nil, error);
                return;
            }
            UIImage *image = [UIImage imageWithData:data];
            request.responseBlock(request, image, image ? nil : [self errorInvalidReturnValue]);
        }];
    }
    else 
    {
        TWRequest *postRequest = CS_AUTORELEASE([[TWRequest alloc] initWithURL:[NSURL URLWithString:request.APIcall]
                                                                    parameters:[NSDictionary dictionary]//request.params
                                                                 requestMethod:TWRequestMethodGET]);
        [postRequest setAccount:self.twitterAccount];
        
        NSLog(@"%@", [postRequest URL]);
        [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
         {
             CSLog(@"Twitter response, HTTP response: %i", [urlResponse statusCode]);
             
             if (error) 
             {
                 request.responseBlock(request, nil, error);
             }
             else 
             {
                 CSLog(@"%@", responseData);
                 NSError *parseError = nil;
                 UIImage *image = [UIImage imageWithData:responseData];
                 
                 id response = [self parseResponseData:responseData error:&parseError];
                 if (response) 
                 {
                     request.responseBlock(request, response, nil);
                 } 
                 else if (image) 
                 {
                     request.responseBlock(request, image, nil);
                 }
                 else 
                 { 
                     request.responseBlock(request, nil, parseError);
                 }
             }
         }];
    }

    
    /*
    //[postRequest setAccount:account];
    CSSocialRequestTwitter *twRequest = (CSSocialRequestTwitter*) request;
    twRequest.request = postRequest;
    twRequest.account = self.twitterAccount;
    [self.requestQueue addOperation:twRequest];
    */
}

-(NSArray*) permissions {
    return nil;
}

#pragma mark - Private

-(BOOL) canAccessTwitterAccounts {
    ACAccountType *twitterAccountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    __block BOOL accessGranted = NO;
    [_accountStore requestAccessToAccountsWithType:twitterAccountType
                             withCompletionHandler:^(BOOL granted, NSError *error) {
                                 accessGranted = granted;
                                 waitingForAccess = NO;
                             }];
    waitingForAccess = YES;
    while (waitingForAccess) {
        sleep(1);
    }
    return accessGranted;
}

-(void) checkTwitterCredentials {
    if ([self canAccessTwitterAccounts]) {
        ACAccountType *twitterAccountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [_accountStore accountsWithAccountType:twitterAccountType];
        if ([twitterAccounts count] < 1) {
            [self displayNoTwitterAccountsAlert];
        }
    } else {
        //handle error: Cannot access twitter accounts
    }

}

- (NSArray *)accounts
{
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) return nil;
    
    ACAccountType *twitterAccountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    self.accounts = [_accountStore accountsWithAccountType:twitterAccountType];
    return _accounts;
}

-(ACAccount *) obtainAccount 
{
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) return nil;

    return [self obtainAccountWithIdentifier:_twitterAccount.identifier];
}

-(ACAccount *) obtainAccountWithIdentifier:(NSString*) identifier 
{
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) return nil;
    
      for (ACAccount *account_ in [self accounts]) 
      {
        if ([account_.identifier isEqualToString:identifier]) {
            return account_;
        }
    }
    return nil;
}

- (BOOL)selectTwitterAccount
// Picks the iOS 5 Twitter account to use.
// If one is already selected, makes sure it's still valid.
// If not, another is picked.
{
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) return NO;
    
    NSArray *accounts = [self accounts];
     
    if ([accounts count] == 0) {
        self.twitterAccount = nil;
        return NO;
    }
    
    if ([accounts count] > 1) {
        //if there are more accounts, return and present ActionSheet for user to pick his account
        self.twitterAccount = nil;
        return YES;
    }
    
    NSString *accountIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:CSTweetLastAccountIdentifier];
    if (_twitterAccount) {
        accountIdentifier = _twitterAccount.identifier;
    }
    
    if ([accountIdentifier length] > 0) {
        NSUInteger index = [accounts indexOfObjectPassingTest:^BOOL(ACAccount *account, NSUInteger idx, BOOL *stop) {
            *stop = [account.identifier isEqualToString:accountIdentifier];
            return *stop;
        }];
        if (index != NSNotFound) {
            self.twitterAccount = [accounts objectAtIndex:index];
        } else {
            self.twitterAccount = nil;  // Clear out the invalid account.
        }
    }
    
    if (_twitterAccount == nil) {
        self.twitterAccount = [accounts objectAtIndex:0];  // Safe, since we tested for [accounts count] == 0 above.
    }
     
    [[NSUserDefaults standardUserDefaults] setObject:_twitterAccount.identifier forKey:CSTweetLastAccountIdentifier];
    
    return NO;
}

- (void)displayNoTwitterAccountsAlert
// We have an instance method that's identical to this. Make sure it stays identical.
// This duplicates the message and buttons displayed in Apple's TWTweetComposeViewController alert message.
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Twitter Accounts", @"")
                                                         message:NSLocalizedString(@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings.", @"")
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"Settings", @"")
                                               otherButtonTitles:NSLocalizedString(@"Cancel", @""), nil];
    CS_AUTORELEASE(alertView);
    //alertView.tag = DETweetComposeViewControllerNoAccountsAlert;
    [alertView show];
}

-(void) presentTwitterAccountPicker {
    NSArray *accounts = [self accounts];
    
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
        
        NSAssert([CSSocial sharedManager].dataSource, @"You must assign a dataSource!");
        UIViewController *viewController = [[CSSocial sharedManager].dataSource presentingViewController];
        
        [sheet showInView:viewController.view];
        
    } else {
        
        //if in rare case user has more then 4 accounts, present UIPickerView
        UIPickerView *picker = CS_AUTORELEASE([[UIPickerView alloc] init]);
        picker.delegate = self;
        picker.dataSource = self;
        [picker sizeToFit];
        picker.frame = CGRectMake(picker.frame.origin.x, CS_WINSIZE.height, picker.frame.size.width, 80);
        
        NSAssert([CSSocial sharedManager].dataSource, @"You must assign a dataSource!");
        UIViewController *viewController = [[CSSocial sharedManager].dataSource presentingViewController];
        
        [viewController.view addSubview:picker];
        
        float navBarOffset = (viewController.navigationController.navigationBarHidden)?0:viewController.navigationController.navigationBar.frame.size.height;
        
        [UIView animateWithDuration:.3f animations:^{
            picker.frame = CGRectMake(picker.frame.origin.x, picker.frame.origin.y - picker.frame.size.height - navBarOffset, picker.frame.size.width, picker.frame.size.height);
        }];
    }
    
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
    if (buttonIndex == accounts.count) {
        //cancel pressed
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        
        if (self.loginFailedBlock) {
            self.loginFailedBlock([self errorWithLocalizedDescription:@"Twitter Login Failed"]);
        }
    }
    else
    {
        self.twitterAccount = [accounts objectAtIndex:buttonIndex];
        [[NSUserDefaults standardUserDefaults] setObject:_twitterAccount.identifier forKey:CSTweetLastAccountIdentifier];
        
        if (self.loginSuccessBlock)
        {
            self.loginSuccessBlock();
        }
    }
    actionSheet.delegate = nil;
    actionSheet = nil;
}

#pragma mark - UIPickerViewDatasource

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self accounts].count;
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
  
#pragma mark - UIPickerViewDelegate

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[[self accounts] objectAtIndex:row] username];
}

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSArray *accounts = [self accounts];
    
    self.twitterAccount = [accounts objectAtIndex:row];
    [[NSUserDefaults standardUserDefaults] setObject:_twitterAccount.identifier forKey:CSTweetLastAccountIdentifier];
    
    if (self.loginSuccessBlock) {
        self.loginSuccessBlock();
    }
    
    NSAssert([CSSocial sharedManager].dataSource, @"You must assign a dataSource!");
    UIViewController *viewController = [[CSSocial sharedManager].dataSource presentingViewController];
    float navBarOffset = (viewController.navigationController.navigationBarHidden)?0:viewController.navigationController.navigationBar.frame.size.height;
    
    [UIView animateWithDuration:.3f animations:^{
        pickerView.frame = CGRectMake(pickerView.frame.origin.x, pickerView.frame.origin.y + pickerView.frame.size.height + navBarOffset, pickerView.frame.size.width, pickerView.frame.size.height);
    } completion:^(BOOL finished) {
        [pickerView removeFromSuperview];
        pickerView.delegate = nil;
        pickerView.dataSource = nil;
    }];
    
    /*
     TODO: create cancel option
    if (self.loginBlock) {
        self.loginBlock([self response:kCSSocialResponseError]);
    }
     */
}

#pragma mark - Requests

-(NSError*) errorInvalidReturnValue
{
    return [self errorWithLocalizedDescription:@"Invalid return value"];
}

-(NSError*) errorAccountNotFound
{
    return [self errorWithLocalizedDescription:@"Account not found"];
}

-(NSError*) errorUnsupportedSDK
{
    return [self errorWithLocalizedDescription:@"Unsupported SDK"];
}

@end
