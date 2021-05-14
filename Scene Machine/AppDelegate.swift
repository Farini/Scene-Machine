//
//  AppDelegate.swift
//  Scene Machine
//
//  Created by Carlos Farini on 12/2/20.
//

import Cocoa
import SwiftUI
import SceneKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NSApp.appearance = NSAppearance(named: .darkAqua)
        
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
        let contentView = FrontView().environment(\.managedObjectContext, persistentContainer.viewContext)
        
        // Top Bar
        let topBar = TopBar()
        let accessoryHostingView = NSHostingView(rootView: topBar)
        accessoryHostingView.frame.size = accessoryHostingView.fittingSize
        let tbarAccessory = NSTitlebarAccessoryViewController()
        tbarAccessory.view = accessoryHostingView
        
        
        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Front Window")
        
        // Top bar (again)
        window.addTitlebarAccessoryViewController(tbarAccessory)
        window.title = "Scene Machine"
        window.toolbarStyle = .unified
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Scene_Machine")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    // MARK: - Menu
    
    @IBAction func openFinder(_ sender: NSMenuItem) {
        
        print("Getting finder")
        
        if let documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("Doc url: \(documentsPathURL)")
            // This gives you the URL of the path
            // print("Documents Path URL:\(documentsPathURL)")
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: documentsPathURL.absoluteString)
            //        }
        }else{
            print("Where is finder ??")
        }
    }
    
    var drawingWindow:NSWindow!
    @IBAction func openDrawingView(_ sender: Any) {
        
        if nil == drawingWindow {
            let drawingView = DrawingPadView()
            drawingWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 900, height: 700),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            drawingWindow.center()
            drawingWindow.setFrameAutosaveName("DrawingPadView")
            drawingWindow.title = "Drawing Pad"
            drawingWindow.isReleasedWhenClosed = false
            drawingWindow.contentView = NSHostingView(rootView: drawingView)
        }
        drawingWindow.makeKeyAndOrderFront(nil)
    }
    
    /// Quick Noise
    var quickNoiseWindow:NSWindow!
    @IBAction func openNoiseMaker(_ sender: NSMenuItem) {
        
        if nil == quickNoiseWindow {
            let view = QuickNoiseView()
            quickNoiseWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 900, height: 500),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            quickNoiseWindow.center()
            quickNoiseWindow.setFrameAutosaveName("QuickNoiseWindow")
            quickNoiseWindow.title = "Quick Noise"
            quickNoiseWindow.isReleasedWhenClosed = false
            quickNoiseWindow.contentView = NSHostingView(rootView: view)
        }
        
        quickNoiseWindow.makeKeyAndOrderFront(nil)
    }
    
    
    
    @IBAction func openSpriteKitNoise(_ sender: NSMenuItem) {
        openSpriteNoiseWindow()
    }
    
    @IBAction func openFrontWindow(_ sender: NSMenuItem) {
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1200, height: 800),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        newWindow.center()
        newWindow.setFrameAutosaveName("FrontView")
        //        window.toolbarStyle = .unified
        window = newWindow
        window.contentView = NSHostingView(rootView: FrontView())
        window.makeKeyAndOrderFront(nil)
    }
    
    
    // MARK: - App Windows
    
    /// Sprite Noise
    var spriteNoiseWindow: NSWindow!
    @objc func openSpriteNoiseWindow() {
        if nil == spriteNoiseWindow {
            let spriteNoiseView = SpriteNoiseMaker()
            // Create the preferences window and set content
            spriteNoiseWindow = NSWindow(
                contentRect: NSRect(x: 20, y: 20, width: 900, height: 500),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false)
            spriteNoiseWindow.center()
            spriteNoiseWindow.setFrameAutosaveName("SpriteNoiseWindow")
            spriteNoiseWindow.title = "Sprite Noise"
            spriteNoiseWindow.isReleasedWhenClosed = false
            spriteNoiseWindow.contentView = NSHostingView(rootView: spriteNoiseView)
        }
        spriteNoiseWindow.makeKeyAndOrderFront(nil)
    }
    
    /// Metal Generator
    var metalGenWindow: NSWindow!
    @objc func openMetalGenerators() {
        if nil == metalGenWindow {
            let metalView = MetalGenView()
            // Create the preferences window and set content
            metalGenWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1200, height: 800),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            metalGenWindow.center()
            metalGenWindow.setFrameAutosaveName("MetalGenWindow")
            metalGenWindow.title = "Metal"
            metalGenWindow.isReleasedWhenClosed = false
            metalGenWindow.contentView = NSHostingView(rootView: metalView)
        }
        metalGenWindow.makeKeyAndOrderFront(nil)
    }
    
    
    /// Composition
    var compositionWindow:NSWindow!
    @objc func openCompositionView() {
        if nil == compositionWindow {
            let view = CompositionView()
            compositionWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1200, height: 800),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            compositionWindow.center()
            compositionWindow.setFrameAutosaveName("CompositionWindow")
            compositionWindow.title = "Composition"
            compositionWindow.isReleasedWhenClosed = false
            compositionWindow.contentView = NSHostingView(rootView: view)
        }
        compositionWindow.makeKeyAndOrderFront(nil)
    }
    
    /// Image FX
    var imageFXWindow:NSWindow!
    @objc func openImageFXView() {
        if nil == imageFXWindow {
            let fxView = ImageFXView()
            imageFXWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1200, height: 800),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            imageFXWindow.center()
            imageFXWindow.setFrameAutosaveName("ImageFX")
            imageFXWindow.title = "Image FX"
            imageFXWindow.isReleasedWhenClosed = false
            imageFXWindow.contentView = NSHostingView(rootView: fxView)
        }
        imageFXWindow.makeKeyAndOrderFront(nil)
    }
    @objc func openImageFX(_ sender:NSImage) {
        
        let controller = ImageFXController(image: sender)
        let fxView = ImageFXView(controller: controller)
        
        if nil == imageFXWindow {
            imageFXWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1200, height: 800),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            imageFXWindow.center()
            imageFXWindow.setFrameAutosaveName("ImageFX")
            imageFXWindow.title = "Image FX"
            imageFXWindow.isReleasedWhenClosed = false
            imageFXWindow.contentView = NSHostingView(rootView: fxView)
        } else {
            imageFXWindow.contentView = NSHostingView(rootView: fxView)
        }
        
        imageFXWindow.makeKeyAndOrderFront(nil)
    }
    
    // MARK: - Scenes
    
    var terrainWindow: NSWindow!
    @objc func openTerrainWindow() {
        if nil == terrainWindow {
            let terrainView = TerrainView()
            // Create the preferences window and set content
            terrainWindow = NSWindow(
                contentRect: NSRect(x: 20, y: 20, width: 900, height: 500),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false)
            terrainWindow.center()
            terrainWindow.setFrameAutosaveName("TerrainWindow")
            terrainWindow.title = "Terrain Machine"
            terrainWindow.isReleasedWhenClosed = false
            terrainWindow.contentView = NSHostingView(rootView: terrainView)
        }
        terrainWindow.makeKeyAndOrderFront(nil)
    }
    
    var monkeyWindow: NSWindow!
    @IBAction func displayMonkeyTest(_ sender: NSMenuItem) {
        if nil == monkeyWindow {
            let view = MaterialEditView()
            monkeyWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 900, height: 500),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            monkeyWindow.center()
            monkeyWindow.setFrameAutosaveName("MonkeyWindow")
            monkeyWindow.title = "Material Editor"
            monkeyWindow.isReleasedWhenClosed = false
            monkeyWindow.contentView = NSHostingView(rootView: view)
        }
        monkeyWindow.makeKeyAndOrderFront(nil)
    }
    
    var sceneMachineWindow: NSWindow!
    @objc func openSceneMachine() {
        if nil == sceneMachineWindow {
            let view = SceneMachineView()
            sceneMachineWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 900, height: 500),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            sceneMachineWindow.center()
            sceneMachineWindow.setFrameAutosaveName("SceneMachine")
            sceneMachineWindow.title = "Scene Machine"
            sceneMachineWindow.isReleasedWhenClosed = false
            sceneMachineWindow.contentView = NSHostingView(rootView: view)
        }
        sceneMachineWindow.makeKeyAndOrderFront(nil)
    }
    
    @objc func openScene(_ sender:SCNScene) {
        let controller = SceneMachineController(scene: sender)
        let sceneView = SceneMachineView(controller: controller)
        
        if nil == sceneMachineWindow {
            
            sceneMachineWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 900, height: 500),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            sceneMachineWindow.center()
            sceneMachineWindow.setFrameAutosaveName("SceneMachine")
            sceneMachineWindow.title = "Scene Machine"
            sceneMachineWindow.isReleasedWhenClosed = false
            sceneMachineWindow.contentView = NSHostingView(rootView: sceneView)
        }
        sceneMachineWindow.makeKeyAndOrderFront(nil)
    }
    
    
    
    
    // MARK: - Help
    
    var helpWindow:NSWindow!
    @IBAction func openHelp(_ sender: NSMenuItem) {
        
        if nil == helpWindow {
            let view = HelpMainView()
            helpWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            helpWindow.center()
            helpWindow.setFrameAutosaveName("SceneMachine")
            helpWindow.title = "Scene Machine Help"
            helpWindow.isReleasedWhenClosed = false
            helpWindow.contentView = NSHostingView(rootView: view)
        }
        helpWindow.makeKeyAndOrderFront(nil)
    }
    
}

