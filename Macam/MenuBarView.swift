//
//  MenuBarView.swift
//  Macam
//
//  Created by Ethan Xu on 2024-04-18.
//

import SwiftUI

struct MenuBarView: View {
    var body: some View {
        CameraFeedView()
        Button("Hello") {
            print("testing")
        }
    }
}

#Preview {
    MenuBarView()
}
