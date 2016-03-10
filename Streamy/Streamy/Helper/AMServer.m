//
//  AMServer.m
//  Streamy
//
//  Created by Arthur Myronenko on 3/4/16.
//  Copyright © 2016 Arthur Myronenko. All rights reserved.
//

#import "AMServer.h"
#import "GCDAsyncSocket.h"

@interface AMServer () <GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *server;
@property (nonatomic) BOOL isConnected;
@property (nonatomic) NSInteger tag;

@end

@implementation AMServer

- (instancetype)init {
    if (self = [super init]) {
        _server = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        _tag = 0;
    }
    return self;
}

- (NSInteger)tag {
    _tag += 1;
    return _tag;
}

- (void)connectToHost:(NSString *)host onPort:(NSInteger)port {
    if (self.isConnected) {
        return;
    }
    
    if (port < 0 || port > 65535) {
        NSLog(@"Error! Incorrect port was set");
        return;
    }
    
    NSError *error = nil;
    
    if (![self.server connectToHost:host onPort:port error:&error]) {
        NSLog(@"Error connecting: %@", error);
    }
}

- (void)disconnect {
    if (!self.isConnected) {
        return;
    }
    
    [self.server disconnect];
    NSLog(@"Server disconnected");
    self.isConnected = NO;
}

- (void)sendMessage:(NSString *)message {
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [self.server writeData:messageData withTimeout:-1 tag:self.tag];
}

- (void)sendImage:(NSImage *)image {
    NSData  *tiffData = [image TIFFRepresentation];
    NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:tiffData];
    NSData *jpgData = [bitmap representationUsingType:NSJPEGFileType properties:@{NSImageCompressionFactor: @1.0}];
    [self.server writeData:jpgData withTimeout:-1 tag:self.tag];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"Server connected to host %@:%hu", self.server.localHost, self.server.localPort);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"Server did disconnect with error: %@", err);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"Server did write data with tag %lu", tag);
    [self disconnect];
}

@end
