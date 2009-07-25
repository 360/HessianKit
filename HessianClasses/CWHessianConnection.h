//
//  CWHessianConnection.h
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

@class CWDistantHessianObject;

/*!
 * @abstract Hessian serialization version.
 *
 * Currently only version 1.00 is supported.
 */
enum {
	CWHessianVersion1_00 = 0x100
};
typedef int CWHessianVersion;

@class CWDistantHessianObject;

/*!
 * @abstract An <code>CWHessianConnection</code> object is responsible for handling states related to the web service connection,
 * and create proxy objects to communicate with the web services.
 * 
 * @discussion Unless the client uses custom value objects, this is the only class in HessianKit that is needed to be
 * created directly. All other objects can be created using the <code>CWHessianConnection</code> object. If custom
 * value objects are needed use the 
 * @link //hessiankit_ref/occ/cl/CWValueObject <code>CWValueObject</code>@/link to realize objects using protocol 
 * definitions, or implement classes conforming to <code>NSCoding</code> protocol.
 * <p>
 * <code>CWHessianConnection</code> is closely modelled after <code>NSConnection</code> used for full scale 
 * Distrebuted Objects on Mac OS X, but not available on iPhone OS.
 */
@interface CWHessianConnection : NSObject {
@private
	CWHessianVersion _version;
}

/*!
 * @abstract The Hessian serialization protocol version to use for this connection.
 */
@property(assign, nonatomic) CWHessianVersion version;

/*!
 * @abstract Returns an inititialized <code>CWHessianConnection</code> object.
 *
 * @param version The Hessian serialization protocol version to use.
 * @result The initialized <code>CWHessianConnection</code> object.
 */
-(id)initWithHessianVersion:(CWHessianVersion)version;

/*!
 * @abstract Returns a Hessian web service proxy associated with a temporary <code>CWHessianConnection</code> object, 
 *           for a given URL, conforming to a given protocol.
 *
 * @param URL The URL of the Hessian web service.
 * @param aProtocol The Protocol that the proxy should conform to.
 * @result A proxy for the Hessian web service.
 *
 * @seealso 
 */
+(CWDistantHessianObject*)proxyWithURL:(NSURL*)URL protocol:(Protocol*)aProtocol;

/*!
 * @abstract Returns a Hessian web service proxy for a given URL, conforming to a given protocol.
 *
 * @param URL The URL of the Hessian web service.
 * @param aProtocol The Protocol that the proxy should conform to.
 * @result A proxy for the Hessian web service. 
 */
-(CWDistantHessianObject*)proxyWithURL:(NSURL*)URL protocol:(Protocol*)aProtocol;

@end
