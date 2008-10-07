//
//  CWHessianConnection+Private.h
//  HessianKit
//
//  Created by Fredrik Olsson on 2008-10-07.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWHessianConnection.h"
#import "CWHessianBonjourServer.h"

@interface CWHessianConnection (Private) <CWHessianBonjourServerDelegate>

@property(retain, nonatomic) NSNetServiceBrowser* netServiceBrowser;
@property(retain, nonatomic) NSNetService* currentResolve;

@end
