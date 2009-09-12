//
//  CWHessianTranslator+Private.m
//  HessianKit
//
//  Created by Fredrik Olsson on 2009-09-12.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CWHessianTranslator+Private.h"


@implementation CWHessianTranslator (Private)

-(void)setLocalTypeName:(NSString*)localTypeName forDistantTypeName:(NSString*)distantTypeName;
{
  [typeNameTranslations setObject:distantTypeName forKey:localTypeName];
}

-(NSString*)distantTypeNameForLocalTypeName:(NSString*)localTypeName;
{
  NSString* distantTypeName = [typeNameTranslations objectForKey:localTypeName];
  if (distantTypeName == nil) {
    NSString* distantTypeName = localTypeName;
    if (_localTypeNamePrefix != nil && [localTypeName hasPrefix:_localTypeNamePrefix]) {
      distantTypeName = [localTypeName substringFromIndex:[_localTypeNamePrefix length]];
    }
    if (_distantTypeNamePrefix != nil) {
      distantTypeName = [_distantTypeNamePrefix stringByAppendingString:distantTypeName];
    }
    [self setLocalTypeName:localTypeName forDistantTypeName:distantTypeName];
  }
  return distantTypeName;
}

-(NSString*)localTypeNameForDistantTypeName:(NSString*)distantTypeName;
{
  NSArray* knownLocalTypeNames = [typeNameTranslations allKeysForObject:distantTypeName];
  if ([knownLocalTypeNames count] > 0) {
    return [knownLocalTypeNames objectAtIndex:0];
  }
  NSString* localTypeName = distantTypeName;
  if (_distantTypeNamePrefix != nil && [distantTypeName hasPrefix:_distantTypeNamePrefix]) {
    localTypeName = [localTypeName substringFromIndex:[_distantTypeNamePrefix length]];
  }
  NSInteger lastDotPosition = [localTypeName rangeOfString:@"." options:NSBackwardsSearch].location;
  if (lastDotPosition != NSNotFound) {
    localTypeName = [localTypeName substringFromIndex:lastDotPosition + 1];
  }
  if (_localTypeNamePrefix != nil) {
    NSString* potentialLocalTypeName = [_localTypeNamePrefix stringByAppendingString:localTypeName];
    if (NSProtocolFromString(potentialLocalTypeName) != nil || NSClassFromString(potentialLocalTypeName)) {
      localTypeName = potentialLocalTypeName;
    }
  }
  [self setLocalTypeName:localTypeName forDistantTypeName:distantTypeName];
  return localTypeName;
}

@end
