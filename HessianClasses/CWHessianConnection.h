//
//  CWHessianConnection.h
//  HessianKit
//
//  Copyright 2008 Fredrik Olsson, Cocoway. All rights reserved.
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
#import <HessianKit/HessianKitTypes.h>
#else
#import "HessianKitTypes.h"
#endif

#ifdef GAMEKIT_AVAILABLE
@class GKSession;
#endif

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
  NSTimeInterval _requestTimeout;
  NSTimeInterval _replyTimeout;
  NSURL* _serviceURL;
  NSInputStream* _receiveStream;
  NSOutputStream* _sendStream;
#ifdef GAMEKIT_AVAILABLE
  GKSession* _gameKitSession;
#endif
  NSMutableDictionary* responseMap;
  NSUInteger messageCount;
  NSRecursiveLock* lock;
}

/*!
 * @abstract The Hessian serialization protocol version to use for this connection.
 */
@property(assign, nonatomic) CWHessianVersion version;

/*!
 * @abstract The timeout for outgoing method call requests. 
 */
@property(assign, nonatomic) NSTimeInterval requestTimeout;

/*!
 * @abstract The timeout for outgoing method call replies. 
 */
@property(assign, nonatomic) NSTimeInterval replyTimeout;

/*!
 * The channel for this Hessian connection.
 */
@property(readonly, nonatomic) CWHessianChannel channel;

/*!
 * @abstract The URL of the Hessian web service.
 */
@property(readonly, nonatomic) NSURL* serviceURL;

/*!
 * @abstract The recieve port for the Hessian connection
 */
@property(readonly, nonatomic) NSInputStream* receiveStream;

/*!
 * @abstract The send port for the Hessian connection
 */
@property(readonly, nonatomic) NSOutputStream* sendStream;

#ifdef GAMEKIT_AVAILABLE
/*!
 * @abstract The initialized GameKit session for the Hessian connection.
 */
@property(readonly, nonatomic) GKSession* gameKitSession;
#endif


/*!
 * @abstract Returns an inititialized <code>CWHessianConnection</code> object over a HTTP channel.
 *
 * @discussion A Hessian connection over HTTP channel can only receive proxy objects, not vend them 
 *             for the server.
 *             Method name translation is used by default as the service is assumed to be implemented
 *             in Java or another language but Objective-C. Translation can be turned off if desired.
 *
 * @param URL The URL of the Hessian web service.
 * @result The initialized <code>CWHessianConnection</code> object.
 */
-(id)initWithServiceURL:(NSURL*)URL;

/*!
 * @abstract Returns an inititialized <code>CWHessianConnection</code> object over a port channel.
 *
 * @discussion A Hessian connection over port channel can recieve and vend proxy objects, both by 
 *             vending a root object and by sending proxies as method arguments.
 *             Method name translation is not used by default as the receiving service is assumed
 *             to be implemented in Objective-C as well. Translation can be turned on of desired.
 *
 * @param recievePort The recieve port for the Hessian connection.
 * @param sendPort The send port for the Hessian connection. 
 * @result The initialized <code>CWHessianConnection</code> object.
 */
//-(id)initWithReceivePort:(NSPort*)receivePort sendPort:(NSPort*)sendPort;

#ifdef GAMEKIT_AVAILABLE
/*!
 * @abstract Returns an inititialized <code>CWHessianConnection</code> object over a GameKit channel.
 *
 * @discussion A Hessian connection over GameKit channel can recieve and vend proxy objects, both by 
 *             vending a root object and by sending proxies as method arguments.
 *             Method name translation is not used by default as all connected clients can safely be 
 *             assumed to be implemented in Objective-C. Translation can be turned on of desired.
 *
 * @param session The initialized GameKit session for the Hessian connection.
 * @result The initialized <code>CWHessianConnection</code> object.
 */
-(id)initWithGameKitSession:(GKSession*)session;
#endif

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
+(CWDistantHessianObject*)rootProxyWithServiceURL:(NSURL*)URL protocol:(Protocol*)aProtocol;

/*!
 * @abstract Returns a Hessian web service proxy for a given URL, conforming to a given protocol.
 *
 * @param URL The URL of the Hessian web service.
 * @param aProtocol The Protocol that the proxy should conform to.
 * @result A proxy for the Hessian web service. 
 */
-(CWDistantHessianObject*)rootProxyWithProtocol:(Protocol*)aProtocol;

@end
