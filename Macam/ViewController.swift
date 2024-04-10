//
//  ViewController.swift
//  Macam
//
//  Created by Ethan Xu on 2024-04-07.
//

import Cocoa
import AVFoundation
import SwiftUI

class ViewController: NSViewController, AVCapturePhotoCaptureDelegate {
    
    var imageView: NSImageView!
    var cameraView: NSView!
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var stillImageOutput: AVCapturePhotoOutput!
    var captureDevice: AVCaptureDevice?

    override func viewDidLoad() {
        super.viewDidLoad()

        cameraView = NSView()
        cameraView.wantsLayer = true
        cameraView.layer?.cornerRadius = 10
        cameraView.layer?.masksToBounds = true
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cameraView)
        
        imageView = NSImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        
        cameraView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let captureButton = CaptureButton {
            self.capturePhoto()
        }
        
        let buttonController = NSHostingController(rootView: captureButton)
        buttonController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(buttonController.view)
        
        NSLayoutConstraint.activate([
            buttonController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        setupCamera()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @objc func capturePhoto() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                let settings = AVCapturePhotoSettings()
                self.stillImageOutput.capturePhoto(with: settings, delegate: self)
            } else {
                debugPrint("Camera cannot accessed")
            }
        }
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        if discoverySession.devices.count > 0 {
            captureDevice = discoverySession.devices.first
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession.addInput(input)
            
            stillImageOutput = AVCapturePhotoOutput()
            captureSession.addOutput(stillImageOutput)
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.connection?.videoRotationAngle = 0
            videoPreviewLayer.frame = cameraView.bounds
            cameraView.layer?.addSublayer(videoPreviewLayer)
            
            captureSession.startRunning()
        } catch {
            print(error)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            if let image = NSImage(data: imageData) {
                imageView.image = image
                
                let savePanel = NSSavePanel()
                savePanel.allowedContentTypes = [UTType.png]
                savePanel.nameFieldStringValue = "capturedPhoto.png"
                savePanel.begin{ (result) in
                    if result == .OK {
                        if let url = savePanel.url {
                            if let pngData = image.tiffRepresentation {
                                let bitmap = NSBitmapImageRep(data: pngData)
                                let pngImage = bitmap?.representation(using: .png, properties: [:])
                                do {
                                    try pngImage?.write(to: url)
                                    print("Image saved to \(url.path)")
                                } catch {
                                    print("Failed to save image: \(error)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        if (captureSession.isRunning) {
            captureSession.stopRunning()
        }
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        videoPreviewLayer.frame = cameraView.bounds
    }
}
