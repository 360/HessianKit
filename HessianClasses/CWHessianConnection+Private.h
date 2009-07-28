//
//  CWHessianConnection+Private.h
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


#import <Foundation/Foundation.h>
#import "CWHessianConnection.h"

@class CWHessianCoder;
@class CWHessianChannel;
@class CWHessianArchiver;
@class CWHessianUnarchiver;
@class CWDistantHessianObject;

@protocol CWHessianChannelDelegate;
@protocol CWHessianCoderDelegate;


@interface CWHessianConnection () <CWHessianChannelDelegate, CWHessianCoderDelegate>

@property(readwrite, retain, nonatomic) CWHessianChannel* channel;

-(void)channel:(CWHessianChannel*)channel didReceiveDataInInputStream:(NSInputStream*)inputStream;

-(CWDistantHessianObject*)coder:(CWHessianCoder*)coder didUnarchiveProxyWithRemoteId:(NSString*)remoteId protocol:(Protocol*)aProtocol;

@end


@interface CWHessianConnection (Private)

-(id)init;

-(NSNumber*)nextMessageNumber;
-(NSNumber*)lastMessageNumber;

-(void)forwardInvocation:(NSInvocation*)anInvocation forProxy:(CWDistantHessianObject*)proxy;

-(NSString*)methodNameFromInvocation:(NSInvocation*)invocation;

-(void)writeHeadersToArchiver:(CWHessianArchiver*)archiver;
-(void)writeArgumentAtIndex:(int*)pIndex type:(const char*)type archiver:(CWHessianArchiver*)archiver invocation:(NSInvocation*)invocation;
-(void)archiveInvocation:(NSInvocation*)invocation asMessage:(NSNumber*)messageNumber toOutputStream:(NSOutputStream*)outputStream;

-(void)waitForReturnValueForMessage:(NSNumber*)messageNumber invocation:(NSInvocation*)invocation;

-(void)readHeaderFromUnarchiver:(CWHessianUnarchiver*)unarchiver;
-(id)unarchiveDataFromInputStream:(NSInputStream*)inputStream;
-(void)setReturnValue:(id)value invocation:(NSInvocation*)invocation;

@end
