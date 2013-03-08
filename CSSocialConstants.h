//
//  CSSocialConstants.h
//  CSCocialManager2.0
//
//  Created by marko.hlebar on 6/21/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#ifndef CSCocialManager2_0_CSSocialConstants_h
#define CSCocialManager2_0_CSSocialConstants_h

#define kCSSocialResponseOK NSLocalizedString(@"OK", @"")
#define kCSSocialResponseError @"Error"

#define kCSFacebookPermissionsRead @"CSSOCIAL_FACEBOOK_PERMISSIONS_READ"
#define kCSFacebookPermissionsPublish @"CSSOCIAL_FACEBOOK_PERMISSIONS_PUBLISH"

#define kCSFacebookAppID @"CSSOCIAL_FACEBOOK_APP_ID"

#define kCSTwitterConsumerKey @"CSSOCIAL_TWITTER_CONSUMER_KEY"
#define kCSTwitterConsumerSecret @"CSSOCIAL_TWITTER_CONSUMER_SECRET"

#define kCSGoogleClientID @"CSSOCIAL_GOOGLEPLUS_CLIENT_ID"

#define kCSTwitterOAuthToken @"CSSocialTwitterOAuthToken"
#define kCSTwitterOAuthTokenSecret @"CSSocialTwitterOAuthTokenSecret"
#define kCSTwitterOAuthTokenAuthorized @"CSSocialTwitterOAuthTokenAuthorized"
#define kCSTwitterOAuthDictionary [NSString stringWithFormat:@"%@.CSSocialTwitterOAuthDictionary", CS_BUNDLE_ID]

#define CSFacebook (CSSocialServiceFacebook*)[CSSocial facebook]
#define CSTwitter (CSSocialServiceTwitter*)[CSSocial twitter]
#define CSGoogle (CSSocialServiceGoogle*)[CSSocial google]

typedef enum
{
    CSSocialErrorCodeLoginFailed = 10000,
    CSSocialErrorCodeUserCancelled = 10001
}
CSSocialServiceErrorCode;

#endif
