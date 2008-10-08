//
//  NSStream+CWAdditions.m
//  HessianKit
//
//  Created by Fredrik Olsson on 2008-10-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSStream+CWAdditions.h"


@implementation NSInputStream (CWAdditions)

-(BOOL)readBool;
{
	BOOL value;
  [self read:(void*)&value maxLength:sizeof(value)];
  return value;
}

-(char)readChar;
{
	char value;
  [self read:(void*)&value maxLength:sizeof(value)];
  return value;
}

-(unsigned char)readUnsignedChar;
{
	unsigned char value;
  [self read:&value maxLength:sizeof(value)];
  return value;
}

-(double)readDouble;
{
	double value;
  [self read:(void*)&value maxLength:sizeof(value)];
  return NSSwapBigDoubleToHost(NSConvertHostDoubleToSwapped(value));
}

-(float)readFloat;
{
	double value;
  [self read:(void*)&value maxLength:sizeof(value)];
  return NSSwapBigFloatToHost(NSConvertHostFloatToSwapped(value));
}

-(int)readInt;
{
	int value;
  [self read:(void*)&value maxLength:sizeof(value)];
  return NSSwapBigIntToHost(value);
}

-(unsigned int)readUnsignedInt;
{
	int value;
  [self read:(void*)&value maxLength:sizeof(value)];
  return (unsigned int)NSSwapBigIntToHost(value);
}

-(NSInteger)readInteger;
{
	NSInteger value;
  [self read:(void*)&value maxLength:sizeof(value)];
	if (sizeof(NSInteger) == sizeof(int))
  	return NSSwapBigIntToHost(value);
	else
  	return NSSwapBigLongLongToHost(value);
}

-(NSUInteger)readUnsignedInteger;
{
	NSInteger value;
  [self read:(void*)&value maxLength:sizeof(value)];
	if (sizeof(NSInteger) == sizeof(int))
  	return (NSUInteger)NSSwapBigIntToHost(value);
	else
  	return (NSUInteger)NSSwapBigLongLongToHost(value);
}

-(long)readLong;
{
	long value;
  [self read:(void*)&value maxLength:sizeof(value)];
  return NSSwapBigLongToHost(value);
}

-(unsigned long)readUnsignedLong;
{
	long value;
  [self read:(void*)&value maxLength:sizeof(value)];
  return (unsigned long)NSSwapBigLongToHost(value);
}

-(long long)readLongLong;
{
	long long value;
  [self read:(void*)&value maxLength:sizeof(value)];
  return NSSwapBigLongLongToHost(value);
}

-(unsigned long long)readUnsignedLongLong;
{
	long long value;
  [self read:(void*)&value maxLength:sizeof(value)];
  return (unsigned long long)NSSwapBigLongToHost(value);
}

-(short)readShort;
{
	short value;
  [self read:(void*)&value maxLength:sizeof(value)];
  return NSSwapBigShortToHost(value);
}

-(unsigned short)readUnsignedShort;
{
	short value;
  [self read:(void*)&value maxLength:sizeof(value)];
  return (unsigned short)NSSwapBigShortToHost(value);
}

-(NSData*)readData;
{
	NSUInteger length = [self readUnsignedInteger];
  return [self readDataWithLength:length];
}

-(NSData*)readDataWithLength:(NSUInteger)length;
{
	NSMutableData* data = [NSMutableData dataWithLength:length];
	[self read:[data mutableBytes] maxLength:length];
  return [NSData dataWithData:data];
}

-(NSData*)readDataWithUnsignedShortLength:(unsigned short)length;
{
	NSMutableData* data = [NSMutableData dataWithLength:(NSUInteger)length];
	[self read:[data mutableBytes] maxLength:(NSUInteger)length];
  return [NSData dataWithData:data];
}

-(NSString*)readUTF8String;
{
	NSUInteger bytes = [self readUnsignedInteger];
  return [self readUTF8StringWithBytes:bytes];
}

-(NSString*)readUTF8StringWithBytes:(NSUInteger)bytes;
{
	NSData* data = [self readDataWithLength:bytes];
  NSString* string = [NSString alloc];
  [string initWithData:data encoding:NSUTF8StringEncoding];
  return [string autorelease];
}

-(NSString*)readUTF8StringWithUnsignedShortBytes:(unsigned short)bytes;
{
	NSData* data = [self readDataWithUnsignedShortLength:bytes];
  NSString* string = [NSString alloc];
  [string initWithData:data encoding:NSUTF8StringEncoding];
  return [string autorelease];
}

@end



@implementation NSOutputStream (CWAdditions)

-(void)writeBool:(BOOL)value;
{
	[self write:(void*)&value maxLength:sizeof(value)];
}

-(void)writeChar:(char)value;
{
	[self write:(void*)&value maxLength:sizeof(value)];
}

-(void)writeUnsignedChar:(unsigned char)value;
{
	[self write:&value maxLength:sizeof(value)];
}

-(void)writeDouble:(double)value;
{
	value = NSConvertSwappedDoubleToHost(NSSwapHostDoubleToBig(value));
	[self write:(void*)&value maxLength:sizeof(value)];
}

-(void)writeFloat:(float)value;
{
	value = NSConvertSwappedFloatToHost(NSSwapHostFloatToBig(value));
	[self write:(void*)&value maxLength:sizeof(value)];
}

-(void)writeInt:(int)value;
{
	value = NSSwapHostIntToBig(value);
	[self write:(void*)&value maxLength:sizeof(value)];
}

-(void)writeUnsignedInt:(unsigned int)value;
{
	value = NSSwapHostIntToBig((int)value);
	[self write:(void*)&value maxLength:sizeof(value)];
}

-(void)writeInteger:(NSInteger)value;
{
	if (sizeof(NSInteger) == sizeof(int))
		value = NSSwapHostIntToBig(value);
	else
		value = NSSwapHostLongLongToBig(value);
	[self write:(void*)&value maxLength:sizeof(value)];
}

-(void)writeUnsignedInteger:(NSUInteger)value;
{
	if (sizeof(NSInteger) == sizeof(int))
		value = NSSwapHostIntToBig((NSInteger)value);
	else
		value = NSSwapHostLongLongToBig((NSInteger)value);
	[self write:(void*)&value maxLength:sizeof(value)];
}

-(void)writeLong:(long)value;
{
	value = NSSwapHostLongToBig((int)value);
	[self write:(void*)&value maxLength:sizeof(value)];
}

-(void)writeUnsignedLong:(unsigned long)value;
{
	value = NSSwapHostLongToBig((long)value);
	[self write:(void*)&value maxLength:sizeof(value)];
}

-(void)writeLongLong:(long long)value;
{
	value = NSSwapHostLongLongToBig(value);
	[self write:(void*)&value maxLength:sizeof(value)];
}

-(void)writeUnsignedLongLong:(unsigned long long)value;
{
	value = NSSwapHostLongLongToBig((long long)value);
	[self write:(void*)&value maxLength:sizeof(value)];
}

-(void)writeShort:(short)value;
{
	value = NSSwapHostShortToBig(value);
	[self write:(void*)&value maxLength:sizeof(value)];
}

-(void)writeUnsignedShort:(unsigned short)value;
{
	value = NSSwapHostShortToBig((short)value);
	[self write:(void*)&value maxLength:sizeof(value)];
}

-(void)writeData:(NSData*)data;
{
	NSUInteger length = [data length];
  [self write:[data bytes] maxLength:length];
}

-(void)writeDataWithLength:(NSData*)data;
{
	[self writeUnsignedLongLong:[data length]];
	[self writeData:data];
}

-(void)writeDataWithUnsignedShortLength:(NSData*)data;
{
	NSUInteger length = [data length];
  if (length > USHRT_MAX) {
  	[NSException raise:NSInvalidArgumentException format:@"length exceeds unsigned short"];
  }
	[self writeUnsignedShort:(unsigned short)length];
	[self writeData:data];
}

-(void)writeUTF8String:(NSString*)string;
{
	NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
  [self writeData:data];
}

-(void)writeUTF8StringWithBytes:(NSString*)string;
{
	NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
  [self writeDataWithLength:data];
}

-(void)writeUTF8StringWithUnsignedShortBytes:(NSString*)string;
{
	NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
  [self writeDataWithUnsignedShortLength:data];
}

@end