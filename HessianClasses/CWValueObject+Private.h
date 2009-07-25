//
//  CWHessianValueObject+Private.h
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
#import <HessianKit/CWValueObject.h>
#else
#import "CWValueObject.h"
#endif

@interface CWValueObject (Private)

-(NSArray*)allPropertyNames;

-(BOOL)priv_boolValue;
-(void)priv_setBoolValue:(BOOL)value;
-(int32_t)priv_int32Value;
-(void)priv_setInt32Value:(int32_t)value;
-(int64_t)priv_int64Value;
-(void)priv_setInt64Value:(int64_t)value;
-(float)priv_floatValue;
-(void)priv_setFloatValue:(float)value;
-(double)priv_doubleValue;
-(void)priv_setDoubleValue:(double)value;
-(id)priv_objectValue;
-(void)priv_setObjectValue:(id)value;
-(void)priv_setObjectValueCopy:(id)value;

-(Class)classForProtocol:(Protocol*)aProtocol;

@end
