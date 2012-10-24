//
//  SimpleKeychain.h
//  CSSocial
//
//  Created by marko.hlebar on 10/19/12.
//  Copyright (c) 2012 Clover Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

///from http://stackoverflow.com/questions/5247912/saving-email-password-to-keychain-in-ios

@interface SimpleKeychain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end