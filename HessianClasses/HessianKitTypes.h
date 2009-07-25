//
//  HessianKitTypes.h
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


#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
#undef GAMEKIT_AVAILABLE
#define XML_AVAILABLE
#else
#define GAMEKIT_AVAILABLE
#undef XML_AVAILABLE
#endif


/*!
 * @abstract IO timeout.
 */
extern NSString* const CWHessianTimeoutException;


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

#ifndef DEFAULT_HESSIAN_VERSION
#define DEFAULT_HESSIAN_VERSION CWHessianVersion1_00
#endif

#ifndef DEFAULT_HESSIAN_REQUEST_TIMEOUT
#define DEFAULT_HESSIAN_REQUEST_TIMEOUT 30.0
#endif

#ifndef DEFAULT_HESSIAN_REPLY_TIMEOUT
#define DEFAULT_HESSIAN_REPLY_TIMEOUT 30.0
#endif

/*!
 * @abstract Communication channel for hessian binary protocol.
 */
enum {
  CWHessianChannelHTTP = 0,
  CWHessianChannelStream = 1
#ifdef GAMEKIT_AVAILABLE  
  , CWHessianChannelGameKit = 2
#endif  
};
typedef int CWHessianChannel;
