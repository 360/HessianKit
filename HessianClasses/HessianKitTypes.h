/*
 *  HessianKitTypes.h
 *  HessianKit
 *
 *  Created by Fredrik Olsson on 2009-07-15.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

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
