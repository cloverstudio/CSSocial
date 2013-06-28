//
//  CSSocialRequestFacebook.h
//  CSSocial
//
//  Created by Marko Hlebar on 12/19/12.
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

#import "CSSocialRequest.h"

@interface CSSocialRequestFacebook : CSSocialRequest
///Facebook permission needed to do the request.
///List of all permissions is here https://developers.facebook.com/docs/howtos/ios-6/
@property (nonatomic, strong) NSArray *permissions;

///interface to use when creating a custom request
///@param apiCall path to graph api, for instance me/friends
///@param method HTTP method (GET, POST, PUT)
///@param parameters parameters to use when making a request
///@param permissions permissions needed for this API
///@return CSSocialRequestFacebook object
+(CSSocialRequestFacebook*) requestWithApiCall:(NSString*) apiCall
                                    httpMethod:(NSString*) method
                                    parameters:(NSDictionary*) parameters
                                    permissions:(NSArray*) permissions;
@end

///user
@interface CSSocialRequestFacebookUser : CSSocialRequestFacebook
@end

///friends
@interface CSSocialRequestFacebookFriends : CSSocialRequestFacebook
@end

///friends paging
@interface CSSocialRequestFacebookFriendsPaging : CSSocialRequestFacebookFriends
@end

///post wall
@interface CSSocialRequestFacebookPostWall : CSSocialRequestFacebook
@end

///post photo
@interface CSSocialRequestFacebookPostPhoto : CSSocialRequestFacebook
@end

///get picture
@interface CSSocialRequestFacebookGetUserImage : CSSocialRequestFacebook
@end