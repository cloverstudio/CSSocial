//
//  CSSocialServiceFacebook.h
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

#import "CSSocialService.h"
#import "External/Facebook/FBSession.h"

@interface CSSocialServiceFacebook : CSSocialService
///Facebook specific, people you want to share your published stuff with
///@default FBSessionDefaultAudienceEveryone
@property (nonatomic) FBSessionDefaultAudience audience;

///returns accessToken of the current FBSession
@property (nonatomic, readonly) NSString *accessToken;

///requests read permissions for the current session
///@param permissions an array of permissions
///@parama errorBlock returns an error if one occured or nil 
-(void) requestReadPermissions:(NSArray*) permissions errorBlock:(CSErrorBlock) errorBlock;

///requests publish permissions for the current session
///@param permissions an array of permissions
///@parama errorBlock returns an error if one occured or nil
-(void) requestPublishPermissions:(NSArray*) permissions errorBlock:(CSErrorBlock) errorBlock;
@end
