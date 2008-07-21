//
//  CWHessianCoder.h
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

@class CWHessianConnection;

#define MAX_CHUNK_SIZE 0xffff

/*!
 * The <code>CWHessianCoder</code> abstract class declares the interface in common for the two concrete subclasses
 * @link //hessiankit_ref/occ/cl/CWHessianArchiver <code>CWHessianArchiver</code>@/link, and 
 * @link //hessiankit_ref/occ/cl/CWHessianArchiver <code>CWHessianUnarchiver</code>@/link to transfer
 * serialized objected over the binary Hessian web servcide protocol.
 * <p>
 * Clients should not use the abstract <code>CWHessianCoder</code> class directly.
 * <p>
 * <code>CWHessianCoder</code> is loosely related to <code>NSPortCodert</code> used for full scale Distrebuted Objects on
 * Mac OS X, but not available on iPhone OS.
 */
@interface CWHessianCoder : NSCoder {
@private
	CWHessianConnection* _connection;
  NSMutableData* _archiveData;
  NSMutableArray* _objectReferences;
}

/*!
 * @abstract The recievers associated @link //hessiankit_ref/occ/cl/CWHessianConnection <code>CWHessianConnection</code>@/link object.
 */
@property(readonly, retain, nonatomic) CWHessianConnection* connection;

/*!
 * @abstract A <code>NSMutableData</code> object that is used by concrete subclasses to store and retrieve serialized data.
 */
@property(readonly, retain, nonatomic) NSMutableData* archiveData;

/*!
 * @abstract A <code>NSMutableArray</code> object that is used by concrete subclasses to keep track of reference object to avoid
 * 					 circular references and save data pay load.
 */
@property(readonly, retain, nonatomic) NSMutableArray* objectReferences;

/*!
 * @abstract Returns an initialized <code>CWHessianCoder</code> object.
 * 
 * @param connection The @link //hessiankit_ref/occ/cl/CWHessianConnection <code>CWHessianConnection</code>@/link object to asociate with.
 * @param data The <code>NSMutableData</code> object to store to or retrieve data from.
 * @result A Hessian coder.
 */
-(id)initWithConnection:(CWHessianConnection*)connection mutableData:(NSMutableData*)data;

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

@interface CWHessianCoder (Unsupported)

-(void)encodeValueOfObjCType:(const char*)valueType at:(const void*)address;
-(void)encodeDataObject:(NSData*)data;
-(void)decodeValueOfObjCType:(const char*)valueType at:(void*)data;
-(NSData*)decodeDataObject;

@end
