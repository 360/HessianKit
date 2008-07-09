//
//  CWHessianObject.m
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

#import "CWValueObject.h"
#import "CWValueObject+Private.h"
#import <objc/runtime.h>

@implementation CWValueObject

@synthesize protocol = _protocol;

- (void)dealloc
{
	[_instanceVariables release];
  _instanceVariables = nil;  
  [super dealloc];
}


+(CWValueObject*)valueObjectWithProtocol:(Protocol*)aProtocol;
{
	CWValueObject* valueObject = [[CWValueObject alloc] initWithProtocol:aProtocol];
	if (valueObject) {
	  return [valueObject autorelease];
  } else {
  	return nil;
  }
}

-(id)initWithProtocol:(Protocol*)aProtocol;
{
  Class aClass = [self classForProtocol:aProtocol];
	[self release];
  self = nil;
  if (aClass) {
	  self = objc_allocate_object(aClass, 0);
    self = [self init];
    self->_protocol = aProtocol;
    self->_instanceVariables = [[NSMutableDictionary alloc] init];
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)decoder;
{
	if (![decoder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Only KeyedCoding is supported"];
  }
  if (self) {
    NSArray* propertyNames = [self allPropertyNames];
    for (NSString* propertyName in propertyNames) {
    	id value = [decoder decodeObjectForKey:propertyName];
			[self setValue:value forKey:propertyName];
    }
	}
  return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder;
{
	if (![encoder allowsKeyedCoding]) {
		[NSException raise:NSInvalidArgumentException format:@"Only KeyedCoding is supported"];
  }
  NSArray* propertyNames = [self allPropertyNames];
  for (NSString* propertyName in propertyNames) {
  	id value = [self valueForKey:propertyName];
		[encoder encodeObject:value forKey:propertyName];
  }
}

-(NSString*)description;
{
	return [_instanceVariables description];
}

@end
