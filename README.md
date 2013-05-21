CSSocial
========

CSSocial is an iOS social sharing library supporting Facebook, Twitter and Google+ 
CSSocial framework was built to make use of social services like
Facebook, Twitter or Google+ safe and easy to implement by
the programmer. We were frustrated that every time we needed to integrate 
a social service into the app, each programmer did it his own way and usually spent more than an hour doing so. The decision was to make a one-line-of-code-do-magic solution
which took only a couple of minutes to set up and run.

Setup
-----

* clone the CSSocial.git to CSSocial directory on your Mac
* open your XCode project where you want to add the social features
* drag&drop CSSocial.framework to Frameworks - check copy
* drag&drop CSSocial.plist to Supporting Files - check copy
* open CSSocial.plist and enter your parameters

<table>
  <tr>
    <th>ID</th><th>Parameter</th><th>Description</th>
  </tr>
  <tr>
    <td>1</td><td>CSSOCIAL_FACEBOOK_APP_ID</td><td>Facebook App ID</td>
  </tr>
  <tr>
    <td>2</td><td>CSSOCIAL_TWITTER_CONSUMER_KEY</td><td>Twitter Consumer Key</td>
  </tr>
  <tr>
    <td>3</td><td>CSSOCIAL_TWITTER_CONSUMER_SECRET</td><td>Twitter Consumer Secret</td>
  </tr>
  <tr>
    <td>4</td><td>CSSOCIAL_FACEBOOK_PERMISSIONS_READ</td><td>Facebook read permissions</td>
  </tr>
  <tr>
    <td>5</td><td>CSSOCIAL_FACEBOOK_PERMISSIONS_PUBLISH</td><td>Facebook publish permissions</td>
  </tr>
  <tr>
    <td>6</td><td>CSSOCIAL_GOOGLEPLUS_CLIENT_ID</td><td>Google+ Client ID</td>
  </tr>
</table>

*add the following frameworks to your XCode project*
* Accounts.framework
* AdSupport.framework
* CFNetwork.framework
* MobileCoreServices.framework
* Security.framework
* Social.framework
* SystemConfiguration.framework
* libsqlite3.0.dylib
* libz.1.2.5.dylib

Facebook
--------

*Posting a message to Facebook wall* can be done by calling a single method like this. If you haven't handled the login or permissions process yourself, CSSocial handles it for you automagically:

    [CSFacebook postToWall:@"Test"
           completionBlock:^(CSSocialRequest *request, id response, NSError *error)
    {
 
    }];

If you assign a handler block, you will receive a response or an error if one has occured during the posting process.

*Posting an image with a caption* is done like this 

    [CSFacebook postPhoto:[UIImage imageNamed:@"test"]
                  caption:@"test"
          completionBlock:^(CSSocialRequest *request, id response, NSError *error) {
 
    }];

*Showing a Facebook dialog* (as available depending on the platform )

    [CSFacebook showDialogWithMessage:@"test"
                                photo:[UIImage imageNamed:@"test"]
                              handler:^(NSError *error) {
 
    }];

If you assign a handler block, you will receive an error if user cancels the dialog or if something goes wrong while posting.

Twitter
-------

*Posting a tweet to Twitter* can be done calling a single method like this:

    [CSTwitter tweet:@"test"
     completionBlock:^(CSSocialRequest *request, id response, NSError *error) {
    }];

*Showing a Twitter dialog* (as available depending on the platform )

    [CSTwitter showDialogWithMessage:@"test"
                               photo:[UIImage imageNamed:@"test"]
                             handler:^(NSError *error) {
    }];

If you assign a handler block, you will receive an error if user cancels the dialog or if something goes wrong while posting.

Google+
-------

*Showing a Google+ dialog* (as available depending on the platform )

    [CSGoogle showDialogWithMessage:@"test"
                              photo:[UIImage imageNamed:@"test"]
                            handler:^(NSError *error) {
    }];

If you assign a handler block, you will receive an error if user cancels the dialog or if something goes wrong while posting. For more information on errors, see here.