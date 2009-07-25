//
//  CWHessianKitBasicTests.h
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

#import <SenTestingKit/SenTestingKit.h>
#import "HessianKit.h"
#import "Test.h"


@interface CWHessianKitBasicTests : SenTestCase {
@private
	CWDistantHessianObject<Test>* proxy;
}

-(void)testNull;

-(void)testBool;

-(void)testInt;

-(void)testLong;

-(void)testDouble;

-(void)testString;

-(void)testBinary;

-(void)testDate;

-(void)testList;

-(void)testMap;

@end
