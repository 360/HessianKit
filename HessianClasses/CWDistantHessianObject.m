//
//  CWDistantHessianObject.m
//  HessianKit
//
//  Copyright 2008 Fredrik Olsson, Jayway AB. All rights reserved.
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

#import "CWDistantHessianObject.h"
#import "CWDistantHessianObject+Private.h"
#import "CWHessianConnection.h"
#import "CWHessianArchiver.h"
#import "CWHessianArchiver+Private.h"
#import <objc/runtime.h>

static NSMethodSignature* getMethodSignatureRecursively(Protocol *p, SEL aSel)
{
	NSMethodSignature* methodSignature = nil;
	struct objc_method_description md = protocol_getMethodDescription(p, aSel, YES, YES);
  if (md.name == NULL) {
  	unsigned int count = 0;
  	Protocol **pList = protocol_copyProtocolList(p, &count);
    for (int index = 0; !methodSignature && index < 0; index++) {
    	methodSignature = getMethodSignatureRecursively(pList[index], aSel);
    }
    free(pList);
  } else {
  	methodSignature = [NSMethodSignature signatureWithObjCTypes:md.types];
  }
  return methodSignature;
}

@interface CWDistantHessianObject ()
@property(retain, nonatomic) NSURL* URL;
@property(assign, nonatomic) Protocol* protocol;
@property(retain, nonatomic) NSMutableDictionary* methodSignatures;
@end

@implementation CWDistantHessianObject

@synthesize connection = _connection;
@synthesize URL = _URL;
@synthesize netService = _netService;
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize protocol = _protocol;
@synthesize methodSignatures = _methodSignatures;

-(void)dealloc;
{
	self.connection = nil;
  self.URL = nil;
  self.protocol = nil;
  self.methodSignatures = nil;
  [super dealloc];
}

-(id)initWithConnection:(CWHessianConnection*)connection URL:(NSURL*)URL protocol:(Protocol*)aProtocol;
{
  self.connection = connection;
  self.URL = URL;
	self.protocol = aProtocol;
  self.methodSignatures = [NSMutableDictionary dictionary];
  return self;
}

-(id)initWithConnection:(CWHessianConnection*)connection netService:(NSNetService*)service protocol:(Protocol*)aProtocol;
{
	self.connection = connection;
  self.netService = service;
  self.protocol = aProtocol;
  self.methodSignatures = [NSMutableDictionary dictionary];
  [service setDelegate:self];
  [service resolveWithTimeout:30.0];
  return self;
}

-(BOOL)isReady;
{
	return (self.URL != nil || (self.outputStream != nil && self.inputStream != nil));
}

-(BOOL)conformsToProtocol:(Protocol*)aProtocol;
{
	if (self.protocol == aProtocol) {
  	return YES;
  } else {
  	return [super conformsToProtocol:aProtocol];
  }
}

-(BOOL)isKindOfClass:(Class)aClass;
{
	if (aClass == [self class] || aClass == [NSProxy class]) {
  	return YES;
  }
  return NO;
}

-(BOOL)respondsToSelector:(SEL)aSelector;
{
	if ([self methodSignatureForSelector:aSelector] != nil) {
  	return YES;
  }
  if (aSelector == @selector(netServiceDidResolveAddress:)) {
  	return YES;
  }
  return [NSObject instancesRespondToSelector:aSelector];
}

-(NSString*)remoteClassName;
{
	NSString* protocolName = [CWHessianArchiver classNameForProtocol:self.protocol];
  if (!protocolName) {
  	protocolName = NSStringFromProtocol(self.protocol);
  }
  return protocolName;
}

-(void)forwardInvocation:(NSInvocation *)invocation;
{
	id returnValue = nil;
	if (_URL != nil) {
		NSOutputStream* outStream = [NSOutputStream outputStreamToMemory];
  	[outStream open];
    [self archiveHessianInvocation:invocation toStream:outStream];
    [outStream close];
    NSData* requestData = [outStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
#if DEBUG
    NSLog([requestData description]);
#endif
    NSData* responseData = [self sendRequestWithPostData:requestData];
#if DEBUG
    NSLog([responseData description]);
#endif
    NSInputStream* inStream = [NSInputStream inputStreamWithData:responseData];
	  [inStream open];
  	returnValue = [self unarchiveResponeFromStream:inStream];
  	[inStream close];
  } else {
  	[self archiveHessianInvocation:invocation toStream:self.outputStream];
    returnValue = [self unarchiveResponeFromStream:self.inputStream];
  }
  if (returnValue) {
    if ([returnValue isKindOfClass:[NSException class]]) {
      [(NSException*)returnValue raise];
      return;  
    }
  }
  [self setReturnValue:returnValue invocation:invocation];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;
{
	if (aSelector != _cmd && ![NSStringFromSelector(aSelector) hasPrefix:@"_cf"]) {
    NSNumber* selectorKey = [NSNumber numberWithInteger:(NSInteger)aSelector];
    NSMethodSignature* signature = [self.methodSignatures objectForKey:selectorKey];
    if (!signature) {
      signature = getMethodSignatureRecursively(self.protocol, aSelector);
      if (signature) {
        [self.methodSignatures setObject:signature forKey:selectorKey];
      }
    }
    return signature;
  } else {
  	return nil;
  }
}

-(void)netServiceDidResolveAddress:(NSNetService *)service;
{
	if (![service getInputStream:&_inputStream outputStream:&_outputStream]) {
		NSLog(@"Error getting streams from service.");
  }
}

@end
