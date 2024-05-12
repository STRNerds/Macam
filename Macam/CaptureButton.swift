//
//  CaptureButton.swift
//  Macam
//
//  Created by Ethan Xu on 2024-04-08.
//

import SwiftUI

struct CaptureButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "camera.fill")
                .font(.largeTitle)
                .padding()
        }
        .keyboardShortcut(KeyboardShortcut(KeyEquivalent(" "), modifiers: []))
    }
}

#Preview {
    CaptureButton(action: { print("Button pressed") })
}
