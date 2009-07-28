//
//  CWHessianKitStreamChannelTests.m
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

#import "CWHessianKitStreamChannelTests.h"


@implementation CWHessianKitStreamChannelTests


-(void)setUp;
{/*
  CWStreamPipe* upStreamPipe = [[CWStreamPipe alloc] initWithCapacity:0x20000];
  CWStreamPipe* downStreamPipe = [[CWStreamPipe alloc] initWithCapacity:0x20000];
  serverConnection = [[CWHessianConnection alloc] initWithReceiveStream:upStreamPipe.inputStream sendStream:downStreamPipe.outputStream];
  Test* rootObject = [[Test alloc] init];
  serverConnection.rootObject = rootObject;
  [rootObject release];
  clientConnection = [[CWHessianConnection alloc] initWithReceiveStream:downStreamPipe.inputStream sendStream:upStreamPipe.outputStream];
  proxy = [clientConnection rootProxyWithProtocol:@protocol(Test)];
*/}

-(void)tearDown;
{
 /* [clientConnection release];
  [serverConnection release];
*/}

@end
