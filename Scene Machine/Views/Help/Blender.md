# Blender Hot Keys

## Object Mode

### Basic Operations

SPACE. Open the Toolbox.
TAB. Start or quit EditMode.

CTRL-LEFTARROW. Go to the previous Screen. 
CTRL-RIGHTARROW. Go to the next Screen.

CTRL-X. Erase All. Everything (except the render buffer) is erased and released. The default scene is reloaded.

Redo: SHIFT-CMD-Z: (also works with CMD-Y)
Undo. CMD-Z.

CTRL-A. Apply size and rotation. The rotation and dimensions of the Object are assigned to the ObData (Mesh, Curve, etc.).
SHIFT-A. This is the AddMenu. In fact, it is the ToolBox that starts with the ‘ADD’ option. When Objects are added, Blender starts EditMode immediately if possible.

## Painting

    F:          Controls the brush size
    SHIFT-F:    Controls the brush intensity
    

**BKEY** Border Select. 
Draw a rectangle with the LeftMouse;
all Objects within this area are selected, but not made active. Draw a rectangle with the RightMouse to deselect Objects. 
In orthonormal ViewMode, the dimensions of the rectangle are displayed, expressed as global coordinates, as an extra feature in the lower left corner. 
In Camera ViewMode, the dimensions that are to be rendered according to the DisplayButtons are displayed in pixel units.

**CKEY** Centre View. 
The position of the 3DCursor becomes the new centre of the 3DWindow.
ALT-C. Convert Menu. Depending on the active Object, a PopupMenu is displayed. This enables you to convert certain types of ObData. It only converts in one direction, everything ultimately degrades to a Mesh! The options are:
    • Font -> Curve
    • MetaBall -> Mesh The original MetaBall remains
    unchanged.
    • Curve -> Mesh
    • Surface -> Mesh

**DKEY** Draw mode menu. 
Allows to select draw modes exactly as the corresponding menu in the 3D viewport header does.
SHIFT-D. Add Duplicate. The selected Objects are duplicated. Grab mode starts immediately thereafter.
ALT-D. Add Linked Duplicate. Of the selected Objects linked duplicates are created. Grab mode starts immediately thereafter.
CTRL-D. Draw the (texture) Image as wire. This option has a limited function. It can only be used for 2D compositing.

FKEY. If selected Object is a mesh Toggles Face selectMode on
and off.
CTRL-F. Sort Faces. The faces of the active Mesh Object are sorted, based on the current view in the 3DWindow. The leftmost face first, the rightmost last. The sequence of faces is important for the Build Effect (AnimButtons).

**GKEY** Grab Mode. 
Or: the translation mode. This works on selected Objects and vertices. Blender calculates the quantity and direction of the translation, so that they correspond exactly with the mouse movements, regardless of the ViewMode or view direction of the 3DWindow. Alternatives for starting this mode:
    • LMB to draw a straight line.
    The following options are available in translation mode:
    • Limiters:
        o CTRL: in increments of 1 grid unit.
        o SHIFT: fine movements.
        o SHIFT-CTRL: in increments of 0.1 grid unit.
    • MMB toggles: A short click restricts the current translation to the X,Y or Z axis. Blender calculates which axis to use, depending on the already initiated mouse movement. Click MiddleMouse again to return to unlimited translation.
    • XKEY, YKEY, ZKEY constrains movement to X, Y or Z axis of the global reference.
    
    • a second XKEY, YKEY, ZKEY constrains movement to X, Y or Z axis of the local reference.
    • a third XKEY, YKEY, ZKEY removes constraints. NKEY enters numerical input, as well as any numeric key directly. TAB will switch between values, ENTER finalizes, ESC exits.

    • ARROWS:These keys can be used to move the mouse cursor exactly 1 pixel.
    Grabber can be terminated with:
        o LMB SPACE or ENTER: move to a new position.
        o RMB or ESC: everything goes back to the old position.
    Switching mode:
        o GKEY: starts Grab mode again.
        o SKEY: switches to Size (Scale) mode. o RKEY: switches to Rotate mode.
    ALT-G. Clears translations, given in Grab mode. The X,Y,Z locations of selected Objects are set to zero.
    SHIFT-G. Group Selection
        • Children: Selects all selected Object’s Children.
        • Immediate Children: Selects all selected Object’s
        first level Children.
        • Parent: Selects selected Object’s Parent.
        • Shared Layers: Selects all Object on the same
        Layer of active Object

**IKEY**  Insert Object Key. 
A keyposition is inserted in the current frame of all selected Objects. A PopupMenu asks what key position(s) must be added to the IpoCurves.
    • Loc: The XYZ location of the Object.
    • Rot: The XYZ rotation of the Object.
    • Size: The XYZ dimensions of the Object
    • LocRot: The XYZ location and XYZ rotation of the
    Object.
    • LocRotSize: The XYZ location, XYZ rotation and
    XYZ dimensions of the Object.
    • Layer: The layer of the Object.
    • Avail: A position is only added to all the current
    IpoCurves, that is curves which already exists.
    • Mesh, Lattice, Curve or Surface: depending on
    the type of Object, a VertexKey can be added
    
CTRL-J. Join Objects. All selected Objects of the same type are added to the active Object. What actually happens here is that the ObData blocks are combined and all the selected Objects (except for the active one) are deleted. This is a rather complex operation, which can lead to confusing results, particularly when working with a lot of linked data, animation curves and hierarchies.

**KKEY** Show Keys. 
The DrawKey option is turned ON for all selected Objects. If all of them were already ON, they are all turned OFF.
SHIFT-K. A PopupMenu asks: OK? Show and select all keys. The DrawKey option is turned ON for all selected Objects, and all Object-keys are selected. This function is used to enable transformation of the entire animation system.


**LKEY** L for Local. Makes selected Object local. Makes library linked
objects local for the current scene.
    CTRL-L. Link selected. Links some of the Active Object data to all selected Objects, the following menu entry appears only if applicable.
    • To Scene: Creates a link of the Object to a scene.
    • Object IPOs: Links Active Object IPOs to selected
    ones.
    • Mesh Data: Links Active Object Mesh data selected
    ones.
    • Lamp Data: Links Active Object Lamp data to
    selected ones.
    • Curve Data: Links Active Object Curve data
    selected ones.
    • Surf Data: Links Active Object Surf data selected
    ones.
    • Material: Links Active Object Material to selected
    ones.
    SHIFT-L. Select Linked. Selects all Objects somehow linked to active Object.
    • Object IPO: Selects all Object(s) sharing active Object’s IPOs.
    • Object Data: Selects all Object(s) sharing active Object’s ObData.
    • Current Material: Selects all Object(s) sharing active Object’s current Material.
    • Current Texture: Selects all Object(s) sharing active Object’s current Texture.

**MKEY**
Moves selected Object(s) to another layer, a pop-up appers. Use LMB to move, use SHIFT-LMB to make the object belong to multiple layers.
CTRL-M. Mirror Menu. It is possible to mirror an Object along the X, Y or Z axis.

**NKEY**
Number Panel. The location, rotation and scaling of the active Object are displayed and can be modified.

ALT-O. Clear Origin. The ‘Origin’ is erased for all Child Objects, which causes the Child Objects to move to the exact location of the Parent Objects.

CTRL-P. Make selected Object(s) the child(ren) of the active Object.
ALT-P. Clears Parent relation, user is asked if he wishes to keep or clear parent-induced transforms.

**RKEY** Rotate mode. Works on selected Object(s). In Blender, a rotation is by default a rotation perpendicular to the screen, regardless of the view direction or ViewMode. The degree of rotation is exactly linked to the mouse movement.

ALT-R. Clears Rotation. The X,Y,Z rotations of selected Objects are set to zero.

**SKEY** Size mode or scaling mode. 
ALT-S. Clears Size. The X,Y,Z dimensions of selected Objects are set to 1.0.
SHIFT-S. SnapMenu:
    • Sel->Grid: Moves Object to nearest grid point.
    • Sel->Curs: Moves Object to cursor.
    • Curs->Grid: Moves cursor to nearest grid point.
    • Curs->Sel: Moves cursor to selected Object(s).
    • Sel->Center: Moves Objects to their barycentrum.

**TKEY** Texture space mode. The position and dimensions of the texture space for the selected Objects can be changed in the same manner as described above for Grab and Size mode.
CTRL-T. Makes selected Object(s) track the Active Object.
Old track method was Blender default tracking before version 2.30. The new method is the Constrain Track, this creates a fully editable constraint on the selected object targeting the active Object.
ALT-T. Clears old style Track. Constraint track is removed as all constrains are.

**UKEY** Makes Object Single User, the inverse operation of Link
**VKEY** Switches in/out of Vertex Paint Mode.

ALT-V. Object-Image Aspect. This hotkey sets the X and Y dimensions of the selected Objects in relation to the dimensions of the Image Texture they have. Use this hotkey when making 2D Image compositions and multi-plane designs to quickly place the Objects in the appropriate relationship with one another.

**WKEY** Opens Object Booleans Menu.

**XKEY** Erase Selected? Deletes selected objects.

**ZKEY** Toggles Solid Mode on/off.
SHIFT-Z Toggles Shaded Mode on/off.
ALT-Z Toggles Textured Mode on/off.

## Edit Mode

TAB or ALT-E. This button starts and stops Edit Mode.
CTRL-TAB. Switches between Vertex Select, Edge Select, and Face Select modes. Holding SHIFT while clicking on a mode will allow you to combine modes.
AKEY. Select/Unselect all.
BKEY-BKEY. Circle Select. If you press BKEY a second time after starting Border Select, Circle Select is invoked. It works as described above. Use NUM+ or NUM- or MW to adjust the circle size. Leave Circle Select with RMB or ESC.
CTRL-H. With vertices selected, this creates a “Hook” object. Once a hook is selected, CTRL-H brings up an options menu for it.
NKEY. Number Panel. Simpler than the Object Mode one, in Edit Mode works for Mesh, Curve, Surface: The location of the active vertex is displayed.
OKEY. Switch in/out of Proportional Editing.
SHIFT-O. Toggles between Smooth and Sharp Proportional
Editing.
PKEY. SeParate. You can choose to make a new object with
all selected vertices, edges, faces and curves or create a new object from each separate group of interconnected vertices from a popup. Note that for curves you cannot separate connected control vertices. This operation is the opposite of Join (CTRL- J).
CTRL-P. Make Vertex Parent. If one object (or more than one) is/are selected and the active Object is in Edit Mode with 1 or 3 vertices selected then the Object in Edit Mode becomes the Vertex Parent of the selected Object(s). If only 1 vertex is selected, only the location of this vertex determines the Parent transformation; the rotation and dimensions of the Parent do not play a role here. If three vertices are selected, it is a ‘normal’ Parent relationship in which the 3 vertices determine the rotation and location of the Child together. This method produces interesting effects with Vertex Keys. In EditMode, other Objects can be selected with CTRL-RMB.
CTRL-S. Shear. In EditMode this operation enables you to make selected forms ‘slant’. This always works via the horizontal screen axis.
UKEY. Undo. When starting Edit Mode, the original ObData block is saved and can be returned to via UKEY. Mesh Objects have better Undo, see next section.
WKEY. Specials PopupMenu. A number of tools are included in this PopupMenu as an alternative to the Edit Buttons. This makes the buttons accessible as shortcuts, e.g. EditButtons- >Subdivide is also ‘WKEY, 1KEY’.
SHIFT-W. Warp. Selected vertices can be bent into curves with this option. It can be used to convert a plane into a tube or even a sphere. The centre of the circle is the 3DCursor. The mid-line of the circle is determined by the horizontal dimensions of the selected vertices. When you start, everything is already bent 90 degrees. Moving the mouse up or down increases or decreases the extent to which warping is done. By zooming in/out of the 3Dwindow, you can specify the maximum degree of warping. The CTRL limiter increments warping in steps of 5 degrees.


### EditMode - Mesh

This section and the following highlight peculiar EditMode Hotkeys.
CTRL-NUM+. Adds to selection all vertices connected by an edge to an already selected vertex.
CTRL-NUM-. Removes from selection all vertices of the outer ring of selected vertices.
ALT-CTRL-RMB. Edge select.
CKEY. If using curve deformations, this toggles the curve
Cyclic mode on/off.
EKEY. Extrude Selected. “Extrude” in EditMode transforms all the selected edges to faces. If possible, the selected faces are also duplicated. Grab mode is started directly after this command is executed.
SHIFT-EKEY. Crease Subsurf edge. With “Draw Creases” enabled, pressing this key will allow you to set the crease weight. Black edges have no weight, edge-select color have full weight.
CTRL-EKEY. Mark LSCM Seam. Marks a selected edge as a “seam” for unwrapping using the LSCM mode.
FKEY. Make Edge/Face. If 2 vertices are selected, an edge is created. If 3 or 4 vertices are selected, a face is created.
SHIFT-F. Fill selected. All selected vertices that are bound by edges and form a closed polygon are filled with triangular faces. Holes are automatically taken into account. This operation is 2D; various layers of polygons must be filled in succession.
ALT-F. Beauty Fill. The edges of all the selected triangular faces are switched in such a way that equally sized faces are formed. This operation is 2D; various layers of polygons must be filled in succession. The Beauty Fill can be performed immediately after a Fill.
CTRL-F. Flip faces, selected triangular faces are paired and common edge of each pair swapped.
HKEY. Hide Selected. All selected vertices and faces are temporarily hidden.
SHIFT-H. Hide Not Selected: All non-selected vertices and faces are temporarily hidden.
ALT-H. Reveal. All temporarily hidden vertices and faces are drawn again.
ALT-J. Join faces, selected triangular faces are joined in pairs and transformed to quads
KKEY. Knife tool Menu.
• Face Loop Select: (SHIFT-R) Face loops are
highlighted starting from edge under mouse pointer.
LMB finalizes, ESC exits.
• Face Loop Cut: (CTRL-R) Face loops are
highlighted starting from edge under mouse pointer.
LMB finalizes, ESC exits.
• Knife (exact): (SHIFT-K) Mouse starts draw
mode. Selected Edges are cut at intersections with
mouse line. ENTER or RMB finalizes, ESC exits.
• Knife (midpoints): (SHIFT-K) Mouse starts draw mode. Selected Edges intersecting with mouse
line are cut in middle regardless of true intersection point. ENTER or RMB finalizes, ESC exits.
LKEY. Select Linked. If you start with an unselected vertex near the mouse cursor, this vertex is selected, together with all vertices that share an edge with it.
SHIFT-L. Deselect Linked. If you start with a selected vertex, this vertex is deselected, together with all vertices that share an edge with it.
CTRL-L. Select Linked Selected. Starting with all selected vertices, all vertices connected to them are selected too.
MKEY. Mirror. Opens a popup asking for the axis to mirror. 3 possible axis group are available, each of which contains three axes, for a total of nine choices. Axes can be Global (Blender Global Reference); Local (Current Object Local Reference) or View (Current View reference). Remember that mirroring, like scaling, happens with respect to the current pivot point.
ALT-M. Merges selected vertices at barycentrum or at cursor depending on selection made on pop-up.
CTRL-N. Calculate Normals Outside. All normals from selected faces are recalculated and consistently set in the same direction. An attempt is made to direct all normals ‘outward’.
SHIFT-CTRL-N. Calculate Normals Inside. All normals from selected faces are recalculated and consistently set in the same direction. An attempt is made to direct all normals ‘inward’.
ALT-S. Whereas SHIFT-S scales in Edit Mode as it does in Object Mode, for Edit Mode a further option exists, ALT-S moves each vertex in the direction of its local normal, hence effectively shrinking/fattening the mesh.
CTRL-T. Make Triangles. All selected faces are converted to triangles.
UKEY. Undo. When starting Edit Mode, the original ObData block is saved and all subsequent changes are saved on a stack. This option enables you to restore the previous situation, one after the other.
  
SHIFT-U. Redo. This let you re-apply any undone changes up to the moment in which Edit Mode was entered
ALT-U. Undo Menu. This let you choose the exact point to which you want to undo changes.
WKEY. Special Menu. A PopupMenu offers the following options:
    • Subdivide: all selected edges are split in two.
    • Subdivide Fractal: all selected edges are split in
    two and middle vertex displaced randomly.
    • Subdivide Smooth: all selected edges are split in
    two and middle vertex displaced along the normal.
    • Merge: as ALT-M.
    • Remove Doubles: All selected vertices closer to
    each other than a given threshold (See EditMode Button
    Window) are merged ALT-M.
    • Hide: as HKEY.
    • Reveal: as ALT-H.
    • Select Swap: Selected vertices become unselected
    and vice versa.
    • Flip Normals: Normals of selected faces are
    flipped.
    • Smooth: Vertices are moved closer one to each other,
    getting a smoother object.
    • Bevel: Faces are reduced in size and the space
    between edges is filled with a smoothly curving bevel of the desired order.
    
XKEY. Erase Selected. A PopupMenu offers the following options:
    • Vertices: all vertices are deleted. This includes the edges and faces they form.
    • Edges: all edges with both vertices selected are deleted. If this ‘releases’ certain vertices, they are deleted as well. Faces that can no longer exist as a result of this action are also deleted.
    • Faces: all faces with all their vertices selected are deleted. If any vertices are ‘released’ as a result of this action, they are deleted.
    • All: everything is deleted.
    • Edges and Faces: all selected edges and faces are
    deleted, but the vertices remain.
    • Only Faces: all selected faces are deleted, but the
    edges and vertices remain.
    
YKEY. Split. This command ʻsplitsʼ the selected part of a Mesh without deleting faces. The split parts are no longer bound by edges. Use this command to control smoothing. Since the split parts have vertices at the same position, selection with LKEY is recommended.
    

### EditMode - Curve

CKEY. Set the selected curves to cyclic or turn cyclic off. An individual curve is selected if at least one of the vertices is selected.
EKEY. Extrude Curve. A vertex is added to the selected end of the curves. Grab mode is started immediately after this command is executed.
FKEY. Add segment. A segment is added between two selected vertices at the end of two curves. These two curves are combined into one curve.
HKEY. Toggle Handle align/free. Toggles the selected Bezier handles between free or aligned.
SHIFT-H. Set Handle auto. The selected Bezier handles are converted to auto type.
CTRL-H. Calculate Handles. The selected Bezier curves are calculated and all handles are assigned a type.
LKEY. Select Linked. If you start with an non-selected vertex near the mouse cursor, this vertex is selected together with all the vertices of the same curve.
SHIFT-L. Deselect Linked. If you start with a selected vertex, it is deselected together with all the vertices of the same curve.
MKEY. Mirror. Mirror selected control points exactly as for vertices in a Mesh.
TKEY. Tilt mode. Specify an extra axis rotation, i.e. the tilt, for each vertex in a 3D curve.
ALT-T. Clear Tilt. Set all axis rotations of the selected vertices to zero.
VKEY. Vector Handle. The selected Bezier handles are converted to vector type.
WKEY. The special menu for curves appears:
• Subdivide. Subdivide the selected vertices.
• Switch direction. The direction of the selected curves
is reversed. This is mainly for Curves that are used as paths!
XKEY. Erase Selected. A PopupMenu offers the following options:
• Selected: all selected vertices are deleted.
• Segment: a curve segment is deleted. This only works
for single segments. Curves can be split in two using this option. Or use this option to specify the cyclic position within a cyclic curve.
• All: delete everything.

### EditMode - Metaball
MKEY. Mirror. Mirror selected control points exactly as for vertices in a Mesh.

### EditMode - Surface
CKEY. Toggle Cyclic menu. A PopupMenu asks if selected surfaces in the ‘U’ or the ‘V’ direction must be cyclic. If they were already cyclic, this mode is turned off.
EKEY. Extrude Selected. This makes surfaces of all the selected curves, if possible. Only the edges of surfaces or loose curves are candidates for this operation. Grab mode is started immediately after this command is completed.
FKEY. Add segment. A segment is added between two selected vertices at the ends of two curves. These two curves are combined into 1 curve.
LKEY. Select Linked. If you start with an non-selected vertex near the mouse cursor, this vertex is selected together with all the vertices of the same curve or surface.
SHIFT-L. Deselect Linked. If you start with a selected vertex, this vertex is deselected together with all vertices of the same curve or surface.
MKEY. Mirror. Mirror selected control points exactly as for vertices in a Mesh.
SHIFT-R. Select Row. Starting with the last selected vertex, a complete row of vertices is selected in the ‘U’ or ‘V’ direction. Selecting Select Row a second time with the same vertex switches the ‘U’ or ‘V’ selection.
WKEY. The special menu for surfaces appears:
• Subdivide. Subdivide the selected vertices
• Switch direction. This will switch the normals of the
selected parts.
• Mirror. Mirrors the selected vertices
XKEY. Erase Selected. A PopupMenu offers the following choices:
• Selected: all selected vertices are deleted.
• All: delete everything.

### VertexPaint Hotkeys
SHIFT-K. All vertex colours are erased; they are changed to the current drawing colour.
UKEY. Undo. This undo is ‘real’. Pressing Undo twice redoes the undone.
WKEY. Shared Vertexcol: The colours of all faces that share vertices are blended.

### UV Editor Hotkeys
EKEY. LSCM Unwrapping. Launches LSCM unwrapping on the faces visible in the UV editor.
PKEY. Pin selected vertices. Pinned vertices will stay in place on the UV editor when executing an LSCM unwrap.
ALT-PKEY. Un-Pin selected vertices. Pinned vertices will stay in place on the UV editor when executing an LSCM unwrap.

### FaceSelect Hotkeys
ALT-CLICK. Selects a Face Loop.
TAB. Switches to EditMode, selections made here will show up
when switching back to FaceSelectMode with TAB.
FKEY. With multiple, co-planar faces selected, this key will merge them into one “FGon” so long as they remain co-planar (flat to each other).
LKEY. Select Linked UVs. To ease selection of face groups, Select Linked in UV Face Select Mode will now select all linked faces, if no seam divides them.
RKEY. Calls a menu allowing to rotate the UV coordinates or the VertexCol.
UKEY. Calls the UV Calculation menu. The following modes can the applied to the selected faces:
• Cube: Cubical mapping, a number button asks for the cubemap size
• Cylinder: Cylindrical mapping, calculated from the center of the selected faces
• Sphere: Spherical mapping, calculated from the center of the selected faces
• Bounds to x: UV coordinates are calculated from the actual view, then scaled to a boundbox of 64 or 128 pixels in square
• Standard x: Each face gets default square UV coordinates
• From Window: The UV coordinates are calculated using the projection as displayed in the 3DWindow

## Vertex Groups
Source: https://docs.blender.org/manual/en/latest/modeling/meshes/properties/vertex_groups/vertex_weights.html

Vertex groups are mainly used to tag the vertices belonging to parts of a mesh object or Lattice. Think of the legs of a chair or the hinges of a door, or hands, arms, limbs, head, feet, etc. of a character. In addition you can assign different weight values (in the range 0 to 1) to the vertices within a vertex group. Hence vertex groups are sometimes also named ‘weight groups’.
Vertex groups are most commonly used for armatures. But they are also used in many other areas of Blender, like for example:

    • Armature deformation (also called skinning)
    • Shape keys
    • Modifiers
    • Particle generators
    • Physics simulations

(Image)
https://docs.blender.org/manual/en/latest/_images/modeling_meshes_properties_vertex-groups_introduction_panel.png


Specials
Sort by Name
Sorts vertex groups alphabetically.

Sort by Bone Hierarchy
(Todo)

Copy Vertex Group
Add a copy of the active vertex group as a new group. The new group will be named like the original group with “_copy” appended at the end of its name. And it will contain associations to exactly the same vertices with the exact same weights as in the source vertex group.

Copy Vertex Group to Selected
Copy all vertex groups to other selected objects provided they have matching indices (typically this is true for copies of the mesh which are only deformed and not otherwise edited).

Mirror Vertex Group
Mirrors weights and/or flips group names. See Mirror Vertex Group for more information.

Mirror Vertex Group (Topology)
Performs the Mirror Vertex Group with the Topology Mirror option enabled.

Remove from All Groups
Unassigns the selected vertices from all (even locked) groups. After this operation has been performed, the vertices will no longer be contained in any vertex group. (Not available for locked groups.)

Clear Active Group
Remove all assigned vertices from the active group. The group is made empty. Note that the vertices may still be assigned to other vertex groups of the object. (Not available for locked groups.)

Editing Vertex Groups
When you switch either to Edit Mode or to Weight Paint Mode, vertex weights can be edited. The same operations are available in the 3D Viewport’s Vertex ‣ Vertex Groups menu or `Ctrl-G`.

Vertex groups are maintained within the Object Data tab (1) in the Properties. As long as no vertex groups are defined (the default for new mesh objects), the panel is empty (2).
You create a vertex group by LMB on the Add button + on the right panel border (3). Initially the group is named “Group” (or “Group.nnn” when the name already exists) and gets displayed in the panel (2) (see next image).

Once a new vertex group has been added, the new group appears in the Vertex Groups panel. There you find three clickable elements:

Group Name
The group name can be changed by double-clicking LMB on the name itself. Then you can edit the name as you like.

Filter (arrow icon)
When the little arrow icon in the left lower corner is clicked, a new row opens up where you can enter a search term. This becomes handy when the number of vertex groups gets big.

Drag Handle
If you have a large number of vertex groups and you want to see more than a few groups, you can LMB on the small drag handle to make the vertex groups list larger or smaller.

Active Group
When a vertex group is created, then it is also automatically marked as the Active Group. This is indicated by setting the background of the panel entry to a light gray color. If you have two or more groups in the list, then you can change the active group by LMB on the corresponding entry in the Vertex Groups panel.

Locking Vertex Groups
Right after creation of a vertex group, an open padlock icon shows up on the right side of the list entry. This icon indicates that the vertex group can be edited. You can add vertex assignments to the group or remove assignments from the group. And you can change it with the weight paint brushes, etc.
When you click on the icon, it changes to a closed padlock icon and all vertex group modifications get disabled. You can only rename or delete the group, and unlock it again. No other operations are allowed on locked vertex groups, thus all corresponding buttons become disabled for locked vertex groups.

Assigning Vertices to a Group
You add vertices to a group as follows:
- Select the group from the group list, thus making it the active group (1).
- From the 3D Viewport select Shift-LMB all vertices that you want to add to the group.
- Set the weight value that shall be assigned to all selected vertices (2).
- LMB the Assign button to assign the selected vertices to the active group using the given weight (3).

Checking Assignments
To be sure the selected vertices are in the desired vertex group, you can try press the deselect button. If the vertices remain selected then they are not yet in the current vertex group.
At this point you may assign them, but take care since all selected vertices will have their weight set to the value in the Weight: field.

Removing Assignments from a Group
You remove vertices from a group as follows:
- Select the group from the group list (make it the active group).
- Select all vertices that you want to remove from the group.
- LMB click the Remove button.

Finding Ungrouped Vertices
You can find ungrouped vertices as follows:
Press Alt-A to deselect all vertices.
In the header of the 3D Viewport, navigate to Select ‣ Select All by Trait ‣ Ungrouped Vertices.

**Vertex Group Categories**
Actually we do not have any strict categories of vertex groups in Blender. Technically they all behave the same way. However, we can identify two implicit categories of vertex groups:

**Deform Groups**
These vertex groups are sometimes also named ‘weight groups’ or ‘weight maps’. They are used for defining the weight tables of armature bones. All deform groups of an object are strictly related to each other via their weight values.
Strictly speaking, the sum of all deform weights for any vertex of a mesh should be exactly 1.0. In Blender this constraint is a bit relaxed (see below). Nevertheless, deform groups should always be seen as related to each other. Hence, we have provided a filter that allows restricting the Vertex Weight panel to display only the deform bones of an object.

**Other Groups**
All other usages of vertex groups are summarized into the Other category. These vertex groups can be found within Shape keys, Modifiers, etc. There is really no good name for this category, so we kept it simple and named it Other.

> Tip: The active Vertex
> That is the most recently selected vertex. This vertex is always highlighted so that you can see it easily in the mesh. If the active vertex does not have weights, or there is no active vertex selected at the moment, then the Vertex Weights Panel disappears.

Display Weights in Edit Mode
When you are in Edit Mode, you can make the weights of the active group visible on the mesh:
Select the Viewport Overlays popover from the header of the 3D Viewport. And there enable the Vertex Group Weights option. Now you can see the weights of the active vertex group displayed on the mesh surface.

**Geometry Data**

Clear Sculpt-Mask Data
Completely removes the mask data from the mesh. While not a huge benefit, this can speed-up sculpting if the mask is no longer being used.

Add/Clear Skin Data
Used to manage the skin data which is used by the Skin Modifier. This operator can be needed in case a Skin modifier is created but no skin data exist.

Add/Clear Custom Split Normals Data
Adds Custom Split Normals data, if none exists yet.

Store
Vertex Bevel Weight
Save the Vertex Bevel Weight with the mesh data.

Edge Bevel Weight
Save the Edge Bevel Weight with the mesh data.

Edge Crease
Save the Edge Crease with the mesh data.


## UVs & Texture Space

UV Maps
(Image) https://docs.blender.org/manual/en/latest/_images/modeling_meshes_uv_uv-texture-spaces_uv-maps.png
The UV Maps panel in the Mesh tab

In the Mesh tab the UV maps panel contains a List view that lists the UV maps created for this mesh. The selected map is displayed in the UV Editor.

Active Render
Click the camera icon to enable that UV texture for rendering. If no other map is explicitly specified.

Add +
Clicking the Add button duplicates the selected UV map.

### Texture Space

These are settings of the Texture Space used by generated texture mapping. The visualization of the texture space can be activated in the Viewport Display.

Auto Texture Space
Adjusts the active object’s texture space automatically when transforming the object.

Location, Size
If the texture space is not calculated automatically then you can define the location and size of the texture space relative to the base object. These can also be adjusted from the 3D Viewport, see Editing for more information.

Texture Mesh
Use another mesh for texture indices, the vertex of the two objects must be perfectly aligned. Otherwise the UV map will be distorted. Note that, this is only for mesh objects.

Match Texture Space
Modifies the Location and Size to match the objects bounding box. This disables Auto Texture Space. Note that, this is only for curve objects.

## Editing

To modify the texture space from the 3D Viewport, enable Edit Texture Space while transforming an object.

The automatically calculated UV map can be accessed by an object’s material through the Generated output of the Texture Coordinate Node. This output can then be used to map any texture onto an object.

> Tip: Generated texture spaces do not have rotation support, to overcome this, a Mapping Node can be used to rotate the UV map.

### About UVs

Every point in the UV map corresponds to a vertex in the mesh. The lines joining the UVs correspond to edges in the mesh. Each face in the UV map corresponds to a mesh face. Think of a UV map as projecting the surface of your 3D model onto a 2D image.

Each face of a mesh can have many UV textures. Each UV texture can have an individual image assigned to it. When you unwrap a face to a UV texture in the UV Editor, each face of the mesh is automatically assigned four UV coordinates: These coordinates define the way an image or a texture is mapped onto the face. To distinguish from XYZ coordinates, the U and V axes are used to mark the coordinates of each point. Hence the name, UV unwrapping. These coordinates can be used for rendering or for real-time viewport display as well.

Every face in Blender can have a link to a different image. The UV coordinates define how this image is mapped onto the face. This image then can be rendered or displayed in real-time. A 3D Viewport has to be in “Face Select” mode to be able to assign Images or change UV coordinates of the active mesh object. This allows a face to participate in many UV textures. A face at the hairline of a character might participate in the facial UV texture, and in the scalp/hair UV texture.

These are described more fully in the next sections.

By default, meshes are not created with UVs. First you must map the faces, then you can edit them. The process of unwrapping your model is done within Edit Mode in the 3D Viewport. This process creates one or more UV Islands in the UV Editor.

To begin, choose the UV Editing workspace from the selection list at the top of your screen in the Preferences header. This sets one of the areas to show you the UV Editor, and the other area to the 3D Viewport.

Enter Edit Mode, as all unwrapping is done in Edit Mode. You can be in vertex, face, or edge selection mode.

`Workflow`

The general workflow is as follows, but know that different models may require different approaches to unwrapping:

1. Mark Seams if necessary. See more about marking seams.
2. Select mesh faces in the 3D Viewport.
3. Select a UV mapping method from the UV ‣ Unwrap menu or the UV menu in the 3D Viewport.
4. Adjust the unwrap settings in the Adjust Last Operation panel.
5. Add a test image to see if there will be any distortion. See Applying Images to UVs.
6. Adjust UVs in the UV editor. See Editing UVs.

**Seams**

For many cases, using the Unwrap calculations of Cube, Cylinder, Sphere, or best fit will produce a good UV layout. But for more complex meshes, especially those with lots of indentations, you may want to define a seam to limit and guide the Unwrap operator.

Just like in sewing, a seam is where the ends of the image/cloth are sewn together. In unwrapping, the mesh is unwrapped at the seams. Think of this method as peeling an orange or skinning an animal. You make a series of cuts in the skin, then peel it off. You could then flatten it out, applying some amount of stretching. These cuts are the same as seams.

When using this method, you need to be aware of how much stretching there is. The more seams there are, the less stretching there is, but this is often an issue for the texturing process. It is a good idea to have as few seams as possible while having the least amount of stretching. Try to hide seams where they will not be seen. In productions where 3D paint is used, this becomes less of an issue, as projection painting can easily deal with seams, as opposed to 2D texturing, where it is difficult to match the edges of different UV islands.

The workflow is the following:

1. Mark seams.
2. Unwrap.
3. Adjust seams and repeat.
4. Manually adjust UVs.

Mark Seam

To add an edge to a seam, simply select the edge and press Ctrl-E to Mark Seam, or to remove it, use Ctrl-E to Clear Seam.

When marking seams, you can use the Select ‣ Linked Faces or Ctrl-L in Face Select Mode to check your work. This menu option selects all faces connected to the selected one, up to a seam. If faces outside your intended seam are selected, you know that your seam is not continuous. You do not need continuous seams, however, as long as they resolve regions that may stretch.

Just as there are many ways to skin a cat, there are many ways to go about deciding where seams should go. In general though, you should think as if you were holding the object in one hand, and a pair of sharp scissors in the other, and you want to cut it apart and spread it on the table with as little tearing as possible.

** Toolbar **

Transform
Tool to adjust the UVs translation, rotations and scale.

Annotate
Draw free-hand annotation.

Annotate Line
Draw straight line annotation.

Annotate Polygon
Draw a polygon annotation.

Annotate Eraser
Erase previous drawn annotations.

Rip - Shortcut: V
The Rip tool separates UV faces from each other.

Grab
The Grab tool moves UVs around.

Relax
The Relax tool makes UVs more evenly distributed.

Pinch
The Pinch tool moves UVs toward the brush’s center.

** Editing **

After unwrap, you will likely need to arrange the UV maps, so that they can be used in texturing or painting. Your goals for editing are:

Stitch pieces (of UV maps) back together.
Minimize wasted space in the image.
Enlarge the faces where you want more detail.
Re-size/enlarge the faces that are stretched.
Shrink the faces that are too grainy and have too much detail.

With a minimum of dead space, the most pixels can be dedicated to giving the maximum detail and fineness to the UV texture. A UV face can be as small as a pixel (the little dots that make up an image) or as large as an entire image. You probably want to make major adjustments first, and then tweak the layout.

`Mirror`
Editor:     UV Editor
Mode:       Edit Mode
Menu:       UV ‣ Mirror
Shortcut:   Ctrl-M

`UV ‣ Copy Mirrored UV Coordinates`

`Snap`
Editor:     UV Editor
Mode:       Edit Mode
Menu:       UV ‣ Snap
Shortcut:   Shift-S

Snapping in the UV Editor is similar to Snapping in 3D. For the snap to pixel options to work an image has to be loaded.

Selected to Pixels
Moves selection to nearest pixel. See also Snap to pixel above.

Selected to Cursor
Moves selection to 2D cursor location.

Selected to Cursor (Offset)
Moves selection center to 2D cursor location, while preserving the offset of the vertices from the center.

Selected to Adjacent Unselected
Moves selection to adjacent unselected element.

Cursor to Pixels
Snaps the cursor to the nearest pixels.

Cursor to Selected
Moves the Cursor to the center of the selection.

`Merge` + `Split`
Editor:     UV Editor
Mode:       Edit Mode
Menu:       UV ‣ Split
Shortcut:   M(Merge), Alt-M(Split)

`Pin` & `Unpin`
Editor:     UV Editor
Mode:       Edit Mode
Menu:       UV ‣ Pin/Unpin
Shortcut:   P, Alt-P

You can pin UVs so they do not move between multiple unwrap operations. When Unwrapping a model it is sometimes useful to “Lock” certain UVs, so that parts of a UV layout stay the same shape, and/or in the same place. Pinning is done by selecting a UV, then selecting Pin from the UVs menu, or the shortcut P. You can Unpin a UV with the shortcut Alt-P.

`Average Island Scale` (Ctrl-A)
Using the Average Island Scale tool, will scale each UV island so that they are all approximately the same scale.

`Minimize Stretch` (Ctrl-V)
The Minimize Stretch tool, reduces UV stretch by minimizing angles. This essentially relaxes the UVs.

`Stitch`
The Stitch tool, will join selected UVs that share vertices. You set the tool to limit stitching by distance in the Adjust Last Operation panel, by activating Use Limit and adjusting the Limit Distance.

`Align` (Shift-W)
Will line up the selected UVs on the X axis, Y axis, or automatically chosen axis.

`Proportional Editing` (O) (as in Oscar)
Proportional Editing is available in UV editing. The controls are the same as in the 3D Viewport. See Proportional Editing in 3D for a full reference.
https://docs.blender.org/manual/en/latest/editors/3dview/controls/proportional_editing.html

`Multiple UV Maps`
You are not limited to one UV map per mesh. You can have multiple UV maps for parts of the mesh by creating new UV maps. This can be done by clicking the Add button next to UV maps list and unwrapping a different part of the mesh. UV maps always include the whole mesh.

### Optimizing the UV Layout

When you have unwrapped, possibly using seams, your UV layout may be quite disorganized and chaotic. You may need to proceed with the following tasks: Orientation of the UV mapping, arranging the UV maps, stitching several maps together.

The next step is to work with the UV layouts that you have created through the unwrap process. If you do add faces or subdivide existing faces when a model is already unwrapped, Blender will add those new faces for you. In this fashion, you can use the UV texture image to guide additional geometry changes.

When arranging, keep in mind that the entire view is your workspace, but only the UV coordinates within the grid are mapped to the image. So, you can put pieces off to the side while you arrange them. Also, each UV unwrap is its own linked set of coordinates.

You can lay them on top of one another, and they will onion skin (the bottom one will show through the top one). To move only one though, RMB select one of the UV coordinates, and use Select ‣ Linked UVs, Ctrl-L to select connected UVs, not box select because UVs from both will be selected.

Iteration & Refinement

At least for common people, we just do not “get it right the first time.” It takes building on an idea and iterating our creative process until we reach that magical milestone called “Done”. In software development, this is called the ‘spiral methodology’.

Applied to computer graphics, we cycle between modeling, texturing, animating, and then back to making modifications to mesh, UV mapping, tweaking the animation, adding a bone or two, finding out we need a few more faces, so back to modeling, etc. We continue going round and round like this until we either run out of time, money, or patience, or, in rare cases, are actually happy with our results.

Reusing Textures

Another consideration is the need to conserve resources. Each image file is loaded in memory. If you can reuse the same image on different meshes, it saves memory. So, for example, you might want to have a generic face painting, and use that on different characters, but alter the UV map and shape and props (sunglasses) to differentiate.

You might want to have a “faded blue jeans” texture, and unwrap just the legs of characters to use that image. It would be good to have a generic skin image, and use that for character’s hands, feet, arms, legs, and neck. When modeling a fantasy sword, a small image for a piece of the sword blade would suffice, and you would Reset Unwrap the sword faces to reuse that image down the length of the blade.

Retopology

Retopology is the process of simplifying the topology of a mesh to make it cleaner and easier to work with. Retopology is need for mangled topology resulting from sculpting or generated topology, for example from a 3D scan. Meshes often need to be retopologized if the mesh is going to be deformed in some way. Deformations can include rigging or physics simulations such as cloth or soft body. Retopology can be done by hand by manipulating geometry in Edit Mode or through automated methods.

**Remeshing** - Panel Properties ‣ Object Data ‣ Remesh 

`Voxel Size`
The resolution or the amount of detail the remeshed mesh will have. The value is used to define the size, in object space, of the Voxel. These voxels are assembled around the mesh and are used to determine the new geometry. For example a value of 0.5 m will create topological patches that are about 0.5 m (assuming Preserve Volume is enabled). Lower values preserve finer details but will result in a mesh with a much more dense topology.

`Adaptivity`
Reduces the final face count by simplifying geometry where detail is not needed. This introduce triangulation to faces that do not need as much detail. Note, an Adaptivity value greater than zero disables Fix Poles.

`Fix Poles`
Tries to produce less Poles at the cost of some performance to produce a better topological flow.

Preserve
`Volume` Tells the algorithm to try to preserve the original volume of the mesh. Enabling this could make the operator slower depending on the complexity of the mesh.
`Paint Mask` Reprojects the paint mask onto the new mesh.
`Face Sets` Reprojects Face Sets onto the new mesh.

Voxel Remesh
Performs the remeshing operation to create a new manifold mesh based on the volume of the current mesh. Performing this will lose all mesh object data layers associated with the original mesh.

Quad

The Quad remesh uses the Quadriflow algorithm to create a Quad based mesh with few poles and edge loops following the curvature of the surface. This method is relatively slow but generates a higher quality output for final topology.

## Brush Control

Set brush size F
Set brush strength Shift-F
Rotate brush texture Ctrl-F
Invert stroke toggle Ctrl

Selection Masking

If you have a complex mesh, it is sometimes not easy to paint on all vertices. Suppose you only want to paint on a small area of the Mesh and keep the rest untouched. This is where “selection masking” comes into play. When this mode is enabled, a brush will only paint on the selected vertices or faces. The option is available from the header of the 3D Viewport (see icons surrounded by the yellow frame):

Selection masking has some advantages over the default paint mode:
- The original mesh edges are shown, even when modifiers are active.
- You can select faces to restrict painting to the vertices of the selected faces.

Details About Selecting

The following standard selection operations are supported:

RMB – Single faces. Use Shift-RMB to select multiple.
A – All faces, also to deselect.
B – Box selection.
C – Circle select with brush.
L – Pick linked (under the mouse cursor).
Ctrl-L – Select linked.
Ctrl-I – Invert selection Inverse.

## Grease Pencil
Source: https://docs.blender.org/manual/en/latest/grease_pencil/selecting.html

Mode:       Object Mode and Edit Mode
Menu:       Add ‣ Grease Pencil
Shortcut:   Shift-A

Introduction

Grease Pencil is a particular type of Blender object that allow you to draw in the 3D space. Can be use to make traditional 2D animation, cut-out animation, motion graphics or used it as storyboard tool among other things.
The object act as a container of strokes that you can create using drawing tools in Draw Mode. More detailed editing of the strokes is done in Edit Mode, and Sculpt Mode.

> Tip: To obtain best results with Grease Pencil is highly recommended to use a Graphics Tablet.

