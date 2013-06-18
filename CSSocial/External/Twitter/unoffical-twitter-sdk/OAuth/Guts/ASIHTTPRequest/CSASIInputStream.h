//
//  CSASIInputStream.h
//  Part of CSASIHTTPRequest -> http://allseeing-i.com/CSASIHTTPRequest
//
//  Created by Ben Copsey on 10/08/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSASIHTTPRequest;

// This is a wrapper for NSInputStream that pretends to be an NSInputStream itself
// Subclassing NSInputStream seems to be tricky, and may involve overriding undocumented methods, so we'll cheat instead.
// It is used by CSASIHTTPRequest whenever we have a request body, and handles measuring and throttling the bandwidth used for uploading

@interface CSASIInputStream : NSObject {
	NSInputStream *stream;
	CSASIHTTPRequest *request;
}
+ (id)inputStreamWithFileAtPath:(NSString *)path request:(CSASIHTTPRequest *)request;
+ (id)inputStreamWithData:(NSData *)data request:(CSASIHTTPRequest *)request;

@property (retain, nonatomic) NSInputStream *stream;
@property (assign, nonatomic) CSASIHTTPRequest *request;
@end
