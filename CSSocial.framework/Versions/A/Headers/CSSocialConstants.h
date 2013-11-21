//
//  CSSocialConstants.h
//  CSCocialManager2.0
//
//  Created by Marko Hlebar on 6/21/12.
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

#ifndef CSCocialManager2_0_CSSocialConstants_h
#define CSCocialManager2_0_CSSocialConstants_h

#define kCSSocialResponseOK NSLocalizedString(@"OK", @"")
#define kCSSocialResponseError @"Error"

#define kCSFacebookPermissionsRead @"CSSOCIAL_FACEBOOK_PERMISSIONS_READ"
#define kCSFacebookPermissionsPublish @"CSSOCIAL_FACEBOOK_PERMISSIONS_PUBLISH"

#define kCSFacebookAppID @"CSSOCIAL_FACEBOOK_APP_ID"

#define kCSLinkedinConsumerKey @"CSSOCIAL_LINKEDIN_API_KEY"
#define kCSLinkedinConsumerSecret @"CSSOCIAL_LINKEDIN_API_SECRET"

#define kCSTwitterConsumerKey @"CSSOCIAL_TWITTER_CONSUMER_KEY"
#define kCSTwitterConsumerSecret @"CSSOCIAL_TWITTER_CONSUMER_SECRET"

#define kCSGoogleClientID @"CSSOCIAL_GOOGLEPLUS_CLIENT_ID"

#define kCSTwitterOAuthToken @"CSSocialTwitterOAuthToken"
#define kCSTwitterOAuthTokenSecret @"CSSocialTwitterOAuthTokenSecret"
#define kCSTwitterOAuthTokenAuthorized @"CSSocialTwitterOAuthTokenAuthorized"
#define kCSTwitterOAuthDictionary [NSString stringWithFormat:@"%@.CSSocialTwitterOAuthDictionary", CS_BUNDLE_ID]

#define CSFacebook  (CSSocialServiceFacebook*)[CSSocial facebook]
#define CSTwitter   (CSSocialServiceTwitter*)[CSSocial twitter]
#define CSGoogle    (CSSocialServiceGoogle*)[CSSocial google]
#define CSLinkedin  (CSSocialServiceLinkedin*)[CSSocial linkedin]

#endif
