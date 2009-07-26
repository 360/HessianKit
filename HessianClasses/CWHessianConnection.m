//
//  CWHessianConnection.m
//  HessianKit
//
//  Copyright 2008-2009 Fredrik Olsson, Cocoway. All rights reserved.
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

#import <Foundation/Foundation.h>

#import "CWHessianConnection+Private.h"
#import "CWDistantHessianObject.h"


NSString* const CWHessianTimeoutException = @"CWHessianTimeoutException";
NSString* const CWHessianObjectNotAvailableException = @"CWHessianObjectNotAvailableException";
NSString* const CWHessianObjectNotVendableException = @"CWHessianObjectNotVendableException";


@implementation CWHessianConnection

@synthesize channel = _channel;
@synthesize version = _version;
@synthesize requestTimeout = _requestTimeout;
@synthesize replyTimeout = _replyTimeout;


-(void)dealloc;
{
  [_channel release];
  [responseMap release];
  [lock release];
  [super dealloc];
}

-(id)initWithServiceURL:(NSURL*)URL;
{
  if (URL == nil) {
    [self release];
    [NSException raise:NSInvalidArgumentException format:@"Service URL must not be nil"];
    self = nil;
  } else {
    self = [self init];
  } 
  if (self) {
    _channel = [[CWHessianHTTPChannel alloc] initWithConnection:self serviceURL:URL];
    if (_channel == nil) {
      [self release];
      [NSException raise:NSInvalidArgumentException format:@"Could not create HTTP Channel"];
      self = nil;
    }
  }
  return self;
}


-(id)initWithReceiveStream:(NSInputStream*)receiveStream sendStream:(NSOutputStream*)sendStream;
{
  if (receiveStream == nil || sendStream == nil) {
    [self release];
    [NSException raise:NSInvalidArgumentException format:@"Receieve and send streams must not be nil"];
    self = nil;
  } else {
    self = [self init];
  } 
  if (self) {
    NSAssert(NO, @"TODO: Create a Stream Channel");
  }
  return self;
}


#ifdef GAMEKIT_AVAILABLE
-(id)initWithGameKitSession:(GKSession*)session;
{
  if (session == nil) {
    [self release];
    [NSException raise:NSInvalidArgumentException format:@"GameKit session must not be nil"];
    self = nil;
  } else {
    self = [self init];
  }
  if (self) {
    NSAssert(NO, @"TODO: Create a GameKit Channel");
  } 
  return self;
}
#endif

+(CWDistantHessianObject*)rootProxyWithServiceURL:(NSURL*)URL protocol:(Protocol*)aProtocol;
{
	CWDistantHessianObject* proxy = nil;
  CWHessianConnection* connection = [[CWHessianConnection alloc] initWithServiceURL:URL];
  if (connection) {
  	proxy = [connection rootProxyWithProtocol:aProtocol];
    [connection release];
  }
  return proxy;
}

-(CWDistantHessianObject*)rootProxyWithProtocol:(Protocol*)aProtocol;
{
  CWDistantHessianObject* proxy = [[CWDistantHessianObject alloc] 
                                   initWithConnection:self remoteId:nil protocol:aProtocol];
  return [proxy autorelease];
}

@end
