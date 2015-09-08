//
//  SocketServer.m
//  Testing
//
//  Created by xulu on 15/7/27.
//  Copyright (c) 2015年 _MC. All rights reserved.
//

#import "TCPClient.h"
CFSocketRef _socket;
@implementation TCPClient

-(void)createConnect:(NSString *)strAddress {
    CFSocketContext sockContext = {0,//结构体版本，必须为0
        
        (__bridge void *)(self),
        
        NULL,//一个定义在上面指针中的回调，可以为NULL
    
        NULL,
        
        NULL};
    
    _socket = CFSocketCreate(kCFAllocatorDefault,//为新对象分配内存，可以为nil
                             
                             PF_INET,//协议簇，如果为0或者负数，则默认为PF_INET
                             
                             SOCK_STREAM,//套接字类型，如果协议为PE_INET，则它会默认为SOCK_STREAM
                             
                             IPPROTO_TCP,//套接字协议，如果协议为PF_INET且协议是0或者负数，它会默认为IPPROTO_TCP
                             
                             kCFSocketConnectCallBack, //处罚会掉函数的socket消息类型
                             
                             TCPClientConnectCallBack,//上面触发的回调函数
                             
                             &sockContext//一个持有CFSocket结构的信息对象
                             );
    if (_socket != NULL) {
        struct sockaddr_in addr4;//IPV4
        memset(&addr4, 0, sizeof(addr4));
        addr4.sin_len = sizeof(addr4);
        addr4.sin_family = AF_INET;
        addr4.sin_port = htons(8888);
        addr4.sin_addr.s_addr = inet_addr([strAddress  UTF8String]);//把字符串转换为机器可识别的网络地址
        
        CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr4, sizeof(addr4));
        CFSocketConnectToAddress(_socket,//连接socket
                                 
                                 address,//CFDataRef类型的包含上面socket的远程地址的对象
                                 
                                 -1//连接超时时间，如果为负，则不尝试连接，而是把连接放在后台进行，如果_socket消息类型为kCFSocketConnectCallBack,将会在连接成功或者失败的时候在后台触发回调函数
                                 );
        CFRunLoopRef cRunRef = CFRunLoopGetCurrent();//获取当前线程的循环
        
        //创建一个循环，但并没有真正加入到循环中，需要调用CFRunLoopAddSource
        CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, 0);
        CFRunLoopAddSource(cRunRef,//运行循环
                           
                           sourceRef,//增加的运行循环源，它会被retain一次
                           
                           kCFRunLoopCommonModes//增加的运行循环的模式
                           
                           );
        CFRelease(sourceRef);
        NSLog(@"conect ok");
        
    }
}

//socket回调函数
static void TCPClientConnectCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    TCPClient * client = (__bridge TCPClient *)info;
    if (data != NULL) {
        NSLog(@"连接失败");
        return;
    }
    NSLog(@"连接成功");
    
    [client performSelectorInBackground:@selector(readStream) withObject:nil];
    
}

-(void)readStream{
    char buffer[1024];
    while (recv(CFSocketGetNative(_socket), buffer, sizeof(buffer), 0))
    {
        [self performSelectorOnMainThread:@selector(getMessage:) withObject:[NSString stringWithUTF8String:buffer] waitUntilDone:true];
    }
}

-(void)getMessage:(id)message {
    [self.delegate clientReceivedMessage:message];
}

-(void)sendMessage:(NSString *)message {
   const char * data = [message UTF8String];
    send(CFSocketGetNative(_socket), data, strlen(data) + 1, 0);
}

@end
