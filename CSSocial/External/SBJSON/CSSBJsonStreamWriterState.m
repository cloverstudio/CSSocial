/*
 Copyright (c) 2010, Stig Brautaset.
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

   Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   Neither the name of the the author nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "CSSBJsonStreamWriterState.h"
#import "CSSBJsonStreamWriter.h"

#define SINGLETON \
+ (id)sharedInstance { \
    static id state; \
    if (!state) state = [[self alloc] init]; \
    return state; \
}


@implementation CSSBJsonStreamWriterState
+ (id)sharedInstance { return nil; }
- (BOOL)isInvalidState:(CSSBJsonStreamWriter*)writer { return NO; }
- (void)appendSeparator:(CSSBJsonStreamWriter*)writer {}
- (BOOL)expectingKey:(CSSBJsonStreamWriter*)writer { return NO; }
- (void)transitionState:(CSSBJsonStreamWriter *)writer {}
- (void)appendWhitespace:(CSSBJsonStreamWriter*)writer {
	[writer appendBytes:"\n" length:1];
	for (NSUInteger i = 0; i < writer.stateStack.count; i++)
	    [writer appendBytes:"  " length:2];
}
@end

@implementation CSSBJsonStreamWriterStateObjectStart

SINGLETON

- (void)transitionState:(CSSBJsonStreamWriter *)writer {
	writer.state = [CSSBJsonStreamWriterStateObjectValue sharedInstance];
}
- (BOOL)expectingKey:(CSSBJsonStreamWriter *)writer {
	writer.error = @"JSON object key must be string";
	return YES;
}
@end

@implementation CSSBJsonStreamWriterStateObjectKey

SINGLETON

- (void)appendSeparator:(CSSBJsonStreamWriter *)writer {
	[writer appendBytes:"," length:1];
}
@end

@implementation CSSBJsonStreamWriterStateObjectValue

SINGLETON

- (void)appendSeparator:(CSSBJsonStreamWriter *)writer {
	[writer appendBytes:":" length:1];
}
- (void)transitionState:(CSSBJsonStreamWriter *)writer {
    writer.state = [CSSBJsonStreamWriterStateObjectKey sharedInstance];
}
- (void)appendWhitespace:(CSSBJsonStreamWriter *)writer {
	[writer appendBytes:" " length:1];
}
@end

@implementation CSSBJsonStreamWriterStateArrayStart

SINGLETON

- (void)transitionState:(CSSBJsonStreamWriter *)writer {
    writer.state = [CSSBJsonStreamWriterStateArrayValue sharedInstance];
}
@end

@implementation CSSBJsonStreamWriterStateArrayValue

SINGLETON

- (void)appendSeparator:(CSSBJsonStreamWriter *)writer {
	[writer appendBytes:"," length:1];
}
@end

@implementation CSSBJsonStreamWriterStateStart

SINGLETON


- (void)transitionState:(CSSBJsonStreamWriter *)writer {
    writer.state = [CSSBJsonStreamWriterStateComplete sharedInstance];
}
- (void)appendSeparator:(CSSBJsonStreamWriter *)writer {
}
@end

@implementation CSSBJsonStreamWriterStateComplete

SINGLETON

- (BOOL)isInvalidState:(CSSBJsonStreamWriter*)writer {
	writer.error = @"Stream is closed";
	return YES;
}
@end

@implementation CSSBJsonStreamWriterStateError

SINGLETON

@end

