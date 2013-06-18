//
//  CSSocialUser.h
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

#import <UIKit/UIKit.h>

@protocol CSSocialService;
@protocol CSSocialUser <NSObject>
-(NSString*) name;
-(NSString*) firstName;
-(NSString*) lastName;
-(NSString*) userName;
-(NSString*) ID;
-(NSString*) location; 
-(NSString*) gender; 
-(NSURL*) pageURL;
-(NSURL*) photoURL;
@end

@interface CSSocialUser : NSObject <CSSocialUser>
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *gender;
@property (nonatomic, retain) NSString *ID;
@property (nonatomic, retain) NSURL *photoURL;
@property (nonatomic, retain) NSURL *pageURL;

///initializes a user based on the response
///@param response a response obtained when calling an API on a social service
///@return a CSSocialUser instance
-(id) initWithResponse:(id) response;

///initializes a user based on the response
///@param response a response obtained when calling an API on a social service
///@return a CSSocialUser instance
+(id) userWithResponse:(id) response;

///returns an array of users from response
///@param response social response
///@return array of CSSocialUser objects
+(NSArray*) usersWithResponse:(id) response;
@end
