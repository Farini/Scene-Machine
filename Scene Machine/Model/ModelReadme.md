#  Scene Machine Data Model

The objective of this folder is to persist data created in the app.

For now, objects are related to:

- MaterialModel (needs rename)
- Drawing

Some challenges here includes:

- Persisting Color. See: `ColorData` object.
- `CGLineJoin` conforms to  `Codable`
- `CGLineCap` conforms to `Codable`

# SceneKit studies
You use geometry sources together with SCNGeometryElement objects to define custom SCNGeometry objects or to inspect the data that composes an existing geometry.

### GeometryElement
SCNGeometryElement object, containing an array of indices identifying vertices in the geometry sources and describing the drawing primitive that SceneKit uses to connect the vertices when rendering the geometry.

### GeometrySource
SCNGeometrySource objects containing vertex data. Each geometry source defines an attribute, or semantic, of the vertices it describes. You must provide at least one geometry source, using the vertex semantic, to create a custom geometry; typically you also provide geometry sources for surface normals and texture coordinates.
