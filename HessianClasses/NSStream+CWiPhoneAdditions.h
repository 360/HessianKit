//
//  NSTream+CWiPhoneAdditions.h
//  HessianKit
//
//  Created by Fredrik Olsson on 2009-07-16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSStream (CWiPhoneAdditions)

+(void)getStreamsToHostAddress:(NSString*)host 
                          port:(NSInteger)port 
                   inputStream:(NSInputStream**)inputStream 
                  outputStream:(NSOutputStream**)outputStream;

@end
