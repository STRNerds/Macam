//
//  ViewController.swift
//  Macam
//
//  Created by Ethan Xu on 2024-04-07.
//

import Cocoa
import AVFoundation
import SwiftUI

class CameraFeedViewController: NSViewController, AVCapturePhotoCaptureDelegate {
    
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
        cameraView.widthAnchor.constraint(equalTo: cameraView.heightAnchor, multiplier: 16/9).isActive = true
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
    
    static func newInstance() -> CameraFeedViewController {
        return CameraFeedViewController()
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
                imageView.isHidden = true
                
                let imageType = SettingsView().imageType
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
                let imageName = dateFormatter.string(from: Date())
                let saveURL = SettingsView().selectedFolder!.appendingPathComponent("\(imageName)\(rawValueToString(imageType.rawValue))")
                
                if let imageData = image.tiffRepresentation {
                    let bitmap = NSBitmapImageRep(data: imageData)
                    let image = bitmap?.representation(using: imageType, properties: [:])
                    do {
                        try image?.write(to: saveURL)
                        print("Image saved to \(saveURL.path)")
                    } catch {
                        print("Failed to save image: \(error)")
                    }
                }
            }
        }
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        videoPreviewLayer.frame = cameraView.bounds
    }
    
    func rawValueToString(_ value: UInt) -> String {
        switch value {
        case 0:
            return ".tiff"
        case 3:
            return ".jpeg"
        case 4:
            return ".png"
        default:
            return ""
        }
    }
}
