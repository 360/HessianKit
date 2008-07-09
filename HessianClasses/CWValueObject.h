//
//  CWHessianObject.h
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

/*!
 * <code>CWValueObject</code> is a abstract bas clase for defining value object with automatic keyed coding, or
 * automatically create objects conforming to a given protocol as a concrete subclass of <code>CWValueObject</code>.
 * <p>
 * <code>CWValueObject</code> conforms to <code>NSCoding</code> protocol, and implements keyed coding.
 * <p> 
 * The default implementation of @link initWithCoder: <code>initWithCoder:</code>@/link will get a list of all 
 * property names of the actual subclass and decode the values using <code>decodeObjectForKey:</code> in the supplied 
 * <code>NSCoder</code> object with the property names as keys, and set the value using <code>setValue:forKey:</code>.
 * <p>
 * The default implementation of @link encodeWithCoder: <code>encodeWithCoder:</code>@/link will get a list of all 
 * property names of the actual subclass and fech the values using <code>valueForKey:</code> with the property names 
 * as keys, and encode the value in the supplied <code>NSCoder</code> object using <code>encodeObject:forKey:</code>.
 * <p>
 * This means that only properties are automatically coded. Subclasses can override and call default implementations,
 * to encode and decode using a custom scheme.
 */
@interface CWValueObject : NSObject <NSCoding> {
@private
	Protocol* _protocol;
  NSMutableDictionary* _instanceVariables;
}

/*!
 * @abstract The protocol the automatically generated concrete subclass reciever conforms to,
 *           or nil if it is a manually implemented subclass.
 */
@property(readonly, assign, nonatomic) Protocol* protocol;

/*!
 * @abstract Creates and returns a conrete subclass of <code>CWValueObject</code> object, that conforms to a protocol.
 *
 * @param aProtocol A protocol that the created object shoulc conform to.
 * @result An object conforming to aProtocol.
 *
 * Only a single concrete subclass is generated per protocol on demand. Generated subclasses are cached.
 */
+(CWValueObject*)valueObjectWithProtocol:(Protocol*)aProtocol;

/*!
 * @abstract Returns an initialized conrete subclass of <code>CWValueObject</code> object, that conforms to a protocol.
 *
 * @param aProtocol A protocol that the created object shoulc conform to.
 * @result An object conforming to aProtocol.
 *
 * Only a single concrete subclass is generated per protocol on demand. Generated subclasses are cached.
 * The returned object is not guaranteed to be the same object that was sent the message.
 */
-(id)initWithProtocol:(Protocol*)aProtocol;

/*!
 * @abstract Returns an object initialized from data in a given unarchiver.
 *
 * @param decoder An unarchiver object, that supports keyed coding.
 * @result self, initialized using the data in decoder.
 *
 * Must be called on already initialized objects.
 */
-(id)initWithCoder:(NSCoder *)decoder;

/*!
 * @abstract Encodes the receiver using a given archiver.
 *
 * @param An archiver object, that supports keyed coding.
 */
-(void)encodeWithCoder:(NSCoder *)encoder;

-(NSString*)description;

@end
