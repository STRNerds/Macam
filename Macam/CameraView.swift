//
//  CameraView.swift
//  Macam
//
//  Created by Ethan Xu on 2024-04-07.
//

import SwiftUI

struct CameraView: NSViewControllerRepresentable {
    typealias NSViewControllerType = ViewController
    
    func makeNSViewController(context: NSViewControllerRepresentableContext<CameraView>) -> ViewController {
        return ViewController(inMenuBar: false)
    }
    
    func updateNSViewController(_ nsViewController: ViewController, context: NSViewControllerRepresentableContext<CameraView>) {
        
    }
}

#Preview {
    CameraView()
}
