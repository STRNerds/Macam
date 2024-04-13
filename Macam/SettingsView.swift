//
//  SettingsView.swift
//  Macam
//
//  Created by Ethan Xu on 2024-04-12.
//

import SwiftUI

struct SettingsView: View {
    @State public var selectedFolder: URL? {
        didSet {
            if let url = selectedFolder {
                UserDefaults.standard.set(url, forKey: "selectedFolder")
            }
        }
    }
    
    @State public var imageType: NSBitmapImageRep.FileType = .png {
        didSet {
            UserDefaults.standard.set(imageType.rawValue, forKey: "imageType")
        }
    }
    
    @State private var pickingFolder = false
    @State private var showingResetAlert = false
    
    init() {
        if let url = UserDefaults.standard.url(forKey: "selectedFolder") {
            _selectedFolder = State(initialValue: url)
        } else {
            let picturesDirectory = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!
            let macamDirectory = picturesDirectory.appendingPathComponent("Macam")
            
            do {
                try FileManager.default.createDirectory(at: macamDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create directory: \(error)")
            }
            
            _selectedFolder = State(initialValue: macamDirectory)
            UserDefaults.standard.set(macamDirectory, forKey: "selectedFolder")
        }
        
        if let typeRawValue = UserDefaults.standard.object(forKey: "imageType") as? UInt, let type = NSBitmapImageRep.FileType(rawValue: typeRawValue) {
            _imageType = State(initialValue: type)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Picker("Save Folder", selection: $pickingFolder) {
                    Text(selectedFolder?.lastPathComponent ?? "NULL").tag(false)
                    Text("Choose Folder").tag(true)
                }
                .onChange(of: pickingFolder) {
                    if pickingFolder {
                        self.selectFolder()
                        pickingFolder = false
                    }
                }
                .frame(width: 300, height: 15, alignment: Alignment.bottom)
            }
            .padding()
            .background(Color(red: 56/255, green: 48/255, blue: 61/255))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(red: 76/255, green: 68/255, blue: 80/255), lineWidth: 1))
            
            Picker("Image Type", selection: $imageType) {
                Text("PNG").tag(NSBitmapImageRep.FileType.png)
                Text("JPEG").tag(NSBitmapImageRep.FileType.jpeg)
                Text("TIFF").tag(NSBitmapImageRep.FileType.tiff)
            }
            .onChange(of: imageType) {
                UserDefaults.standard.set(imageType.rawValue, forKey: "imageType")
            }
            .frame(width: 150, height: 15, alignment: Alignment.bottom)
            .padding()
            
            Button("Reset To Default") {
                showingResetAlert = true
            }
            .alert(isPresented: $showingResetAlert) {
                Alert(title: Text("Reset To Default"),
                      message: Text("Are you sure you want to reset to default?"),
                      primaryButton: .destructive(Text("Reset")) {
                    self.resetAll()
                },
                      secondaryButton: .cancel()
                )
            }
            .padding()
        }
        .padding()
    }
    
    func selectFolder() {
        let folderChooserPoint = CGPoint(x: 0, y: 0)
        let folderChooserSize = CGSize(width: 500, height: 600)
        let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
        let folderPicker = NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .utilityWindow, backing: .buffered, defer: true)
        
        folderPicker.canChooseDirectories = true
        folderPicker.canChooseFiles = false
        folderPicker.allowsMultipleSelection = false
        folderPicker.canDownloadUbiquitousContents = true
        folderPicker.canResolveUbiquitousConflicts = true
        
        folderPicker.begin { response in
            if response == .OK {
                let pickedFolders = folderPicker.urls
                
                if let firstFolder = pickedFolders.first {
                    self.selectedFolder = firstFolder
                    print("Selected folder: \(firstFolder)")
                }
            }
        }
    }
    
    func resetAll() {
        let picturesDirectory = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!
        let macamDirectory = picturesDirectory.appendingPathComponent("Macam")
        
        do {
            try FileManager.default.createDirectory(at: macamDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create directory: \(error)")
        }
        
        selectedFolder = macamDirectory
        UserDefaults.standard.set(macamDirectory, forKey: "selectedFolder")
        imageType = .png
        UserDefaults.standard.set(NSBitmapImageRep.FileType.png.rawValue, forKey: "imageType")
    }
}

#Preview {
    SettingsView()
}
