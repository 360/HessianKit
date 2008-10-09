//
//  CWHessianUnarchiver+Private.m
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

#import "CWHessianArchiver+Private.h"
#import "CWHessianConnection.h"
#import "CWValueObject.h"
#import <objc/runtime.h>


@implementation CWHessianUnarchiver (Private)

-(int)decodeIntForKey:(NSString*)key;
{
	if (sizeof(int) == sizeof(int32_t)) {
  	return [self decodeInt32ForKey:key];
  } else {
  	return [self decodeInt64ForKey:key];
  }
}

-(NSInteger)decodeIntegerForKey:(NSString*)key;
{
	if (sizeof(NSInteger) == sizeof(int32_t)) {
  	return [self decodeInt32ForKey:key];
  } else {
  	return [self decodeInt64ForKey:key];
  }
}

-(BOOL)readBool;
{
  char value = [self.inputStream readChar];
  switch (value) {
    case 'T':
      return YES;
    case 'F':
      return NO;
    default:
      [NSException raise:NSInvalidArchiveOperationException format:@"%c is not a valid bool value", value];
    return NO;
  }
}

-(int32_t)readInt32;
{
	return [self.inputStream readInt];
}

-(int64_t)readInt64;
{
	return [self.inputStream readLongLong];
}

-(double)readDouble;
{
	return [self.inputStream readDouble];
}

-(NSDate*)readDate;
{
  int64_t value = [self readInt64];
  return [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)value / 1000.0];
}

-(NSString*)readStringWithTag:(char)tag;
{
  NSMutableString* string = nil;
  if ('N' == tag) {
    return nil;
  } else if ('S' == toupper(tag) || 'X' == toupper(tag)) {
    int len = [self.inputStream readUnsignedShort];
    string = [NSMutableString stringWithCapacity:len];
    for (int index = 0; index < len; index++) {
      unichar ch = [self.inputStream readChar];
      if (ch < 0x80) {
			} else if ((ch & 0xe0) == 0xc0) {
				unichar ch1 = [self.inputStream readChar];
				ch = ((ch & 0x1f) << 6) + (ch1 & 0x3f);
			} else if ((ch & 0xf0) == 0xe0) {
				int ch1 = [self.inputStream readChar];
				int ch2 = [self.inputStream readChar];
				ch = ((ch & 0x0f) << 12) + ((ch1 & 0x3f) << 6)
						+ (ch2 & 0x3f);
			} else {
        [NSException raise:NSInvalidArchiveOperationException format:@"bad utf-8 encoding"];
      }
      [string appendString:[NSString stringWithCharacters:&ch length:1]];
    }
  } else {
    [NSException raise:NSInvalidArchiveOperationException format:@"expected string marker"];
  }
  if ('s' == tag || 'x' == tag) {
    tag = [self.inputStream readChar];
    NSString* nextStringChunk = [self readStringWithTag:tag];
    if (nextStringChunk) {
      [string appendString:nextStringChunk];
    } else {
      [NSException raise:NSInvalidArchiveOperationException format:@"expected next string marker"];
    }
  }
  
  return string;
}

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
-(NSXMLDocument*)readXMLWithTag:(char)tag;
{
  NSString* xmlString = [self readStringWithTag:tag];
  NSError* error = nil;
  NSXMLDocument* xmlDocument = [[NSXMLDocument alloc] initWithXMLString:xmlString options:NSXMLNodeOptionsNone error:&error]; 
  if (!xmlDocument) {
    if (error) {
      [NSException raise:NSInvalidArchiveOperationException format:@"XML parse error domain:%@ code:%d", [error domain], [error code]];
    } else {
      [NSException raise:NSInvalidUnarchiveOperationException format:@"Unknown error in XML stream"];
    }
  }
  return [xmlDocument autorelease];
}
#endif

-(NSData*)readDataWithTag:(char)tag;
{
  NSMutableData* data = nil;
  if ('N' == tag) {
    return nil;
  } else if ('B' == toupper(tag)) {
    int len = [self.inputStream readUnsignedShort];
    data = [NSMutableData dataWithCapacity:len];
    [self.inputStream read:[data mutableBytes] maxLength:len];
  } else {
    [NSException raise:NSInvalidArchiveOperationException format:@"expected binary marker"];
  }
  if ('b' == tag) {
    tag = [self.inputStream readChar];
    NSData* nextDataChunk = [self readDataWithTag:tag];
    if (nextDataChunk) {
      [data appendData:nextDataChunk];
    } else {
      [NSException raise:NSInvalidArchiveOperationException format:@"expected next binary marker"];
    }
  }
  return data;
}

-(NSException*)readFault;
{
  NSDictionary* faultMap = [self readMap];
  NSString* code = [faultMap objectForKey:@"code"];
  if ([code isEqualToString:@"ServiceException"]) {
    id detail = [faultMap objectForKey:@"detail"];
    if ([detail isKindOfClass:[NSException class]]) {
      return (NSException*)detail;
    }
  }
  return [NSException exceptionWithName:code reason:(NSString*)[faultMap objectForKey:@"message"] userInfo:faultMap];
}

-(NSArray*)readList;
{
	char aChar = [self.inputStream readChar];
  if (aChar == 't') {
    (void)[self readStringWithTag:'S'];
    aChar = [self.inputStream readChar];
  }
  NSMutableArray* list = nil;
  int length = 8;
  if (aChar == 'l') {
    length = [self readInt32];
    aChar = [self.inputStream readChar];
  }
  list = [NSMutableArray arrayWithCapacity:length];
  [self.objectReferences addObject:list];
  for ( ; aChar != 'z'; aChar = [self.inputStream readChar]) {
    NSObject* object = [self readTypedObjectWithInitialChar:aChar];
    if (!object) {
      object = [NSNull null];
    }
    [list addObject:object];
  }
  return list;
}

-(id)readMapWithInitialChar:(char)aChar typedObject:(id)typedObject;
{
  NSMutableDictionary* map = [NSMutableDictionary dictionary];
  if (typedObject) {
    [self.objectReferences addObject:typedObject];
  } else {
    [self.objectReferences addObject:map];
  }
  for (; aChar != 'z'; aChar = [self.inputStream readChar]) {
    NSObject* key = [self readTypedObjectWithInitialChar:aChar];
    aChar = [self.inputStream readChar];
    NSObject* object = [self readTypedObjectWithInitialChar:aChar];
    if (!object) {
      object = [NSNull null];
    }
    [map setObject:object forKey:key];
  }
  if (typedObject) {
    id previousObjectMap = self.currentObjectMap;
    self.currentObjectMap = map;
    typedObject = [typedObject initWithCoder:self];
    self.currentObjectMap = previousObjectMap;
    return typedObject;
  } else {
    return map;
  }
}

-(id)readMap;
{
  NSString* className = nil;
  id typedObject = nil;
  char aChar = [self.inputStream readChar];
  if (aChar == 't') {
    className = [self readStringWithTag:'S'];
    if ([className length] > 0) {
      Class typedClass = [CWHessianUnarchiver classForClassName:className];
      if (typedClass) {
        typedObject = class_createInstance(typedClass, 0);
        if (![typedClass conformsToProtocol:@protocol(NSCoding)]) {
          [NSException raise:NSInvalidUnarchiveOperationException format:@"%@ do not conform to NSCoding", className];
        }
      } else {
				Protocol* typedProtocol = [CWHessianUnarchiver protocolForClassName:className];
        if (typedProtocol) {
        	typedObject = [CWValueObject valueObjectWithProtocol:typedProtocol];
        }     	
      }
    }
    aChar = [self.inputStream readChar];
  }
  return [self readMapWithInitialChar:aChar typedObject:typedObject];
}

-(CWDistantHessianObject*)readRemote;
{
	char aChar = [self.inputStream readChar];
	if (aChar != 't') {
  	[NSException raise:NSInvalidUnarchiveOperationException format:@"expected type token"];
  }
	NSString* className = [self readStringWithTag:'S'];
  Protocol* aProtocol = NSProtocolFromString(className);
  if (!aProtocol) {
  	aProtocol = [CWHessianUnarchiver protocolForClassName:className];
  }
  if (!aProtocol) {
  	[NSException raise:NSInvalidUnarchiveOperationException format:@"no proxy protocol for remote clas %@", className];
  }
  aChar = [self.inputStream readChar];
  NSString* URLString = [self readTypedObjectWithInitialChar:aChar];
  if (!URLString || ![URLString isKindOfClass:[NSString class]]) {
  	[NSException raise:NSInvalidUnarchiveOperationException format:@"expected string"];
  }
	return [self.connection proxyWithURL:[NSURL URLWithString:URLString] protocol:aProtocol];
}

-(id)readTypedObjectWithInitialChar:(char)aChar;
{
  switch (aChar) {
    case 'N':
      return nil;
    case 'T':
      return [NSNumber numberWithBool:YES];
    case 'F':
      return [NSNumber numberWithBool:NO];
    case 'I':
      return [NSNumber numberWithInt:[self readInt32]];
    case 'L':
      return [NSNumber numberWithLongLong:[self readInt64]];
    case 'D':
			return [NSNumber numberWithDouble:[self readDouble]];
    case 'd':
      return [self readDate];
    case 'x':
    case 'X':
#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
			return [self readXMLWithTag:tag];
#endif
    case 's':
    case 'S':
      return [self readStringWithTag:aChar];
    case 'b':
    case 'B':
      return [self readDataWithTag:aChar];
    case 'V':
      return [self readList];
    case 'M':
      return [self readMap];
    case 'R':
    {
      int refIndex = [self readInt32];
      return [self.objectReferences objectAtIndex:refIndex];
    }
    case 'r':
			return [self readRemote];
    case 'f':
    	return [self readFault];
    default:
      [NSException raise:NSInvalidUnarchiveOperationException format:@"%c is not a known marker", aChar];
  }
  return nil;
}

-(id)readDecodeCandidateForKey:(NSString*)key ofClass:(Class)cls;
{
  if (self.currentObjectMap) {
  	return [self.currentObjectMap objectForKey:key];
  } else {
    BOOL validKey = YES;
    if (key) {
	    id possibleKey = [self readTypedObjectWithInitialChar:[self.inputStream readChar]];
      validKey = [possibleKey isKindOfClass:[NSString class]] && [(NSString*)possibleKey isEqualToString:key];
    }
    if (validKey) {
      id object = [self readTypedObjectWithInitialChar:[self.inputStream readChar]];
      if (cls) {
        if (![object isKindOfClass:cls]) {
          [NSException raise:NSInvalidUnarchiveOperationException format:@"encoutered invalid class, expected:%s got:%@", 
              class_getName(cls), [NSString stringWithCString:class_getName([object class])]];
        }
      }
      return object;
    }
    return nil;
  }
}

@end