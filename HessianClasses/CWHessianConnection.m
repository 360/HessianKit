//
//  CWHessianConnection.m
//  HessianKit
//
//  Copyright 2008 Fredrik Olsson, Cocoway. All rights reserved.
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

#import "CWHessianConnection.h"
#import "CWDistantHessianObject.h"


NSString* const CWHessianTimeoutException = @"CWHessianTimeoutException";


@implementation CWHessianConnection

@synthesize version = _version;
@synthesize requestTimeout = _requestTimeout;
@synthesize replyTimeout = _replyTimeout;
@synthesize serviceURL = _serviceURL;
@synthesize receiveStream = _receiveStream;
@synthesize sendStream = _sendStream;
#ifdef GAMEKIT_AVAILABLE
@synthesize gameKitSession = _gameKitSession;
#endif

-(CWHessianChannel)channel;
{
  if (_serviceURL != nil) {
    return CWHessianChannelHTTP;
  }
  if (_receiveStream != nil && _sendStream != nil) {
    return CWHessianChannelStream;
  }
#ifdef GAMEKIT_AVAILABLE
  if (_gameKitSession != nil) {
    return CWHessianChannelGameKit;
  }
#endif
  [NSException raise:NSInternalInconsistencyException format:@"Unknown communication channel."];
  return -1;
}


-(void)dealloc;
{
  [_serviceURL release];
  [_receiveStream release];
  [_sendStream release];
#ifdef GAMEKIT_AVAILABLE
  [_gameKitSession release];
#endif
  [responseMap dealloc];
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
    _serviceURL = [URL copy];
  }
  return self;
}

/*
-(id)initWithReceivePort:(NSPort*)receivePort sendPort:(NSPort*)sendPort;
{
  if (receivePort == nil || sendPort == nil) {
    [self release];
    [NSException raise:NSInvalidArgumentException format:@"Receieve and send ports must not be nil"];
    self = nil;
  } else {
    self = [self init];
  } 
  if (self) {
    _receivePort = [receivePort retain];
    _sendPort = [sendPort retain];
  }
  return self;
}
*/

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
    _gameKitSession = [session retain];
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
