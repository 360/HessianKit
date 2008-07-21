//
//  CWHessianArchiver.h
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

#import <Foundation/Foundation.h>

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
#import <HessianKit/CWHessianCoder.h>
#else
#import "CWHessianCoder.h"
#endif

/*!
 * <code>CWHessianArchiver</code>, a concrete subclass of @link //hessiankit_ref/occ/cl/CWHessianCoder <code>CWHessianCoder</code>@/link 
 * provides a way to encode objects, and scalar values that can be sent over the Hessian binary web service protocol.
 * <p>
 * Only keyed archiving is supported.
 */
@interface CWHessianArchiver : CWHessianCoder {
}

/*!
 * @abstract Adds a class translation mapping to <code>CWHessianArchiver</code> whereby instances of a given class 
 *           are encoded with a given class name instead of their real class names.
 * 
 * @param className The name of the class that <code>CWHessianArchiver</code> uses in place of aClass.
 * @param aClass The class for which to set up a translation mapping.
 */ 
+(void)seClassName:(NSString*)className forClass:(Class)aClass;

/*!
 * @abstract Adds a interface translation mapping to <code>CWHessianArchiver</code> whereby conforming instances of a 
 *           given protocol are encoded with a given class name instead of their real protocol names.
 * 
 * @param className The name of the class that <code>CWHessianArchiver</code> uses in place of aProtocol.
 * @param aProtocol The protocol for which to set up a translation mapping.
 */ 
+(void)setClassName:(NSString*)className forProtocol:(Protocol*)aProtocol;

/*!
 * @abstract Adds a method translation mapping to <code>CWHessianArchiver</code> whereby invocations of a given method 
 *           are encoded with a given method name instead of default translation.
 * 
 * @param methodName The name of the method that <code>CWHessianArchiver</code> uses in place of aSelector.
 * @param aSelector The selector for which to set up a translation mapping.
 */ 
+(void)setMethodName:(NSString*)methodName forSelector:(SEL)aSelector;

/*!
 * @abstract Returns the class name with which <code>CWHessianArchiver</code> encodes instances of a given class.
 *
 * @param aClass The class for which to determine the translation mapping.
 * @result The class name with which <code>CWHessianArchiver</code> encodes instances of aClass. 
 *         Returns nil if <code>CWHessianArchiver</code> does not have a translation mapping for aClass.
 */
+(NSString*)classNameForClass:(Class)aClass;

/*!
 * @abstract Returns the class name with which <code>CWHessianArchiver</code> encodes conforming instances of a given protocol.
 *
 * @param aProtocol The protocol for which to determine the translation mapping.
 * @result The class name with which <code>CWHessianArchiver</code> encodes instances of aProtocol. 
 *         Returns nil if <code>CWHessianArchiver</code> does not have a translation mapping for aProtocol.
 */
+(NSString*)classNameForProtocol:(Protocol*)aProtocol;

/*!
 * @abstract Returns the method name with which <code>CWHessianArchiver</code> encodes ivocations of a given selector.
 *
 * @param aSelector The selector for which to determine the translation mapping.
 * @result The class name with which <code>CWHessianArchiver</code> encodes instances of aSelector. 
 *         Returns the (SEL)0 if <code>CWHessianArchiver</code> does not have a translation mapping for aSelector.
 */
+(NSString*)methodNameForSelector:(SEL)aSelector;

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
  NSInteger _offset;
  NSDictionary* _currentObjectMap;
}

/*!
 * @abstract Adds a class translation mapping to <code>CWHessianUnarchiver</code> whereby instances of a given class 
 *           are decoded with a given class name instead of their real class names.
 * 
 * @param className The name of the class that <code>CWHessianUnarchiver</code> uses in place of aClass.
 * @param aClass The class for which to set up a translation mapping.
 */ 
+(void)setClass:(Class)aClass forClassName:(NSString*)className;

/*!
 * @abstract Adds a interface translation mapping to <code>CWHessianUnarchiver</code> whereby conforming instances of a 
 *           given protocol are decoded with a given class name instead of their real protocol names.
 * 
 * @param className The name of the class that <code>CWHessianUnarchiver</code> uses in place of aProtocol.
 * @param aProtocol The protocol for which to set up a translation mapping.
 */ 
+(void)setProtocol:(Protocol*)aProtocol forClassName:(NSString*)className;

/*!
 * @abstract Returns the class name with which <code>CWHessianUnarchiver</code> decodes instances of a given class.
 *
 * @param aClass The class for which to determine the translation mapping.
 * @result The class name with which <code>CWHessianUnarchiver</code> decodes instances of aClass. 
 *         Returns nil if <code>CWHessianUnarchiver</code> does not have a translation mapping for aClass.
 */
+(Class)classForClassName:(NSString*)className;

/*!
 * @abstract Returns the class name with which <code>CWHessianUnarchiver</code> decodes conforming instances of a given protocol.
 *
 * @param aProtocol The protocol for which to determine the translation mapping.
 * @result The class name with which <code>CWHessianUnarchiver</code> decodes instances of aProtocol. 
 *         Returns nil if <code>CWHessianUnarchiver</code> does not have a translation mapping for aProtocol.
 */
+(Protocol*)protocolForClassName:(NSString*)className;

-(BOOL)containsValueForKey:(NSString*)key;
-(BOOL)decodeBoolForKey:(NSString*)key;
-(int32_t)decodeInt32ForKey:(NSString*)key;
-(int64_t)decodeInt64ForKey:(NSString*)key;
-(float)decodeFloatForKey:(NSString*)key;
-(double)decodeDoubleForKey:(NSString*)key;
-(id)decodeObjectForKey:(NSString*)key;
-(const uint8_t*)decodeBytesForKey:(NSString*)key returnedLength:(NSUInteger*)lengthp;

@end

