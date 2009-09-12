//
//  CWHessianTranslator.m
//  HessianKit
//
//  Copyright 2009 Fredrik Olsson, Cocoway. All rights reserved.
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

#import "CWHessianTranslator.h"
#import "CWHessianTranslator+Private.h"


@implementation CWHessianTranslator

@synthesize methodTranslation = _methodTranslation;

@synthesize localTypeNamePrefix = _localTypeNamePrefix;

@synthesize distantTypeNamePrefix = _distantTypeNamePrefix;

+(CWHessianTranslator*)defaultHessianTranslator;
{
  CWHessianTranslator* translator = [[self alloc] initWithMethodTranslation:CWHessianMethodTranslationDromedarCase 
                                                        localTypeNamePrefix:nil
                                                      distantTypeNamePrefix:nil];
  return [translator autorelease];
}

-(void)dealloc;
{
  self.localTypeNamePrefix = nil;
  self.distantTypeNamePrefix = nil;
  [typeNameTranslations release];
  [methodNameTranslations release];
  [super dealloc];
}

-(id)initWithMethodTranslation:(CWHessianMethodTranslation)methodTranslation localTypeNamePrefix:(NSString*)localPrefix distantTypeNamePrefix:(NSString*)distantPrefix;
{
  self = [super init];
  if (self) {
    self.methodTranslation = methodTranslation;
    self.localTypeNamePrefix = localPrefix;
    self.distantTypeNamePrefix = distantPrefix;
    typeNameTranslations = [NSMutableDictionary new];
    methodNameTranslations = [NSMutableDictionary new];
  }
  return self;
}

-(void)setClass:(Class)aClass forDistantTypeName:(NSString*)distantTypeName;
{
  [self setLocalTypeName:NSStringFromClass(aClass) forDistantTypeName:distantTypeName];
}

-(void)setProtocol:(Protocol*)aProtocol forDistantTypeName:(NSString*)distantTypeName;
{
  [self setLocalTypeName:NSStringFromProtocol(aProtocol) forDistantTypeName:distantTypeName];
}

-(Class)classForDistantTypeName:(NSString*)distantName;
{
  return NSClassFromString([self localTypeNameForDistantTypeName:distantName]);
}

-(Protocol*)protocolForDistantTypeName:(NSString*)distantName;
{
  return NSProtocolFromString([self localTypeNameForDistantTypeName:distantName]);
}

-(NSString*)distantTypeNameForClass:(Class)aClass;
{
  return [self distantTypeNameForLocalTypeName:NSStringFromClass(aClass)];
}

-(NSString*)distantTypeNameForProtocol:(Protocol*)aProtocol;
{
  return [self distantTypeNameForLocalTypeName:NSStringFromProtocol(aProtocol)];
}

-(void)setSelector:(SEL)aSelector forDistantMethodName:(NSString*)distantMethodName;
{
  [methodNameTranslations setObject:distantMethodName forKey:NSStringFromSelector(aSelector)];
}

-(NSString*)distantMethodNameForSelector:(SEL)aSelector;
{
  NSString* localSelectorName = NSStringFromSelector(aSelector);
  NSString* distantMethodName = [methodNameTranslations objectForKey:localSelectorName];
  if (distantMethodName == nil) {
    NSMutableArray* splittedName = [NSMutableArray arrayWithArray:[localSelectorName componentsSeparatedByString:@":"]];
    for (int index = 0; index < [splittedName count]; index++) {
      if (index > 0 || _methodTranslation == CWHessianMethodTranslationCamelCase) {
        NSString* namePart = [splittedName objectAtIndex:index];
        if ([namePart length] > 0) {
          NSString* firstChar = [[namePart substringToIndex:1] uppercaseString];
          NSString* remainingChars = [namePart substringFromIndex:1];
          namePart = [firstChar stringByAppendingString:remainingChars];
        }
        [splittedName replaceObjectAtIndex:index withObject:namePart];
      }
    }
    distantMethodName = [splittedName componentsJoinedByString:@""];
    [self setSelector:aSelector forDistantMethodName:distantMethodName];
  }
  return distantMethodName;
}

-(SEL)selectorForDistantMethodName:(NSString*)distantMethodName;
{
  NSArray* knownLocalSelectors = [methodNameTranslations allKeysForObject:distantMethodName];
  if ([knownLocalSelectors count] > 0) {
    return NSSelectorFromString([knownLocalSelectors objectAtIndex:0]);
  }
  return NSSelectorFromString(distantMethodName);
}

@end
