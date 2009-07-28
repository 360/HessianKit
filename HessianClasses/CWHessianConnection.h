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
@class CWHessianChannel;
#ifdef GAMEKIT_AVAILABLE
@class GKSession;
#endif
@protocol CWHessianRemoting;

/*!
 * @abstract Hessian serialization version.
 *
 * Currently only version 1.00 is complete.
 */
enum {
  CWHessianVersion1_00 = 0x100,
  CWHessianVersion2_00 = 0x200
};
typedef int CWHessianVersion;

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
  CWHessianChannel* _channel;
  CWHessianVersion _version;
  NSTimeInterval _requestTimeout;
  NSTimeInterval _replyTimeout;
  NSMutableDictionary* pendingResponses;
  NSUInteger messageCount;
  NSMutableDictionary* localObjects;
  NSMutableDictionary* remoteProxies;
  NSRecursiveLock* lock;
}

/*!
 * The channel for this Hessian connection.
 */
@property(readonly, retain, nonatomic) CWHessianChannel* channel;

/*!
 * @abstract The Hessian serialization protocol version to use for this connection.
 */
@property(assign, nonatomic) CWHessianVersion version;

/*!
 * @abstract The root object to vend to clients.
 */
@property(retain, nonatomic) id<CWHessianRemoting> rootObject;

/*!
 * @abstract The timeout for outgoing method call requests. 
 */
@property(assign, nonatomic) NSTimeInterval requestTimeout;

/*!
 * @abstract The timeout for outgoing method call replies. 
 */
@property(assign, nonatomic) NSTimeInterval replyTimeout;

/*!
 * @abstract Returns an inititialized <code>CWHessianConnection</code> object over a given channel.
 *
 * @discussion This is the designated initializer for <code>CWHessianConection</code>, call
 *             <code>initWithChannel:</code> when implementing a custom channel. Use secondary
 *             initializers for the default channels.
 *
 * @param channel The channel to send and receive Hessian data.
 * @result The initialized <code>CWHessianConnection</code> object.
 */
-(id)initWithChannel:(CWHessianChannel*)channel;

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
 * @discussion A Hessian connection over port channel can receive and vend proxy objects, both by 
 *             vending a root object and by sending proxies as method arguments.
 *             Method name translation is not used by default as the receiving service is assumed
 *             to be implemented in Objective-C as well. Translation can be turned on of desired.
 *
 * @param receiveStream The input stream to receive data for the Hessian connection.
 * @param sendStream The send stream to receive data for the Hessian connection.
 * @result The initialized <code>CWHessianConnection</code> object.
 */
-(id)initWithReceiveStream:(NSInputStream*)receiveStream sendStream:(NSOutputStream*)sendStream;

#ifdef GAMEKIT_AVAILABLE
/*!
 * @abstract Returns an inititialized <code>CWHessianConnection</code> object over a GameKit channel.
 *
 * @discussion A Hessian connection over GameKit channel can receive and vend proxy objects, both by 
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
