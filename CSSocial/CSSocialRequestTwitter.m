//
//  CSSocialRequestTwitter.m
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

#import "CSSocialRequestTwitter.h"
#import "OAuth.h"
#import <Twitter/TWRequest.h>
#import "CSSocialUserTwitter.h"

#pragma mark - CSSocialRequestTwitter

@interface CSSocialRequestTwitter (Private) <NSURLConnectionDelegate>

-(id) parseResponseData:(id)response error:(NSError**) error;
-(NSString*) paramsString;
- (NSString *)encodedURLParameterString:(NSString*) string;
@end

@implementation CSSocialRequestTwitter
{
    NSMutableData *_data;
}
-(void) dealloc
{
    CS_RELEASE(_data);
    CS_SUPER_DEALLOC;
}

-(void) makeRequest
{
    if (SYSTEM_VERSION_LESS_THAN(@"5.0"))
    {
        NSError *error = nil;
        NSHTTPURLResponse *response = nil;
        _data = (NSMutableData*)[NSURLConnection sendSynchronousRequest:[self request]
                                                      returningResponse:&response
                                                                  error:&error];
        [self buildResponse:_data error:error];
    }
    else
    {
        [NSURLConnection sendAsynchronousRequest:[self request]
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             [self buildResponse:data error:error];
         }];
    }
}

-(void) buildResponse:(NSData*) data error:(NSError*) error
{
    if (data)
    {
        NSError *jsonError = nil;
        id parsedResponse = [self parseResponseData:data error:&jsonError];
        if (!parsedResponse || jsonError)
        {
            self.responseBlock(self, nil, jsonError);
            return;
        }
        
        NSError *twitterError = [self checkJSONForTwitterError:parsedResponse];
        if (twitterError)
        {
            self.responseBlock(self, nil, twitterError);
            return;
        }
       
        self.responseBlock(self, parsedResponse, nil);
    }
    else if (error)
    {
        ///there is a twitter error message probably here 
        self.responseBlock(self, nil, error);
    }
    else
    {
        self.responseBlock(self, nil, [NSError errorWithDomain:@""
                                                          code:0
                                                      userInfo:[NSDictionary dictionaryWithObject:@"No data in response"
                                                                                           forKey:NSLocalizedDescriptionKey]]);
    }
}

-(NSError*) checkJSONForTwitterError:(NSDictionary*) JSONDict
{
    NSString *errorString = JSONDict[@"error"];
    if (errorString)
    {
        return [NSError errorWithDomain:@""
                                   code:0
                               userInfo:[NSDictionary dictionaryWithObject:errorString
                                                                    forKey:NSLocalizedDescriptionKey]];
    }
    return nil;
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

-(void) connectionDidFinishLoading:(NSURLConnection*) connection
{
    [self buildResponse:_data error:nil];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.responseBlock(self, nil, error);
}

-(NSMutableURLRequest*) request
{
    NSString *urlString = [NSString stringWithFormat:@"%@?%@", [self APIcall], [self paramsString]];
    return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
}

///parse JSON by default.
-(id) parseResponseData:(id)responseData error:(NSError**) error
{
    if (responseData)
    {
        return [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:error];
    }
    else
    {
        return nil;
    }
}

-(NSString*) paramsString
{
    NSMutableString *paramsString = [NSMutableString string];
    
    [self.params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [paramsString appendFormat:@"%@=%@&", key, [self encodedURLParameterString:[self.params objectForKey:key]]];
    }];
    return [NSString stringWithString:paramsString];
}

- (NSString *)encodedURLParameterString:(NSString*) string
{
    NSString *result = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                   (__bridge CFStringRef)string,
                                                                                   NULL,
                                                                                   CFSTR(":/=,!$&'()*+;[]@#?"),
                                                                                   kCFStringEncodingUTF8);
	return CS_AUTORELEASE(result);
}

@end

@implementation CSSocialRequestTwitterMessage
-(NSString*) APIcall {return @"https://api.twitter.com/1.1/statuses/update.json";}

-(NSMutableURLRequest*) request
{
    OAuth *oAuth = (OAuth*)self.service;
    NSString *postBodyString = [self paramsString];
    NSString *postUrl = [self APIcall];
    NSMutableDictionary *postInfo = [NSMutableDictionary dictionaryWithDictionary:[self params]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postUrl]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postBodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *authHeader = [oAuth oAuthHeaderForMethod:@"POST"
                                                andUrl:postUrl
                                             andParams:postInfo];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    return request;
}
@end

@implementation CSSocialRequestTwitterGetUserImage
-(NSString*) APIcall { return @"https://api.twitter.com/1.1/users/profile_image"; }
-(id) method { return [NSNumber numberWithInteger:TWRequestMethodGET]; }
-(id) parseResponseData:(id)responseData error:(NSError**) error
{
    UIImage *image = [UIImage imageWithData:responseData];
    if (!image) {
        *error = [NSError errorWithDomain:@"com.clover-studio" code:100 userInfo:nil];
        return nil;
    }
    return image;
}
@end

@implementation CSSocialRequestTwitterFriends
-(NSString*) APIcall { return @"https://api.twitter.com/1.1/friends/ids.json"; }
-(id) method { return [NSNumber numberWithInteger:TWRequestMethodGET]; }
-(id) parseResponseData:(id)responseData error:(NSError**) error
{
    return [CSSocialUserTwitter usersWithResponse:responseData];
}
@end
