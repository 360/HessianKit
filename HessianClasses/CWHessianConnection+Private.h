//
//  CWHessianConnection+Private.h
//  HessianKit
//
//  Created by Fredrik Olsson on 2009-07-15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWHessianConnection.h"

@class CWHessianArchiver;
@class CWHessianUnarchiver;

@interface CWHessianConnection (Private)

#ifdef GAMEKIT_AVAILABLE
-(void)receiveData:(NSData*)data fromPeer:(NSString*)peer inSession:(GKSession*)session context:(void*)context;
#endif

-(void)forwardInvocation:(NSInvocation*)anInvocation forProxy:(CWDistantHessianObject*)proxy;

-(NSString*)methodNameFromInvocation:(NSInvocation*)invocation;

-(void)writeHeadersToArchiver:(CWHessianArchiver*)archiver;
-(void)writeArgumentAtIndex:(int*)pIndex type:(const char*)type archiver:(CWHessianArchiver*)archiver invocation:(NSInvocation*)invocation;
-(NSData*)archivedDataForInvocation:(NSInvocation*)invocation;

-(NSData*)sendRequestWithPostData:(NSData*)postData;

-(void)readHeaderFromUnarchiver:(CWHessianUnarchiver*)unarchiver;
-(id)unarchiveData:(NSData*)data;
-(void)setReturnValue:(id)value invocation:(NSInvocation*)invocation;

@end
