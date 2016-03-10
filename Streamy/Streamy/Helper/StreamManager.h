//
//  StreamManager.h
//  Streamy
//
//  Created by Arthur Myronenko on 3/3/16.
//  Copyright © 2016 Arthur Myronenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StreamManager;

@protocol StreamManagerDelegate <NSObject>

- (void)streamManager:(StreamManager *)manager didCaptureFrame:(NSImage *)image;

@end

@interface StreamManager : NSObject

- (void)startCaptureWithDelegate:(id<StreamManagerDelegate>)delegate;

- (void)stop;

@end
