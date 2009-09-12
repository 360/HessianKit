//
//  CWHessianTranslator.h
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

#import <Foundation/Foundation.h>


enum {
  CWHessianMethodTranslationDromedarCase = 0,
  CWHessianMethodTranslationCamelCase = 1
};
typedef int CWHessianMethodTranslation;

/*!
 * @abstract A <code>CWHessianTranslator</code> object is responsible for translating selector, class and protocol names
 *           when sending and receiveng messages. 
 *
 * @discussion Translations can both be automatic to support the conventions of the remote end, and explicit to support
 *             fine grain customizations.
 *             The default implementation supports translation of selector names into C-like names using camel and 
 *             dromedar case. Class names using dot separated name-spaces are also matched against run-times classes with
 *             optional prefixes.
 *             Implement subclasses to support automatic translations for more programming languages at the remote end.
 */
@interface CWHessianTranslator : NSObject {
@private
  CWHessianMethodTranslation _methodTranslation;
  NSString* _localTypeNamePrefix;
  NSString* _distantTypeNamePrefix;
  NSMutableDictionary* typeNameTranslations;
  NSMutableDictionary* methodNameTranslations;
}

@property(assign, nonatomic) CWHessianMethodTranslation methodTranslation;

@property(copy, nonatomic) NSString* localTypeNamePrefix;

@property(copy, nonatomic) NSString* distantTypeNamePrefix;

+(CWHessianTranslator*)defaultHessianTranslator;

-(id)initWithMethodTranslation:(CWHessianMethodTranslation)methodTranslation localTypeNamePrefix:(NSString*)localPrefix distantTypeNamePrefix:(NSString*)distantPrefix;

-(void)setClass:(Class)aClass forDistantTypeName:(NSString*)distantTypeName;

-(void)setProtocol:(Protocol*)aProtocol forDistantTypeName:(NSString*)distantTypeName;

-(Class)classForDistantTypeName:(NSString*)distantName;

-(Protocol*)protocolForDistantTypeName:(NSString*)distantName;

-(NSString*)distantTypeNameForClass:(Class)aClass;

-(NSString*)distantTypeNameForProtocol:(Protocol*)aProtocol;

-(void)setSelector:(SEL)aSelector forDistantMethodName:(NSString*)distantMethodName;

-(NSString*)distantMethodNameForSelector:(SEL)aSelector;

-(SEL)selectorForDistantMethodName:(NSString*)distantMethodName;

@end
