//
//  CWHessianValueObject+Private.m
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

#import "CWValueObject+Private.h"
#import <objc/runtime.h>

static NSMutableDictionary* _generatedClasses = nil;

static NSString* CWPropertyNameFromSelector(SEL aSelector) {
	NSString* propertyName = NSStringFromSelector(aSelector);
  if ([propertyName hasSuffix:@":"]) {
  	NSString* firstChar = [[propertyName substringWithRange:NSMakeRange(3, 1)] lowercaseString];
	  propertyName = [propertyName substringWithRange:NSMakeRange(4, [propertyName length] - 5)];
    propertyName = [firstChar stringByAppendingString:propertyName];
  }
  return propertyName;
}

static SEL CWSetterSelectorFromPropertyName(NSString* propertyName) {
	NSString* firstChar = [[propertyName substringToIndex:1] uppercaseString];
	NSString* restOfName = [propertyName substringFromIndex:1];
	propertyName = [NSString stringWithFormat:@"set%@%@:", firstChar, restOfName];
  return NSSelectorFromString(propertyName);
}

static BOOL CWAddProtocolImplementationsToClass(Class aClass, Protocol* aProtocol) {
	BOOL success = YES;
	unsigned int count = 0;
  objc_property_t* propertyList = protocol_copyPropertyList(aProtocol, &count);
	for (int index = 0; success && index < count; index++) {
  	objc_property_t property = propertyList[index];
		NSString* propertyName = [NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
		char type = property_getAttributes(property)[1];
    SEL getterSEL;
    SEL setterSEL;
		if (type == @encode(BOOL)[0]) {
    	getterSEL = @selector(priv_boolValue);
      setterSEL = @selector(priv_setBoolValue:);
    } else if (type == @encode(int32_t)[0]) {
    	getterSEL = @selector(priv_int32Value);
      setterSEL = @selector(priv_setInt32Value:);
    } else if (type == @encode(int64_t)[0]) {
    	getterSEL = @selector(priv_int64Value);
      setterSEL = @selector(priv_setInt64Value:);
    } else if (type == @encode(float)[0]) {
    	getterSEL = @selector(priv_floatValue);
      setterSEL = @selector(priv_setFloatValue:);
    } else if (type == @encode(double)[0]) {
    	getterSEL = @selector(priv_doubleValue);
      setterSEL = @selector(priv_setDoubleValue:);
    } else if (type == @encode(id)[0]) {
    	getterSEL = @selector(priv_objectValue);
			NSString* propertyAttrs = [NSString stringWithCString:property_getAttributes(property) encoding:NSASCIIStringEncoding];
      if ([propertyAttrs hasSuffix:@",C"]) {
	      setterSEL = @selector(priv_setObjectValueCopy:);
      } else {
	      setterSEL = @selector(priv_setObjectValue:);
      }
    } else {
    	success = NO;
    }
    if (success) {
    	IMP anIMP = [CWValueObject instanceMethodForSelector:getterSEL];
      const char* types = method_getTypeEncoding(class_getInstanceMethod([CWValueObject class], getterSEL));
	    class_addMethod(aClass, NSSelectorFromString(propertyName), anIMP, types);
    	anIMP = [CWValueObject instanceMethodForSelector:setterSEL];
      types = method_getTypeEncoding(class_getInstanceMethod([CWValueObject class], setterSEL));
  	  success = class_addMethod(aClass, CWSetterSelectorFromPropertyName(propertyName), anIMP, types);
    }
  }
  free(propertyList);
  if (success) {
	  Protocol** protocolList = protocol_copyProtocolList(aProtocol, &count);
  	for (int index = 0; index < count; index++) {
  		Protocol* aChildProtocol = protocolList[index];
    	success = CWAddProtocolImplementationsToClass(aClass, aChildProtocol);
    }
    free(protocolList);
  }
  return success;
}

static NSMutableArray* CWAllPropertyNamesForProtocol(Protocol* aProtocol) {
	NSMutableArray* names = [NSMutableArray array];
	unsigned int count = 0;
  objc_property_t* propertyList = protocol_copyPropertyList(aProtocol, &count);
	for (int index = 0; index < count; index++) {
  	objc_property_t property = propertyList[index];
		NSString* propertyName = [NSString stringWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
    [names addObject:propertyName];
	}
	free(propertyList);
  Protocol** protocolList = protocol_copyProtocolList(aProtocol, &count);
  for (int index = 0; index < count; index++) {
    Protocol* aChildProtocol = protocolList[index];
    [names addObjectsFromArray:CWAllPropertyNamesForProtocol(aChildProtocol)];
  }
  free(protocolList);
	return names;
}

@implementation CWValueObject (Private)

+(void)initialize;
{
	if (self == [CWValueObject class]) {
		_generatedClasses = [[NSMutableDictionary alloc] init]; 
  }
}

-(BOOL)priv_boolValue;
{
	NSNumber* value = [_instanceVariables objectForKey:CWPropertyNameFromSelector(_cmd)];
  if (value) {
  	return [value boolValue];
  } else {
  	return NO;
  }
}

-(void)priv_setBoolValue:(BOOL)value;
{
	[_instanceVariables setObject:[NSNumber numberWithBool:value] forKey:CWPropertyNameFromSelector(_cmd)];	
}

-(int32_t)priv_int32Value;
{
	NSNumber* value = [_instanceVariables objectForKey:CWPropertyNameFromSelector(_cmd)];
  if (value) {
  	return [value intValue];
  } else {
  	return 0;
  }
}

-(void)priv_setInt32Value:(int32_t)value;
{
	[_instanceVariables setObject:[NSNumber numberWithInt:value] forKey:CWPropertyNameFromSelector(_cmd)];	
}

-(int64_t)priv_int64Value;
{
	NSNumber* value = [_instanceVariables objectForKey:CWPropertyNameFromSelector(_cmd)];
  if (value) {
  	return [value longLongValue];
  } else {
  	return 0;
  }
}

-(void)priv_setInt64Value:(int64_t)value;
{
	[_instanceVariables setObject:[NSNumber numberWithLongLong:value] forKey:CWPropertyNameFromSelector(_cmd)];	
}

-(float)priv_floatValue;
{
	NSNumber* value = [_instanceVariables objectForKey:CWPropertyNameFromSelector(_cmd)];
  if (value) {
  	return [value floatValue];
  } else {
  	return 0.0f;
  }
}

-(void)priv_setFloatValue:(float)value;
{
	[_instanceVariables setObject:[NSNumber numberWithFloat:value] forKey:CWPropertyNameFromSelector(_cmd)];	
}

-(double)priv_doubleValue;
{
	NSNumber* value = [_instanceVariables objectForKey:CWPropertyNameFromSelector(_cmd)];
  if (value) {
  	return [value doubleValue];
  } else {
  	return 0.0;
  }
}

-(void)priv_setDoubleValue:(double)value;
{
	[_instanceVariables setObject:[NSNumber numberWithDouble:value] forKey:CWPropertyNameFromSelector(_cmd)];	
}

-(id)priv_objectValue;
{
	id value = [_instanceVariables objectForKey:CWPropertyNameFromSelector(_cmd)];
  if (value) {
		if ([value isKindOfClass:[NSNull class]]) {
    	value = nil;
    }
  }
  return value;
}

-(void)priv_setObjectValue:(id)object;
{
	if (!object) {
		object = [NSNull null];
  }
	[_instanceVariables setObject:object forKey:CWPropertyNameFromSelector(_cmd)];	
}

-(void)priv_setObjectValueCopy:(id)object;
{
	if (!object) {
		[_instanceVariables setObject:object forKey:CWPropertyNameFromSelector(_cmd)];	
  } else {
  	object = [object copy];
		[_instanceVariables setObject:object forKey:CWPropertyNameFromSelector(_cmd)];	
		[object release];
  }
}


-(NSArray*)allPropertyNames;
{
	return CWAllPropertyNamesForProtocol(_protocol);
}

-(Class)classForProtocol:(Protocol*)aProtocol;
{
	Class aClass = NSClassFromString([_generatedClasses objectForKey:NSStringFromProtocol(aProtocol)]);
  if (!aClass) {
  	NSString* className = NSStringFromClass([CWValueObject class]);
    NSString* protocolName = NSStringFromProtocol(aProtocol);
    NSString* newClassName = [NSString stringWithFormat:@"%@%@", className, protocolName];
    aClass = objc_allocateClassPair([CWValueObject class], [newClassName cStringUsingEncoding:NSASCIIStringEncoding], 0);
		if (aClass) {
    	if (CWAddProtocolImplementationsToClass(aClass, aProtocol) && class_addProtocol(aClass, aProtocol)) {
      	objc_registerClassPair(aClass);
        [_generatedClasses setObject:NSStringFromClass(aClass) forKey:NSStringFromProtocol(aProtocol)];
      } else {
      	objc_disposeClassPair(aClass);
        aClass = Nil;
      }
    }
  }
  return aClass;
}

@end
