//
//  CWHessianArchiver+Private.m
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
#import "CWDistantHessianObject.h"
#import "CWHessianTranslator.h"
#import "CWValueObject.h"
#import "HessianKitTypes.h" 
#import <objc/runtime.h>

@implementation CWHessianArchiver (Private)

-(id)initWithDelegate:(id<CWHessianCoderDelegate>)delegate outputStream:(NSOutputStream*)outputStream;
{
  self = [super initWithDelegate:delegate];
  if (self) {
    self.outputStream = outputStream;
  }
  return self;
}

-(void)dealloc;
{
  self.outputStream = nil;
  [super dealloc];
}

-(NSString*)classNameForClass:(Class)aClass;
{
  CWHessianTranslator* translator = self.delegate.translator;
  if (translator != nil) {
    return [translator distantTypeNameForClass:aClass];
  }
  return NSStringFromClass(aClass);
}

-(NSString*)classNameForProtocol:(Protocol*)aProtocol;
{
  CWHessianTranslator* translator = self.delegate.translator;
  if (translator != nil) {
    return [translator distantTypeNameForProtocol:aProtocol];
  }
  return NSStringFromProtocol(aProtocol);
}

-(void)encodeInt:(int)intv forKey:(NSString*)key;
{
  if (sizeof(int) == sizeof(int32_t)) {
  	[self encodeInt32:intv forKey:key];
  } else {
  	[self encodeInt64:intv forKey:key];
  }
}

-(void)encodeInteger:(NSInteger)intv forKey:(NSString*)key;
{
  if (sizeof(NSInteger) == sizeof(int32_t)) {
  	[self encodeInt32:intv forKey:key];
  } else {
  	[self encodeInt64:intv forKey:key];
  }
}

-(void)writeBytes:(const void*)buffer count:(NSInteger)count;
{
  NSInteger written = 0;
  while (written < count) {
    written = [self.outputStream write:buffer + written maxLength:count - written];
    if (written == -1) {
      [NSException raise:NSInternalInconsistencyException format:@"Could not write to stream"];
      return;
    }
  }
}

-(void)writeChar:(char)ch;
{
  [self writeBytes:&ch count:1];
}

-(void)writeBool:(BOOL)value;
{
  [self writeChar:(value ? 'T' : 'F')];
}

-(void)writeUInt16:(uint16_t)value;
{
  value = NSSwapHostShortToBig(value);
  [self writeBytes:&value count:2];
}

-(void)writeInt32:(int32_t)value;
{
  value = NSSwapHostIntToBig(value);
  [self writeBytes:&value count:4];
}

-(void)writeInt64:(int64_t)value;
{
  value = NSSwapHostLongLongToBig(value);
  [self writeBytes:&value count:8];
}

-(void)writeDouble:(double)value;
{
  int64_t int64v = 0;
  memcpy(&int64v, &value, sizeof(double));
  [self writeInt64:int64v];
}

-(void)writeDate:(NSDate*)date;
{
  int64_t value = (int64_t)([date timeIntervalSince1970] * 1000);
  [self writeInt64:value];
}

-(void)writeString:(NSString*)string withTag:(char)tag;
{
  NSData* bytes = nil;
  NSString* stringChunk = string;
  if ('s' == tag || 'x' == tag) {
    stringChunk = [string substringToIndex:MAX_CHUNK_SIZE + 1];
  }
  bytes = [stringChunk dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
  [self writeUInt16:[stringChunk length]];
  [self writeBytes:[bytes bytes] count:[bytes length]];
  if ('s' == tag || 'x' == tag) {
    string = [string substringFromIndex:MAX_CHUNK_SIZE + 1];
    if ('s' == tag) {
      tag = ([string length] > MAX_CHUNK_SIZE ? 's' : 'S');
    } else {
      tag = ([string length] > MAX_CHUNK_SIZE ? 'x' : 'X');
    }
    [self writeChar:tag];
    [self writeString:string withTag:tag];
  }
}

-(void)writeData:(NSData*)data withTag:(char)tag;
{
  NSData* dataChunk = data;
  if ('b' == tag) {
    dataChunk = [data subdataWithRange:NSMakeRange(0, MAX_CHUNK_SIZE)];
  }
  [self writeUInt16:[dataChunk length]];
  [self writeBytes:[dataChunk bytes] count:[dataChunk length]];
  if ('b' == tag) {
    data = [data subdataWithRange:NSMakeRange(MAX_CHUNK_SIZE, [data length] - MAX_CHUNK_SIZE)];
    tag = ([data length] > MAX_CHUNK_SIZE ? 'b' : 'B');
    [self writeChar:tag];
    [self writeData:data withTag:tag];
  }
}

-(void)writeList:(NSArray*)list;
{
  [self writeChar:'l'];
  [self writeInt32:[list count]];
  for (id object in list) {
    [self writeTypedObject:object];
  }
  [self writeChar:'z'];
}

-(void)writeMap:(NSDictionary*)map;
{
  for (id key in map) {
  	[self writeTypedObject:key];
    [self writeTypedObject:[map objectForKey:key]];
  }
  [self writeChar:'z'];
}

-(void)writeTypedObject:(id)object;
{
  if (object == nil || [object isKindOfClass:[NSNull class]]) {
  	[self writeChar:'N'];
    return;
  }
  NSUInteger index = [self.objectReferences indexOfObject:object];
  if (index != NSNotFound) {
    [self writeChar:'R'];
    [self writeInt32:index];
  } else if ([object isKindOfClass:[NSNumber class]]) {
  	NSNumber* number = (NSNumber*)object;
    if (strcmp([number objCType], @encode(BOOL)) == 0) {
      [self writeChar:[number boolValue] ? 'T' : 'F'];
    } else if (strcmp([number objCType], @encode(int32_t)) == 0) {
      [self writeChar:'I'];
      [self writeInt32:[number intValue]];
    } else if (strcmp([number objCType], @encode(int64_t)) == 0) {
      [self writeChar:'L'];
      [self writeInt64:[number longLongValue]];
    } else {
      [self writeChar:'D'];
      double realv = [number doubleValue];
      [self writeDouble:realv];
    }
  } else if ([object isKindOfClass:[NSDate class]]) {
    [self writeChar:'d'];
    [self writeDate:(NSDate*)object];
  } else if ([object isKindOfClass:[NSString class]]) {
  	char tag = ([(NSString*)object length] > MAX_CHUNK_SIZE ? 's' : 'S');
    [self writeChar:tag];
    [self writeString:(NSString*)object withTag:tag];
#ifdef XML_AVAILABLE
  } else if ([object isKindOfClass:[NSXMLNode class]]) {
  	NSString* xmlString = [(NSXMLNode*)object XMLStringWithOptions:NSXMLNodeOptionsNone];
  	char tag = ([xmlString length] > MAX_CHUNK_SIZE ? 'x' : 'X');
    [self writeChar:tag];
    [self writeString:xmlString withTag:tag];
#endif
  } else if ([object isKindOfClass:[NSData class]]) {
  	char tag = ([object length] > MAX_CHUNK_SIZE ? 'b' : 'B');
    [self writeChar:tag];
    [self writeData:object withTag:tag];
  } else if ([object isKindOfClass:[NSArray class]]) {
  	[self.objectReferences addObject:object];
  	[self writeChar:'V'];
    [self writeList:(NSArray*)object];
  } else if ([object isKindOfClass:[NSDictionary class]]) {
  	[self.objectReferences addObject:object];
  	[self writeChar:'M'];
    [self writeMap:(NSDictionary*)object];
  } else if ([object isKindOfClass:[CWDistantHessianObject class]]) {
    [self writeChar:'r'];
    [self writeChar:'t'];
    [self writeString:[((CWDistantHessianObject*)object) remoteClassName] withTag:'S'];
    [self writeChar:'S'];
    [self writeString:((CWDistantHessianObject*)object).remoteId withTag:'S'];
  } else if ([object conformsToProtocol:@protocol(CWHessianRemoting)]) {
    Protocol* aProtocol = [(id<CWHessianRemoting>)object remoteProtocol];
    NSString* protocolName = [self classNameForProtocol:aProtocol];
    if (protocolName == nil) {
      protocolName = NSStringFromProtocol(aProtocol);
    }
    NSString* remoteId = [self.delegate coder:self willArchiveObjectAsProxy:object protocol:aProtocol];
    [self writeChar:'r'];
    [self writeChar:'t'];
    [self writeString:protocolName withTag:'S'];
    [self writeChar:'S'];
    [self writeString:remoteId withTag:'S'];
  } else if ([object conformsToProtocol:@protocol(NSCoding)]) {
  	[self.objectReferences addObject:object];
    NSString* className = [self classNameForClass:[object class]];
    if (!className && [object isKindOfClass:[CWValueObject class]]) {
      className = [self classNameForProtocol:((CWValueObject*)object).protocol];
    }
    if (!className) {
      className = NSStringFromClass([object class]);
    }
    [self writeChar:'M'];
    [self writeChar:'t'];
    [self writeString:className withTag:'S'];
    [object encodeWithCoder:self];
    [self writeChar:'z'];
  } else {
  	NSString* className = NSStringFromClass([object class]);
  	[NSException raise:NSInvalidArchiveOperationException 
                format:@"%@ do not conform to NSCoding or CWHessianRemoting", className];
  }
}

@end
