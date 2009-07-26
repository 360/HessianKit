//
//  CWHessianChannel.h
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

@protocol CWHessianChannelDelegate;

/*!
 * @abstract The <code>CWHessianChannel</code> abstract class declares an interface for sending and recieving
 *           Hessian messages and responses between a client an a server.
 *
 * @discussion Subclasses must override <code>outputStreamForMessage</code> to return a <code>NSOutputStream</code>
 *             that the <code>CWHessianConnection</code> can write messages and replies to. 
 *             Subclasses must also override <code>finishOutputStreamForMessage:</code> to handle sending of written
 *             data, <code>finishOutputStreamForMessage:</code> should return as quickly as possible. Results are 
 *             handled by <code>CWHessianChannel</code> subclasses asynchroniously calling
 *             <code>-[CWHessianConnection unarchiveReplyFromInputStream:] with a <code>NSInputStream</code> that the
 *             <code>CWHessianConnection</code> can read messages and replies from.
 */
@interface CWHessianChannel : NSObject {
@private
  id<CWHessianChannelDelegate> _delegate;
}

/*!
 * @abstract The Hessian channel delegate.
 */
@property(readonly, assign, nonatomic) id<CWHessianChannelDelegate> delegate;

/*!
 * @abstract Returns and initialized <code>CWHessianChannel</code> object.
 *
 * @param delegate The Hessian channel delegate.
 * @result A Hessian channel.
 */
-(id)initWithDelegate:(id<CWHessianChannelDelegate>)delegate;

/*!
 * @abstract Generate a unique remote ID to use for a vended object.
 *
 * @discussion Default implementation throws an <code>CWHessianObjectNotVendableException</code> exception. Subclasses
 *             for channels that suports vended objects must override.
 *
 * @param anObject an object to generate a remote ID for.
 * @result a unique remote ID.
 */
-(NSString*)remoteIdForObject:(id)anObject;

/*!
 * @abstract Get a <code>NSOutputStream</code> that <code>CWHessianConnection</code> can write a message call or reply to.
 *
 * @discussion Subclasses must override this method. The returned stream must be open, and the channel is responsible
 *             closing the stream and any other maintaincance tasks.
 *
 * @result an open <code>NSOutputStream</code>.
 */
-(NSOutputStream*)outputStreamForMessage;

/*!
 * @abstract Called by the <code>CWHessianConnection</code> to finalize a message or reply.
 *
 * @discussion Subclasses must override this method. When called the complete message has been written to the stream,
 *             subclasses should do what is needed to transmit data and close stream if stream is not re-useable.
 * 
 * @param outputStream the <code>NSOutputStream</code> previosly fetched from <code>outputStreamForMessage</code>.
 */
-(void)finishOutputStreamForMessage:(NSOutputStream*)outputStream;

@end


/*!
 * @abstract Hessian channel delegate protocol.
 */
@protocol CWHessianChannelDelegate

/*!
 * @abstract A message or reply was recieved by channel and delegate should unarchive and act upon it.
 *
 * @param channel the channel.
 * @param the input stream to read message or reply from.
 */
-(void)channel:(CWHessianChannel*)channel didRecieveMessageInInputStream:(NSInputStream*)inputStream;

@end
