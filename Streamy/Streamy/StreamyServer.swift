//
//  StreamyServer.swift
//  Streamy
//
//  Created by Arthur Myronenko on 4/17/16.
//  Copyright © 2016 Arthur Myronenko. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class StreamyServer {
    private let server: GCDAsyncSocket
    private var tag = 0
    
    init() {
        server = GCDAsyncSocket(delegate: nil, delegateQueue: dispatch_get_main_queue())
        server.delegate = self
    }
    
    func connectToHost(host: String, port: UInt16) {
        precondition(port > 0 && port < 65535)
        
        do {
            try server.connectToHost(host, onPort: port)
            print("Server connected")
        } catch (let error) {
            print(error)
            return
        }
    }
    
    func disconnect() {
        server.disconnect()
        print("Server disconnected")
    }
    
    func sendMessage(message: String) {
        let messageData = message.dataUsingEncoding(NSUTF8StringEncoding)
        server.writeData(messageData, withTimeout: -1, tag: getTag())
    }
    
    func sendImage(image: NSImage) {
        guard let
            tiffData = image.TIFFRepresentation,
            bitmap = NSBitmapImageRep(data: tiffData),
            jpgData = bitmap.representationUsingType(.NSJPEGFileType, properties: [NSImageCompressionFactor:0.5])
        else { fatalError() }
        
        server.writeData(jpgData, withTimeout: -1, tag: getTag())
    }
    
    private func getTag() -> Int {
        tag += 1
        return tag
    }
}

extension StreamyServer: GCDAsyncSocketDelegate {
    @objc func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        print("Server connected to host \(host):\(port)")
    }
    
    @objc func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        if (err != nil) {
            print("Server did disconnect with error \(err)")
        } else {
            print("Server did disconnect")
        }
    }
    
    @objc func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        
    }
    
}
