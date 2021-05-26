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
    
    /// Opens the finder with the App's document folder.
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
    
    /// Opens the finder at an alternative URL.
    @objc func openFinderAt(_ sender:URL) {
        if FileManager.default.fileExists(atPath: sender.path) {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: sender.path)
        } else {
            print("⚠️ Error: File doesn't exist: \(sender)")
        }
    }
    
    var drawingWindow:NSWindow!
    @IBAction func openDrawingView(_ sender: Any) {
        
        if nil == drawingWindow {
            
            // View
            let drawingView = MaterialMachineView()
            drawingWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 900, height: 700),
                styleMask: [.titled, .closable, .miniaturizable,
                            .resizable, .fullSizeContentView,
                            .unifiedTitleAndToolbar],
                backing: .buffered, defer: false)
            drawingWindow.center()
            drawingWindow.setFrameAutosaveName("MaterialEditorView")
            
            drawingWindow.title = "Material Editor"
            
            drawingWindow.isReleasedWhenClosed = false
            drawingWindow.contentView = NSHostingView(rootView: drawingView)
        }
        
        drawingWindow.makeKeyAndOrderFront(nil)
    }
    
    // MARK: - App Windows
    
    @IBAction func openFrontWindow(_ sender: NSMenuItem) {
        
//        if nil == window {
//            window = NSWindow(
//                contentRect: NSRect(x: 0, y: 0, width: 1200, height: 800),
//                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
//                backing: .buffered, defer: false)
//            window.center()
//            window.setFrameAutosaveName("FrontView")
//            //        window.toolbarStyle = .unified
//            window.contentView = NSHostingView(rootView: FrontView())
//        }
        
        window.makeKeyAndOrderFront(nil)
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
    
    /// Terrain Scene
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
    
    /// Monkey (Material) Scene
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
    
    /// Scene Machine
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
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
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
    
    var blenderShortcutsWindow:NSWindow!
    @IBAction func openBlenderShortcuts(_ sender: Any) {
        if nil == blenderShortcutsWindow {
            let view = HelpCharacterModeling()
            blenderShortcutsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            blenderShortcutsWindow.center()
            blenderShortcutsWindow.setFrameAutosaveName("BlenderShortcuts")
            blenderShortcutsWindow.title = "Blender tips"
            blenderShortcutsWindow.isReleasedWhenClosed = false
            blenderShortcutsWindow.contentView = NSHostingView(rootView: view)
        }
        blenderShortcutsWindow.makeKeyAndOrderFront(nil)
    }
}

/*
extension NSImage.Name {
    static let calendar = "calendar"
    static let today = "clock"
}

extension NSToolbar {
    static let drawingPadToolbar: NSToolbar = {
        let toolbar = NSToolbar(identifier: "DrawingPadToolbar")
        toolbar.displayMode = .iconOnly
        
        return toolbar
    }()
}

extension NSToolbarItem.Identifier {
    static let calendar = NSToolbarItem.Identifier(rawValue: "ShowCalendar")
    static let today = NSToolbarItem.Identifier(rawValue: "GoToToday")
}

extension AppDelegate: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [NSToolbarItem.Identifier(rawValue: "GoToToday"), NSToolbarItem.Identifier(rawValue: "ShowCalendar")]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [NSToolbarItem.Identifier(rawValue: "GoToToday"), NSToolbarItem.Identifier(rawValue: "ShowCalendar")]
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
            case NSToolbarItem.Identifier.calendar:
                let button = NSButton(image: NSImage(named: .calendar)!, target: nil, action: nil)
                button.bezelStyle = .texturedRounded
                return customToolbarItem(itemIdentifier: .calendar, label: "Calendar", paletteLabel: "Calendar", toolTip: "Show day picker", itemContent: button)
            case NSToolbarItem.Identifier.today:
                let button = NSButton(title: "Today", target: nil, action: nil)
                button.bezelStyle = .texturedRounded
                return customToolbarItem(itemIdentifier: .calendar, label: "Today", paletteLabel: "Today", toolTip: "Go to today", itemContent: button)
            default:
                return nil
        }
    }
    
    /**
     Mostly base on Apple sample code: https://developer.apple.com/documentation/appkit/touch_bar/integrating_a_toolbar_and_touch_bar_into_your_app
     */
    func customToolbarItem(
        itemIdentifier: NSToolbarItem.Identifier,
        label: String,
        paletteLabel: String,
        toolTip: String,
        itemContent: NSButton) -> NSToolbarItem? {
        
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        
        toolbarItem.label = label
        toolbarItem.paletteLabel = paletteLabel
        toolbarItem.toolTip = toolTip
        /**
         You don't need to set a `target` if you know what you are doing.
         
         In this example, AppDelegate is also the toolbar delegate.
         
         Since AppDelegate is not a responder, implementing an IBAction in the AppDelegate class has no effect. Try using a subclass of NSWindow or NSWindowController to implement your action methods and use them as the toolbar delegate instead.
         
         Ref: https://developer.apple.com/documentation/appkit/nstoolbaritem/1525982-target
         
         From doc:
         
         If target is nil, the toolbar will call action and attempt to invoke the action on the first responder and, failing that, pass the action up the responder chain.
         */
        //        toolbarItem.target = self
        //        toolbarItem.action = #selector(methodName)
        
        toolbarItem.view = itemContent
        
        // We actually need an NSMenuItem here, so we construct one.
        let menuItem: NSMenuItem = NSMenuItem()
        menuItem.submenu = nil
        menuItem.title = label
        toolbarItem.menuFormRepresentation = menuItem
        
        return toolbarItem
    }
    
}
*/

