//
//  CWHessianUnitTest.h
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

#import <Foundation/Foundation.h>

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
#import <HessianKit/HessianKit.h>
#else
#import "HessianKit.h"
#endif

#import "Test.h"


@interface CWHessianUnitTest : NSObject <CWHessianConnectionServiceSearchDelegate> {
	CWHessianConnection* _currentConnection;
}

-(BOOL)setupAsBonjourService;

-(BOOL)testAllWithWebService;

-(BOOL)testAllWithBonjourService;

-(BOOL)testAllWithProxy:(CWDistantHessianObject<Test>*)proxy;

-(BOOL)testPrimitivesWithProxy:(CWDistantHessianObject<Test>*)proxy;

-(BOOL)testPublicTestWithProxy:(CWDistantHessianObject<Test>*)proxy;

-(BOOL)testListWithProxy:(CWDistantHessianObject<Test>*)proxy;

-(BOOL)testMapWithProxy:(CWDistantHessianObject<Test>*)proxy;

-(BOOL)testObjectWithProxy:(CWDistantHessianObject<Test>*)proxy;

@end
