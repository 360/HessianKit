//
//  CWHessianHTTPChannel.m
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

#import "CWHessianHTTPChannel.h"

@implementation CWHessianHTTPChannel

@synthesize serviceURL = _serviceURL;

-(id)initWithDelegate:(id<CWHessianChannelDelegate>)delegate serviceURL:(NSURL*)URL;
{
  if (URL == nil) {
    [self release];
    [NSException raise:NSInvalidArgumentException format:@"Service URL must not be nil"];
    self = nil;
  } else {
    self = [super initWithDelegate:delegate];
  }
  if (self) {
    self.serviceURL = URL;
  }
  return self;
}

-(void)dealloc;
{
  self.serviceURL = nil;
  [super dealloc];
}

-(BOOL)canVendObjects;
{
  return NO;
}

-(NSOutputStream*)outputStreamForMessage;
{
  NSOutputStream* outputStream = [NSOutputStream outputStreamToMemory]; 
  [outputStream open];
  return outputStream;
}

-(void)finishOutputStreamForMessage:(NSOutputStream*)outputStream;
{
  NSData* postData = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.serviceURL
                                                         cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                     timeoutInterval:60.0];
  [request setHTTPMethod:@"POST"];   
  [request setHTTPBody:postData];
  // Fool Tomcat 4, fails otherwise...
  [request setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
  NSHTTPURLResponse * returnResponse = nil; 
  NSError* requestError = nil;
  NSData* responseData = responseData = [NSURLConnection sendSynchronousRequest:request
                                                              returningResponse:&returnResponse error:&requestError];
  if (requestError) {
    responseData = nil;
    [NSException raise:NSInvalidArchiveOperationException 
                format:@"Network error domain:%@ code:%d", [requestError domain], [requestError code]];
  } else if (returnResponse != nil) {
  	if ([returnResponse statusCode] == 200) {
      [responseData retain];
    } else {
      [NSException raise:NSInvalidArchiveOperationException format:@"HTTP error %d", [returnResponse statusCode]];
      return;
    }
  } else {
  	[NSException raise:NSInvalidArchiveOperationException format:@"Unknown network error"];
    return;
  }
  NSInputStream* inputStream = [NSInputStream inputStreamWithData:responseData];
  [inputStream open];
  [self.delegate channel:self didReceiveDataInInputStream:inputStream];
  [inputStream close];
}

@end
