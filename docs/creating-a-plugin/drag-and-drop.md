# Drag and Drop Support

One of the most powerful features of the S4L Plugin Framework is the ability to associate geometric entities (like vertices, edges, faces, and bodies) with simulation components through drag-and-drop operations. This page explains how to implement drag-and-drop support for your plugin.

## The HasGeometries Base Class

The framework provides a `HasGeometries` base class that handles most of the complexity of geometry association. When a user drags geometric entities from the modeling window and drops them onto a settings component in the simulation tree, the framework automatically associates those entities with the component.

## Creating a Geometry-Aware Component

To create a settings component that can accept geometric entities:

1. Make your class inherit from `HasGeometries`
2. Specify which types of geometric entities are allowed
3. Implement geometry-related methods

Here's an example:

```python
class SourceSettings(HasGeometries):
    """
    Defines heat source properties that can be associated with point locations.
    """

    def __init__(
        self,
        parent: "TreeItem",
    ) -> None:
        # Step 1: Define allowed geometry types
        allowed_types = self._get_allowed_entity_types()

        # Step 2: Initialize with HasGeometries as a base class
        super().__init__(
            parent=parent,
            icon="icons/EmFdtdSimulatorUI/semx_pointsensor.ico",
            allowed_entity_types=allowed_types,
        )

        # Step 3: Create properties as usual
        self._properties = XCoreHeadless.DialogOptions()
        self._properties.Description = "Source Settings"

        volumetric_heat_source = XCore.PropertyReal(100.0, 0.0, 0.0, XCore.Unit("W/m³"))
        volumetric_heat_source.Description = "Volumetric Heat Source"
        self._properties.Add("volumetric_heat_source", volumetric_heat_source)

    def _get_allowed_entity_types(self) -> tuple[type[xm.Entity], ...]:
        """
        Specifies which types of geometric entities can be dropped on this component.
        
        Returns:
            Tuple of allowed entity types
        """
        return (xm.Vertex,)  # Only vertices are allowed for point sources
```

## Allowed Entity Types

The `_get_allowed_entity_types` method specifies which types of geometric entities can be associated with your component. The S4L modeling system provides several entity types:

| Entity Type | Description |
|-------------|-------------|
| `xm.Vertex` | A point or vertex in 3D space |
| `xm.Edge` | A curve or edge connecting vertices |
| `xm.Face` | A surface bounded by edges |
| `xm.Body` | A solid volume bounded by faces |
| `xm.Group` | A collection of other entities |

Choose the entity types that make sense for your component. For example:
- Material properties typically apply to bodies (volumes)
- Boundary conditions typically apply to faces (surfaces)
- Point sources or sensors typically apply to vertices (points)
- Line sources typically apply to edges (curves)

## Working with Associated Geometries

Once geometric entities are associated with your component, you can access them through the `_geometries` collection:

```python
def validate(self) -> bool:
    """
    Validates that the source settings are complete and valid.
    
    Checks that the source is associated with exactly one geometric vertex and
    that the power density is non-negative.
    
    Returns:
        True if the source settings are valid, False otherwise
    """
    # Check that we have exactly one geometry
    if len(self._geometries) != 1:
        self.status_icons = ["icons/TaskManager/Warning.ico"]
        self.status_icons_tooltip = "Source must be associated with exactly one vertex"
        return False

    return True

def as_api_model(self) -> api_models.SourceSettings:
    """
    Converts this source settings object to a solver API model.
    
    Returns:
        A SourceSettings object in the solver API format
    """
    # Extract property value
    volumetric_heat_source_prop = self._properties.volumetric_heat_source
    assert isinstance(volumetric_heat_source_prop, XCore.PropertyReal)

    # Make sure we have a geometry
    assert len(self._geometries) == 1

    # Get the vertex and its position
    point = self._geometries[0].entity
    points = xm.GetVertices(point)
    assert len(points)
    point = points[0]

    # Create the API model with the position
    return api_models.SourceSettings(
        volumetric_heat_source=volumetric_heat_source_prop.Value,
        x=point.Position[0],
        y=point.Position[1],
        z=point.Position[2],
    )
```

## Entity Selection and Filtering

The `HasGeometries` base class handles filtering of entities based on your allowed types. When a user drags entities onto your component, the framework automatically:

1. Filters out entities that don't match your allowed types
2. Adds valid entities to your `_geometries` collection
3. Displays the associated geometries in the tree view

## Working with Multiple Geometries

Some components may need to work with multiple geometric entities. For example, a material property might apply to multiple bodies:

```python
def as_api_model(self) -> api_models.MaterialSettings:
    """
    Converts this material settings object to a solver API model.
    
    Returns:
        A MaterialSettings object in the solver API format
    """
    thermal_conductivity_prop = self._properties.thermal_conductivity
    assert isinstance(thermal_conductivity_prop, XCore.PropertyReal)

    # Calculate the combined bounding box of all geometries
    entities = [geom.entity for geom in self._geometries]
    p1, p2 = xm.GetBoundingBox(entities)

    return api_models.MaterialSettings(
        thermal_conductivity=thermal_conductivity_prop.Value,
        xmin=p1[0],
        xmax=p2[0],
        ymin=p1[1],
        ymax=p2[1],
        zmin=p1[2],
        zmax=p2[2],
    )
```

## Validating Geometry Assignments

Always validate that the correct geometries are assigned to your component:

```python
def validate(self) -> bool:
    """
    Validates that the boundary condition is properly configured.
    
    Checks that the boundary is associated with a face entity and 
    that the temperature is physically reasonable.
    
    Returns:
        True if the boundary condition is valid, False otherwise
    """
    self.clear_status()
    
    # Check that we have at least one geometry
    if len(self._geometries) == 0:
        self.status_icons = ["icons/TaskManager/Warning.ico"]
        self.status_icons_tooltip = "No geometry assigned to this boundary"
        return False
    
    # Check that all assigned geometries are faces
    for geom in self._geometries:
        if not isinstance(geom.entity, xm.Face):
            self.status_icons = ["icons/TaskManager/Warning.ico"]
            self.status_icons_tooltip = "Only face entities can be assigned to boundaries"
            return False
    
    # Validate property values if needed
    temperature_prop = self._properties.temperature
    assert isinstance(temperature_prop, XCore.PropertyReal)
    
    if temperature_prop.Value < 0:
        self.status_icons = ["icons/TaskManager/Warning.ico"]
        self.status_icons_tooltip = "Temperature must be non-negative"
        return False
    
    return True
```

## Advanced Geometry Processing

For more complex scenarios, you might need to extract specific information from the geometry or process it in custom ways:

```python
def process_geometries(self):
    """Process the assigned geometries to extract specialized information."""
    results = []
    
    for geom in self._geometries:
        if isinstance(geom.entity, xm.Face):
            face = geom.entity
            
            # Calculate face area
            area = xm.CalculateArea(face)
            
            # Get face normal at the center
            center = xm.GetCenterOfMass(face)
            normal = xm.CalculateNormal(face, center)
            
            results.append({
                "area": area,
                "center": center,
                "normal": normal
            })
    
    return results
```

## Custom Drag and Drop Handlers

While the `HasGeometries` base class handles most drag-and-drop functionality automatically, you can implement custom drop handlers if needed:

```python
def on_drop(self, data: Any) -> bool:
    """
    Custom drop handler for specialized drag-and-drop behavior.
    
    Args:
        data: The dragged data, typically a collection of entities
        
    Returns:
        True if the drop was handled, False otherwise
    """
    # Let the base class handle normal geometry drops
    if isinstance(data, list) and all(isinstance(item, xm.Entity) for item in data):
        return super().on_drop(data)
    
    # Handle custom data types
    if isinstance(data, CustomDataType):
        # Process the custom data
        # ...
        return True
    
    return False
```

## Example: Boundary Condition with Face Assignment

Here's a complete example of a boundary condition component that requires face assignment:

```python
class BoundarySettings(HasGeometries):
    """
    Defines boundary conditions that can be applied to faces in the domain.
    """

    def __init__(
        self,
        parent: "TreeItem",
    ) -> None:
        allowed_types = self._get_allowed_entity_types()

        super().__init__(
            parent=parent,
            icon="icons/XSimulatorUI/BoundarySettings.ico",
            allowed_entity_types=allowed_types,
        )

        self._properties = XCoreHeadless.DialogOptions()
        self._properties.Description = "Boundary Settings"

        # Boundary type selection
        boundary_type = XCore.PropertyEnum(
            ("Dirichlet", "Neumann", "Robin"),
            0,
        )
        boundary_type.Description = "Boundary Type"
        self._properties.Add("boundary_type", boundary_type)

        # Temperature value for Dirichlet condition
        temperature = XCore.PropertyReal(0.0, 0.0, 1000.0, XCore.Unit("K"))
        temperature.Description = "Temperature"
        self._properties.Add("temperature", temperature)

        # Heat flux value for Neumann condition
        heat_flux = XCore.PropertyReal(0.0, -1000.0, 1000.0, XCore.Unit("W/m²"))
        heat_flux.Description = "Heat Flux"
        self._properties.Add("heat_flux", heat_flux)

        # Convection coefficient for Robin condition
        h_coeff = XCore.PropertyReal(10.0, 0.0, 1000.0, XCore.Unit("W/(m²·K)"))
        h_coeff.Description = "Convection Coefficient"
        self._properties.Add("h_coeff", h_coeff)

        # Ambient temperature for Robin condition
        t_ambient = XCore.PropertyReal(293.15, 0.0, 1000.0, XCore.Unit("K"))
        t_ambient.Description = "Ambient Temperature"
        self._properties.Add("t_ambient", t_ambient)

    def _get_allowed_entity_types(self) -> tuple[type[xm.Entity], ...]:
        """Only faces can have boundary conditions."""
        return (xm.Face,)

    # ... other methods for validation and API model conversion ...
```

## Next Steps

After implementing drag-and-drop support for your settings components, you'll want to:

- [Write a Solver](../solver-implementation/writing-solver.md): Implement the numerical solver for your simulation
- [Define API Models](../solver-implementation/api-models.md): Create data transfer objects for the solver
- [Create an Extractor](../extractors/creating-extractor.md): Implement result visualization and analysis