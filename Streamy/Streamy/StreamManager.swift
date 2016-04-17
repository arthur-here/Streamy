//
//  StreamManager.swift
//  Streamy
//
//  Created by Arthur Myronenko on 4/17/16.
//  Copyright © 2016 Arthur Myronenko. All rights reserved.
//

import AVFoundation

protocol StreamManagerDelegate {
    func streamManager(streamManager: StreamManager, didCaptureFrame: NSImage)
}

class StreamManager: NSObject {
    private let session: AVCaptureSession
    private let dataOutput: AVCaptureVideoDataOutput
    private var delegate: StreamManagerDelegate?
    
    override init() {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPreset960x540
        
        let displayId = CGMainDisplayID()
        
        guard let input = AVCaptureScreenInput(displayID: displayId) else {
            fatalError()
        }
        
        if (session.canAddInput(input)) {
            session.addInput(input)
        }
        
        dataOutput = AVCaptureVideoDataOutput()
        if (session.canAddOutput(dataOutput)) {
            session.addOutput(dataOutput)
        }
        
        super.init()
    }
    
    func startCaptureWithDelegate(delegate: StreamManagerDelegate?) {
        self.delegate = delegate
        session.startRunning()
        dataOutput.setSampleBufferDelegate(self, queue: dispatch_get_main_queue())
    }
    
    func stop() {
        session.stopRunning()
    }
}

extension StreamManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(captureOutput: AVCaptureOutput!,
                       didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,
                       fromConnection connection: AVCaptureConnection!) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return print("Error") }
        let ciImage = CIImage(CVImageBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        let frame = context.createCGImage(ciImage, fromRect: CGRect(x: 0, y: 0, width: width, height: height))
        let result = NSImage(CGImage: frame, size: CGSize(width: width, height: height))
        
        self.delegate?.streamManager(self, didCaptureFrame: result)
    }
}
