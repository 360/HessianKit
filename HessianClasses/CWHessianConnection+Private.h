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

-(id)init;

-(NSNumber*)nextMessageNumber;
-(NSNumber*)lastMessageNumber;

#ifdef GAMEKIT_AVAILABLE
-(void)receiveData:(NSData*)data fromPeer:(NSString*)peer inSession:(GKSession*)session context:(void*)context;
#endif

-(void)forwardInvocation:(NSInvocation*)anInvocation forProxy:(CWDistantHessianObject*)proxy;

-(NSString*)methodNameFromInvocation:(NSInvocation*)invocation;

-(void)writeHeadersToArchiver:(CWHessianArchiver*)archiver;
-(void)writeArgumentAtIndex:(int*)pIndex type:(const char*)type archiver:(CWHessianArchiver*)archiver invocation:(NSInvocation*)invocation;
-(void)archiveInvocation:(NSInvocation*)invocation asMessage:(NSNumber*)messageNumber toOutputStream:(NSOutputStream*)outputStream;

-(NSOutputStream*)outputStreamForHTTPChannel;
-(void)finishOutputStreamForHTTPChannel:(NSOutputStream*)outputStream;

-(NSOutputStream*)outputStreamForStreamChannel;
-(void)finishOutputStreamForStreamChannel:(NSOutputStream*)outputStream;

#ifdef GAMEKIT_AVAILABLE
-(NSOutputStream*)outputStreamForGameKitChannel;
-(void)finishOutputStreamForGameKitChannel:(NSOutputStream*)outputStream;
#endif

-(void)waitForReturnValueForMessage:(NSNumber*)messageNumber invocation:(NSInvocation*)invocation;

-(void)readHeaderFromUnarchiver:(CWHessianUnarchiver*)unarchiver;
-(id)unarchiveDataFromInputStream:(NSInputStream*)inputStream;
-(void)setReturnValue:(id)value invocation:(NSInvocation*)invocation;

-(void)unarchiveReplyFromInputStream:(NSInputStream*)inputStream;

@end
