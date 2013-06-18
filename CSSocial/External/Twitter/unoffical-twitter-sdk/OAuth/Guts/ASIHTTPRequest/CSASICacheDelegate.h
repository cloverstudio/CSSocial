//
//  CSASICacheDelegate.h
//  Part of CSASIHTTPRequest -> http://allseeing-i.com/CSASIHTTPRequest
//
//  Created by Ben Copsey on 01/05/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CSASIHTTPRequest;

typedef enum _CSASICachePolicy {
	CSASIDefaultCachePolicy = 0,
	CSASIIgnoreCachePolicy = 1,
	CSASIReloadIfDifferentCachePolicy = 2,
	CSASIOnlyLoadIfNotCachedCachePolicy = 3,
	CSASIUseCacheIfLoadFailsCachePolicy = 4
} CSASICachePolicy;

typedef enum _CSASICacheStoragePolicy {
	CSASICacheForSessionDurationCacheStoragePolicy = 0,
	CSASICachePermanentlyCacheStoragePolicy = 1
} CSASICacheStoragePolicy;


@protocol CSASICacheDelegate <NSObject>

@required

// Should return the cache policy that will be used when requests have their cache policy set to CSASIDefaultCachePolicy
- (CSASICachePolicy)defaultCachePolicy;

// Should Remove cached data for a particular request
- (void)removeCachedDataForRequest:(CSASIHTTPRequest *)request;

// Should return YES if the cache considers its cached response current for the request
// Should return NO is the data is not cached, or (for example) if the cached headers state the request should have expired
- (BOOL)isCachedDataCurrentForRequest:(CSASIHTTPRequest *)request;

// Should store the response for the passed request in the cache
// When a non-zero maxAge is passed, it should be used as the expiry time for the cached response
- (void)storeResponseForRequest:(CSASIHTTPRequest *)request maxAge:(NSTimeInterval)maxAge;

// Should return an NSDictionary of cached headers for the passed request, if it is stored in the cache
- (NSDictionary *)cachedHeadersForRequest:(CSASIHTTPRequest *)request;

// Should return the cached body of a response for the passed request, if it is stored in the cache
- (NSData *)cachedResponseDataForRequest:(CSASIHTTPRequest *)request;

// Same as the above, but returns a path to the cached response body instead
- (NSString *)pathToCachedResponseDataForRequest:(CSASIHTTPRequest *)request;

// Clear cached data stored for the passed storage policy
- (void)clearCachedResponsesForStoragePolicy:(CSASICacheStoragePolicy)cachePolicy;
@end
