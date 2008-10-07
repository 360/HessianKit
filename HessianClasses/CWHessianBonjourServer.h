//
//  CWHessianBonjourServer.h
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

@protocol CWHessianBonjourServerDelegate;

NSString* const CWHessianBonjourServerErrorDomain;

enum {
  CWHessianBonjourServerCouldNotBindToIPv4Address = 1,
  CWHessianBonjourServerCouldNotBindToIPv6Address = 2,
  CWHessianBonjourServerNoSocketsAvailable = 3,
};
typedef NSUInteger CWHessianBonjourServerErrorCode;

@interface CWHessianBonjourServer : NSObject {
@private
	id<NSObject> _vendedObject;
	id<CWHessianBonjourServerDelegate> _delegate;
  uint16_t _port;
	CFSocketRef _ipv4socket;
	NSNetService* _netService;
}

@property(nonatomic, retain) id<NSObject> vendedObject;
@property(nonatomic, assign) id<CWHessianBonjourServerDelegate> delegate;

+(NSString*)bonjourTypeFromIdentifier:(NSString*)identifier;
	
-(BOOL)startAndReturnError:(NSError**)error;
-(BOOL)stop;
-(BOOL)enableBonjourWithDomain:(NSString*)domain applicationProtocol:(NSString*)protocol name:(NSString*)name;
-(void)disableBonjour;

@end

@protocol CWHessianBonjourServerDelegate <NSObject>
@required
-(void)didAcceptConnectionForServer:(CWHessianBonjourServer*)server inputStream:(NSInputStream*)istr outputStream:(NSOutputStream*)ostr;

@optional
-(void)serverDidEnableBonjour:(CWHessianBonjourServer*)server withName:(NSString*)name;
-(void)server:(CWHessianBonjourServer*)server didNotEnableBonjour:(NSDictionary *)errorDict;

@end

