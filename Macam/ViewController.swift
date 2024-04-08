//
//  ViewController.swift
//  Macam
//
//  Created by Ethan Xu on 2024-04-07.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, AVCapturePhotoCaptureDelegate {
    
    var imageView: NSImageView!
    var button: NSButton!
    var cameraView: NSView!
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var stillImageOutput: AVCapturePhotoOutput!
    var captureDevice: AVCaptureDevice?

    override func viewDidLoad() {
        super.viewDidLoad()

        cameraView = NSView()
        cameraView.wantsLayer = true
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(cameraView)
        
        imageView = NSImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)
        
        button = NSButton(title: "Capture Photo", target: self, action: #selector(capturePhoto(_:)))
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        
        cameraView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        cameraView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        cameraView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        
        setupCamera()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @objc func capturePhoto(_ sender: NSButton) {
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
            videoPreviewLayer.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            cameraView.layer?.addSublayer(videoPreviewLayer)
            
            captureSession.startRunning()
        } catch {
            print(error)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
          print("Error capturing photo: \(error)")
          return
        }

        guard let photoData = photo.fileDataRepresentation() else {
          print("Failed to get photo data")
          return
        }

        // Get a filename for the image (replace "image.jpg" with your logic)
        let filename = "image.jpg"

        // Get the desired destination folder path (replace "your/folder/path" with your actual path)
        let destinationURL = FileManager.default.homeDirectoryForCurrentUser

        // Create a complete file path within the destination folder
        let filePath = destinationURL.appendingPathComponent(filename)

        do {
          try photoData.write(to: filePath)
          print("Image saved successfully!")
        } catch {
          print("Error saving photo data: \(error)")
        }
        if let imageData = photo.fileDataRepresentation() {
            if let image = NSImage(data: imageData) {
                imageView.image = image
                captureSession.stopRunning()
            }
        }
    }
}
