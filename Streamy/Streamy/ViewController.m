//
//  ViewController.m
//  Streamy
//
//  Created by Arthur Myronenko on 3/3/16.
//  Copyright © 2016 Arthur Myronenko. All rights reserved.
//

#import "ViewController.h"
#import "AMServer.h"
#import "StreamManager.h"

@interface ViewController () <StreamManagerDelegate>

@property (weak) IBOutlet NSImageView *imageView;

@property (strong, nonatomic) AMServer *server;
@property (strong, nonatomic) StreamManager *streamManager;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.server = [[AMServer alloc] init];
    self.streamManager = [[StreamManager alloc] init];
}

- (IBAction)start:(NSButton *)sender {

    [self.streamManager startCaptureWithDelegate:self];
    [self.server connectToHost:@"localhost" onPort:8001];
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(sendMessage) userInfo:nil repeats:YES];
}

- (IBAction)stop:(NSButton *)sender {
    [self.server disconnect];
    [self.streamManager stop];
    [self.timer invalidate];
}

- (void)sendMessage {
    [self.server sendImage:self.imageView.image];
    [self.server sendMessage:@"end_of_frame"];
}

#pragma mark - StreamManagerDelegate

- (void)streamManager:(StreamManager *)manager didCaptureFrame:(NSImage *)image {
    self.imageView.image = image;
    [self.server sendImage:self.imageView.image];
    [self.server sendMessage:@"end_of_frame"];
}

@end
