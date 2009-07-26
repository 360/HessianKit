//
//  CWHessianChannel.m
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

#import "CWHessianChannel.h"


@implementation CWHessianChannel

@synthesize connection = _connection;

-(id)initWithConnection:(CWHessianConnection*)connection;
{
  self = [super init];
  if (self) {
    self.connection = connection;
  }
  return self;
}

-(NSString*)remoteIdForObject:(id)anObject;
{
  [NSException raise:NSInternalInconsistencyException 
              format:@"-[CWHessianChannel remoteIdForObject:] not overridden"];
  return nil;
}

-(NSOutputStream*)outputStreamForMessage;
{
  [NSException raise:NSInternalInconsistencyException 
              format:@"-[CWHessianChannel outputStreamForMessage] not overridden"];
  return nil;
}

-(void)finishOutputStreamForMessage:(NSOutputStream*)outputStream;
{
  [NSException raise:NSInternalInconsistencyException 
              format:@"-[CWHessianChannel finnishOutputStreamForMessage] not overridden"];  
}

@end
