//
//  CWDistantHessianObject.h
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

@class CWHessianConnection;

/*!
 * @abstract <code>CWDistantHessianObject</code> is a concrete subclass of <code>NSProxy</code> that defines proxies for objects that exists
 * as a Hessian web service.
 * 
 * @discussion When a distant object receives a message, in most cases it forwards the message to the real object published 
 * on the Hessian web service using a <code>NSURLRequest</code> object and the provided URL, supplying the return value to the 
 * sender of the message if one is received, and propagating any exception back to the invoker of the method that
 * raised it.
 * <p>
 * A @link //hessiankit_ref/occ/cl/CWHessianArchiver <code>CWHessianArchiver</code>@/link object is created and 
 * used to encode the call to the Hessian web service, and a 
 * @link //hessiankit_ref/occ/cl/CWHessianUnarchiver <code>CWHessianUnacrhiver</code>@/link object is created and 
 * used to decode the response from the Hessian web service. 
 * <p>
 * Valid argument and return types for distand objects are:
 * <ul>
 * <li><code>BOOL</code> - Maps to Java <code>boolean</code>, trabsfered as Hessian boolean.</li>
 * <li><code>int32_t</code> - Maps to Java <code>int</code>, transfered as Hessian int.</li>
 * <li><code>int64_t</code> - Maps to Java <code>long</code>, trabsfered as Hessian long.</li>
 * <li><code>float</code> - Maps to Java <code>float</code>, transfered as Hessian float.</li>
 * <li><code>double</code> - Maps to Java <code>double</code>, trabsfered as Hessian double.</li>
 * <li><code>id<NSCoding></code> - Maps to Java <code>java.lang.Object</code> or <code>java.util.Map</code>, transfered as typed Hessian map.</li>
 * </ul>
 * <p>
 * The following Cocoa classes are treaded with special care:
 * <ul>
 * <li><code>NSArray</code> - Maps to Java array or <code>java.util.List</code>, tansfered as Hessian list.</li>
 * <li><code>NSDictionary</code> - Maps to Java <code>java.util.Map</code>, or domain class, trabsfered as Hessian map.</li>
 * <li><code>NSData</code> - Maps to Java byte array, transfered as Hessian binary data.</li>
 * <li><code>NSDate</code> - Maps to Java long or <code>java.util.Date</code>, transfered as Hessian date.</li>
 * <li><code>NSString</code> - Maps to Java <code>java.lang.String</code>, transfered as Hessian string.</li>
 * <li><code>NSXMLNode</code> - Maps to Java <code>org.w3c.dom.Node</code>, transfered as Hessian xml.</li>
 * </ul>
 * <p>
 * <code>CWDistantHessianObject</code> is closely modelled after <code>NSDistantObject</code> used for full scale Distrebuted Objects on
 * Mac OS X, but not available on iPhone OS.
 */
@interface CWDistantHessianObject : NSProxy {
@private
	CWHessianConnection* _connection;
  NSURL* _URL;
  Protocol* _protocol;
  NSMutableDictionary* _methodSignatures;
}

/*!
 * @abstract The recievers associated @link //hessiankit_ref/occ/cl/CWHessianConnection <code>CWHessianConnection</code>@/link object.
 */
@property(readonly, retain, nonatomic) CWHessianConnection* connection;

/*!
 * @abstract The URL publishing the recievers Hessian web service.
 */
@property(readonly, retain, nonatomic) NSURL* URL;

/*!
 * @abstract The protocol the reciever conforms to, a mirror of the interface the Hessian web service publishes.
 */
@property(readonly, assign, nonatomic) Protocol* protocol;

/*!
 * @abstract Returns a initialized <code>CWDistantHessianObject</code> associated with a given 
 *           @link //hessiankit_ref/occ/cl/CWHessianConnection <code>CWHessianConnection</code>@/link object,
 *           a Hessian web service published at an URL, and conforming to a given Protocol.
 *
 * @param connection The @link //hessiankit_ref/occ/cl/CWHessianConnection <code>CWHessianConnection</code>@/link object to asociate with.
 * @param URL URL of the published Hessian web service.
 * @param aProtocol a protol mirroring the published interface of the Hessian web service, to conform to.
 * @result A proxy for the Hessian web service.
 */
-(id)initWithConnection:(CWHessianConnection*)connection URL:(NSURL*)URL protocol:(Protocol*)aProtocol;

/*!
 * @abstract Returns a Boolean value that indicates whether the receiver conforms to a given protocol.
 * 
 * @param aProtocol A protocol.
 * @result YES if the receiver conforms to aProtocol, otherwise NO.
 *
 * Will first check against the protocol the reciever is set to conform to, including any protocol that
 * protocol conforms to. And lastly call the super implementation. 
 */
-(BOOL)conformsToProtocol:(Protocol*)aProtocol;

/*!
 * @abstract Returns a Boolean value that indicates whether the receiver is an instance of given class or an instance of any class that inherits from that class.
 *
 * @param aClass A class object representing the Objective-C class to be tested.
 * @result YES if the receiver is an instance of aClass or an instance of any class that inherits from aClass, otherwise NO.
 */  
-(BOOL)isKindOfClass:(Class)aClass;

/*!
 * Return the remote class name on the Hessian web service that the reciever is a proxy for.
 *
 * @result A class name.
 *
 * Unsess the class method @link //hessiankit_ref/occ/clm/CWHessianConnection/classNameForProtocol: <code>classNameForProtocol:</code>@/link 
 * on @link //hessiankit_ref/occ/cl/CWHessianArchiver <code>CWHessianArchiver</code>@/link class to determine the 
 * class name using the protocol this reciever is set to conform to. If no protocol mapping is found, the name of the 
 * protocol is returned.
 */
-(NSString*)remoteClassName;

- (void)forwardInvocation:(NSInvocation *)anInvocation;
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;

@end
