//
//  Extensions.swift
//  Macam
//
//  Created by Ethan Xu on 2024-04-24.
//

import Foundation
import AppKit

extension NSImage {
    func mirroring() -> NSImage {
        guard let tiffData = self.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let cgImage = bitmapImage.cgImage else { return self }
        
        let baseImage = CIImage(cgImage: cgImage)
        let flippedImage = baseImage.oriented(.upMirrored)
        
        let rep = NSCIImageRep(ciImage: flippedImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
}

extension Notification.Name {
    static let didChangeTrueMirror = Notification.Name("didChangeTrueMirror")
    static let menuBarCapturePhoto = Notification.Name("menuBarCapturePhoto")
}
