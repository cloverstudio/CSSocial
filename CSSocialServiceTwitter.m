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
#import "OAuth.h"
#import "SimpleKeychain.h"
#import "CSTwitterPlugin.h"
#import "CSSocialRequestTwitter.h"

static NSString * const CSTweetLastAccountIdentifier = @"CSTweetLastAccountIdentifier";

#pragma mark - CSSocialServiceTwitter

@interface CSSocialServiceTwitter()
-(NSString*) consumerKey;
-(NSString*) consumerSecret;
@property (nonatomic, retain) ACAccountStore *accountStore;
@property (nonatomic, retain) ACAccount *twitterAccount;
@property (nonatomic, retain) NSArray *accounts;
@end

@implementation CSSocialServiceTwitter
{
    CSTwitterPlugin *_plugin;
    BOOL waitingForAccess;
    OAuth *_oAuth;
}
@synthesize accountStore = _accountStore;
@synthesize twitterAccount = _twitterAccount;
@synthesize accounts = _accounts;

-(NSString*) consumerKey
{
    NSString *consumerKey = [[CSSocial configDictionary] objectForKey:kCSTwitterConsumerKey];
    NSString *message = [NSString stringWithFormat:@"Add Consumer Key with %@ key to CSSocial.plist", kCSTwitterConsumerKey];
    NSAssert(consumerKey, message);
    return consumerKey;
}

-(NSString*) consumerSecret
{
    NSString *consumerSecret = [[CSSocial configDictionary] objectForKey:kCSTwitterConsumerSecret];
    NSString *message = [NSString stringWithFormat:@"Add Consumer Secret with %@ key to CSSocial.plist", kCSTwitterConsumerSecret];
    NSAssert(consumerSecret, message);
    return consumerSecret;
}

-(void) dealloc
{
    CS_RELEASE(_oAuth);
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
        
        _plugin = [CSTwitterPlugin plugin];
    }
    return self;
}

-(NSOperationQueue*) operationQueue
{
    return CS_AUTORELEASE([[NSOperationQueue alloc] init]);
}

-(void) login:(CSVoidBlock) success error:(CSErrorBlock) error
{
    self.loginSuccessBlock = success;
    self.loginFailedBlock = error;
    
    if (YES)//SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
        [_plugin login:success error:error];
    }
    else
    {
    
        [self checkTwitterCredentials];
        if ([self selectTwitterAccount])
        {
            [self presentTwitterAccountPicker];
        }
        else
        {
            _twitterAccount ?
            self.loginSuccessBlock() :
            self.loginFailedBlock([NSError errorWithDomain:@""
                                                      code:0
                                                  userInfo:[NSDictionary dictionaryWithObject:@"No twitter account available" forKey:NSLocalizedDescriptionKey]]);
        }
    }
}

-(BOOL) handleOpenURL:(NSURL *)url
{
    return NO;
}

-(void) logout
{
    [_plugin logout];
}

-(BOOL) isAuthenticated
{
    return [_plugin isAuthenticated];
}

-(CSSocialRequest*) constructRequestWithParameter:(id<CSSocialParameter>)parameter
{
    CSSocialRequest *request = nil;
    
    switch (parameter.requestName)
    {
        case CSRequestLogin:
            break;
        case CSRequestLogout:
            break;
        case CSRequestUser:
            //request = [CSSocialRequestTwitterUser requestWithService:nil parameters:[parameter parameters]];
            break;
        case CSRequestFriends:
            request = [CSSocialRequestTwitterFriends requestWithService:_plugin.oAuth parameters:[parameter parameters]];
            break;
        case CSRequestPostMessage:
            request = [CSSocialRequestTwitterMessage requestWithService:_plugin.oAuth parameters:[parameter parameters]];
            break;
        case CSRequestGetUserImage:
            request = [CSSocialRequestTwitterGetUserImage requestWithService:_plugin.oAuth parameters:[parameter parameters]];
            break;
        default:
            break;
    }
    return request;
}

/*
-(void) request:(CSSocialRequest*) request response:(CSSocialResponseBlock) responseBlock
{
 
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

    
    
    //[postRequest setAccount:account];
//    CSSocialRequestTwitter *twRequest = (CSSocialRequestTwitter*) request;
//    twRequest.request = postRequest;
//    twRequest.account = self.twitterAccount;
//    [self.requestQueue addOperation:twRequest];
    
}
*/

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

-(void) checkTwitterCredentials
{
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

#pragma mark - TwitterLoginDialogDelegate



#pragma mark - Errors

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

-(NSError*) errorTwitterLoginFailed
{
    return [self errorWithLocalizedDescription:@"Twitter login failed"];
}

#pragma mark - OAuth

-(void) saveOAuth:(OAuth*) oAuth
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                oAuth.oauth_token, kCSTwitterOAuthToken,
                                oAuth.oauth_token_secret, kCSTwitterOAuthTokenSecret,
                                NSStringFromBOOL(oAuth.oauth_token_authorized), kCSTwitterOAuthTokenAuthorized,
                                nil];
    [SimpleKeychain save:kCSTwitterOAuthDictionary data:dictionary];
}

-(void) loadOAuth:(OAuth*) oAuth
{
    NSDictionary *dictionary = [SimpleKeychain load:kCSTwitterOAuthDictionary];
    oAuth.oauth_token = [dictionary objectForKey:kCSTwitterOAuthToken];
    oAuth.oauth_token_secret = [dictionary objectForKey:kCSTwitterOAuthTokenSecret];
    oAuth.oauth_token_authorized = [[dictionary objectForKey:kCSTwitterOAuthTokenAuthorized] boolValue];
}

-(void) resetOAuth
{
    [SimpleKeychain delete:kCSTwitterOAuthDictionary];
}

@end
