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

#import "CWHessianCoder.h"
#import "CWHessianChannel.h"
#import "CWHessianHTTPChannel.h"
#import "CWHessianConnection+Private.h"
#import "CWHessianArchiver.h"
#import "CWDistantHessianObject.h"


NSString* const CWHessianTimeoutException = @"CWHessianTimeoutException";
NSString* const CWHessianObjectNotAvailableException = @"CWHessianObjectNotAvailableException";
NSString* const CWHessianObjectNotVendableException = @"CWHessianObjectNotVendableException";
NSString* const CWHessianChannelIOException = @"CWHessianChannelIOException";


@implementation CWHessianConnection

@synthesize channel = _channel;
@synthesize version = _version;
@dynamic rootObject;
@synthesize requestTimeout = _requestTimeout;
@synthesize replyTimeout = _replyTimeout;


-(void)dealloc;
{
  self.channel = nil;
  [pendingResponses release];
  [localObjects release];
  [remoteProxies release];
  [lock release];
  [super dealloc];
}

-(id)initWithChannel:(CWHessianChannel*)channel;
{
  self = [self init];
  if (self) {
    _channel = [channel retain];
    localObjects = [NSMutableDictionary new];
    remoteProxies = [NSMutableDictionary new];
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

-(id<CWHessianRemoting>)rootObject;
{
  return [localObjects objectForKey:[self.channel remoteIdPrefix]];
}

-(void)setRemoteObject:(id<CWHessianRemoting>)rootObject;
{
  if (![self.channel canVendObjects]) {
    [NSException raise:CWHessianObjectNotVendableException
                format:@"Can not vend remote objects over %@ channel", NSStringFromClass([self.channel class])];
  }
  [localObjects setObject:rootObject forKey:[self.channel remoteIdPrefix]];
}

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

-(void)channel:(CWHessianChannel*)channel didReceiveDataInInputStream:(NSInputStream*)inputStream;
{
  id returnValue = [self unarchiveDataFromInputStream:inputStream];
  if (returnValue == nil) {
    returnValue = [NSNull null];
  }
  // TODO: this should be read fromt he headers. 
  NSNumber* messageNumber = [self lastMessageNumber];
  [lock lock];
  NSRunLoop* runloop = [pendingResponses objectForKey:messageNumber];
  [lock unlock];
  NSLog(@"Schedule handleReturnValue:%@", [returnValue description]);
  [runloop performSelector:@selector(handleReturnValue:) 
                    target:self 
                  argument:[NSArray arrayWithObjects:returnValue, messageNumber, nil] 
                     order:0 
                     modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
}

-(NSString*)coder:(CWHessianCoder*)coder willArchiveObjectAsProxy:(id)anObject protocol:(Protocol*)aProtocol;
{
  return [self.channel remoteIdForObject:anObject];
}

-(CWDistantHessianObject*)coder:(CWHessianCoder*)coder didUnarchiveProxyWithRemoteId:(NSString*)remoteId protocol:(Protocol*)aProtocol;
{
  return [CWDistantHessianObject proxyWithConnection:self
                                            remoteId:remoteId 
                                            protocol:aProtocol]; 
}

@end
