# Defining Settings

Settings components are the building blocks of your simulation's user interface. They allow users to configure various aspects of the simulation through property panels in the S4L interface.

## Types of Settings Components

The S4L Plugin Framework provides several types of settings components:

1. **Basic Settings**: Simple configuration options like `SetupSettings` and `GridSettings`
2. **Collection Settings**: Group-based settings like `Materials` and `Sources` that contain multiple items
3. **Geometry-Connected Settings**: Settings that can be associated with geometric entities, like `MaterialSettings`

## Creating a Basic Settings Component

Basic settings components inherit from `TreeItem` and provide a property panel:

```python
class GridSettings(TreeItem):
    """
    Defines the computational grid settings for the simulation domain.
    """

    def __init__(
        self,
        parent: TreeItem,
    ) -> None:
        """Initialize grid settings with default values."""
        super().__init__(parent, icon="icons/GridderUI/grid.ico")

        # Create properties panel
        self._properties = XCoreHeadless.DialogOptions()
        self._properties.Description = "Grid Settings"

        # Add properties to the panel
        dx = XCore.PropertyReal(1.0, 0.0, 100000.0, XCore.Unit("mm"))
        dx.Description = "Grid spacing along x-axis"
        self._properties.Add("dx", dx)

        dy = XCore.PropertyReal(1.0, 0.0, 100000.0, XCore.Unit("mm"))
        dy.Description = "Grid spacing along y-axis"
        self._properties.Add("dy", dy)

        dz = XCore.PropertyReal(1.0, 0.0, 100000.0, XCore.Unit("mm"))
        dz.Description = "Grid spacing along z-axis"
        self._properties.Add("dz", dz)

    @property
    def description(self) -> str:
        """Gets the descriptive name of the grid settings as shown in the UI."""
        return self._properties.Description

    @description.setter
    def description(self, value: str) -> None:
        """Sets the descriptive name of the grid settings as shown in the UI."""
        self._properties.Description = value

    @property
    def properties(self) -> XCore.PropertyGroup:
        """
        Provides access to the property group containing editable grid parameters.
        
        These properties will be displayed in the S4L properties panel when the
        grid settings are selected in the UI.
        """
        return self._properties

    def validate(self) -> bool:
        """
        Validates that the grid settings are physically reasonable.
        
        Returns:
            True if the grid settings are valid, False otherwise
        """
        return True

    def as_api_model(self) -> api_models.GridSettings:
        """
        Converts the grid settings to a solver API model.
        
        Returns:
            A GridSettings object in the solver API format
        """
        dx_prop = self._properties.dx
        assert isinstance(dx_prop, XCore.PropertyReal)

        dy_prop = self._properties.dy
        assert isinstance(dy_prop, XCore.PropertyReal)

        dz_prop = self._properties.dz
        assert isinstance(dz_prop, XCore.PropertyReal)

        return api_models.GridSettings(
            dx=dx_prop.Value,
            dy=dy_prop.Value,
            dz=dz_prop.Value,
        )
```

## Creating a Collection Settings Component

Collection settings use the `Group` generic class to manage multiple items of the same type:

```python
class Boundaries(Group[BoundarySettings]):
    """Collection class that manages a group of BoundarySettings objects."""

    def __init__(
        self, parent: TreeItem, is_expanded: bool = True, icon: str = ""
    ) -> None:
        super().__init__(
            parent,
            BoundarySettings,  # The item type for this collection
            is_expanded,
            icon="icons/XSimulatorUI/BoundarySettings.ico",
        )

    def _get_new_element_description(self) -> str:
        """Base name for new elements."""
        return "Boundary"

    def clear_status_recursively(self):
        """Clear status icons for this item and all children."""
        self.clear_status()
        for element in self._elements:
            element.clear_status_recursively()

    @property
    def description_text(self) -> str:
        """Display text in the tree."""
        return "Boundaries"
```

## Creating a Geometry-Connected Settings Component

Settings that need to be associated with geometric entities inherit from `HasGeometries`:

```python
class MaterialSettings(HasGeometries):
    """
    Defines material properties that can be assigned to geometric entities.
    """

    def __init__(
        self,
        parent: "TreeItem",
    ) -> None:
        # Define which types of geometry can be assigned to this setting
        allowed_types = self._get_allowed_entity_types()

        super().__init__(parent=parent, allowed_entity_types=allowed_types)

        # Create properties panel
        self._properties = XCoreHeadless.DialogOptions()
        self._properties.Description = "Material Settings"

        # Add material properties
        thermal_conductivity = XCore.PropertyReal(
            200.0, 0.0, 100000.0, XCore.Unit("W/mK")
        )
        thermal_conductivity.Description = "Thermal Conductivity"
        self._properties.Add("thermal_conductivity", thermal_conductivity)

    def _get_allowed_entity_types(self) -> tuple[type[xm.Entity], ...]:
        """
        Specifies which types of geometric entities can have this material assigned.
        
        Returns:
            Tuple of allowed entity types (only Body objects in this case)
        """
        return (xm.Body,)

    # ... other methods ...

    def as_api_model(self) -> api_models.MaterialSettings:
        """
        Converts this settings object to a solver API model.
        
        Extracts properties and the bounding box of associated geometries.
        
        Returns:
            A MaterialSettings object in the solver API format
        """
        thermal_conductivity_prop = self._properties.thermal_conductivity
        assert isinstance(thermal_conductivity_prop, XCore.PropertyReal)

        # Get the bounding box of the geometry
        p1, p2 = xm.GetBoundingBox([geom.entity for geom in self._geometries])

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

## Property Types

The S4L framework provides various property types for your settings. For a comprehensive list with detailed examples, see the [Property Types](property-types.md) documentation.

Here are some commonly used property types in settings components:

| Property Type | Description |
|---------------|-------------|
| `PropertyReal` | Floating-point value with optional units |
| `PropertyInt` | Integer value with range |
| `PropertyBool` | Boolean toggle |
| `PropertyString` | Text string |
| `PropertyEnum` | Dropdown selection |

Refer to the [Property Types](property-types.md) documentation for a complete reference including collection types, UI control types, and detailed usage examples.

## Creating Custom Property Panels

The property panel is created using `XCoreHeadless.DialogOptions()` and populated with property objects:

```python
# Create the panel
self._properties = XCoreHeadless.DialogOptions()
self._properties.Description = "My Settings"

# Add a numeric property
my_parameter = XCore.PropertyReal(1.0, 0.0, 10.0, XCore.Unit("m/s"))
my_parameter.Description = "My Parameter"
self._properties.Add("my_parameter", my_parameter)

# Add a dropdown property
solver_method = XCore.PropertyEnum(
    ("Method 1", "Method 2", "Method 3"),
    0,  # Default selection index
)
solver_method.Description = "Calculation Method"
self._properties.Add("solver_method", solver_method)

# Add a toggle property
enable_feature = XCore.PropertyBool(False)
enable_feature.Description = "Enable Advanced Features"
self._properties.Add("enable_feature", enable_feature)
```

## Handling Property Values

To retrieve property values when needed:

```python
def as_api_model(self) -> api_models.MySettings:
    """Convert settings to solver API model."""
    
    # Get property values - note the type assertions
    parameter_prop = self._properties.my_parameter
    assert isinstance(parameter_prop, XCore.PropertyReal)
    
    method_prop = self._properties.solver_method
    assert isinstance(method_prop, XCore.PropertyEnum)
    
    enable_prop = self._properties.enable_feature
    assert isinstance(enable_prop, XCore.PropertyBool)
    
    # Use the values
    return api_models.MySettings(
        parameter=parameter_prop.Value,
        method=method_prop.ValueDescription,
        advanced_enabled=enable_prop.Value,
    )
```

## Validation

Settings components should implement validation to ensure they have valid configurations:

```python
def validate(self) -> bool:
    """
    Validates that the settings are properly configured.
    
    Sets status indicators if validation fails.
    
    Returns:
        True if valid, False otherwise
    """
    # Clear any previous validation status
    self.clear_status()
    
    # Check for valid configuration
    if len(self._geometries) == 0:
        # Set a warning icon and tooltip
        self.status_icons = ["icons/TaskManager/Warning.ico"]
        self.status_icons_tooltip = "No geometry assigned"
        return False
        
    # Check property values
    my_param_prop = self._properties.my_parameter
    assert isinstance(my_param_prop, XCore.PropertyReal)
    
    if my_param_prop.Value <= 0:
        self.status_icons = ["icons/TaskManager/Warning.ico"]
        self.status_icons_tooltip = "Parameter must be positive"
        return False
    
    return True
```

## Example: A Custom Settings Component

Here's an example of a custom settings component for a wave simulation that includes time-domain settings:

```python
class TimeSettings(TreeItem):
    """
    Defines time-domain settings for a wave propagation simulation.
    
    This class manages parameters related to the temporal discretization and
    simulation duration for time-domain wave simulations.
    """

    def __init__(
        self,
        parent: TreeItem,
    ) -> None:
        """Initialize time settings with default values."""
        super().__init__(parent, icon="icons/XSimulatorUI/TimeSettings.ico")

        self._properties = XCoreHeadless.DialogOptions()
        self._properties.Description = "Time Settings"

        # Simulation end time
        end_time = XCore.PropertyReal(1.0, 0.0, 1000.0, XCore.Unit("s"))
        end_time.Description = "Simulation Duration"
        self._properties.Add("end_time", end_time)

        # Time step size
        dt = XCore.PropertyReal(0.001, 0.0, 1.0, XCore.Unit("s"))
        dt.Description = "Time Step"
        self._properties.Add("dt", dt)

        # Output interval
        output_interval = XCore.PropertyInt(10, 1, 1000)
        output_interval.Description = "Output Every N Steps"
        self._properties.Add("output_interval", output_interval)

        # Time integration method
        method = XCore.PropertyEnum(
            ("Explicit", "Implicit", "Crank-Nicolson"),
            0,
        )
        method.Description = "Time Integration Method"
        self._properties.Add("method", method)

    # ... Property getters, validation, API model conversion ...
```

## Next Steps

After defining your settings components, you'll want to:

- [Implement Drag and Drop](drag-and-drop.md): Enable geometry association for your settings
- [Create a Simulation Manager](../plugin-structure/entry-points.md#registration-module): Handle UI actions for your settings
- [Define API Models](../solver-implementation/api-models.md): Create data transfer objects for your solver