//
//  CWHessian.h
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
#import <HessianKit/HessianKitTypes.h>
#import <HessianKit/CWHessianConnection.h>
#import <HessianKit/CWHessianChannel.h>
#import <HessianKit/CWHessianTranslator.h>
#import <HessianKit/CWHessianCoder.h>
#import <HessianKit/CWHessianArchiver.h>
#import <HessianKit/CWDistantHessianObject.h>
#import <HessianKit/CWValueObject.h>
#else
#import "HessianKitTypes.h"
#import "CWHessianConnection.h"
#import "CWHessianChannel.h"
#import "CWHessianTranslator.h"
#import "CWHessianCoder.h"
#import "CWHessianArchiver.h"
#import "CWDistantHessianObject.h"
#import "CWValueObject.h"
#import "NSStream+CWiPhoneAdditions.h"
#endif
