/*
 *  HessianKitTypes.h
 *  HessianKit
 *
 *  Created by Fredrik Olsson on 2009-07-15.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
#define GAMEKIT_AVAILABLE
#undef XML_AVAILABLE
#else
#undef GAMEKIT_AVAILABLE
#define XML_AVAILABLE
#endif

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

/*!
 * @abstract Communication channel for hessian binary protocol.
 */
enum {
  CWHessianChannelHTTP = 0,
  CWHessianChannelPort = 1
#ifdef GAMEKIT_AVAILABLE  
  , CWHessianChannelGameKit = 2
#endif  
};
typedef int CWHessianChannel;
