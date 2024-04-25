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
    
    var inMenuBar: Bool
    var imageView: NSImageView!
    var cameraView: NSView!
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var stillImageOutput: AVCapturePhotoOutput!
    var captureDevice: AVCaptureDevice?
    
    init(inMenuBar: Bool) {
        self.inMenuBar = inMenuBar
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        buttonController.view.isHidden = inMenuBar
        
        NSLayoutConstraint.activate([
            buttonController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        setupCamera()
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeTrueMirror(_:)), name: .didChangeTrueMirror, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(capturePhoto), name: .menuBarCapturePhoto, object: nil)
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
            if !UserDefaults.standard.bool(forKey: "trueMirror") {
                videoPreviewLayer.transform = CATransform3DMakeScale(-1, 1, 1)
            }
            cameraView.layer?.addSublayer(videoPreviewLayer)
            
            //captureSession.startRunning()
        } catch {
            print(error)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            if var image = NSImage(data: imageData) {
                if !SettingsView().trueMirror {
                    image = NSImage(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!, size: image.size).mirroring()
                }
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
    
    override func viewWillAppear() {
        captureSession.startRunning()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        if (captureSession.isRunning) {
            print("captureSession.stopRunning()")
            captureSession.stopRunning()
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
    
    @objc func didChangeTrueMirror(_ notification: Notification) {
        videoPreviewLayer.removeFromSuperlayer()
            
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        
        if !SettingsView().trueMirror {
            videoPreviewLayer.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1))
        }
        
        cameraView.layer?.addSublayer(videoPreviewLayer)
        videoPreviewLayer.frame = cameraView.bounds
    }
}
