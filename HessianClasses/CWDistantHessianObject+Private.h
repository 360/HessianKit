//
//  CWDistantHessianObject+Private.h
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

#import "CWDistantHessianObject.h"
#import "CWHessianArchiver.h"

@interface CWDistantHessianObject ()
@property(retain, nonatomic) CWHessianConnection* connection;
@end

@interface CWDistantHessianObject (Private)

-(NSString*)methodNameFromInvocation:(NSInvocation*)invocation;

-(void)writeHeadersToArchiver:(CWHessianArchiver*)archiver;
-(void)writeArgumentAtIndex:(int*)pIndex type:(const char*)type archiver:(CWHessianArchiver*)archiver invocation:(NSInvocation*)invocation;
-(NSData*)archivedDataForInvocation:(NSInvocation*)invocation;
-(NSData*)sendRequestWithPostData:(NSData*)postData;

-(void)readHeaderFromUnarchiver:(CWHessianUnarchiver*)unarchiver;
-(id)unarchiveData:(NSData*)data;
-(void)setReturnValue:(id)value invocation:(NSInvocation*)invocation;

@end
