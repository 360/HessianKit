//
//  CWHessianBonjourServer.m
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

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
//#include <CFNetwork/CFSocketStream.h>

#import "CWHessianBonjourServer.h"

NSString * const CWHessianBonjourServerErrorDomain = @"CWHessianBonjourServerErrorDomain";

static void BonjourServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info);

@interface CWHessianBonjourServer ()
@property(nonatomic,retain) NSNetService* netService;
@property(assign) uint16_t port;
@end

@implementation CWHessianBonjourServer

@synthesize vendedObject = _vendedObject, delegate=_delegate, netService=_netService, port=_port;

-(id)init;
{
	return self;
}

-(void)dealloc;
{
  [self stop];
  [super dealloc];
}

+(NSString*)bonjourTypeFromApplicationProtocol:(NSString*)protocol;
{
	if (![protocol length]) {
		return nil;
  }
  return [NSString stringWithFormat:@"_%@._tcp.", protocol];
}

-(BOOL)startAndReturnError:(NSError**)error;
{
  CFSocketContext socketCtxt = {0, self, NULL, NULL, NULL};
  _ipv4socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&BonjourServerAcceptCallBack, &socketCtxt);

  if (NULL == _ipv4socket) {
    if (error) {
    	*error = [[NSError alloc] initWithDomain:CWHessianBonjourServerErrorDomain code:CWHessianBonjourServerNoSocketsAvailable userInfo:nil];
      [*error autorelease];
    }
    if (_ipv4socket) {
    	CFRelease(_ipv4socket);
    }
    _ipv4socket = NULL;
    return NO;
  }

  int yes = 1;
  setsockopt(CFSocketGetNative(_ipv4socket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));

  // set up the IPv4 endpoint; use port 0, so the kernel will choose an arbitrary port for us, which will be advertised using Bonjour
  struct sockaddr_in addr4;
  memset(&addr4, 0, sizeof(addr4));
  addr4.sin_len = sizeof(addr4);
  addr4.sin_family = AF_INET;
  addr4.sin_port = 0;
  addr4.sin_addr.s_addr = htonl(INADDR_ANY);
  NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];

  if (kCFSocketSuccess != CFSocketSetAddress(_ipv4socket, (CFDataRef)address4)) {
    if (error) {
    	*error = [[NSError alloc] initWithDomain:CWHessianBonjourServerErrorDomain code:CWHessianBonjourServerCouldNotBindToIPv4Address userInfo:nil];
      [*error autorelease];
    }
    if (_ipv4socket) {
    	CFRelease(_ipv4socket);
    }
    _ipv4socket = NULL;
    return NO;
  }

  // now that the binding was successful, we get the port number 
  // -- we will need it for the NSNetService
  NSData* addr = [(NSData*)CFSocketCopyAddress(_ipv4socket) autorelease];
  memcpy(&addr4, [addr bytes], [addr length]);
  self.port = ntohs(addr4.sin_port);

  // set up the run loop sources for the sockets
  CFRunLoopRef cfrl = CFRunLoopGetCurrent();
  CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _ipv4socket, 0);
  CFRunLoopAddSource(cfrl, source4, kCFRunLoopCommonModes);
  CFRelease(source4);

  return YES;
}

-(BOOL)stop;
{
  [self disableBonjour];

  if (_ipv4socket) {
    CFSocketInvalidate(_ipv4socket);
    CFRelease(_ipv4socket);
    _ipv4socket = NULL;
  }
  return YES;
}

-(BOOL)enableBonjourWithDomain:(NSString*)domain applicationProtocol:(NSString*)protocol name:(NSString*)name;
{
	if(![domain length]) {
		domain = @""; //Will use default Bonjour registration doamins, typically just ".local"
	}
	if(![name length]) {
		name = @""; //Will use default Bonjour name, e.g. the name assigned to the device in iTunes
	}
	
	if(!protocol || ![protocol length] || _ipv4socket == NULL) {
		return NO;
	}

	self.netService = [[NSNetService alloc] initWithDomain:domain type:[CWHessianBonjourServer bonjourTypeFromApplicationProtocol:protocol] name:name port:self.port];
	if(self.netService == nil) {
		return NO;
	}
  	
	[self.netService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[self.netService publish];
	[self.netService setDelegate:self];
	
	return YES;
}

-(void)disableBonjour;
{
	if(self.netService) {
		[self.netService stop];
		[self.netService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		self.netService = nil;
	}
}

@end


@implementation CWHessianBonjourServer (Private)

-(void)handleNewConnectionFromAddress:(NSData*)addr inputStream:(NSInputStream*)istr outputStream:(NSOutputStream*)ostr;
{
  // if the delegate implements the delegate method, call it  
  if (self.delegate && [self.delegate respondsToSelector:@selector(didAcceptConnectionForServer:inputStream:outputStream:)]) { 
	  [self.delegate didAcceptConnectionForServer:self inputStream:istr outputStream:ostr];
  }
}

// This function is called by CFSocket when a new connection comes in.
// We gather some data here, and convert the function call to a method
// invocation on CWHessianBonjourServer.
static void BonjourServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
  CWHessianBonjourServer *server = (CWHessianBonjourServer *)info;
  if (kCFSocketAcceptCallBack == type) { 
    // for an AcceptCallBack, the data parameter is a pointer to a CFSocketNativeHandle
    CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
    uint8_t name[SOCK_MAXADDRLEN];
    socklen_t namelen = sizeof(name);
    NSData *peer = nil;
    if (0 == getpeername(nativeSocketHandle, (struct sockaddr *)name, &namelen)) {
      peer = [NSData dataWithBytes:name length:namelen];
    }
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);
    if (readStream && writeStream) {
      CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
      CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
      [server handleNewConnectionFromAddress:peer inputStream:(NSInputStream*)readStream outputStream:(NSOutputStream*)writeStream];
    } else {
      // on any failure, need to destroy the CFSocketNativeHandle 
      // since we are not going to use it any more
      close(nativeSocketHandle);
    }
    if (readStream) {
    	CFRelease(readStream);
    }
    if (writeStream) {
    	CFRelease(writeStream);
    }
  }
}

/*
 Bonjour will not allow conflicting service instance names (in the same domain), and may have automatically renamed
 the service if there was a conflict.  We pass the name back to the delegate so that the name can be displayed to
 the user.
 See http://developer.apple.com/networking/bonjour/faq.html for more information.
 */

-(void)netServiceDidPublish:(NSNetService*)sender;
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(serverDidEnableBonjour:withName:)]) {
	  [self.delegate serverDidEnableBonjour:self withName:sender.name];
	}
}

-(void)netService:(NSNetService*)sender didNotPublish:(NSDictionary*)errorDict;
{
	[super netServiceDidPublish:sender];
	if(self.delegate && [self.delegate respondsToSelector:@selector(server:didNotEnableBonjour:)]) {
		[self.delegate server:self didNotEnableBonjour:errorDict];
	}
}

-(NSString*)description;
{
	return [NSString stringWithFormat:@"<%@ = 0x%08X | port %d | netService = %@>", [self class], (long)self, self.port, self.netService];
}

- (void)stream:(NSStream*)stream handleEvent:(NSStreamEvent)streamEvent;
{
	// TODO: If this is the input stream, then we should read the request, forward to our object, and return the result in the output stream.
}

@end

