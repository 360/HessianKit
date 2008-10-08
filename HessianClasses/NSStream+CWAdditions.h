//
//  NSStream+CWAdditions.h
//  HessianKit
//
//  Created by Fredrik Olsson on 2008-10-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NSInputStream (CWAdditions)

-(BOOL)readBool;
-(char)readChar;
-(unsigned char)readUnsignedChar;
-(double)readDouble;
-(float)readFloat;
-(int)readInt;
-(unsigned int)readUnsignedInt;
-(NSInteger)readInteger;
-(NSUInteger)readUnsignedInteger;
-(long)readLong;
-(unsigned long)readUnsignedLong;
-(long long)readLongLong;
-(unsigned long long)readUnsignedLongLong;
-(short)readShort;
-(unsigned short)readUnsignedShort;
-(NSData*)readData;
-(NSData*)readDataWithLength:(NSUInteger)length;
-(NSData*)readDataWithUnsignedShortLength:(unsigned short)length;
-(NSString*)readUTF8String;
-(NSString*)readUTF8StringWithBytes:(NSUInteger)bytes;
-(NSString*)readUTF8StringWithUnsignedShortBytes:(unsigned short)bytes;

@end

@interface NSOutputStream (CWAdditions)

-(void)writeBool:(BOOL)value;
-(void)writeChar:(char)value;
-(void)writeUnsignedChar:(unsigned char)value;
-(void)writeDouble:(double)value;
-(void)writeFloat:(float)value;
-(void)writeInt:(int)value;
-(void)writeUnsignedInt:(unsigned int)value;
-(void)writeInteger:(NSInteger)value;
-(void)writeUnsignedInteger:(NSUInteger)value;
-(void)writeLong:(long)value;
-(void)writeUnsignedLong:(unsigned long)value;
-(void)writeLongLong:(long long)value;
-(void)writeUnsignedLongLong:(unsigned long long)value;
-(void)writeShort:(short)value;
-(void)writeUnsignedShort:(unsigned short)value;
-(void)writeData:(NSData*)data;
-(void)writeDataWithLength:(NSData*)data;
-(void)writeDataWithUnsignedShortLength:(NSData*)data;
-(void)writeUTF8String:(NSString*)string;
-(void)writeUTF8StringWithBytes:(NSString*)string;
-(void)writeUTF8StringWithUnsignedShortBytes:(NSString*)string;

@end
