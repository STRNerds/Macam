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
    
    @Environment(\.colorScheme) var colorScheme
    
    private var lightBorder = Color(red: 216/255, green: 214/255, blue: 217/255)
    private var lightBackground = Color(red: 235/255, green: 233/255, blue: 236/255)
    private var darkBorder = Color(red: 63/255, green: 58/255, blue: 63/255)
    private var darkBackground = Color(red: 46/255, green: 41/255, blue: 46/255)
    
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
                Text("Save Folder")
                
                Spacer()
                
                Picker("", selection: $pickingFolder) {
                    Text(selectedFolder?.lastPathComponent ?? "NULL").tag(false)
                    Text("Choose Folder").tag(true)
                }
                .onChange(of: pickingFolder) {
                    if pickingFolder {
                        self.selectFolder()
                        pickingFolder = false
                    }
                }
                .frame(width: 150, height: 15, alignment: Alignment.bottom)
            }
            .padding()
            .background(colorScheme == .light ? lightBackground : darkBackground)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(colorScheme == .light ? lightBorder : darkBorder, lineWidth: 1))
            
            HStack {
                Text("Image Type")
                
                Spacer()
                
                Picker("", selection: $imageType) {
                    Text("PNG").tag(NSBitmapImageRep.FileType.png)
                    Text("JPEG").tag(NSBitmapImageRep.FileType.jpeg)
                    Text("TIFF").tag(NSBitmapImageRep.FileType.tiff)
                }
                .onChange(of: imageType) {
                    UserDefaults.standard.set(imageType.rawValue, forKey: "imageType")
                }
                .frame(width: 150, height: 15, alignment: Alignment.bottom)
            }
            .padding()
            .background(colorScheme == .light ? lightBackground : darkBackground)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(colorScheme == .light ? lightBorder : darkBorder, lineWidth: 1))
            
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
        .background(colorScheme == .light ? Color(red: 238/255, green: 236/255, blue: 239/255) : Color(red: 43/255, green: 38/255, blue: 43/255))
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
