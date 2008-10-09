//
//  CWHessianConnection.m
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

#import <Foundation/Foundation.h>

#import "CWHessianConnection.h"
#import "CWHessianConnection+Private.h"
#import "CWDistantHessianObject+Private.h"
#import "CWHessianBonjourServer.h"
#import "NSArray+CWAdditions.h"


@implementation CWHessianConnection

@synthesize version = _version;
//@dynamic vendedServicesObjects;
@synthesize serviceSearchDelegate = _searchDelegate;

-(NSArray*)vendedServicesObjects;
{
	if (_registeredServices == nil) {
		return [NSArray array];
  } else {
		return [_registeredServices arrayWithReturnValuesForMakeObjectPerformSelector:@selector(vendedObject)];
  }
}

-(id)initWithHessianVersion:(CWHessianVersion)version;
{
	self = [super init];
  if (self) {
		self.version = version;
  }
  return self;
}

-(void)dealloc;
{
	if (_registeredServices) {
		[_registeredServices release];
  }
	self.netServiceBrowser = nil;
  self.currentResolve = nil;
  [super dealloc];
}

+(CWDistantHessianObject*)proxyWithURL:(NSURL*)URL protocol:(Protocol*)aProtocol;
{
	CWDistantHessianObject* proxy = nil;
	CWHessianConnection* connection = [[CWHessianConnection alloc] initWithHessianVersion:CWHessianVersion1_00];
	if (connection) {
  	proxy = [connection proxyWithURL:URL protocol:aProtocol];
    if (proxy) {
	    proxy.connection = connection;
    }
    [connection release];
  }
  return proxy;
}

-(CWDistantHessianObject*)proxyWithURL:(NSURL*)URL protocol:(Protocol*)aProtocol;
{
	CWDistantHessianObject* proxy = [CWDistantHessianObject alloc];
  [proxy initWithConnection:self URL:URL protocol:aProtocol];
  return [proxy autorelease];
}

-(BOOL)registerServiceWithRootObject:(id<NSObject>)anObject inDomain:(NSString*)domain applicationProtocol:(NSString*)protocol name:(NSString*)name;
{
	BOOL success = NO;
	CWHessianBonjourServer* bonjourServer = [[CWHessianBonjourServer alloc] init];
  if (bonjourServer != nil) {
    bonjourServer.delegate = self;
    bonjourServer.vendedObject = anObject;
    if ([bonjourServer startAndReturnError:NULL]) {
      if ([bonjourServer enableBonjourWithDomain:domain applicationProtocol:protocol name:name]) {
        if (_registeredServices == nil) {
          _registeredServices = [[NSMutableArray alloc] init];
        }
        [_registeredServices addObject:bonjourServer];
        success = YES;
      }
    }
    [bonjourServer release];
	}
	return success;
}

-(BOOL)searchForServicesInDomain:(NSString*)domain applicationProtocol:(NSString*)protocol;
{
	self.currentResolve = nil;
	self.netServiceBrowser = nil;
  NSNetServiceBrowser* netServiceBrowser = [[NSNetServiceBrowser alloc] init];
	if (netServiceBrowser) {
	  netServiceBrowser.delegate = self;
    if (domain == nil) {
    	domain = @"";
    }
  	[netServiceBrowser searchForServicesOfType:[CWHessianBonjourServer bonjourTypeFromApplicationProtocol:protocol] inDomain:domain];
		self.netServiceBrowser = netServiceBrowser;
    [netServiceBrowser release];
		return YES;
  }
  return NO;
}

-(void)stopSearchForServices;
{
	self.netServiceBrowser = nil;
}

+(CWDistantHessianObject*)proxyWithNetService:(NSNetService*)service  protocol:(Protocol*)aProtocol;
{
	CWDistantHessianObject* proxy = nil;
	CWHessianConnection* connection = [[CWHessianConnection alloc] initWithHessianVersion:CWHessianVersion1_00];
	if (connection) {
  	proxy = [connection proxyWithNetService:service protocol:aProtocol];
    if (proxy) {
	    proxy.connection = connection;
    }
    [connection release];
  }
  return proxy;
}

-(CWDistantHessianObject*)proxyWithNetService:(NSNetService*)service  protocol:(Protocol*)aProtocol;
{
	CWDistantHessianObject* proxy = [CWDistantHessianObject alloc];
  [proxy initWithConnection:self netService:service protocol:aProtocol];
  return [proxy autorelease];
}

@end
