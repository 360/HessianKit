//
//  CWDistantHessianObject+Private.m
//  HessianKit
//
//  Copyright 2008-2009 Fredrik Olsson, Cocoway. All rights reserved.
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

#import "CWDistantHessianObject+Private.h"
#import "CWHessianArchiver+Private.h"
#import <objc/runtime.h>

@implementation CWDistantHessianObject (Private)

-(int)_cfTypeID;
{
  return 1;
}

-(NSString*)methodNameFromInvocation:(NSInvocation*)invocation;
{
  NSString* methodName = [CWHessianArchiver methodNameForSelector:[invocation selector]];
  if (!methodName) {
    NSString* selectorName = NSStringFromSelector([invocation selector]);
    NSMutableArray* splittedName = [NSMutableArray arrayWithArray:[selectorName componentsSeparatedByString:@":"]];
    for (int index = 1; index < [splittedName count]; index++) {
      NSString* namePart = [splittedName objectAtIndex:index];
      if ([namePart length] > 0) {
      	NSString* firstChar = [[namePart substringToIndex:1] uppercaseString];
        NSString* remainingChars = [namePart substringFromIndex:1];
        namePart = [firstChar stringByAppendingString:remainingChars];
      }
      [splittedName replaceObjectAtIndex:index withObject:namePart];
    }
    methodName = [splittedName componentsJoinedByString:@""];
    int realParamCount = [[invocation methodSignature] numberOfArguments] - 2;
    if (realParamCount > 0) {
      methodName = [methodName stringByAppendingFormat:@"__%d", realParamCount];
    }
    [CWHessianArchiver setMethodName:methodName forSelector:[invocation selector]];
  }
  return methodName;
}

-(void)writeHeadersToArchiver:(CWHessianArchiver*)archiver;
{
}

-(void)writeArgumentAtIndex:(int*)pIndex type:(const char*)type archiver:(CWHessianArchiver*)archiver invocation:(NSInvocation*)invocation;
{
  int index = *pIndex;
  id object = nil;
  if (strcmp(type, @encode(BOOL)) == 0) {
  	BOOL value;
    [invocation getArgument:&value atIndex:index];
    [archiver writeBool:value];
    return;
  } else if (strcmp(type, @encode(int32_t)) == 0) {
  	int32_t value;
    [invocation getArgument:&value atIndex:index];
    object = [NSNumber numberWithInt:value];
  } else if (strcmp(type, @encode(int64_t)) == 0) {
  	int64_t value;
    [invocation getArgument:&value atIndex:index];
    object = [NSNumber numberWithLongLong:value];
  } else if (strcmp(type, @encode(float)) == 0) {
  	float value;
    [invocation getArgument:&value atIndex:index];
    object = [NSNumber numberWithFloat:value];
  } else if (strcmp(type, @encode(double)) == 0) {
  	double value;
    [invocation getArgument:&value atIndex:index];
    object = [NSNumber numberWithDouble:value];
  } else if (strcmp(type, @encode(id)) == 0) {
    [invocation getArgument:&object atIndex:index];
  } else if (strcmp(type, @encode(void*)) == 0) {
  	void* buffer = NULL;
    [invocation getArgument:&buffer atIndex:index];
    int length = 0;
    [invocation getArgument:&length atIndex:index + 1];
    (*pIndex)++;
    object = [NSData dataWithBytes:buffer length:length];
  } else {
  	[NSException raise:NSInvalidArchiveOperationException format:@"Unsupported type %s", type];
  }
  [archiver writeTypedObject:object];
}

-(NSData*)archivedDataForInvocation:(NSInvocation*)invocation;
{
  NSMutableData* data = [NSMutableData data];
  CWHessianArchiver* archiver = [[[CWHessianArchiver alloc] initWithConnection:self.connection mutableData:data] autorelease];
  [archiver writeChar:'c'];
  [archiver writeChar:0x01];
  [archiver writeChar:0x00];
  [self writeHeadersToArchiver:archiver];
  [archiver writeChar:'m'];
  [archiver writeString:[self methodNameFromInvocation:invocation] withTag:'S'];
  NSMethodSignature* signature = [invocation methodSignature];
  for (int index = 2; index < [signature numberOfArguments]; index++) {
  	const char* type = [signature getArgumentTypeAtIndex:index];
  	[self writeArgumentAtIndex:&index type:type archiver:archiver invocation:invocation];
  }
  [archiver writeChar:'z'];
  return data;
}

-(NSData*)sendRequestWithPostData:(NSData*)postData;
{
  NSData* responseData = nil;
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL
                                                         cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
  [request setHTTPMethod:@"POST"];   
  [request setHTTPBody:postData];
  // Fool Tomcat 4, fails otherwise...
  [request setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
  NSHTTPURLResponse * returnResponse = nil; 
  NSError* requestError = nil;
  responseData = [NSURLConnection sendSynchronousRequest:request 
                                       returningResponse:&returnResponse error:&requestError];
  if (requestError) {
    responseData = nil;
    [NSException raise:NSInvalidArchiveOperationException format:@"Network error domain:%@ code:%d", [requestError domain], [requestError code]];
  } else if (returnResponse != nil) {
  	if ([returnResponse statusCode] == 200) {
      [responseData retain];
    } else {
      responseData = nil;
      [NSException raise:NSInvalidArchiveOperationException format:@"HTTP error %d", [returnResponse statusCode]];    
    }
  } else {
    responseData = nil;
  	[NSException raise:NSInvalidArchiveOperationException format:@"Unknown network error"];
  }
  return responseData ? [responseData autorelease] : nil;
}

-(void)readHeaderFromUnarchiver:(CWHessianUnarchiver*)unarchiver;
{
}

-(id)unarchiveData:(NSData*)data;
{
  CWHessianUnarchiver* unarchiver = [[[CWHessianUnarchiver alloc] 
                                      initWithConnection:self.connection mutableData:(NSMutableData*)data] autorelease];
  char code = [unarchiver readChar];
  if (code == 'r') {
  	int major = [unarchiver readChar];
    int minor = [unarchiver readChar];
  	if (major == 0x01 && minor == 0x00) {
      [self readHeaderFromUnarchiver:unarchiver];
      id object = [unarchiver readTypedObject];
      if ([unarchiver readChar] != 'z') {
        [NSException raise:NSInvalidUnarchiveOperationException format:@"Did not find reply terminator z"];
      	return nil;
      }
      return object;
    } else {
      [NSException raise:NSInvalidUnarchiveOperationException format:@"Unsupported version %d.%d", major, minor];    
    }
  } else  if (code == 'f') {
    [self readHeaderFromUnarchiver:unarchiver];
    NSDictionary* failMap = [unarchiver readMap];
    NSException* exception = [NSException exceptionWithName:[failMap objectForKey:@"code"]
                                                     reason:[failMap objectForKey:@"message"]
                                                   userInfo:[failMap objectForKey:@"description"]];
    [exception raise];
  } else {
    [NSException raise:NSInvalidUnarchiveOperationException format:@"Unknown response data"];
  }
  return nil;
}

-(void)setReturnValue:(id)value invocation:(NSInvocation*)invocation;
{
  BOOL isInvalidClass = NO;
  const char* type = [[invocation methodSignature] methodReturnType];
  if (strcmp(type, @encode(void)) == 0) {
  	// void methods return NULL
  } else if (strcmp(type, @encode(BOOL)) == 0) {
    if ([value isKindOfClass:[NSNumber class]]) {
      BOOL tmp = [(NSNumber*)value boolValue];
      [invocation setReturnValue:&tmp];
    } else {
      isInvalidClass = YES;
    }
  } else if (strcmp(type, @encode(int32_t)) == 0) {
    if ([value isKindOfClass:[NSNumber class]]) {
      int32_t tmp = [(NSNumber*)value intValue];
      [invocation setReturnValue:&tmp];
    } else {
      isInvalidClass = YES;
    }
  } else if (strcmp(type, @encode(int64_t)) == 0) {
    if ([value isKindOfClass:[NSNumber class]]) {
      int64_t tmp = [(NSNumber*)value longLongValue];
      [invocation setReturnValue:&tmp];
    } else {
      isInvalidClass = YES;
    }
  } else if (strcmp(type, @encode(float)) == 0) {
    if ([value isKindOfClass:[NSNumber class]]) {
      float tmp = [(NSNumber*)value floatValue];
      [invocation setReturnValue:&tmp];
    } else {
      isInvalidClass = YES;
    }
  } else if (strcmp(type, @encode(double)) == 0) {
    if ([value isKindOfClass:[NSNumber class]]) {
      double tmp = [(NSNumber*)value doubleValue];
      [invocation setReturnValue:&tmp];
    } else {
      isInvalidClass = YES;
    }
  } else if (strcmp(type, @encode(id)) == 0) {
  	[invocation setReturnValue:&value];
  } else {
  	[NSException raise:NSInvalidUnarchiveOperationException format:@"Unsupported type %s", type];
  }
  if (isInvalidClass) {
  	[NSException raise:NSInvalidUnarchiveOperationException format:@"Invalid type %@", NSStringFromClass([value class])];
  }
}

@end
