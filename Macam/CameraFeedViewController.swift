//
//  CameraFeedViewController.swift
//  Macam
//
//  Created by Ethan Xu on 2024-04-15.
//

import Cocoa
import AVFoundation

class CameraFeedViewController: NSViewController {
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        videoPreviewLayer.frame = view.layer?.bounds ?? CGRect.zero
        view.layer?.addSublayer(videoPreviewLayer)
        
        captureSession.startRunning()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        videoPreviewLayer.frame = view.bounds
    }
    
    static func newInstance() -> CameraFeedViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("CameraFeedViewController")
        guard let cameraFeedViewController = storyboard.instantiateController(withIdentifier: identifier) as? CameraFeedViewController else {
            fatalError("Unable to instantiate CameraFeedViewViewController in Main.storyboard")
        }
        return cameraFeedViewController
    }
}
