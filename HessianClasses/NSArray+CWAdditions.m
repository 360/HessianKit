//
//  NSArray+CWAdditions.m
//  HessianKit
//
//  Created by Fredrik Olsson on 2008-10-07.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSArray+CWAdditions.h"


@implementation NSArray (CWAdditions)

-(NSArray*)arrayWithReturnValuesForMakeObjectPerformSelector:(SEL)aSelector;
{
	NSMutableArray* resultArray = [NSMutableArray arrayWithCapacity:[self count]];
  for (id<NSObject> anObject in self) {
  	[resultArray addObject:[anObject performSelector:aSelector]];
  }
	return resultArray;
}

@end
