//
//  SocketServer.h
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
@protocol TCPClientDelegate <NSObject>

-(void)clientReceivedMessage:(NSString *)message;

@end

@interface TCPClient : NSObject
@property (nonatomic,weak) id<TCPClientDelegate>delegate;
-(void)createConnect:(NSString *)strAddress;
-(void)sendMessage:(NSString *)message;
@end
