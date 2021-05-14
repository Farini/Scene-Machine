#  Scene Machine Data Model

The objective of this folder is to persist data created in the app.

For now, objects are related to:

- MaterialModel (needs rename)
- Drawing

Some challenges here includes:

- Persisting Color. See: `ColorData` object.
- `CGLineJoin` conforms to  `Codable`
- `CGLineCap` conforms to `Codable`
