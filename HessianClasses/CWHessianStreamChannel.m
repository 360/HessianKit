//
//  CWHessianStreamChannel.h
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

#import "CWHessianStreamChannel.h"


@interface CWHessianStreamChannel (CWStreamDelegate)

-(void)stream:(NSStream*)theStream handleEvent:(NSStreamEvent)streamEvent;

@end


@implementation CWHessianStreamChannel

@synthesize receiveStream = _receiveStream;
@synthesize sendStream = _sendStream;

-(id)initWithDelegate:(id<CWHessianChannelDelegate>)delegate receiveStream:(NSInputStream*)receiveStream sendStream:(NSOutputStream*)sendStream;
{
  if (receiveStream == nil || sendStream == nil) {
    [self release];
    [NSException raise:NSInvalidArgumentException format:@"Receive and send streams must not be nil"];
    self = nil;
  } else {
    self = [super initWithDelegate:delegate];
  }
  if (self) {
    [receiveStream setDelegate:self];
    [receiveStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.receiveStream = receiveStream;
    self.sendStream = sendStream;
  }
  return self;
}

-(NSOutputStream*)outputStreamForMessage;
{
  return self.sendStream;
}

-(void)finishOutputStreamForMessage:(NSOutputStream*)outputStream;
{
  // No-op
}

-(void)dealloc;
{
  if (self.receiveStream) {
    [self.receiveStream setDelegate:nil];
    [self.receiveStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
  }
  self.receiveStream = nil;
  self.sendStream = nil;
  [super dealloc];
}



-(void)stream:(NSStream*)stream handleEvent:(NSStreamEvent)streamEvent;
{
  if ([stream isKindOfClass:[NSInputStream class]] && streamEvent == NSStreamEventHasBytesAvailable) {
    [self.delegate channel:self didReceiveDataInInputStream:(NSInputStream*)stream];
  }
  [stream stream:stream handleEvent:streamEvent];
}

@end
