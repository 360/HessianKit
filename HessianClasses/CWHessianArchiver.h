//
//  CWHessianArchiver.h
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

#import <Foundation/Foundation.h>

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
#import <HessianKit/CWHessianCoder.h>
#else
#import "CWHessianCoder.h"
#endif

/*!
 * @abstract <code>CWHessianArchiver</code>, a concrete subclass of @link //hessiankit_ref/occ/cl/CWHessianCoder <code>CWHessianCoder</code>@/link 
 * provides a way to encode objects, and scalar values that can be sent over the Hessian binary web service protocol.
 * <p>
 * @discussion Only keyed archiving is supported.
 */
@interface CWHessianArchiver : CWHessianCoder {
 @private 
  NSOutputStream* _outputStream;
}

/*!
 * @abstract The output stream to archive data to.
 */
@property(readonly, retain, nonatomic) NSOutputStream* outputStream;

-(void)encodeBool:(BOOL)boolv forKey:(NSString*)key;
-(void)encodeInt32:(int32_t)intv forKey:(NSString*)key;
-(void)encodeInt64:(int64_t)intv forKey:(NSString*)key;
-(void)encodeFloat:(float)realv forKey:(NSString*)key;
-(void)encodeDouble:(double)realv forKey:(NSString*)key;
-(void)encodeObject:(id)objv forKey:(NSString*)key;
-(void)encodeBytes:(const uint8_t*)bytesp length:(NSUInteger)lenv forKey:(NSString*)key;

@end


/*!
 * CWHessianArchiver, a concrete subclass of @link //hessiankit_ref/occ/cl/CWHessianCoder <code>CWHessianCoder</code>@/link 
 * provides a way to decode objects, and scalar values that can be sent over the Hessian binary web service protocol.
 * <p>
 * Only keyed archiving is supported.
 */
@interface CWHessianUnarchiver : CWHessianCoder {
@private
  NSInputStream* _inputStream;
  BOOL hasPeekChar;
  char peekChar;
  NSDictionary* _currentObjectMap;
}

/*!
 * @abstract The input stream to archive data from.
 */
@property(readonly, retain, nonatomic) NSInputStream* inputStream;

-(BOOL)containsValueForKey:(NSString*)key;
-(BOOL)decodeBoolForKey:(NSString*)key;
-(int32_t)decodeInt32ForKey:(NSString*)key;
-(int64_t)decodeInt64ForKey:(NSString*)key;
-(float)decodeFloatForKey:(NSString*)key;
-(double)decodeDoubleForKey:(NSString*)key;
-(id)decodeObjectForKey:(NSString*)key;
-(const uint8_t*)decodeBytesForKey:(NSString*)key returnedLength:(NSUInteger*)lengthp;

@end

