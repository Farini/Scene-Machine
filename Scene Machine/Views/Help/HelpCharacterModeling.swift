//
//  HelpCharacterModeling.swift
//  Scene Machine
//
//  Created by Carlos Farini on 5/16/21.
//

import SwiftUI

struct HelpCharacterModeling: View {
    
    // To Open a link...:
    /*
     let url = URL(string: "https://www.stackoverflow.com")!
     NSWorkspace.sharedWorkspace().openURL(url))
     */
    
    /*
     Top Tools
     + Shift + W: Bend, and move your pointer to guide the bending.
     + Alt + S to shrink or fatten
     + F9 to quickly see tool options
     + The Skin modifier is a super powerful modeling tool. One of the most important hotkeys is Control + A, which adjusts the resulting Skin scale of selected vertices in Edit Mode.
     +  Control + Shift + click the other corner face of the desired region to select the matrix of polygons in between. (After selecting the first)
     + Press Control + ‘.’ (period key) in the 3D viewport to transform only the pivot (origin) point of an object.
     
     Shift+left-click    Add to selection
     Ctrl+left-click (edit mode)    Remove from selection
     Left-click+drag    Box selection
     Alt+left-click (edit mode)    Edge/Face loop select
     Middle-click+drag    Rotate view
     Shift+middle-click+drag    Pan view
     Ctrl+middle-click+drag    Zoom view
     Right-click    Context menu
     
     Hotkey    Description
     A    Select all
     Alt+A    Deselect all
     Shift+A    Show Add menu
     Shift+D    Duplicate
     Alt+D    Linked duplicate
     E (edit mode)    Extrude
     F (edit mode)    Create face/edge
     G    Grab/move
     Alt+G    Clear location
     H    Hide selected
     Alt+H    Reveal all
     I    Insert keyframe
     Ctrl+J    Join selected objects
     L (edit mode)    Select linked vertices
     Shift+L (edit mode)    Deselect linked vertices
     M    Move selection to collection
     Ctrl+M    Mirror selection
     N    Toggle Sidebar visibility
     Ctrl+N    New Blender session
     Ctrl+N (edit mode)    Calculate normals outside
     O (edit mode)    Enable proportional editing
     P (edit mode)    Separate to new object
     Ctrl+P    Make parent
     Alt+P    Clear parent
     R    Rotate
     Alt+R    Clear rotation
     S    Scale
     Alt+S    Clear scale
     U (edit mode)    Unwrap mesh
     Ctrl+S    Save file
     X    Delete selection
     Ctrl+Z    Undo
     Ctrl+Shift+Z    Redo
     Spacebar    Play animation
     Shift+Spacebar    Show Tool menu
     Ctrl+Spacebar    Maximize editor area
     Tab    Toggle Edit mode
     Ctrl+Tab    Show mode pie menu
     Tilde (~)    Show view pie menu
     F2    Rename selected object
     F3    Show search menu
     F9    Show floating Last Operator panel
     
     */
    
    var body: some View {
        
        ScrollView {
            VStack(alignment:.leading) {
                
                Text("Blender Shortcuts").font(.largeTitle).foregroundColor(.orange)
                Divider()
                
                Group {
                    Text("Why Blender")
                        .font(.title2).foregroundColor(.blue).padding(.bottom, 6)
                    
                    Text("Blender is a great tool for 3D things. It's free, easy to use, and there is a gigantic community of supporters and fans. Many people may help, in case you come through any issues.")
                        .lineLimit(20)
                        .padding(.horizontal)
                        .frame(minHeight:55, maxHeight:.infinity)
                    Text("There is also a gazillion tutorials about Blender on YouTube.")
                        .padding()
                    
                    Divider()
                }
                
                
                Group {
                    HStack {
                        Text("Blender Shortcuts").font(.title2).foregroundColor(.blue)
                        Text("Number Pad shortcuts")
                    }
                    
                    LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))], alignment: .leading, spacing: 8, pinnedViews: [], content: {
                        
                        Group {
                            HStack {
                                Text(" 1 ")
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(6)
                                Text("Front View")
                            }
                            
                            HStack {
                                Text(" 2 ")
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(6)
                                Text("Rotate Up")
                            }
                        }
                        
                        Group {
                            HStack {
                                Text(" 3 ")
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(6)
                                Text("Left View")
                            }
                            
                            HStack {
                                Text(" 4 ")
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(6)
                                Text("Rotate Left")
                            }
                        }
                        
                        Group {
                            HStack {
                                Text(" 5 ")
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(6)
                                Text("Perspective/Ortho")
                            }
                            
                            HStack {
                                Text(" 6 ")
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(6)
                                Text("Rotate right")
                            }
                        }
                        
                        Group {
                            HStack {
                                Text(" 7 ")
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(6)
                                Text("Top View")
                            }
                            
                            HStack {
                                Text(" 8 ")
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(6)
                                Text("Rotate down")
                            }
                        }
                        
                        Group {
                            HStack {
                                Text(" 9 ")
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(6)
                                Text("Redraw screen")
                            }
                            
                            HStack {
                                Text(" 0 ")
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(6)
                                Text("Camera View")
                            }
                        }
                        
                        Group {
                            HStack {
                                Text(" + ")
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(6)
                                Text("Zoom in")
                            }
                            
                            HStack {
                                Text(" . ")
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(6)
                                Text("Focus selection")
                            }
                        }
                    })
                    
                    
                    Divider()
                }
                
                Text("Essentials").font(.title2).foregroundColor(.blue)
                    .padding(.vertical)
                
                VStack(alignment:.leading, spacing:8) {
                    HStack {
                        Text("A")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Select all")
                    }
                    HStack {
                        Text("⌥  option")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("+")
                        Text("A")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Deselect all")
                    }
                    HStack {
                        Text("shift")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("+")
                        Text("A")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Show add menu")
                    }
                    HStack {
                        Text("shift")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("+")
                        Text("D")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Duplicate selection")
                    }
                    HStack {
                        Text("⌥  option")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("+")
                        Text("D")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Linked duplicate")
                    }
                    HStack {
                        Text("H")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Hide selection")
                    }
                    HStack {
                        Text("⌥  option")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("+")
                        Text("H")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Unhide everything")
                    }
                    HStack {
                        Text("I")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Insert Keyframe")
                    }
                    HStack {
                        Text("⌘  cmd")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("+")
                        Text("J")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Join Selected objects")
                    }
                }
                
                Text("Edit Mode")
                    .font(.title2).foregroundColor(.blue)
                    .padding(.vertical)
                
                VStack(alignment:.leading, spacing:8) {
                    HStack {
                        Text("E")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Extrude")
                    }
                    HStack {
                        Text("F")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Create face/edge")
                    }
                    HStack {
                        Text("G")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Grab/move")
                    }
                    HStack {
                        Text("⌥  option")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("+")
                        Text("G")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Clear location")
                    }

                    HStack {
                        Text("L")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Select linked vertices")
                    }
                    HStack {
                        Text("M")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Merge vertices")
                    }
                    HStack {
                        Text("P")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        Text("Separate from object - unparent")
                    }
                }
                    
                
                /*
                 Shift+A    Show Add menu
                 Shift+D    Duplicate
                 Alt+D    Linked duplicate
                 E (edit mode)    Extrude
                 F (edit mode)    Create face/edge
                 G    Grab/move
                 Alt+G    Clear location
                 H    Hide selected
                 Alt+H    Reveal all
                 I    Insert keyframe
                 Ctrl+J    Join selected objects
                 L (edit mode)    Select linked vertices
                 Shift+L (edit mode)    Deselect linked vertices
                 M    Move selection to collection
                 Ctrl+M    Mirror selection
                 N    Toggle Sidebar visibility
                 */
                
                
            }
            .padding(8)
            .frame(width:500)
        }
        
    }
    
    var numKeyPad: some View {
        VStack {
            HStack {
                Text(" clear ")
                    .padding(.vertical)
                    .padding(.horizontal, 4)
                    .background(Color.black)
                    .cornerRadius(6)
                Text("=")
                    .padding()
                    .background(Color.black)
                    .cornerRadius(6)
                Text("/")
                    .padding()
                    .background(Color.black)
                    .cornerRadius(6)
                Text("*")
                    .padding()
                    .background(Color.black)
                    .cornerRadius(6)
            }
            HStack {
                Text("7")
                    .padding()
                    .background(Color.black)
                    .cornerRadius(6)
                Text("8")
                    .padding()
                    .background(Color.black)
                    .cornerRadius(6)
                Text("9")
                    .padding()
                    .background(Color.black)
                    .cornerRadius(6)
                Text("-")
                    .padding()
                    .background(Color.black)
                    .cornerRadius(6)
            }
            HStack {
                Text("4")
                    .padding()
                    .background(Color.black)
                    .cornerRadius(6)
                Text("5")
                    .padding()
                    .background(Color.black)
                    .cornerRadius(6)
                Text("6")
                    .padding()
                    .background(Color.black)
                    .cornerRadius(6)
                Text("+")
                    .padding()
                    .background(Color.black)
                    .cornerRadius(6)
            }
            
            HStack(spacing:0) {
                
                VStack(alignment:.leading) {
                    LazyHGrid(rows: [GridItem(.fixed(50))], alignment: .top, spacing: 8, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                        
                        Text(" 1")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        
                        Text("2")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        
                        Text("3")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                    })
                    .frame(width: 160)
                    .offset(x: -3, y: 0)
                    
                    
                    LazyVGrid(columns: [GridItem(.fixed(90)), GridItem(.fixed(50))], alignment: .center, spacing: 6, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                        
                        Text("0")
                            .padding()
                            .frame(width:90)
                            .background(Color.black)
                            .cornerRadius(6)
                            .offset(x: 4, y: 0)
                        
                        Text(" . ")
                            .padding()
                            .background(Color.black)
                            .cornerRadius(6)
                        
                    })
                    .frame(width: 160)
                    .offset(x: -3, y: 0)
                }
                
                Text("enter").font(.footnote)//.foregroundColor(.gray)
//                    .padding()
                    .frame(width:40, height:100)
                    .background(Color.black)
                    .cornerRadius(6)
                    .offset(x: -6, y: 0)
            }
        }
        .padding()
    }
    
    var keyboard: some View {
        VStack {
            
            Text("Mac Keyboard")
                .font(.largeTitle)
                .padding(.bottom)
                .foregroundColor(.gray)
            
            // Top Row
            HStack {
                Group {
                    Text(" ` ")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                    Text(" 1 ")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                    Text(" 2 ")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                    Text(" 3 ")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                    Text("4")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                    Text("5")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                    Text("6")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                }
                
                // --
                Group {
                    Text("7")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("8")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("9")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("0")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text(" - ")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text(" = ")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text(" delete ")
                        .frame(width:90)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                }
                
            }
            
            // Top Letters
            HStack {
                Group {
                    Text("tab")
                        .frame(width:96)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                    Text("Q")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                    Text("W")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                    Text("E")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                    Text("R")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                    Text("T")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                    Text("Y")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                }
                
                // --
                Group {
                    Text("U")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text(" I ")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("O")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text(" P ")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("[ {")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("] }")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text(" | ")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                }
                
            }
            
            // Middle Letters
            HStack {
                
                Group {
                    Text("caps lock")
                        .frame(width:82)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("A")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("S")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("D")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("F")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("G")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                }
                
                Group {
                    Text("H")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("J")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("K")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("L")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text(": ;")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("' ''")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("return")
                        .frame(width:100)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                }
            }
            
            // Bottom Letters
            HStack {
                
                Group {
                    Text("shift")
                        .frame(width:120)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("Z")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("X")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("C")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("V")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("B")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                }
                
                Group {
                    Text("N")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("M")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("<")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text(">")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("?")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("shift")
                        .frame(width:120)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                }
            }
            
            // Bottom Row
            HStack {
                
                Group {
                    Text("⌃  ctrl")
                        // .frame(width:120)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("⌥  option")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("⌘  cmd")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text(" ")
                        .frame(width:200)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                }
                
                Group {
                    Text("⌘  cmd")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("⌥  option")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    Text("⌃ ctrl")
                        .padding()
                        .background(Color.black)
                        .cornerRadius(6)
                    
                    
                }
            }
            
        }
        .font(.title2)
        .padding(.vertical)
    }
}

struct HelpCharacterModeling_Previews: PreviewProvider {
    static var previews: some View {
        HelpCharacterModeling()
            //.frame(width:900)
    }
}
