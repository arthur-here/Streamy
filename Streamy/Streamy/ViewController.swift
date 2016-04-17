//
//  ViewController.swift
//  Streamy
//
//  Created by Arthur Myronenko on 4/17/16.
//  Copyright © 2016 Arthur Myronenko. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var imageView: NSImageView!
    
    private let server = StreamyServer()
    private let streamManager = StreamManager()
    private var started = false

    @IBAction func toggle(sender: NSButton) {
        if started {
            sender.title = "Start"
            stop()
        } else {
            sender.title = "Stop"
            start()
        }
    }
    
    private func start() {
        started = false
        streamManager.startCaptureWithDelegate(self)
        server.connectToHost("localhost", port: 8001)
    }
    
    private func stop() {
        started = false
        streamManager.stop()
        server.disconnect()
    }
}

extension ViewController: StreamManagerDelegate {
    func streamManager(streamManager: StreamManager, didCaptureFrame frame: NSImage) {
        imageView.image = frame
        server.sendImage(frame)
        server.sendMessage("end_of_frame")
    }
}