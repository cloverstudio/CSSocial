//
//  CSFacebookParameter.h
//  CSCocialManager2.0
//
//  Created by Luka Fajl on 26.6.2012..
//  Copyright (c) 2012. __MyCompanyName__. All rights reserved.
//

#import "CSSocialParameter.h"
#import <UIKit/UIImage.h>

@interface CSFacebookParameter : CSSocialParameter

+(id<CSSocialParameter>) message:(NSString *)message
                            name:(NSString*)name
                            link:(NSString*)link
                      pictureURL:(NSString*)pictureURL
                         caption:(NSString*)caption
                     description:(NSString*)description
                            icon:(NSString*) icon;

+(id<CSSocialParameter>) photo:(UIImage*)image message:(NSString*)message;
+(id<CSSocialParameter>) user;
+(id<CSSocialParameter>) userImage;
+(id<CSSocialParameter>) userImageWithType:(NSString*) type;
+(id<CSSocialParameter>) friends;

///+(id<CSSocialParameter>) friendsWithPagingOffset:(NSInteger) offset limit:(NSInteger) limit;

@end
