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

-(void)testSanity;
{
	STAssertNoThrow([proxy methodNull], @"Sanity call to methodNull");  
}

/*
-(void)testGreeting;
{
  NSString* result = [proxy greeting];
	STAssertEqualObjects(result, @"Hello Hessian World", @"Greeting must return 'Hello Hessian World'.");
}

-(void)testPrimitives;
{
  id result = [proxy echo:[NSNumber numberWithBool:YES]];
	STAssertEqualObjects(result, [NSNumber numberWithBool:YES], @"Echo NSNumber with BOOL.");	

  result = [proxy echo:[NSNumber numberWithInt:INT32_MAX]];
  STAssertEqualObjects(result, [NSNumber numberWithInt:INT32_MAX], @"Echo NSNumber with INT32_MAX");

  result = [proxy echo:[NSNumber numberWithLongLong:INT64_MAX]];
	STAssertEqualObjects(result, [NSNumber numberWithLongLong:INT64_MAX], @"Echo NSNumber with INT64_MAX");  

  NSDate* refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0.0];
  result = [proxy echo:refDate];
	STAssertEqualObjects(result, refDate, @"Echo current time as NSDate");
}

-(void)testPublicTest;
{
	// Setup method mapping.
  [CWHessianArchiver setMethodName:@"subtract__2" forSelector:@selector(subtract:from:)];
    
  STAssertNoThrow([proxy nullCall], @"nullCall must not throw exception");

  STAssertTrue([[proxy hello] isKindOfClass:[NSString class]], @"hello return NSString");

  STAssertEquals([proxy subtract:44 from:2], 42, @"substract must handle 44-2=42");

  STAssertThrows([proxy fault], @"fault must throw exception.");
}

-(void)testList;
{

  NSArray* testArray = [NSArray arrayWithObjects:[NSNumber numberWithBool:YES], @"Hello", [NSNull null],
                          [NSArray arrayWithObjects:@"foo", @"bar", nil], [NSDate date], nil];
  id result = [proxy echo:testArray];
	STAssertTrue([testArray isEqualToArray:result], @"Array must be echoed.");
  
}

-(void)testMap;
{
  NSMutableDictionary* recursive = [NSMutableDictionary dictionary];
  [recursive setObject:recursive forKey:@"me"];
  id result = [proxy echo:recursive];
  STAssertEqualObjects([result objectForKey:@"me"], result, @"Recursive map must be echoed.");
}

-(void)testObject;
{
	// Setup mapping.
  [CWHessianArchiver setClassName:@"java.util.Hashtable" forProtocol:@protocol(ValueTest)];
  [CWHessianUnarchiver setProtocol:@protocol(ValueTest) forClassName:@"java.util.Hashtable"];
  id<ValueTest> bar = (id<ValueTest>)[CWValueObject valueObjectWithProtocol:@protocol(ValueTest)];
  bar.boolValue = YES;
  bar.intValue = 42;
  bar.stringValue = @"Hello";
  bar.numberValue = [NSNumber numberWithFloat:3.14f];
    
  id result = [proxy echo:bar];
  STAssertTrue([result conformsToProtocol:@protocol(ValueTest)], @"Result do not conform to ValueTest");

  STAssertEquals(bar.boolValue, YES, @"boolValue must match.");
  STAssertEquals(bar.intValue, 42, @"intValue must match.");
  STAssertEqualObjects(bar.stringValue, @"Hello", @"stringValue must match.");
  STAssertEqualObjects(bar.numberValue, [NSNumber numberWithFloat:3.14f], @"numberValue must match.");
  
}

*/

@end
