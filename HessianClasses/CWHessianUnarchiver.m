//
//  CWHessianUnarchiver.m
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

#import "CWHessianArchiver.h"
#import "CWHessianArchiver+Private.h"

static NSMutableDictionary* _classTranslations = nil;
static NSMutableDictionary* _protocolTranslations = nil;

@interface CWHessianUnarchiver ()
@end

@implementation CWHessianUnarchiver

@synthesize inputStream = _inputStream;
@synthesize currentObjectMap = _currentObjectMap;

+(void)initialize;
{
	if (self == [CWHessianUnarchiver class]) {
  	_classTranslations = [[NSMutableDictionary alloc] init];
  	_protocolTranslations = [[NSMutableDictionary alloc] init];
  }
}

-(void)dealloc;
{
	self.currentObjectMap = nil;
  [super dealloc];
}

+(void)setClass:(Class)aClass forClassName:(NSString*)className;
{
	[_classTranslations setObject:NSStringFromClass(aClass) forKey:className];
}

+(void)setProtocol:(Protocol*)aProtocol forClassName:(NSString*)className;
{
	[_protocolTranslations setObject:NSStringFromProtocol(aProtocol) forKey:className];
}

+(Class)classForClassName:(NSString*)className;
{
	Class aClass = NSClassFromString([_protocolTranslations objectForKey:className]);
  if (!aClass) {
  	NSInteger location = [className rangeOfString:@"." options:NSBackwardsSearch].location;
    if (NSNotFound != location) {
    	className = [className substringFromIndex:location + 1];
      aClass = NSClassFromString([_protocolTranslations objectForKey:className]);
    }
  }
	return aClass; 
}

+(Protocol*)protocolForClassName:(NSString*)className;
{
	Protocol* aProtocol = NSProtocolFromString([_protocolTranslations objectForKey:className]);
  if (!aProtocol) {
  	NSInteger location = [className rangeOfString:@"." options:NSBackwardsSearch].location;
    if (NSNotFound != location) {
    	className = [className substringFromIndex:location + 1];
      aProtocol = NSProtocolFromString([_protocolTranslations objectForKey:className]);
    }
  }
	return aProtocol; 
}

-(BOOL)containsValueForKey:(NSString*)key;
{
	if (self.currentObjectMap) {
		id object = [self.currentObjectMap objectForKey:key];
		return object != nil;
  } else {
	  return NO;
  }
}

-(BOOL)decodeBoolForKey:(NSString*)key;
{
	NSNumber* object = (NSNumber*)[self readDecodeCandidateForKey:key ofClass:[NSNumber class]];
	if (object) {
    return [object boolValue];
  } else {
  	return NO;
  }
}

-(int32_t)decodeInt32ForKey:(NSString*)key;
{
	NSNumber* object = (NSNumber*)[self readDecodeCandidateForKey:key ofClass:[NSNumber class]];
	if (object) {
    return [object intValue];
  } else {
  	return 0;
  }
}

-(int64_t)decodeInt64ForKey:(NSString*)key;
{
	NSNumber* object = (NSNumber*)[self readDecodeCandidateForKey:key ofClass:[NSNumber class]];
	if (object) {
    return [object longLongValue];
  } else {
  	return 0;
  }
}

-(float)decodeFloatForKey:(NSString*)key;
{
	return (float)[self decodeDoubleForKey:key];
}

-(double)decodeDoubleForKey:(NSString*)key;
{
	NSNumber* object = (NSNumber*)[self readDecodeCandidateForKey:key ofClass:[NSNumber class]];
	if (object) {
    return [object doubleValue];
  } else {
  	return 0.0;
  }
}

-(id)decodeObjectForKey:(NSString*)key;
{
	id object = [self readDecodeCandidateForKey:key ofClass:Nil];
	if ([object isKindOfClass:[NSNull class]]) {
  	return nil;
  } else {
  	return object;
	}
}

-(const uint8_t*)decodeBytesForKey:(NSString*)key returnedLength:(NSUInteger*)lengthp;
{
	NSData* object = (NSData*)[self readDecodeCandidateForKey:key ofClass:[NSData class]];
	if (object) {
		*lengthp = [(NSData*)object length];
    return [object bytes];
  } else {
  	return NULL;
  }
}

@end
