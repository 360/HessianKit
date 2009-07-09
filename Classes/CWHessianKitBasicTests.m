//
//  CWHessianKitBasicTests.m
//  HessianKit
//
//  Copyright 2008 Fredrik Olsson, Cocoway. All rights reserved.
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

#import "CWHessianKitBasicTests.h"
#import "HessianKit.h"
#import "ValueTest.h"

#import "CWDistantHessianObject+Private.h"

@implementation CWHessianKitBasicTests

-(void)setUp;
{
  CWHessianConnection* connection = [[CWHessianConnection alloc] initWithHessianVersion:CWHessianVersion1_00];
  NSURL* URL = [NSURL URLWithString:@"http://hessian.caucho.com/test/test"];
  proxy = [[connection proxyWithURL:URL protocol:@protocol(Test)] retain];
  [connection release];
}

-(void)tearDown;
{
  [proxy release]; 
}


-(void)testNull;
{
  STAssertNoThrow([proxy methodNull], @"Call method with no arguments and no return value");  
  STAssertThrows([proxy methodDoesNotExist], @"Call method that do not exists."); 
  STAssertNoThrow([proxy argNull:nil], @"Call method with null argument and");
}

-(void)testBool;
{
  STAssertNoThrow([proxy argFalse:NO], @"Call method with FALSE argument");
  STAssertNoThrow([proxy argTrue:YES], @"Call method with TRUE argument");
  STAssertFalse([proxy replyFalse], @"Call method with FALSE reply");
  STAssertTrue([proxy replyTrue], @"Call method with TRUE reply");
}

-(void)testInt;
{
  STAssertNoThrow([proxy argInt_0:0], @"Call method with (int32_t)0 argument.");
  STAssertNoThrow([proxy argInt_m17:-17], @"Call method with (int32_t)-17 argument.");
  STAssertNoThrow([proxy argInt_0x7fffffff:0x7fffffff], @"Call method with (int32_t)0x7fffffff argument.");
  STAssertNoThrow([proxy argInt_m0x80000000:-0x80000000], @"Call method with (int32_t)-0x80000000 argument.");
  STAssertEquals([proxy replyInt_0], (int32_t)0, @"Call method with (int32_t)0 reply.");
  STAssertEquals([proxy replyInt_m17], -(int32_t)17, @"Call method with (int32_t)-17 reply.");
  STAssertEquals([proxy replyInt_0x7fffffff], (int32_t)0x7fffffff, @"Call method with (int32_t)0x7fffffff reply.");
  STAssertEquals([proxy replyInt_m0x80000000], (int32_t)-0x80000000, @"Call method with (int32_t)-0x80000000 reply.");
}

-(void)testLong;
{
  STAssertNoThrow([proxy argLong_0:0L], @"Call method with (int64_t)0 argument.");
  STAssertNoThrow([proxy argLong_0x7fffffff:0x7fffffffL], @"Call method with (int64_t)0x7fffffff argument.");
  STAssertNoThrow([proxy argLong_0x80000000:0x80000000L], @"Call method with (int64_t)0x80000000 argument.");
  STAssertNoThrow([proxy argLong_m0x80000000:-0x80000000L], @"Call method with (int64_t)-0x80000000 argument.");
  STAssertEquals([proxy replyLong_0], (int64_t)0L, @"Call method with (int64_t)0 reply.");
  STAssertEquals([proxy replyLong_0x7fffffff], (int64_t)0x7fffffffL, @"Call method with (int64_t)0x7fffffff reply.");
  STAssertEquals([proxy replyLong_0x80000000], (int64_t)0x80000000L, @"Call method with (int64_t)0x80000000 reply.");
  STAssertEquals([proxy replyLong_m0x80000000], (int64_t)-0x80000000L, @"Call method with (int64_t)-0x80000000 reply.");
}

-(void)testDouble;
{
  STAssertNoThrow([proxy argDouble_0_0:0.0], @"Call with (double)0.0 argument.");  
  STAssertNoThrow([proxy argDouble_0_001:0.001], @"Call with (double)0.001 argument.");  
  STAssertNoThrow([proxy argDouble_3_14159:3.14159], @"Call with (double)3.14159 argument.");  
  STAssertNoThrow([proxy argDouble_m0_001:-0.001], @"Call with (double)-0.001 argument.");  
  STAssertEquals([proxy replyDouble_0_0], 0.0, @"Call with (double)0.0 reply.");  
  STAssertEquals([proxy replyDouble_0_001], 0.001, @"Call with (double)0.001 reply.");  
  STAssertEquals([proxy replyDouble_3_14159], 3.14159, @"Call with (double)3.14159 reply.");  
  STAssertEquals([proxy replyDouble_m0_001], -0.001, @"Call with (double)-0.001 reply.");  
}

-(void)testString;
{
  STAssertNoThrow([proxy argString_0:@""], @"Call with string '' argument.");
  STAssertNoThrow([proxy argString_1:@"A"], @"Call with string 'A' argument.");
  STAssertNoThrow([proxy argString_31:@"123456789012345678901234567890A"], @"Call with string <31 char string> argument.");
  STAssertEquals([[proxy replyString_0] length], (NSUInteger)0, @"Call with string '' reply.");
  STAssertEquals([[proxy replyString_1] length], (NSUInteger)1, @"Call with string <1 char string> reply.");
  STAssertEquals([[proxy replyString_31] length], (NSUInteger)31, @"Call with string <31 char string> reply.");
}

-(void)testBinary;
{
  STAssertNoThrow([proxy argBinary_0:[NSData data]], @"Call with zero length data argument.");
  STAssertNoThrow([proxy argBinary_15:[NSData dataWithBytes:(void*)"abcdefghijklmno" length:15]], @"Call with 15 bytes of binary data argument.");
  STAssertEquals([[proxy replyBinary_0] length], (NSUInteger)0, @"Call with zero length data reply.");  
  STAssertEquals([[proxy replyBinary_15] length], (NSUInteger)15, @"Call with 15 bytes of binary data reply.");
}

-(void)testDate;
{
  NSDate* date = [NSDate dateWithTimeIntervalSince1970:0.0];
  STAssertNoThrow([proxy argDate_0:date], @"Call with date 1970-01-01 00:00 argument.");
  STAssertTrue([date isEqualToDate:[proxy replyDate_0]], @"Call with date 1970-01-01 00:00 reply.");
  // TODO: Alseo test for date_1 1998-05-08 07:51
}

-(void)testList;
{
  STAssertNoThrow([proxy argUntypedFixedList_0:[NSArray array]], @"Call with zero length array argument.");
  NSArray* array = [NSArray arrayWithObjects:@"A", @"B", [NSNumber numberWithInt:42], @"C", @"D", [NSNull null], @"E", nil];
  STAssertNoThrow([proxy argUntypedFixedList_7:array], @"Call with array of 7 elements argument.");
  STAssertEquals([[proxy replyUntypedFixedList_0] count], (NSUInteger)0, @"Call with zero length array reply.");
  STAssertEquals([[proxy replyUntypedFixedList_7] count], (NSUInteger)7, @"Call with array of 7 elements reply.");
}

-(void)testMap;
{
  STAssertNoThrow([proxy argUntypedMap_0:[NSDictionary dictionary]], @"Call with empty map argument.");
  NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"first", [NSNumber numberWithFloat:3.14f], @"second", [NSNull null], nil];
  STAssertNoThrow([proxy argUntypedMap_2:dict], @"Call with map of two key value pairs argument.");
  STAssertEquals([[proxy replyUntypedMap_0] count], (NSUInteger)0, @"Call with empty map reply.");
  STAssertEquals([[proxy replyUntypedMap_2] count], (NSUInteger)2, @"Call with map of two key value pairs reply.");
}

@end
