//
//  CWHessianConnection+Private.m
//  HessianKit
//
//  Created by Fredrik Olsson on 2008-10-07.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CWHessianConnection+Private.h"


@implementation CWHessianConnection (Private)

@dynamic netServiceBrowser;
@dynamic currentResolve;

-(NSNetServiceBrowser*)netServiceBrowser;
{
	if (_netServiceBrowser == nil) {
  	_netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    _netServiceBrowser.delegate = self;
  }
  return _netServiceBrowser;
}

-(void)setNetServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser;
{
	if (_netServiceBrowser != nil && netServiceBrowser != _netServiceBrowser) {
  	self.currentResolve = nil;
  	[_netServiceBrowser stop];
    [_netServiceBrowser release];
  }
  _netServiceBrowser = netServiceBrowser;
  if (_netServiceBrowser) {
  	[_netServiceBrowser retain];
  }
}

-(NSNetService*)currentResolve;
{
	return _currentResolve;
}

-(void)setCurrentResolve:(NSNetService*)service;
{
	if (_currentResolve != nil && _currentResolve != service) {
		[_currentResolve stop];
    [_currentResolve release];
  }
  _currentResolve = service;
  if (_currentResolve) {
  	[_currentResolve retain];
  }
}

-(void)didAcceptConnectionForServer:(CWHessianBonjourServer*)server inputStream:(NSInputStream*)istr outputStream:(NSOutputStream*)ostr;
{
	[ostr setDelegate:server];
	[istr setDelegate:server];
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing;
{
	if (self.serviceSearchDelegate != nil) {
  	[self.serviceSearchDelegate hessianConnection:self didFindService:service moreComing:moreComing];
  }
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing;
{
	if (self.serviceSearchDelegate != nil) {
  	[self.serviceSearchDelegate hessianConnection:self didRemoveService:service moreComing:moreComing];
  }
}

@end
