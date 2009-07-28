//
//  CWHessianConnection+Private.m
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


#import "HessianKitTypes.h"
#import "CWHessianChannel.h"
#import "CWHessianCoder.h"
#import "CWHessianConnection+Private.h"
#import "CWHessianArchiver+Private.h"

@implementation CWHessianConnection (Private)

-(id)init;
{
  self = [super init];
  if (self) {
    _version = DEFAULT_HESSIAN_VERSION;
    _requestTimeout = DEFAULT_HESSIAN_REQUEST_TIMEOUT;
    _replyTimeout = DEFAULT_HESSIAN_REPLY_TIMEOUT;
    pendingResponses = [[NSMutableDictionary alloc] init];
    lock = [[NSRecursiveLock alloc] init]; 
  }
  return self;
}

-(NSNumber*)nextMessageNumber;
{
  return [NSNumber numberWithUnsignedInteger:messageCount++];
}
-(NSNumber*)lastMessageNumber;
{
  return [NSNumber numberWithUnsignedInteger:messageCount - 1]; 
}

-(void)forwardInvocation:(NSInvocation*)invocation forProxy:(CWDistantHessianObject*)proxy;
{
  NSLog(@"Forward method %@ for proxy %@", NSStringFromSelector([invocation selector]), [proxy description]);
  NSOutputStream* outputStream = [self.channel outputStreamForMessage];
  
  [lock lock];
  NSNumber* messageNumber = [self nextMessageNumber];
  [pendingResponses setObject:[NSRunLoop currentRunLoop] forKey:messageNumber];
  [lock unlock];
  
  [self archiveInvocation:invocation asMessage:messageNumber toOutputStream:outputStream];
  [self.channel finishOutputStreamForMessage:outputStream];
  
  [self waitForReturnValueForMessage:messageNumber invocation:invocation];
}

-(void)waitForReturnValueForMessage:(NSNumber*)messageNumber invocation:(NSInvocation*)invocation;
{
  [lock lock];
  id result = [pendingResponses objectForKey:messageNumber];
  [lock unlock];
  if ([result isKindOfClass:[NSRunLoop class]]) {
    NSRunLoop* runloop = result;
    NSDate* timeoutDate = [NSDate dateWithTimeIntervalSinceNow:self.requestTimeout];
    NSTimeInterval delayInterval = 0.0001;
    do {
      NSDate* delayDate = [NSDate dateWithTimeIntervalSinceNow:delayInterval];
      if ([timeoutDate earlierDate:delayDate] == timeoutDate) {
        delayDate = timeoutDate;
      }
      NSLog(@"runMode:beforeDate:%@", [delayDate description]);
      if ([runloop runMode:NSDefaultRunLoopMode beforeDate:delayDate]) {
        [lock lock];
        result = [pendingResponses objectForKey:messageNumber];
        [lock unlock];
        if (result && ![result isKindOfClass:[NSRunLoop class]]) {
          break;
        }
      } else if ([timeoutDate timeIntervalSinceNow] <= 0.0) {
        result = [NSException exceptionWithName:CWHessianTimeoutException reason:@"Timeout waiting for reply" userInfo:nil];
        break;
      }
      if (delayInterval < 1.0) {
        delayInterval *= 2;
      }
    } while (YES);
  }
  NSLog(@"Fetched result:%@", [result description]);
  [[result retain] autorelease];
  [lock lock];
  [pendingResponses removeObjectForKey:messageNumber];
  [lock unlock];
  if ([result isKindOfClass:[NSException class]]) {
    [result raise];
  } else {
    [self setReturnValue:result invocation:invocation];
  }
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

-(void)archiveInvocation:(NSInvocation*)invocation asMessage:(NSNumber*)messageNumber toOutputStream:(NSOutputStream*)outputStream;
{
  CWHessianArchiver* archiver = [[[CWHessianArchiver alloc] initWithDelegate:self outputStream:outputStream] autorelease];
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
}



-(void)readHeaderFromUnarchiver:(CWHessianUnarchiver*)unarchiver;
{
}

-(id)unarchiveDataFromInputStream:(NSInputStream*)inputStream;
{
  @try {
    CWHessianUnarchiver* unarchiver = [[[CWHessianUnarchiver alloc] 
                                        initWithDelegate:self inputStream:inputStream] autorelease];
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
  } 
  @catch (NSException* exception) {
    return exception;
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
    if ([value isKindOfClass:[NSNull class]]) {
      value = nil;
    }
  	[invocation setReturnValue:&value];
  } else {
  	[NSException raise:NSInvalidUnarchiveOperationException format:@"Unsupported type %s", type];
  }
  if (isInvalidClass) {
  	[NSException raise:NSInvalidUnarchiveOperationException format:@"Invalid type %@", NSStringFromClass([value class])];
  }
}

-(void)handleReturnValue:(NSArray*)args;
{
  id returnValue = [args objectAtIndex:0];
  NSLog(@"Executed handleReturnValue:%@", [returnValue description]);
  NSNumber* messageNumber = [args objectAtIndex:1];
  [lock lock];
  [pendingResponses setObject:returnValue forKey:messageNumber];
  [lock unlock];
}

@end
