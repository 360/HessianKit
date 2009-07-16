//
//  NSTream+CWiPhoneAdditions.m
//  HessianKit
//
//  Created by Fredrik Olsson on 2009-07-16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSStream+CWiPhoneAdditions.h"

@interface CWReadStreamWrapper : NSInputStream {
 @private
  CFReadStreamRef _readStream;
}

-(id)initWithReadStream:(CFReadStreamRef)readStream;

@end

@interface CWWriteStreamWrapper : NSOutputStream {
@private
  CFWriteStreamRef _writeStream;
}

-(id)initWithWriteStream:(CFWriteStreamRef)writeStream;

@end


@implementation NSStream (CWiPhoneAdditions)

+(void)getStreamsToHostAddress:(NSString*)host 
                          port:(NSInteger)port 
                   inputStream:(NSInputStream**)inputStream 
                  outputStream:(NSOutputStream**)outputStream;
{
  CFReadStreamRef readStream = NULL;
  CFWriteStreamRef writeStream = NULL;  
  CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (CFStringRef)host, port, &readStream, &writeStream);
  if (inputStream) {
    *inputStream = [[CWReadStreamWrapper alloc] initWithReadStream:readStream];
  }
  if (outputStream) {
    *outputStream = [[CWWriteStreamWrapper alloc] initWithWriteStream:writeStream];
  }
  CFRelease(readStream);
  CFRelease(writeStream);
}

@end


@implementation CWReadStreamWrapper

-(id)initWithReadStream:(CFReadStreamRef)readStream;
{
  self = [super init];
  if (self) {
    _readStream = (CFReadStreamRef)CFRetain(readStream);
  }
  return self;
}

-(void)open;
{
  if (!CFReadStreamOpen(_readStream)) {
    [NSException raise:NSInternalInconsistencyException format:@"Could not open read stream"];
  }
}

-(NSInteger)read:(uint8_t*)buffer maxLength:(NSUInteger)len;
{
  CFIndex result = CFReadStreamRead(_readStream, buffer, len);
  if (result == -1) {
    [NSException raise:NSInternalInconsistencyException format:@"Could not read from stream"];
  }
  return result;
}

-(BOOL)getBuffer:(uint8_t**)buffer length:(NSUInteger*)len;
{
  const UInt8* result = CFReadStreamGetBuffer(_readStream, 0, (CFIndex*)len);
  if (result != NULL) {
    *buffer = (uint8_t*)result;
    return YES;
  }
  return NO;
}

-(BOOL)hasBytesAvailable;
{
  return CFReadStreamHasBytesAvailable(_readStream);
}

-(void)close;
{
  CFReadStreamClose(_readStream);
}

-(void)dealloc;
{
  [self close];
  CFRelease(_readStream);
  [super dealloc];
}

@end

@implementation CWWriteStreamWrapper

-(id)initWithWriteStream:(CFWriteStreamRef)writeStream;
{
  self = [super init];
  if (self) {
    _writeStream = (CFWriteStreamRef)CFRetain(writeStream);
  }
  return self;
}

-(void)open;
{
  if (!CFWriteStreamOpen(_writeStream)) {
    [NSException raise:NSInternalInconsistencyException format:@"Could not open write stream"];
  }
}

-(NSInteger)write:(const uint8_t*)buffer maxLength:(NSUInteger)length;
{
  CFIndex result = CFWriteStreamWrite(_writeStream, buffer, length);
  if (result == -1) {
    [NSException raise:NSInternalInconsistencyException format:@"Could not write to stream"];
  }
  return result;
}

-(BOOL)hasSpaceAvailable;
{
  return CFWriteStreamCanAcceptBytes(_writeStream);
}

-(void)close;
{
  CFWriteStreamClose(_writeStream);
}

-(void)dealloc;
{
  [self close];
  CFRelease(_writeStream);
  [super dealloc];
}

@end
