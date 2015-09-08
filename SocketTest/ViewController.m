//
//  ViewController.m
//  SocketTest
//
//  Created by xulu on 15/7/28.
//  Copyright (c) 2015年 _MC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (nonatomic,strong)TCPClient * client;
@property (nonatomic,strong)TCPServer * server;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.server = [[TCPServer alloc]init];
    self.server.delegate = self;
    dispatch_queue_t queue = dispatch_queue_create("serverThread", NULL);
    dispatch_async(queue, ^{
        [self.server runLoopInThread];
    });
    self.client = [[TCPClient alloc]init];
    [self.client createConnect:@"192.168.1.116"];
    self.client.delegate = self;
}

- (IBAction)sendMassage:(id)sender {
    if (self.textField.text.length >0) {
        [self.client sendMessage:self.textField.text];
    }
}
- (IBAction)serverSend:(id)sender {
    [self.server sendMessage:self.textField.text];
}

-(void)clientReceivedMessage:(NSString *)message {
    self.textLabel.text = message;
}

-(void)serverReceivedMessage:(NSString *)message {
    self.textLabel.text = message;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
