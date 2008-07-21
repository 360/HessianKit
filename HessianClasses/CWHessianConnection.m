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
#import "CWDistantHessianObject+Private.h"

@implementation CWHessianConnection

@synthesize version = _version;

-(id)initWithHessianVersion:(CWHessianVersion)version;
{
	self = [super init];
  if (self) {
		self.version = version;
  }
  return self;
}

+(CWDistantHessianObject*)proxyWithURL:(NSURL*)url protocol:(Protocol*)aProtocol;
{
	CWDistantHessianObject* proxy = nil;
	CWHessianConnection* connection = [[CWHessianConnection alloc] initWithHessianVersion:CWHessianVersion1_00];
	if (connection) {
  	proxy = [connection proxyWithURL:url protocol:aProtocol];
    if (proxy) {
	    proxy.connection = connection;
    }
    [connection release];
  }
  return proxy;
}

-(CWDistantHessianObject*)proxyWithURL:(NSURL*)url protocol:(Protocol*)aProtocol;
{
	CWDistantHessianObject* proxy = [CWDistantHessianObject alloc];
  [proxy initWithConnection:self url:url protocol:aProtocol];
  return [proxy autorelease];
}

@end
