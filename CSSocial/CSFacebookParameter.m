//
//  CSFacebookParameter.m
//  CSCocialManager2.0
//
//  Created by Luka Fajl on 26.6.2012..
//  Copyright (c) 2012. Clover Studio. All rights reserved.
//

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
