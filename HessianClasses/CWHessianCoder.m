//
//  CWHessianCoder.m
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

#import "CWHessianCoder.h"
#include <objc/runtime.h>

@interface CWHessianCoder ()
@property(retain, nonatomic) CWHessianConnection* connection;
@property(retain, nonatomic) NSMutableData* archiveData;
@property(retain, nonatomic) NSMutableArray* objectReferences;
@end

@implementation CWHessianCoder

@synthesize connection = _connection;
@synthesize archiveData = _archiveData;
@synthesize objectReferences = _objectReferences;

-(void)dealloc;
{
	self.connection = nil;
  self.archiveData = nil;
  self.objectReferences = nil;
  [super dealloc];
}

-(id)initWithConnection:(CWHessianConnection*)connection mutableData:(NSMutableData*)data;
{
  self = [super init];
  if (self) {
  	self.connection = connection;
    self.archiveData = data;
    self.objectReferences = [NSMutableArray array];
  }
  return self;
}


-(BOOL)allowsKeyedCoding;
{
	return YES;
}

-(NSInteger)versionForClassName:(NSString*)className;
{
	return 1;
}

@end


@implementation CWHessianCoder (Unsupported)

-(void)encodeValueOfObjCType:(const char*)valueType at:(const void*)address;
{
	[self doesNotRecognizeSelector:_cmd];
}

-(void)encodeDataObject:(NSData*)data;
{
	[self doesNotRecognizeSelector:_cmd];
}

-(void)decodeValueOfObjCType:(const char*)valueType at:(void*)data;
{
	[self doesNotRecognizeSelector:_cmd];
}

-(NSData*)decodeDataObject;
{
	[self doesNotRecognizeSelector:_cmd];
  return nil;
}

@end
