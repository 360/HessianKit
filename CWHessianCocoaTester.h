//
// WCHessianCocoaTester.m
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

#import <Cocoa/Cocoa.h>
#import <HessianKit/HessianKit.h>
#import "CWHessianUnitTest.h"

@interface CWHessianCocoaTester : NSObject {
	IBOutlet NSTextView* logView;
	CWHessianUnitTest* unitTest;
}

-(IBAction)startBonjourService:(id)sender;
-(IBAction)stopBonjourService:(id)sender;

-(IBAction)executeTestsAgainstWebService:(id)sender;
-(IBAction)executeTestsAgainstBonjourService:(id)sender;

@end
