//
//  HessianTestAppDelegate.m
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

#import "HessianTestAppDelegate.h"

#import "CWHessian.h"
#import "Test.h"
#import "ValueTest.h"

@implementation HessianTestAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	@try {

    [CWHessianArchiver setMethodName:@"subtract__2" forSelector:@selector(subtract:from:)];
    CWHessianConnection* connection = [[CWHessianConnection alloc] initWithHessianVersion:CWHessianVersion1_00];
    NSURL* url = [NSURL URLWithString:@"http://hessian.caucho.com/test/test"];
    id<Test> proxy = (id<Test>)[connection proxyWithURL:url protocol:@protocol(Test)];
    
    [proxy nullCall];

    NSLog([proxy hello]);

    int theAnswer = [proxy subtract:44 from:2];
    NSLog(@"The Answer = %d", theAnswer);

    [CWHessianArchiver setClassName:@"java.util.Hashtable" forProtocol:@protocol(ValueTest)];
    [CWHessianUnarchiver setProtocol:@protocol(ValueTest) forClassName:@"java.util.Hashtable"];
    id<ValueTest> bar = (id<ValueTest>)[CWValueObject valueObjectWithProtocol:@protocol(ValueTest)];
    bar.boolValue = YES;
    bar.intValue = 42;
    bar.stringValue = @"Hello";
    bar.numberValue = [NSNumber numberWithFloat:3.14f];
    
    NSLog([bar description]);
    id result = [proxy echo:bar];
    if ([result conformsToProtocol:@protocol(ValueTest)]) {
      NSLog(@"SUCCESS");
    } else {
      NSLog(@"FAIL");
    }
    NSLog([result description]);
    
    NSMutableDictionary* recursive = [NSMutableDictionary dictionary];
    [recursive setObject:recursive forKey:@"me"];
    result = [proxy echo:recursive];
		if ([result objectForKey:@"me"] == result) {
      NSLog(@"SUCCESS");
    } else {
      NSLog(@"FAIL");
    }
        
    [proxy fault];
    
  }
  @catch (NSException * e) {
  	NSLog(@"Got Exception name: %@ reason: %@", [e name], [e reason]);
  }
}


- (void)dealloc {
	[window release];
	[super dealloc];
}

@end
