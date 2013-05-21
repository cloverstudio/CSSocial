//
//  CSFacebookParameter.m
//  CSCocialManager2.0
//
//  Created by Luka Fajl on 26.6.2012..
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

#import "CSFacebookParameter.h"
#import "CSConstants.h"

@interface CSFacebookParameter()
@property (nonatomic, retain) NSDictionary *parameters;
@property (nonatomic) CSRequestName requestName;
@end

@implementation CSFacebookParameter

+(id<CSSocialParameter>) message:(NSString *)message
                            name:(NSString*)name
                            link:(NSString*)link
                      pictureURL:(NSString*)pictureURL
                         caption:(NSString*)caption
                     description:(NSString*)description
                            icon:(NSString*) icon
{
    CSFacebookParameter *object = [CSFacebookParameter parameter];
    object.requestName = CSRequestPostMessage;
    object.parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                         message, @"message",
                         name, @"name",
                         link, @"link",
                         pictureURL, @"picture",
                         caption, @"caption",
                         description, @"description",
                         nil];
    
    return object;
}

+(id<CSSocialParameter>) photo:(UIImage*)image
                       message:(NSString*)message
{
    CSFacebookParameter *object = [CSFacebookParameter parameter];
    object.requestName = CSRequestPostPhoto;
    object.parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                         UIImageJPEGRepresentation(image, 1.0f), @"source",
                         message, @"message",
                         nil];
    return object;
}

+(id<CSSocialParameter>) user
{
    CSFacebookParameter *object = [CSFacebookParameter parameter];
    object.requestName = CSRequestUser;
    object.parameters = nil;
    return object;
}

+(id<CSSocialParameter>) userImageWithType:(NSString*) type
{
    CSFacebookParameter *object = [CSFacebookParameter parameter];
    object.requestName = CSRequestGetUserImage;
    object.parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSString stringWithFormat:@"picture.type(%@)", type], @"fields", nil];
    return object;
}

+(id<CSSocialParameter>) userImage
{
    return [CSFacebookParameter userImageWithType:@"large"];
}

+(id<CSSocialParameter>) friends
{
    CSFacebookParameter *object = [CSFacebookParameter parameter];
    object.requestName = CSRequestFriends;
    object.parameters = @{@"fields" : @"name,id,picture"};
    return object;
}

@end
