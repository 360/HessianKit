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
#import "HessianKitTypes.h"


@interface CWHessianChannel ()

@property(readwrite, assign, nonatomic) id<CWHessianChannelDelegate> delegate;

@end


@implementation CWHessianChannel

@synthesize delegate = _delegate;

-(id)initWithDelegate:(id<CWHessianChannelDelegate>)delegate;
{
  self = [super init];
  if (self) {
    self.delegate = delegate;
  }
  return self;
}

-(void)dealloc;
{
  self.delegate = nil;
  [super dealloc];
}

-(NSString*)remoteIdForObject:(id)anObject;
{
  [NSException raise:CWHessianObjectNotVendableException
              format:@"Can not vend remote objects over %@ channel", NSStringFromClass([self class])];
  return nil;
}

-(NSOutputStream*)outputStreamForMessage;
{
  [NSException raise:NSInternalInconsistencyException 
              format:@"-[CWHessianChannel outputStreamForMessage] not overridden for %@", NSStringFromClass([self class])];
  return nil;
}

-(void)finishOutputStreamForMessage:(NSOutputStream*)outputStream;
{
  [NSException raise:NSInternalInconsistencyException 
              format:@"-[CWHessianChannel finnishOutputStreamForMessage] not overridden for %@", NSStringFromClass([self class])];
}

@end
