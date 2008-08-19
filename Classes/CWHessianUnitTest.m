//
//  CWHessianUnitTest.m
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

#import "CWHessianUnitTest.h"

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
#import <HessianKit/HessianKit.h>
#else
#import "HessianKit.h"
#endif

#import "Test.h"
#import "ValueTest.h"

@implementation CWHessianUnitTest

-(NSProxy<Test>*)testProxy;
{
  CWHessianConnection* connection = [[[CWHessianConnection alloc] initWithHessianVersion:CWHessianVersion1_00] autorelease];
  NSURL* URL = [NSURL URLWithString:@"http://hessian.caucho.com/test/test"];
  NSProxy<Test>* proxy = (NSProxy<Test>*)[connection proxyWithURL:URL protocol:@protocol(Test)];
  [connection release];
  return proxy;  
}

-(BOOL)testAll;
{
	BOOL success = YES;
	success &= [self testPrimitives];
	success &= [self testPublicTest];
	success &= [self testList];
	success &= [self testMap];
	success &= [self testObject];
  return success;
}

-(BOOL)testPrimitives;
{
  id<Test> proxy = [self testProxy];
	@try {
    id result = [proxy echo:[NSNumber numberWithBool:YES]];
    if (!result || ![result isKindOfClass:[NSNumber class]] || ![result boolValue]) {
      NSLog(@"Failed, expected YES got %@", [result description]);
      return NO;
    } else {
    	NSLog(@"Passed, primitive boolean");
    }
    result = [proxy echo:[NSNumber numberWithInt:INT32_MAX]];
    if (!result || ![result isKindOfClass:[NSNumber class]] || INT32_MAX != [result intValue]) {
      NSLog(@"Failed, expected %d got %@", INT32_MAX, [result description]);
      return NO;
    } else {
    	NSLog(@"Passed, primitive int");
    }
    result = [proxy echo:[NSNumber numberWithLongLong:INT64_MAX]];
    if (!result || ![result isKindOfClass:[NSNumber class]] || INT64_MAX != [result longLongValue]) {
      NSLog(@"Failed, expected %l got %@", INT64_MAX, [result description]);
      return NO;
    } else {
    	NSLog(@"Passed, primitive long");
    }
    NSDate* refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0.0];
    result = [proxy echo:refDate];
    if (!result || ![result isKindOfClass:[NSDate class]] || ![refDate isEqualToDate:result]) {
      NSLog(@"Failed, expected %@ got %@", refDate, [result description]);
      return NO;
    } else {
    	NSLog(@"Passed, primitive date");
    }
  }
  @catch (NSException * e) {
  	NSLog(@"Failed with Exception name: %@ reason: %@", [e name], [e reason]);
	  return NO;	
  }
  return YES;
}

-(BOOL)testPublicTest;
{
  id<Test> proxy = [self testProxy];
	@try {
    [CWHessianArchiver setMethodName:@"subtract__2" forSelector:@selector(subtract:from:)];

    [proxy nullCall];
    NSLog(@"Passed, void nullCall()");
    
    NSString* hello = [proxy hello];
    if (!hello || ![hello isKindOfClass:[NSString class]]) {
    	NSLog(@"Failed hello() result: %@", hello);
			return NO;
    } else {
    	NSLog(@"Passed, String hello()");
    }

    int theAnswer = [proxy subtract:44 from:2];
		if (theAnswer != 42) {
    	NSLog(@"Failed subtract() result: %d", theAnswer);
      return NO;
    } else {
    	NSLog(@"Passed, int subtract(int, int)");
    }

		@try {
	    [proxy fault];
			return NO;
		}
    @catch (NSException * e) {
    	NSLog(@"Passed, void fault() throws Exception");
    }
  }
  @catch (NSException * e) {
  	NSLog(@"Failed with Exception name: %@ reason: %@", [e name], [e reason]);
	  return NO;	
  }
  return YES;
}

-(BOOL)testList;
{
  id<Test> proxy = [self testProxy];
	@try {
  	NSArray* testArray = [NSArray arrayWithObjects:[NSNumber numberWithBool:YES], @"Hello", [NSNull null],
    	[NSArray arrayWithObjects:@"foo", @"bar", nil], [NSDate date], nil];
    id result = [proxy echo:testArray];
    if (![[testArray description] isEqualToString:[result description]]) {
    	NSLog(@"Failed, expected %@ got %@", [testArray description], [result description]);
      return NO;
    } else {
    	NSLog(@"Passed, complex list");
    }
  }
  @catch (NSException * e) {
  	NSLog(@"Failed with Exception name: %@ reason: %@", [e name], [e reason]);
	  return NO;	
  }
  return YES;
}

-(BOOL)testMap;
{
  id<Test> proxy = [self testProxy];
	@try {
    NSMutableDictionary* recursive = [NSMutableDictionary dictionary];
    [recursive setObject:recursive forKey:@"me"];
    id result = [proxy echo:recursive];
		if ([result objectForKey:@"me"] != result) {
			NSLog(@"Failed, did not recieve a recursive map");
			return NO;
    } else {
    	NSLog(@"Passed, complex map");
    }
  }
  @catch (NSException * e) {
  	NSLog(@"Failed with Exception name: %@ reason: %@", [e name], [e reason]);
	  return NO;	
  }
  return YES;
}

-(BOOL)testObject;
{
  id<Test> proxy = [self testProxy];
	@try {
    [CWHessianArchiver setClassName:@"java.util.Hashtable" forProtocol:@protocol(ValueTest)];
    [CWHessianUnarchiver setProtocol:@protocol(ValueTest) forClassName:@"java.util.Hashtable"];
    NSProxy<ValueTest>* bar = (NSProxy<ValueTest>*)[CWValueObject valueObjectWithProtocol:@protocol(ValueTest)];
    bar.boolValue = YES;
    bar.intValue = 42;
    bar.stringValue = @"Hello";
    bar.numberValue = [NSNumber numberWithFloat:3.14f];
    
    id result = [proxy echo:bar];
    if (![result conformsToProtocol:@protocol(ValueTest)]) {
			NSLog(@"Failed result: %@", [result description]);
      return NO;
    } else {
    	NSLog(@"Passed, custom value object");
    }
  }
  @catch (NSException * e) {
  	NSLog(@"Failed with Exception name: %@ reason: %@", [e name], [e reason]);
	  return NO;	
  }
  return YES;
}

@end
