//
//  AMServer.h
//  Streamy
//
//  Created by Arthur Myronenko on 3/4/16.
//  Copyright © 2016 Arthur Myronenko. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMServer : NSObject

- (void)connectToHost:(NSString *)host onPort:(NSInteger)port;
- (void)disconnect;

- (void)sendMessage:(NSString *)message;
- (void)sendImage:(NSImage *)image;

@end
