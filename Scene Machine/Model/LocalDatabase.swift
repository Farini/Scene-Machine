//
//  LocalDatabase.swift
//  Scene Machine
//
//  Created by Carlos Farini on 4/15/21.
//

import Foundation

/**
 This is a class that persists the objects created in this app.
 */
class LocalDatabase {
    
    static let shared = LocalDatabase()
    
    // MARK: - Materials
    /// Saves
    func saveMaterial(material:SceneMaterial) {
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = .prettyPrinted
        
        var allMaterials:[SceneMaterial] = LocalDatabase.loadMaterials()
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
    
    // MARK: - General
    
    static var folder:URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
            fatalError("Default folder for ap not found")
        }
        return url
    }
    
    private init() {
        let materials = LocalDatabase.loadMaterials()
        self.materials = materials
        let sURLs = LocalDatabase.loadSavedURLs()
        self.savedURLS = sURLs
    }
}
