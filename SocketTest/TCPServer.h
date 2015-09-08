//
//  TCPServer.h
//  Testing
//
//  Created by xulu on 15/7/27.
//  Copyright (c) 2015年 _MC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>
@protocol TCPServerDelegate <NSObject>
-(void)serverReceivedMessage:(NSString *)message;
@end
@interface TCPServer : NSObject
@property (nonatomic,weak) id<TCPServerDelegate> delegate;
-(void)runLoopInThread;
-(void)sendMessage:(NSString *)message;
@end
