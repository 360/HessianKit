//
//  CWHessianArchiver.m
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

@implementation CWHessianArchiver

@synthesize outputStream = _outputStream;

-(void)encodeBool:(BOOL)boolv forKey:(NSString*)key;
{
  if (key) [self writeTypedObject:key];
  [self writeBool:boolv];
}

-(void)encodeInt32:(int32_t)intv forKey:(NSString*)key;
{
  if (key) [self writeTypedObject:key];
  [self writeChar:'I'];
  [self writeInt32:intv];
}

-(void)encodeInt64:(int64_t)intv forKey:(NSString*)key;
{
  if (key) [self writeTypedObject:key];
  [self writeChar:'L'];
  [self writeInt64:intv];
}

-(void)encodeFloat:(float)realv forKey:(NSString*)key;
{
  [self encodeDouble:realv forKey:key];
}

-(void)encodeDouble:(double)realv forKey:(NSString*)key;
{
  if (key) [self writeTypedObject:key];
  [self writeChar:'D'];
  [self writeInt64:(int64_t)(*((double*)(&realv)))];
}

-(void)encodeObject:(id)objv forKey:(NSString*)key;
{
  if (key) [self writeTypedObject:key];
  [self writeTypedObject:objv];
}

-(void)encodeBytes:(const uint8_t*)bytesp length:(NSUInteger)lenv forKey:(NSString*)key;
{
  if (key) [self writeTypedObject:key];
  NSData* data = [NSData dataWithBytes:bytesp length:lenv];
  [self writeTypedObject:data];
}

@end
