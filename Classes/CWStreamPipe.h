//
//  CWStreamPipe.h
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


@interface CWStreamPipe : NSObject {
@private
  NSOutputStream* _outputStream;
  NSInputStream* _inputStream;
@protected
  uint8_t* buffer;
  NSUInteger bytesAvailable;
}

@property(readonly, retain, nonatomic) NSOutputStream* outputStream;
@property(readonly, retain, nonatomic) NSInputStream* inputStream;

-(id)initWithCapacity:(NSUInteger)capacity;

@end
