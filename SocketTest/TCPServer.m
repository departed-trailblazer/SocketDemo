//
//  TCPServer.m
//  Testing
//
//  Created by xulu on 15/7/27.
//  Copyright (c) 2015年 _MC. All rights reserved.
//

#import "TCPServer.h"
#define TCPServerGetMessage @"TCPServerGetMessage"
CFWriteStreamRef outputStream;
@implementation TCPServer
{
    CFSocketRef _socket;
}

-(int)setupSocket {
    _socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, TCPServerAcceptCallBack, NULL);
    if (_socket == NULL) {
        return 0;
    }
    int optval = 1;
    setsockopt(CFSocketGetNative(_socket), SOL_SOCKET, SO_REUSEADDR,//允许重用本地地址和端口
               
               (void *)&optval, sizeof(optval));
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(8888);
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr4, sizeof(addr4));
    if (kCFSocketSuccess != CFSocketSetAddress(_socket, address)) {
        if (_socket){
            CFRelease(_socket);
        }
            _socket = NULL;
            return 0;
    }
    CFRunLoopRef cfRunLoop = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, 0);
    CFRunLoopAddSource(cfRunLoop, source, kCFRunLoopCommonModes);
    CFRelease(source);
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getMessage:) name:TCPServerGetMessage object:nil];
    return 1;
}

void TCPServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    if (kCFSocketAcceptCallBack == type) {
        //本地套接字句柄
        CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
        uint8_t name[SOCK_MAXADDRLEN];
        socklen_t nameLen = sizeof(name);
        if (0 != getpeername(nativeSocketHandle, (struct sockaddr *)name, &nameLen)) {
            NSLog(@"error");
            exit(1);
        }
        NSLog(@"%s connected.", inet_ntoa( ((struct sockaddr_in*)name )->sin_addr ));
        CFReadStreamRef iStream;
        CFWriteStreamRef oStream;
        //创建可读写的socket连接
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &iStream, &oStream);
        if (iStream && oStream) {
            CFStreamClientContext streamContext = {0,NULL,NULL,NULL};
            if (!CFReadStreamSetClient(iStream, kCFStreamEventHasBytesAvailable, readStream, &streamContext)) {
                exit(1);
            }
            if (!CFWriteStreamSetClient(oStream, kCFStreamEventCanAcceptBytes, writeStream, &streamContext)) {
                exit(1);
            }
            
            CFReadStreamScheduleWithRunLoop(iStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            CFWriteStreamScheduleWithRunLoop(oStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            CFReadStreamOpen(iStream);
            CFWriteStreamOpen(oStream);
        } else {
            exit(1);
        }
    }
    
}

void readStream (CFReadStreamRef stream,CFStreamEventType type,void * clientCallBackInfo) {
    UInt8 buff[255];
    CFReadStreamRead(stream, buff, 255);
    printf("received: %s",buff);
    [[NSNotificationCenter defaultCenter]postNotificationName:TCPServerGetMessage object:[NSString stringWithUTF8String:(const char*)buff]];
}

void writeStream (CFWriteStreamRef stream,CFStreamEventType eventType, void * clientCallBackInfo) {
    outputStream = stream;
}

-(void)runLoopInThread {
    int res = [self setupSocket];
    if (!res) {
        exit(1);
    }
    CFRunLoopRun();
}

-(void)getMessage:(NSNotification *)notification {
    NSString * message = notification.object;
    if (message.length > 0) {
        [self performSelectorOnMainThread:@selector(showMessage:) withObject:message waitUntilDone:YES];
    }
}

-(void)showMessage:(NSString *)message {
    [self.delegate serverReceivedMessage:message];
}

-(void)sendMessage:(NSString *)message {
   const char * string = [message UTF8String];
    uint8_t * uint8b = (uint8_t *)string;
    if (outputStream != NULL) {
        CFWriteStreamWrite(outputStream, uint8b, strlen(string) +1);
    }
}

@end
