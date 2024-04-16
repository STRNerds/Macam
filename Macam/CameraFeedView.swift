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
        return CameraFeedViewController.newInstance()
    }
    
    func updateNSViewController(_ nsViewController: CameraFeedViewController, context: Context) {
        
    }
}

#Preview {
    CameraFeedView()
}
