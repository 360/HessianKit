//
//  Test.m
//  HessianKit
//
//  Copyright 2009 Fredrik Olsson, Cocoway. All rights reserved.
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

#import "Test.h"


@implementation Test

-(Protocol*)remoteProtocol;
{
  return @protocol(Test);
}

-(void)methodNull;
{
  // No-op
}
-(void)argNull:(id)v;
{
  NSAssert(v == nil, @"Argument must be nil");
}
-(id)replyNull;
{
  return nil;
}

-(void)argFalse:(BOOL)v;
{
  NSAssert(v == NO, @"Argument must be NO");
}
-(void)argTrue:(BOOL)v;
{
  NSAssert(v == YES, @"Argument must be YES");
}
-(BOOL)replyFalse;
{
  return NO;
}
-(BOOL)replyTrue;
{
  return YES;
}

-(void)argInt_0:(int32_t)v;
{
  NSAssert(v == 0, @"Argument must be 0");
}
-(void)argInt_m17:(int32_t)v;
{
  NSAssert(v == -17, @"Argument must be -17");
}
-(void)argInt_0x7fffffff:(int32_t)v;
{
  NSAssert(v == 0x7fffffff, @"Argument must be 0x7fffffff");
}
-(void)argInt_m0x80000000:(int32_t)v;
{
  NSAssert(v == -0x80000000, @"Argument must be -0x80000000");
}
-(int32_t)replyInt_0;
{
  return 0;
}
-(int32_t)replyInt_m17;
{
  return -17;
}
-(int32_t)replyInt_0x7fffffff;
{
  return 0x7fffffff;
}
-(int32_t)replyInt_m0x80000000;
{
  return -0x80000000;
}

-(void)argLong_0:(int64_t)v;
{
  NSAssert(v == 0, @"Argument must be 0");
}
-(void)argLong_m0x80000000:(int64_t)v;
{
  NSAssert(v == -0x80000000LL, @"Argument must be (int64_t)-0x80000000");
}
-(void)argLong_0x7fffffff:(int64_t)v;
{
  NSAssert(v == 0x7fffffffLL, @"Argument must be (int64_t)0x7fffffff");
}
-(void)argLong_0x80000000:(int64_t)v;
{
  NSAssert(v == 0x80000000LL, @"Argument must be (int64_t)0x80000000");
}
-(int64_t)replyLong_0;
{
  return 0LL;
}
-(int64_t)replyLong_m0x80000000;
{
  return -0x80000000LL;
}
-(int64_t)replyLong_0x7fffffff;
{
  return 0x7fffffffLL;
}
-(int64_t)replyLong_0x80000000;
{
  return 0x80000000LL;
}

-(void)argDouble_0_0:(double)v;
{
  NSAssert(v == 0.0, @"Argument must be 0.0");
}
-(void)argDouble_0_001:(double)v;
{
  NSAssert(v == 0.001, @"Argument must be 0.001");
}
-(void)argDouble_3_14159:(double)v;
{
  NSAssert(v == 3.15159, @"Argument must be 3.14159");
}
-(void)argDouble_m0_001:(double)v;
{
  NSAssert(v == -0.001, @"Argument must be -0.001");
}
-(double)replyDouble_0_0;
{
  return 0.0;
}
-(double)replyDouble_0_001;
{
  return 0.001;
}
-(double)replyDouble_3_14159;
{
  return 3.14159;
}
-(double)replyDouble_m0_001;
{
  return -0.001;  
}

-(void)argString_0:(NSString*)v;
{
  NSAssert([v isKindOfClass:[NSString class]] && [v length] == 0, @"Argument must be a NSString with length 0");
}
-(void)argString_1:(NSString*)v;
{
  NSAssert([v isKindOfClass:[NSString class]] && [v length] == 1, @"Argument must be a NSString with length 1");
}
-(void)argString_31:(NSString*)v;
{
  NSAssert([v isKindOfClass:[NSString class]] && [v length] == 31, @"Argument must be a NSString with length 31");
}
-(NSString*)replyString_0;
{
  return @"";
}
-(NSString*)replyString_1;
{
  return @"A";
}
-(NSString*)replyString_31;
{
  return @"abcdefghijklmnopqrstuvwxyz12345";
}

-(void)argBinary_0:(NSData*)v;
{
  NSAssert([v isKindOfClass:[NSData class]] && [v length] == 0, @"Argument must be a NSData with length 0");
}
-(void)argBinary_15:(NSData*)v;
{
  NSAssert([v isKindOfClass:[NSData class]] && [v length] == 15, @"Argument must be a NSData with length 15");
}
-(void)argBinary_65536:(NSData*)v;
{
  NSAssert([v isKindOfClass:[NSData class]] && [v length] == 65536, @"Argument must be a NSData with length 65536");
}
-(NSData*)replyBinary_0;
{
  return [NSData data];
}
-(NSData*)replyBinary_15;
{
  return [NSData dataWithBytes:(void*)"abcdefghijklmno" length:15];
}
-(NSData*)replyBinary_65536;
{
  return [NSData dataWithBytesNoCopy:malloc(65536) length:65536]; 
}

-(void)argDate_0:(NSDate*)v;
{
  NSAssert([v isEqualToDate:[NSDate dateWithTimeIntervalSince1970:0.0]], @"Argument must be NSData 1970-01-01 00:00");
}
-(void)argDate_1:(NSDate*)v;
{
  // NOt yet tested for.
}
-(NSDate*)replyDate_0;
{
  return [NSDate dateWithTimeIntervalSince1970:0.0];
}
-(NSDate*)replyDate_1;
{
  return nil; // TODO: Implement this.
}

-(void)argUntypedFixedList_0:(NSArray*)v;
{
  NSAssert([v isKindOfClass:[NSArray class]] && [v count] == 0, @"Argument must be a NSArray with length 0");
}
-(void)argUntypedFixedList_7:(NSArray*)v;
{
  NSAssert([v isKindOfClass:[NSArray class]] && [v count] == 7, @"Argument must be a NSArray with length 7");
}
-(NSArray*)replyUntypedFixedList_0;
{
  return [NSArray array];
}
-(NSArray*)replyUntypedFixedList_7;
{
  return [NSArray arrayWithObjects:[NSNull null], [NSNumber numberWithBool:YES], @"2", [NSArray arrayWithObject:@"3"], @"4", [NSNumber numberWithInt:5], @"6", nil];
}

-(void)argUntypedMap_0:(NSDictionary*)v;
{
  NSAssert([v isKindOfClass:[NSDictionary class]] && [v count] == 0, @"Argument must be a NSDictionary with length 0");
}
-(void)argUntypedMap_2:(NSDictionary*)v;
{
  NSAssert([v isKindOfClass:[NSDictionary class]] && [v count] == 2, @"Argument must be a NSDictionary with length 2");
}
-(NSDictionary*)replyUntypedMap_0;
{
  return [NSDictionary dictionary];
}
-(NSDictionary*)replyUntypedMap_2;
{
  NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:@"first" forKey:[NSArray arrayWithObject:[NSNumber numberWithInt:1]]];
  [dict setObject:dict forKey:@"second"];
  return dict;
}

@end
