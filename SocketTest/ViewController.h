//
//  ViewController.h
//  SocketTest
//
//  Created by xulu on 15/7/28.
//  Copyright (c) 2015年 _MC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPClient.h"
#import "TCPServer.h"
@interface ViewController : UIViewController<TCPClientDelegate,TCPServerDelegate>


@end

