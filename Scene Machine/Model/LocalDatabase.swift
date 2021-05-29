//
//  LocalDatabase.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/15/21.
//

import Foundation
import SceneKit

/** This is a class that persists the objects created in this app. */
class LocalDatabase:NSObject {
    
    static let shared = LocalDatabase()
    
    // MARK: - Materials
    /// Saves
    func saveMaterial(material:SceneMaterial) {
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        var allMaterials:[SceneMaterial] = materials
        if let idx = allMaterials.firstIndex(where: { $0.id == material.id}) {
            allMaterials.remove(at: idx)
        }
        allMaterials.append(material)
        
        guard let encodedData:Data = try? encoder.encode(allMaterials) else { fatalError() }
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        let dataSize = bcf.string(fromByteCount: Int64(encodedData.count))
        print("Saving Materials File Size: \(dataSize)")
        
        let fileUrl = LocalDatabase.folder.appendingPathComponent(LocalDatabase.materialsFile)
        
        // Create if doesn't exist
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: encodedData, attributes: nil)
            print("File created")
            return
        }
        
        do{
            try encodedData.write(to: fileUrl, options: .atomic)
            print("Saved locally")
            self.materials = LocalDatabase.loadMaterials()
        }catch{
            print("Error writting data to local url: \(error)")
        }
    }
    func saveMaterialsList() {
        let allMaterials = materials
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        guard let encodedData:Data = try? encoder.encode(allMaterials) else { fatalError() }
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        let dataSize = bcf.string(fromByteCount: Int64(encodedData.count))
        print("Saving Materials File Size: \(dataSize)")
        
        let fileUrl = LocalDatabase.folder.appendingPathComponent(LocalDatabase.materialsFile)
        
        // Create if doesn't exist
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: encodedData, attributes: nil)
            print("File created")
            return
        }
        
        do{
            try encodedData.write(to: fileUrl, options: .atomic)
            print("Saved locally")
        }catch{
            print("Error writting data to local url: \(error)")
        }
    }
    static let materialsFile = "Materials.json"
    private static func loadMaterials() -> [SceneMaterial] {
        print("Loading Materials")
        let finalUrl = LocalDatabase.folder.appendingPathComponent(materialsFile)
        
        if !FileManager.default.fileExists(atPath: finalUrl.path){
            print("File doesn't exist")
            return []
        }
        
        do{
            let theData = try Data(contentsOf: finalUrl)
            
            do{
                let localData:[SceneMaterial] = try JSONDecoder().decode([SceneMaterial].self, from: theData)
                return localData
                
            }catch{
                // Decode JSON Error
                print("Error Decoding JSON: \(error)")
                return []
            }
        }catch{
            // First Do - let data error
            print("Error getting Data from URL: \(error)")
            return []
        }
    }
    
    /// Materials Loaded
    var materials:[SceneMaterial]
    
    // MARK: - URLS
    // URLs can be useful for "Load recent", or to load saved images.
    
    static let savedURLsFile = "SavedURLs.json"
    var savedURLS:[URL]
    private static func loadSavedURLs() -> [URL] {
        let finalUrl = LocalDatabase.folder.appendingPathComponent(savedURLsFile)
        
        if !FileManager.default.fileExists(atPath: finalUrl.path){
            print("File doesn't exist")
            return []
        }
        
        do{
            let theData = try Data(contentsOf: finalUrl)
            
            do{
                let localData:[URL] = try JSONDecoder().decode([URL].self, from: theData)
                return localData
                
            }catch{
                // Decode JSON Error
                print("Error Decoding JSON: \(error)")
                return []
            }
        }catch{
            // First Do - let data error
            print("Error getting Data from URL: \(error)")
            return []
        }
    }
    func saveURL(url:URL) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        var allURLs:[URL] = LocalDatabase.loadSavedURLs()
        allURLs.append(url)
        
        guard let encodedData:Data = try? encoder.encode(allURLs) else { fatalError() }
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB]
        bcf.countStyle = .file
        let dataSize = bcf.string(fromByteCount: Int64(encodedData.count))
        print("Saving URLs File Size: \(dataSize)")
        
        let fileUrl = LocalDatabase.folder.appendingPathComponent(LocalDatabase.materialsFile)
        
        // Create if doesn't exist
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            FileManager.default.createFile(atPath: fileUrl.path, contents: encodedData, attributes: nil)
            print("File created")
            return
        }
        
        do{
            try encodedData.write(to: fileUrl, options: .atomic)
            print("Saved locally")
        }catch{
            print("Error writting data to local url: \(error)")
        }
    }
    
    // MARK: - Others
    
    // FIXME: - Persist Image References, and other work progress?
    // Data
    // Undo History?
    var exportingFolder:URL?
    func createSceneFolder(named:String, scene:SCNScene, sceneName:String) {
        
        let baseFolder = LocalDatabase.folder
        let sceneFolder = baseFolder.appendingPathComponent("\(named).scnassets")
        let sceneFile = sceneFolder.appendingPathComponent("\(sceneName).scn")
        let fileManager = FileManager.default
        self.exportingFolder = sceneFolder
        
        if fileManager.fileExists(atPath: sceneFolder.path) {
            print("'File' exists at path")
            scene.write(to: sceneFile, options:nil , delegate: self) /// ["checkConsistency":NSNumber.init(booleanLiteral: true)]
            print("Success ?")
        } else {
            // Create directory and save
            do {
                try fileManager.createDirectory(atPath: sceneFolder.path, withIntermediateDirectories: true, attributes: nil)
                scene.write(to: sceneFile, options: ["checkConsistency":NSNumber.init(booleanLiteral: true)], delegate: nil)
                
            } catch {
                NSLog("Couldn't create document directory")
            }
        }
    }
    
    /// Returns the folders under App's documents
    func getSubdirectories() -> [URL] {
        do {
            let documentsDirectory =  try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let url = documentsDirectory.appendingPathComponent("pictures", isDirectory: true)
            if !FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
            }
            let subDirs = try documentsDirectory.subDirectories()
            print("sub directories", subDirs)
            subDirs.forEach { print($0.lastPathComponent) }
            return subDirs
        } catch {
            print("⚠️ Error: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - General
    
    static var folder:URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            fatalError("Default folder for ap not found")
        }
        return url
    }
    
    // Saving Images
    func saveImage(_ image:NSImage, material:SceneMaterial, mode:MaterialMode) -> URL? {
        let folder = LocalDatabase.folder
        let imageName = "\(material.name ?? material.id.uuidString)_\(mode.rawValue).png"
        let folderPath = folder.appendingPathComponent("Material Images", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folderPath.path) {
            try? FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        if let imgData = image.tiffRepresentation {
            let fullPath = folderPath.appendingPathComponent(imageName, isDirectory: false)
            do {
                try imgData.write(to: fullPath)
                print("Image saved at \(fullPath)")
                return fullPath
            }catch {
                print("⚠️ Image could not be saved")
                return nil
            }
        }
        print("No tiff representation when saving image")
        return nil
    }
    
    private override init() {
        let materials = LocalDatabase.loadMaterials()
        self.materials = materials
        let sURLs = LocalDatabase.loadSavedURLs()
        self.savedURLS = sURLs
        super.init()
    }
}

extension LocalDatabase:SCNSceneExportDelegate {
    
    func write(_ image: NSImage, withSceneDocumentURL documentURL: URL, originalImageURL: URL?) -> URL? {
        
        print("Exporting image: \(image.size), name: \(originalImageURL?.path ?? "unnamed")")
        
        if let filename = originalImageURL?.lastPathComponent, !filename.isEmpty {
            return exportingFolder?.appendingPathComponent("/images/\(filename)")
        } else {
            return exportingFolder?.appendingPathComponent("/images/\(UUID().uuidString.prefix(6)).png")
        }
    }
    
}
