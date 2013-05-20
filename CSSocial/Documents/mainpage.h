
/**
 @mainpage Home
 
 @section Introduction
 CSSocial framework was built to make use of social services like
 Facebook, Twitter or Google+ safe and easy to implement by
 the programmer. We were frustrated that every time we needed to integrate 
 a social service into the app, each programmer did it his own way and usually spent more than
 an hour doing so. The decision was to make a one-line-of-code-do-magic solution
 which took only a couple of minutes to set up and run.
 
 @section Setup
 - download the CSSocial.framework file from http://bla.com
 - drag&drop CSSocial.framework to Frameworks - check copy
 - drag&drop CSSocial.plist to Supporting Files - check copy
 - open CSSocial.plist and enter your parameters
 
 Parameter | Description
 ------------- | -------------
 CSSOCIAL_FACEBOOK_APP_ID | Facebook App ID
 CSSOCIAL_TWITTER_CONSUMER_KEY | Twitter Consumer Key
 CSSOCIAL_TWITTER_CONSUMER_SECRET | Twitter Consumer Secret
 CSSOCIAL_FACEBOOK_PERMISSIONS_READ | Facebook read permissions
 CSSOCIAL_FACEBOOK_PERMISSIONS_PUBLISH | Facebook publish permissions
 CSSOCIAL_GOOGLEPLUS_CLIENT_ID | Google+ Client ID
 
 - add the following frameworks
    + Accounts.framework
    + AdSupport.framework
    + CFNetwork.framework
    + MobileCoreServices.framework
    + Security.framework
    + Social.framework
    + SystemConfiguration.framework
    + libsqlite3.0.dylib
    + libz.1.2.5.dylib

 @subsection Facebook
 
 Posting a message to Facebook wall can be done by calling a single method like this. If you haven't handled the login process yourself, CSSocial handles it for you automagically:
 
 @code
 [CSFacebook postToWall:@"Test"
             completionBlock:^(CSSocialRequest *request, id response, NSError *error)
 {
 
 }];
 @endcode
 
 If you assign a handler block, you will receive a response or an error if one has occured during the posting process. For more information on errors, see here.
 
 Posting an image with a caption is done like this 
 
 @code
 [CSFacebook postPhoto:[UIImage imageNamed:@"test"]
             caption:@"test"
             completionBlock:^(CSSocialRequest *request, id response, NSError *error) {
 
 }];
 @endcode
 
 Showing a Facebook dialog (as available depending on the platform )
 
 @code 
 [CSFacebook showDialogWithMessage:@"test"
                             photo:[UIImage imageNamed:@"test"]
                           handler:^(NSError *error) {
 
 }];
 @endcode
 
 If you assign a handler block, you will receive an error if user cancels the dialog or if something goes wrong while posting. For more information on errors, see here.
 
 @subsection Twitter
 
 Posting a tweet to Twitter can be done calling a single method like this:
 
 @code
 [CSTwitter tweet:@"test"
            completionBlock:^(CSSocialRequest *request, id response, NSError *error) {
 }];
 @endcode
 
 Showing a Twitter dialog (as available depending on the platform )
 
 @code
 [CSTwitter showDialogWithMessage:@"test"
                            photo:[UIImage imageNamed:@"test"]
                          handler:^(NSError *error) {
 }];
 @endcode
 
 If you assign a handler block, you will receive an error if user cancels the dialog or if something goes wrong while posting. For more information on errors, see here.
 
 
 @subsection Google
 Showing a Google+ dialog (as available depending on the platform )
 
 @code
 [CSGoogle showDialogWithMessage:@"test"
                           photo:[UIImage imageNamed:@"test"]
                         handler:^(NSError *error) {
 }];
 @endcode
 
 If you assign a handler block, you will receive an error if user cancels the dialog or if something goes wrong while posting. For more information on errors, see here.
 
 */