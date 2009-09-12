//
//  CWHessianTranslator+Private.h
//  HessianKit
//
//  Created by Fredrik Olsson on 2009-09-12.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWHessianTranslator.h"

@interface CWHessianTranslator (Private)

-(void)setLocalTypeName:(NSString*)localTypeName forDistantTypeName:(NSString*)distantTypeName;

-(NSString*)distantTypeNameForLocalTypeName:(NSString*)localTypeName;

-(NSString*)localTypeNameForDistantTypeName:(NSString*)distantTypeName;

@end
