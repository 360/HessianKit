//
//  CWHessianUnarchiver+Private.m
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

#import "CWHessianArchiver+Private.h"
#import "CWHessianTranslator.h"
#import "CWValueObject.h"
#import "CWDistantHessianObject.h"
#import <objc/runtime.h>


@implementation CWHessianUnarchiver (Private)

-(id)initWithDelegate:(id<CWHessianCoderDelegate>)delegate inputStream:(NSInputStream*)inputStream;
{
  self = [super initWithDelegate:delegate];
  if (self) {
    self.inputStream = inputStream;
  }
  return self;
}

-(Class)classForClassName:(NSString*)className;
{
  CWHessianTranslator* translator = self.delegate.translator;
  if (translator != nil) {
    return [translator classForDistantTypeName:className];
  }
  return NSClassFromString(className);
}

-(Protocol*)protocolForClassName:(NSString*)className;
{
  CWHessianTranslator* translator = self.delegate.translator;
  if (translator != nil) {
    return [translator protocolForDistantTypeName:className];
  }
  return NSProtocolFromString(className);
}

-(void)dealloc;
{
  self.inputStream = nil;
  [super dealloc];
}

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

-(void)readBytes:(void*)buffer count:(NSInteger)count;
{
  NSUInteger read = 0;
  if (hasPeekChar) {
    hasPeekChar = NO;
    read++;
    *(char*)buffer = peekChar;
  }
  while (read < count) {
    read = [self.inputStream read:buffer + read maxLength:count - read];
    if (read == -1) {
      [NSException raise:NSInternalInconsistencyException format:@"Coyuld not read from stream"];
      return;
    }
  }
}

-(char)peekChar;
{
  if (!hasPeekChar) {
    [self readBytes:&peekChar count:1];
    hasPeekChar = YES;
  }
  return peekChar;
}

-(char)readChar;
{
  char ch = '\0';
  [self readBytes:&ch count:1];
  return ch;
}

-(BOOL)readBool;
{
  char value = [self readChar];
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

-(uint16_t)readUInt16;
{
  int16_t value = 0;
  [self readBytes:&value count:2];
  return NSSwapBigShortToHost(value);
}

-(int32_t)readInt32;
{
  int32_t value = 0;
  [self readBytes:&value count:4];
  return NSSwapBigIntToHost(value);
}

-(int64_t)readInt64;
{
  int64_t value = 0;
  [self readBytes:&value count:8];
  return NSSwapBigLongLongToHost(value);
}

-(double)readDouble;
{
  int64_t int64tmp = [self readInt64];
  double doublev = 0.0;
  memcpy(&doublev, &int64tmp, sizeof(double));
  return doublev;
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
    int len = [self readUInt16];
    string = [NSMutableString stringWithCapacity:len];
    for (int index = 0; index < len; index++) {
      unichar ch = [self readChar];
      if (ch < 0x80) {
      } else if ((ch & 0xe0) == 0xc0) {
        unichar ch1 = [self readChar];
        ch = ((ch & 0x1f) << 6) + (ch1 & 0x3f);
      } else if ((ch & 0xf0) == 0xe0) {
        int ch1 = [self readChar];
        int ch2 = [self readChar];
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
    tag = [self readChar];
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
    int len = [self readUInt16];
    data = [NSMutableData dataWithLength:len];
    [self readBytes:[data mutableBytes] count:len];
  } else {
    [NSException raise:NSInvalidArchiveOperationException format:@"expected binary marker"];
  }
  if ('b' == tag) {
    tag = [self readChar];
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
  if ([self peekChar] == 't') {
    [self readChar];
    (void)[self readStringWithTag:'S'];
  }
  NSMutableArray* list = nil;
  int length = 8;
  if ([self peekChar] == 'l') {
  	(void)[self readChar];
    length = [self readInt32];
  }
  list =[NSMutableArray arrayWithCapacity:length];
  [self.objectReferences addObject:list];
  while ([self peekChar] != 'z') {
    NSObject* object = [self readTypedObject];
    if (!object) {
      object = [NSNull null];
    }
    [list addObject:object];
  }
  (void)[self readChar];
  return list;
}

-(id)readMapWithTypedObject:(id)typedObject;
{
  NSMutableDictionary* map = [NSMutableDictionary dictionary];
  if (typedObject) {
    [self.objectReferences addObject:typedObject];
  } else {
    [self.objectReferences addObject:map];
  }
  while ([self peekChar] != 'z') {
    NSObject* key = [self readTypedObject];
    NSObject* object = [self readTypedObject];
    if (!object) {
      object = [NSNull null];
    }
    [map setObject:object forKey:key];
  }
  (void)[self readChar];
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
  if ([self peekChar] == 't') {
    [self readChar];
    className = [self readStringWithTag:'S'];
    if ([className length] > 0) {
      Class typedClass = [self classForClassName:className];
      if (typedClass) {
        typedObject = class_createInstance(typedClass, 0);
        if (![typedClass conformsToProtocol:@protocol(NSCoding)]) {
          [NSException raise:NSInvalidUnarchiveOperationException format:@"%@ do not conform to NSCoding", className];
        }
      } else {
        Protocol* typedProtocol = [self protocolForClassName:className];
        if (typedProtocol) {
          typedObject = [CWValueObject valueObjectWithProtocol:typedProtocol];
        }     	
      }
    }
  }
  return [self readMapWithTypedObject:typedObject];
}

-(CWDistantHessianObject*)readRemote;
{
  if ([self readChar] != 't') {
  	[NSException raise:NSInvalidUnarchiveOperationException format:@"expected type token"];
  }
  NSString* className = [self readStringWithTag:'S'];
  Protocol* aProtocol = NSProtocolFromString(className);
  if (!aProtocol) {
  	aProtocol = [self protocolForClassName:className];
  }
  if (!aProtocol) {
  	[NSException raise:NSInvalidUnarchiveOperationException format:@"no proxy protocol for remote class %@", className];
  }
  NSString* remoteId = [self readTypedObject];
  if (!remoteId || ![remoteId isKindOfClass:[NSString class]]) {
  	[NSException raise:NSInvalidUnarchiveOperationException format:@"expected string"];
  }
  return [self.delegate coder:self didUnarchiveProxyWithRemoteId:remoteId protocol:aProtocol];
}

-(id)readTypedObject;
{
  char tag = [self readChar];
  switch (tag) {
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
#ifdef XML_AVAILABLE
      return [self readXMLWithTag:tag];
#endif
    case 's':
    case 'S':
      return [self readStringWithTag:tag];
    case 'b':
    case 'B':
      return [self readDataWithTag:tag];
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
      [NSException raise:NSInvalidUnarchiveOperationException format:@"%c is not a known marker", tag];
  }
  return nil;
}

-(id)readDecodeCandidateForKey:(NSString*)key ofClass:(Class)cls;
{
  if (self.currentObjectMap) {
  	return [self.currentObjectMap objectForKey:key];
  } else {
    /* TODO: Validate that this nver happens!
     int offset = self.offset;
     BOOL validKey = YES;
     if (key) {
     id possibleKey = [self readTypedObject];
     validKey = [possibleKey isKindOfClass:[NSString class]] && [(NSString*)possibleKey isEqualToString:key];
     }
     if (validKey) {
     id object = [self readTypedObject];
     if (cls) {
     if (![object isKindOfClass:cls]) {
     [NSException raise:NSInvalidUnarchiveOperationException format:@"encoutered invalid class, expected:%s got:%@", 
     class_getName(cls), NSStringFromClass([object class])];
     }
     }
     return object;
     } else {
     self.offset = offset;
     }
     */
    return nil;
  }
}

@end