<!-- filepath: /home/guidon/devel/src/gitlab/sim4life/plugins/template/documentation/docs/creating-a-plugin/property-types.md -->
# Property Types

The Sim4Life Plugin Framework supports a wide range of property types to define simulation parameters, settings, and UI elements. This page provides a comprehensive list of available property types with examples of how to use them in your simulation plugins.

## Core Property Types

The framework provides the following core property types:

| Property Type | Description | Sim4Life Class | Example |
|--------------|------------|-----------|---------|
| Real Quantity | Floating-point number with units | `XCore.PropertyReal` | Wave speed (m/s), Temperature (K) |
| Integer | Whole number | `XCore.PropertyInt` | Grid size, Iterations count |
| Boolean | True/false value | `XCore.PropertyBool` | Enable feature flag, Use adaptive meshing |
| String | Text value | `XCore.PropertyString` | Description, Material name |
| Multiline String | Text with multiple lines | `XCore.PropertyMultilineString` | Comments, Notes |
| Expression | Formula or mathematical expression | `XCorePython.PropertyExpression` | Force = mass * acceleration |
| Enumeration | Selection from predefined options | `XCore.PropertyEnum` | Material type, Boundary condition type |
| Color | RGBA color value | `XCore.PropertyColor` | Material color, Visualization color |
| File | File path | `XCore.PropertyFile` | Input mesh, Output file |
| Vec3 | 3D vector | `XCoreMath.PropertyVec3` | Position, Direction |
| Complex | Complex number | `XCore.PropertyComplex` | Impedance, Admittance |

## Collection Property Types

For representing collections of values:

| Property Type | Description | Sim4Life Class | Example |
|--------------|------------|-----------|---------|
| Real Tuple | Fixed-length array of real numbers | `XCore.PropertyRealTuple` | Frequency range [min, max, step] |
| Integer Tuple | Fixed-length array of integers | `XCore.PropertyIntTuple` | Grid dimensions [nx, ny, nz] |
| Real Vector | Dynamic array of real numbers | `XCore.PropertyRealVector` | List of frequencies, Time samples |
| Integer Vector | Dynamic array of integers | `XCore.PropertyIntVector` | List of material IDs |

## UI Control Property Types

For user interface controls:

| Property Type | Description | Sim4Life Class | Example |
|--------------|------------|-----------|---------|
| Group | Container for other properties | `XCore.PropertyGroup` | Material properties group |
| Button | Clickable button | `XCore.PropertyPushButton` | Calculate, Run simulation |
| Value Button | Editable field with button | `XCore.PropertyButton` | Browse for file |
| Filtered Item | Item selection with filtering | `XCore.PropertyFilteredItem` | Select entity from list |
| Proxy | Wrapper for another property | `XCore.PropertyProxy` | Forwarding property access |

## Usage Examples

### Real Quantity Property

```python
# Define a real property for wave speed
wave_speed = XCore.PropertyReal(340.0, 0.0, 10000.0, XCore.Unit("m/s"))
wave_speed.Description = "Wave Speed"
wave_speed.ToolTip = "Speed of wave propagation in the medium"
self._properties.Add("wave_speed", wave_speed)
```

### Integer Property

```python
# Define an integer property for grid size
grid_size = XCore.PropertyInt(100, 10, 1000)
grid_size.Description = "Grid Size"
grid_size.ToolTip = "Number of grid points in each dimension"
self._properties.Add("grid_size", grid_size)
```

### Boolean Property

```python
# Define a boolean property for enabling adaptive meshing
use_adaptive = XCore.PropertyBool(True)
use_adaptive.Description = "Use Adaptive Meshing"
use_adaptive.ToolTip = "Enable adaptive mesh refinement"
self._properties.Add("use_adaptive", use_adaptive)
```

### Enumeration Property

```python
# Define an enumeration property for boundary condition type
boundary_type = XCore.PropertyEnum()
boundary_type.Description = "Boundary Type"
boundary_type.Values = {
    0: "Dirichlet",
    1: "Neumann",
    2: "Robin"
}
boundary_type.Value = 0  # Default to Dirichlet
self._properties.Add("boundary_type", boundary_type)
```

### Vec3 Property

```python
# Define a Vec3 property for source position
source_position = XCoreMath.PropertyVec3(XCoreModeling.Vec3(0.0, 0.0, 0.0), XCore.Unit("m"))
source_position.Description = "Source Position"
source_position.ToolTip = "Position of the source in 3D space"
self._properties.Add("source_position", source_position)
```

### File Property

```python
# Define a file property for mesh input
mesh_file = XCore.PropertyFile("", True)  # True indicates input file
mesh_file.Description = "Mesh File"
mesh_file.ToolTip = "Select input mesh file"
mesh_file.Filter = "Mesh Files (*.msh;*.vtk)|*.msh;*.vtk|All Files (*.*)|*.*"
self._properties.Add("mesh_file", mesh_file)
```

### Real Vector Property

```python
# Define a real vector property for frequency list
frequencies = XCore.PropertyRealVector([2.4e9, 5.0e9, 5.8e9], XCore.Unit("Hz"))
frequencies.Description = "Frequencies"
frequencies.ToolTip = "List of frequencies for the simulation"
frequencies.VectorType = XCore.PropertyRealVector.eVectorType.kList
self._properties.Add("frequencies", frequencies)
```

### Group Property

```python
# Define a property group for material properties
material_props = XCore.PropertyGroup()
material_props.Description = "Material Properties"

# Add child properties to the group
permittivity = XCore.PropertyReal(1.0, 1.0, 100.0)
permittivity.Description = "Relative Permittivity"
material_props.Add("permittivity", permittivity)

conductivity = XCore.PropertyReal(0.0, 0.0, 10.0, XCore.Unit("S/m"))
conductivity.Description = "Conductivity"
material_props.Add("conductivity", conductivity)

# Add the group to the main properties
self._properties.Add("material", material_props)
```

### Push Button Property

Push buttons trigger actions when clicked. They are especially useful for calculations, validations, or displaying help information.

```python
import XCore

# A shared UUID for help windows so they reuse the same window
HELP_BUTTON_REPORT_UUID = XCore.Uuid()
HELP_BUTTON_REPORT_UUID.Create()

class MySettings(TreeItem):
    def __init__(self, parent: TreeItem) -> None:
        super().__init__(parent)
        
        self._properties = XCoreHeadless.DialogOptions()
        self._properties.Description = "My Settings"
        
        # Define a push button property for help
        help_button = XCore.PropertyPushButton()
        help_button.Description = "Help"
        help_button.Icon = "icons/TaskManager/Info.ico"
        
        # Connect a callback function to the button's Click event
        help_button.OnClicked.Connect(self._on_help_clicked)
        
        # Add the button to the properties panel
        self._properties.Add("help_button", help_button)
        
        # Add some parameter properties
        self._frequency = XCore.PropertyReal(2.4e9, 1e6, 1e12, XCore.Unit("Hz"))
        self._frequency.Description = "Frequency"
        self._properties.Add("frequency", self._frequency)
    
    def _on_help_clicked(self) -> None:
        """
        Callback function that will be executed when the Help button is clicked.
        Note that the OnClicked event doesn't pass sender/args parameters.
        """
        title = "Frequency Settings Help"
        text = (
            "The frequency parameter defines the operating frequency of the simulation.\n\n"
            "Valid range: 1 MHz to 1 THz\n\n"
            "For most applications, frequencies in the microwave range (1-300 GHz) are appropriate."
        )
        
        # Display help in a report window
        XCore.ReportWindowNotification.Notify(
            XCore.CreateReportWindowContent(HELP_BUTTON_REPORT_UUID, f"ⓘ {title}", text)
        )
```

You can also create a helper function to standardize help button creation and display:

```python
def create_help_button() -> XCore.PropertyPushButton:
    """Create a standardized help button."""
    help_button = XCore.PropertyPushButton()
    help_button.Description = "Help"
    help_button.Icon = "icons/TaskManager/Info.ico"
    return help_button

def display_help(title: str, text: str) -> None:
    """Display help text in a report window."""
    XCore.ReportWindowNotification.Notify(
        XCore.CreateReportWindowContent(HELP_BUTTON_REPORT_UUID, f"ⓘ {title}", text)
    )

class MySimulation(TreeItem):
    def __init__(self, parent: TreeItem) -> None:
        super().__init__(parent)
        
        # Create properties panel
        self._properties = XCoreHeadless.DialogOptions()
        
        # Add a help button
        help_button = create_help_button()
        self._properties.Add("help_button", help_button)
        
        # Connect event handler
        # Note: In real implementations, you might need to delay connecting
        # the event using asyncio.get_event_loop().call_soon(self._connect_help)
        help_button.OnClicked.Connect(self._display_help)
    
    def _display_help(self) -> None:
        """Handler for help button click."""
        title = "My Simulation"
        text = "This simulation solves... [detailed help text]"
        display_help(title, text)
```

#### Calculate Button Example

Push buttons are also commonly used for triggering calculations or other processing:

```python
class CalculationSettings(TreeItem):
    def __init__(self, parent: TreeItem) -> None:
        super().__init__(parent)
        
        self._properties = XCoreHeadless.DialogOptions()
        self._properties.Description = "Calculation Settings"
        
        # Input parameters
        self._input_value = XCore.PropertyReal(1.0, 0.0, 100.0)
        self._input_value.Description = "Input Value"
        self._properties.Add("input_value", self._input_value)
        
        # Results display
        self._result = XCore.PropertyReal(0.0, 0.0, 1000.0)
        self._result.Description = "Result"
        self._result.IsReadOnly = True
        self._properties.Add("result", self._result)
        
        # Calculate button
        calculate_button = XCore.PropertyPushButton("Calculate")
        calculate_button.Description = "Calculate Result"
        calculate_button.OnClicked.Connect(self._on_calculate_clicked)
        self._properties.Add("calculate", calculate_button)
    
    def _on_calculate_clicked(self) -> None:
        """Handler for calculate button click."""
        try:
            # Get the current input value
            input_val = self._input_value.Value
            
            # Perform calculation
            result = input_val * input_val  # Example: square the input
            
            # Update result property
            self._result.Value = result
```

### Complex Property

```python
# Define a complex property for impedance
impedance = XCore.PropertyComplex(50+0j), XCore.Unit("Ohm"))
impedance.Description = "Load Impedance"
impedance.ToolTip = "Complex impedance of the load"
self._properties.Add("impedance", impedance)
```

### Real Tuple Property

```python
# Define a real tuple property for simulation bounds
bounds = XCore.PropertyRealTuple([0.0, 1.0], XCore.Unit("m"))
bounds.Description = "Simulation Bounds"
bounds.ToolTip = "Min and max coordinates of the simulation domain"
self._properties.Add("bounds", bounds)
```

## Best Practices

When defining properties for your simulation plugin:

1. **Provide Clear Descriptions**: Use the Description field to clearly identify the purpose of each property.
2. **Add ToolTips**: Include tooltips to provide additional context when users hover over properties.
3. **Set Appropriate Bounds**: Define sensible minimum and maximum values for numerical properties.
4. **Use Appropriate Units**: Always specify physical units for real-valued properties.
5. **Group Related Properties**: Use property groups to organize related properties together.
6. **Set Default Values**: Provide sensible default values for all properties.
7. **Handle Property Validation**: Implement validation logic to ensure property values are consistent.

## Property Organization

Properties are typically organized in a tree structure. Each TreeItem in your simulation model can define its own set of properties:

```python
class MaterialSettings(TreeItem):
    def __init__(self, parent: TreeItem) -> None:
        super().__init__(parent)
        
        self._properties = XCoreHeadless.DialogOptions()
        self._properties.Description = "Material Settings"
        
        # Define material properties
        permittivity = XCore.PropertyReal(1.0, 1.0, 100.0)
        permittivity.Description = "Relative Permittivity"
        self._properties.Add("permittivity", permittivity)
        
        conductivity = XCore.PropertyReal(0.0, 0.0, 10.0, XCore.Unit("S/m"))
        conductivity.Description = "Conductivity"
        self._properties.Add("conductivity", conductivity)
        
        color = XCore.PropertyColor(XCore.Color(0.8, 0.8, 0.8, 1.0))
        color.Description = "Display Color"
        self._properties.Add("color", color)
```

## Next Steps

After defining your properties:

- [Define your simulation class](creating-simulation.md) to use these properties
- [Implement your solver](../solver-implementation/writing-solver.md) to process these properties