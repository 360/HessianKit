//
//  CWHessianGameKitChannel.m
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

#import "HessianKitTypes.h"
#import "CWHessianGameKitChannel.h"


@interface CWHessianGameKitChannel ()

-(void)receiveData:(NSData*)data fromPeer:(NSString*)peer inSession:(GKSession*)session context:(void*)context;

@end


@implementation CWHessianGameKitChannel

@synthesize session = _session;

-(id)initWithDelegate:(id<CWHessianChannelDelegate>)delegate session:(GKSession*)session;
{
  if (session == nil) {
    [self release];
    [NSException raise:NSInvalidArgumentException format:@"GameKit session must not be nil"];
    self = nil;
  } else {
    self = [super initWithDelegate:delegate];
  }
  if (self) {
    self.session = session;
    [session setDataReceiveHandler:self withContext:NULL];
  }
  return self;
}

-(void)dealloc;
{
  self.session = nil;
  [super dealloc];
}

-(NSString*)remoteIdPrefix;
{
  return self.session.peerID;
}

-(NSOutputStream*)outputStreamForMessage;
{
  NSOutputStream* outputStream = [NSOutputStream outputStreamToMemory];
  [outputStream open];
  return outputStream;
}

-(void)finishOutputStreamForMessage:(NSOutputStream*)outputStream;
{
  NSData* data = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
  [outputStream close];
  NSError* error = nil;
  if (![self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error]) {
    if (error != nil /* && [[error domain] isEqual:GKSessionErrorDomain] TODO: Fix linker error */) {
      [NSException raise:CWHessianChannelIOException format:@"GameKit error code:%d", [error code]];
      return;
    }
    [NSException raise:CWHessianChannelIOException format:@"Unknown error sending data on GameKit channel"];
  }
}

-(void)receiveData:(NSData*)data fromPeer:(NSString*)peer inSession:(GKSession*)session context:(void*)context;
{
  NSInputStream* inputStream = [NSInputStream inputStreamWithData:data];
  [inputStream open];
  [self.delegate channel:self didReceiveDataInInputStream:inputStream];
  [inputStream close];
}

@end
