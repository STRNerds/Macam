//
//  CameraFeedView.swift
//  Macam
//
//  Created by Ethan Xu on 2024-04-15.
//

import SwiftUI

struct CameraFeedView: NSViewControllerRepresentable {
    typealias NSViewControllerType = CameraFeedViewController
    
    func makeNSViewController(context: Context) -> CameraFeedViewController {
        let controller = CameraFeedViewController.newInstance()
        controller.view.frame.size = CGSize(width: 640, height: 360)
        return controller
    }
    
    func updateNSViewController(_ nsViewController: CameraFeedViewController, context: Context) {
        
    }
}

#Preview {
    CameraFeedView()
}
