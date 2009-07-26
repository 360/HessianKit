//
//  CWHessianCoder.h
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

#define MAX_CHUNK_SIZE 0xffff

@protocol CWHessianCoderDelegate;
@class CWDistantHessianObject;

/*!
 * @abstract The <code>CWHessianCoder</code> abstract class declares the interface in common for the two concrete subclasses
 * @link //hessiankit_ref/occ/cl/CWHessianArchiver <code>CWHessianArchiver</code>@/link, and 
 * @link //hessiankit_ref/occ/cl/CWHessianArchiver <code>CWHessianUnarchiver</code>@/link to transfer
 * serialized objected over the binary Hessian web servcide protocol.
 * 
 * @discussion Clients should not use the abstract <code>CWHessianCoder</code> class directly.
 * <p>
 * <code>CWHessianCoder</code> is loosely related to <code>NSPortCodert</code> used for full scale Distrebuted Objects on
 * Mac OS X, but not available on iPhone OS.
 */
@interface CWHessianCoder : NSCoder {
@private
  id<CWHessianCoderDelegate> _delegate;
  NSMutableArray* _objectReferences;
}

/*!
 * @abstract The Hessian coer delegate.
 */
@property(readonly, assign, nonatomic) id<CWHessianCoderDelegate> delegate;

/*!
 * @abstract A <code>NSMutableArray</code> object that is used by concrete subclasses to keep track of reference object to avoid
 * 					 circular references and save data pay load.
 */
@property(readonly, retain, nonatomic) NSMutableArray* objectReferences;

/*!
 * @abstract Returns an initialized <code>CWHessianCoder</code> object.
 * 
 * @param delegate The Hessian coder delegate.
 * @result A Hessian coder.
 */
-(id)initWithDelegate:(id<CWHessianCoderDelegate>)delegate;

/*!
 * @abstract Default implementation returns YES to allow NCoding conformant objects to suse keyed archiving.
 *
 * @result YES
 *
 * Object to be seriealzed over the Hessian binary web service protocol must support keyed archiving. Failure to do
 * so will result in <code>NSInvalidArchiveOperationException</code>, and <code>NSInvalidUnarchiveOperationException</code> exceptions.
 */
-(BOOL)allowsKeyedCoding;

/*!
 * @abstract Default implementation return 1.
 *
 * @result 1
 */
-(NSInteger)versionForClassName:(NSString*)className;

@end


/*!
 * @abstract Hessian coder delegate protocol.
 */
@protocol CWHessianCoderDelegate

/*!
 * @abstract Coder did unarchive a remote proxy with a given remote ID, and the delegate is asks to provide a 
 *           <code>CWDistantHessianObject</code> to represent it with a given protocol.
 *
 * @param coder the coder instance.
 * @param reoteId a unique remote ID.
 * @param protocol the protocol that the remote objet conforms to.
 * @result a proxy for the remote object.
 */
-(CWDistantHessianObject*)coder:(CWHessianCoder*)coder didUnarchiveProxyWithRemoteId:(NSString*)remoteId protocol:(Protocol*)aProtocol;

@end


@interface CWHessianCoder (Unsupported)

-(void)encodeValueOfObjCType:(const char*)valueType at:(const void*)address;
-(void)encodeDataObject:(NSData*)data;
-(void)decodeValueOfObjCType:(const char*)valueType at:(void*)data;
-(NSData*)decodeDataObject;

@end


