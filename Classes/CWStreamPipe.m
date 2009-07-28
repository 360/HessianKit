//
//  CWStreamPipe.m
//  HessianKit
//
//  Copyright 2009 Fredrik Olsson, Cocoway. All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License. 
//  You may obtain a copy of the License at 
// 
//  http://www.apache.org/licenses/LICENSE-2.0 
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, 
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "CWStreamPipe.h"


@interface CWOutputStreamPipe : NSOutputStream {
@protected
  uint8_t* sharedBuffer;
  NSUInteger capacity;
  NSUInteger* bytesAvailable;
}

-(id)initWithBuffer:(uint8_t*)sharedBuffer capacity:(NSUInteger)capacity bytes:(NSUInteger*)bytes;

-(NSInteger)write:(const uint8_t*)buffer maxLength:(NSUInteger)len;
-(BOOL)hasSpaceAvailable;

@end;

@interface CWInputStreamPipe : NSInputStream {
@protected
  uint8_t* sharedBuffer;
  NSUInteger capacity;
  NSUInteger* bytesAvailable;
}

-(id)initWithBuffer:(uint8_t*)sharedBuffer capacity:(NSUInteger)capacity bytes:(NSUInteger*)bytes;

-(NSInteger)read:(uint8_t*)buffer maxLength:(NSUInteger)len;
-(BOOL)getBuffer:(uint8_t**)buffer length:(NSUInteger *)len;
-(BOOL)hasBytesAvailable;

@end;



@implementation CWStreamPipe

@synthesize outputStream = _outputStream;
@synthesize inputStream = _inputStream;

-(id)initWithCapacity:(NSUInteger)capacity;
{
  self = [super init];
  if (self) {
    buffer = malloc(capacity * sizeof(uint8_t));
    _outputStream = [[CWOutputStreamPipe alloc] initWithBuffer:buffer capacity:capacity bytes:&bytesAvailable];
    _inputStream = [[CWInputStreamPipe alloc] initWithBuffer:buffer capacity:capacity bytes:&bytesAvailable];
  }
  return self;
}

-(void)dealloc;
{
  if (buffer) {
    free(buffer);
  }
  [_outputStream release];
  [_inputStream release];
  [super dealloc];
}

@end


@implementation CWOutputStreamPipe

-(id)initWithBuffer:(uint8_t*)buffer capacity:(NSUInteger)bufferCapacity bytes:(NSUInteger*)bytes;
{
  self = [super init];
  if (self) {
    sharedBuffer = buffer;
    bufferCapacity = bufferCapacity;
    bytesAvailable = bytes;
  }
  return self;
}

-(NSInteger)write:(const uint8_t*)buffer maxLength:(NSUInteger)len;
{
  len = MIN(len, capacity - *bytesAvailable);
  if (len > 0) {
    memcpy(sharedBuffer + *bytesAvailable, buffer, len);
    *bytesAvailable += len;
  }
  return len;
}

-(BOOL)hasSpaceAvailable;
{
  return *bytesAvailable < capacity;
}

@end

@implementation CWInputStreamPipe

-(id)initWithBuffer:(uint8_t*)buffer capacity:(NSUInteger)bufferCapacity bytes:(NSUInteger*)bytes;
{
  self = [super init];
  if (self) {
    sharedBuffer = buffer;
    capacity = bufferCapacity;
    bytesAvailable = bytes;
  }
  return self;
}

-(NSInteger)read:(uint8_t*)buffer maxLength:(NSUInteger)len;
{
  len = MIN(len, *bytesAvailable);
  if (len > 0) {
    memcpy(buffer, sharedBuffer, (size_t)len);
    memmove(buffer, buffer + len, len);
    *bytesAvailable -= len;
  }
  return len;
}

-(BOOL)getBuffer:(uint8_t**)buffer length:(NSUInteger *)len;
{
    *buffer = sharedBuffer;
    *len = *bytesAvailable;
    return YES;
}

-(BOOL)hasBytesAvailable;
{
  return *bytesAvailable > 0;
}

@end


