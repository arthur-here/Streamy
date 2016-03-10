//
//  StreamManager.m
//  Streamy
//
//  Created by Arthur Myronenko on 3/3/16.
//  Copyright © 2016 Arthur Myronenko. All rights reserved.
//

#import "StreamManager.h"
#import <AVFoundation/AVFoundation.h>

@interface StreamManager () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoDataOutput *dataOutput;

@property (weak, nonatomic) id<StreamManagerDelegate> delegate;

@end

@implementation StreamManager

- (void)startCaptureWithDelegate:(id<StreamManagerDelegate>)delegate {
    self.delegate = delegate;
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPreset960x540;
    
    CGDirectDisplayID displayId = kCGDirectMainDisplay;
    
    AVCaptureScreenInput *input = [[AVCaptureScreenInput alloc] initWithDisplayID:displayId];
    if (!input) {
        self.session = nil;
        return;
    }
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    
    self.dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    if ([self.session canAddOutput:self.dataOutput]) {
        [self.session addOutput:self.dataOutput];
    }
    
    [self.session startRunning];
    
    [self.dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
}

- (void)stop {
    [self.session stopRunning];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGFloat width = CVPixelBufferGetWidth(pixelBuffer);
    CGFloat height = CVPixelBufferGetHeight(pixelBuffer);
    
    CGImageRef myImage = [context
                          createCGImage:ciImage
                          fromRect:CGRectMake(0, 0, width, height)];
    
    NSImage *result = [[NSImage alloc] initWithCGImage:myImage size: CGSizeMake(width, height)];
    CGImageRelease(myImage);

    [self.delegate streamManager:self didCaptureFrame:result];
}

@end
