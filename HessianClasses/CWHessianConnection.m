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
  self.channel = nil;
  [responseMap release];
  [lock release];
  [super dealloc];
}

-(id)initWithChannel:(CWHessianChannel*)channel;
{
  self = [self init];
  if (self) {
    _channel = [channel retain];
  }
  return self;
}

-(id)initWithServiceURL:(NSURL*)URL;
{
  return [self initWithChannel:[[[CWHessianHTTPChannel alloc] initWithDelegate:self serviceURL:URL] autorelease]];
}

-(id)initWithReceiveStream:(NSInputStream*)receiveStream sendStream:(NSOutputStream*)sendStream;
{
  [self release];
  self = nil;
  NSAssert(NO, @"TODO: Create a Stream Channel");
  return self;
}


#ifdef GAMEKIT_AVAILABLE
-(id)initWithGameKitSession:(GKSession*)session;
{
  [self release];
  self = nil;
  NSAssert(NO, @"TODO: Create a Stream Channel");
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

-(void)channel:(CWHessianChannel*)channel didRecieveMessageInInputStream:(NSInputStream*)inputStream;
{
  id returnValue = [self unarchiveDataFromInputStream:inputStream];
  if (returnValue == nil) {
    returnValue = [NSNull null];
  }
  // TODO: this should be read fromt he headers. 
  NSNumber* messageNumber = [self lastMessageNumber];
  [lock lock];
  NSRunLoop* runloop = [responseMap objectForKey:messageNumber];
  [lock unlock];
  NSLog(@"Schedule handleReturnValue:%@", [returnValue description]);
  [runloop performSelector:@selector(handleReturnValue:) 
                    target:self 
                  argument:[NSArray arrayWithObjects:returnValue, messageNumber, nil] 
                     order:0 
                     modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
}

-(CWDistantHessianObject*)coder:(CWHessianCoder*)coder didUnarchiveProxyWithRemoteId:(NSString*)remoteId protocol:(Protocol*)aProtocol;
{
  return [CWDistantHessianObject proxyWithConnection:self
                                            remoteId:remoteId 
                                            protocol:aProtocol]; 
}

@end
