//
//  Test.h
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


@protocol Test

-(void)methodNull;
-(id)argNull:(id)v;
-(void)replyNull;

-(void)argFalse:(BOOL)v;
-(void)argTrue:(BOOL)v;
-(BOOL)replyFalse;
-(BOOL)replyTrue;

-(void)argInt_0:(int32_t)v;
-(void)argInt_m17:(int32_t)v;
-(void)argInt_0x7fffffff:(int32_t)v;
-(void)argInt_m0x80000000:(int32_t)v;
-(int32_t)replyInt_0;
-(int32_t)replyInt_m17;
-(int32_t)replyInt_0x7fffffff;
-(int32_t)replyInt_m0x80000000;

-(void)argLong_0:(int64_t)v;
-(void)argLong_m0x80000000:(int64_t)v;
-(void)argLong_0x7fffffff:(int64_t)v;
-(void)argLong_0x80000000:(int64_t)v;
-(int64_t)replyLong_0;
-(int64_t)replyLong_m0x80000000;
-(int64_t)replyLong_0x7fffffff;
-(int64_t)replyLong_0x80000000;

-(void)argDouble_0_0:(double)v;
-(void)argDouble_0_001:(double)v;
-(void)argDouble_3_14159:(double)v;
-(void)argDouble_m0_001:(double)v;
-(double)replyDouble_0_0;
-(double)replyDouble_0_001;
-(double)replyDouble_3_14159;
-(double)replyDouble_m0_001;

-(void)argString_0:(NSString*)v;
-(void)argString_1:(NSString*)v;
-(void)argString_31:(NSString*)v;
-(NSString*)replyString_0;
-(NSString*)replyString_1;
-(NSString*)replyString_31;

-(void)argBinary_0:(NSData*)v;
-(void)argBinary_15:(NSData*)v;
-(NSData*)replyBinary_0;
-(NSData*)replyBinary_15;

-(void)argDate_0:(NSDate*)v;
-(void)argDate_1:(NSDate*)v;
-(NSDate*)replyDate_0;
-(NSDate*)replyDate_1;

-(void)argUntypedFixedList_0:(NSArray*)v;
-(void)argUntypedFixedList_7:(NSArray*)v;
-(NSArray*)replyUntypedFixedList_0;
-(NSArray*)replyUntypedFixedList_7;

-(void)argUntypedMap_0:(NSDictionary*)v;
-(void)argUntypedMap_2:(NSDictionary*)v;
-(NSDictionary*)replyUntypedMap_0;
-(NSDictionary*)replyUntypedMap_2;

@end