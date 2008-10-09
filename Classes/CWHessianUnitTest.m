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

#import "ValueTest.h"

@implementation CWHessianUnitTest

-(BOOL)setupAsBonjourService;
{
	Test* rootObject = [[Test alloc] init];
  _currentConnection = [[CWHessianConnection alloc] initWithHessianVersion:CWHessianVersion1_00];
  BOOL retVal = [_currentConnection registerServiceWithRootObject:rootObject inDomain:nil applicationProtocol:@"Test" name:@"Test"];
	[rootObject release];
  return retVal;
}

-(BOOL)testAllWithWebService;
{
  NSURL* URL = [NSURL URLWithString:@"http://localhost:8080/HessianTest/TestHessian"];
  CWHessianConnection* connection = [[CWHessianConnection alloc] initWithHessianVersion:CWHessianVersion1_00];
  CWDistantHessianObject<Test>* proxy = (CWDistantHessianObject<Test>*)[connection proxyWithURL:URL protocol:@protocol(Test)];
  [connection release];
  [proxy retain];
	return [self testAllWithProxy:proxy];
}

-(BOOL)testAllWithBonjourService;
{
	_currentConnection = [[CWHessianConnection alloc] initWithHessianVersion:CWHessianVersion1_00];
  _currentConnection.serviceSearchDelegate = self;
  return [_currentConnection searchForServicesInDomain:nil applicationProtocol:@"Test"];
}

-(void)hessianConnection:(CWHessianConnection*)connection didFindService:(NSNetService*)service moreComing:(BOOL)moreServicesComing;
{
	CWDistantHessianObject<Test>* proxy = [connection proxyWithNetService:service protocol:@protocol(Test)];
  [connection release];
  [proxy retain];
	[self performSelectorInBackground:@selector(testAllWithProxy:) withObject:proxy];
}

-(void)hessianConnection:(CWHessianConnection*)connection didRemoveService:(NSNetService*)service moreComing:(BOOL)moreServicesComing;
{
}

-(BOOL)testAllWithProxy:(CWDistantHessianObject<Test>*)proxy;
{
	while (![proxy isReady]) {
  	[NSThread sleepForTimeInterval:1.0];
  }
	BOOL success = YES;
	success &= [self testPrimitivesWithProxy:proxy];
	success &= [self testPublicTestWithProxy:proxy];
	success &= [self testListWithProxy:proxy];
	success &= [self testMapWithProxy:proxy];
	success &= [self testObjectWithProxy:proxy];
  [proxy release];
  return success;
}

-(BOOL)testPrimitivesWithProxy:(CWDistantHessianObject<Test>*)proxy;
{
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

-(BOOL)testPublicTestWithProxy:(CWDistantHessianObject<Test>*)proxy;
{
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

    int theAnswer = [proxy subtract:2 from:44];
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

-(BOOL)testListWithProxy:(CWDistantHessianObject<Test>*)proxy;
{
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

-(BOOL)testMapWithProxy:(CWDistantHessianObject<Test>*)proxy;
{
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

-(BOOL)testObjectWithProxy:(CWDistantHessianObject<Test>*)proxy;
{
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
