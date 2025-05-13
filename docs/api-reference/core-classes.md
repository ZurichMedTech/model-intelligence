# Core Classes

This page documents the core classes that form the foundation of the S4L Plugin Framework.

## Base Classes

### Simulation

The `Simulation` class is the central class in the plugin framework. It represents a single simulation and manages its lifecycle.

```python
class Simulation:
    """Base class for all simulations in the S4L Plugin Framework."""
    
    def __init__(self, name: str, description: str):
        """Initialize a new simulation.
        
        Args:
            name: The display name of the simulation
            description: A detailed description
        """
        self.name = name
        self.description = description
        self.settings = {}
        
    def register_settings(self, settings_obj):
        """Register a settings object with the simulation.
        
        Args:
            settings_obj: A settings object instance
        """
        pass
        
    def create_extractor(self):
        """Create a result extractor for this simulation.
        
        Returns:
            An extractor instance
        """
        pass
        
    def validate(self):
        """Validate the simulation settings.
        
        Returns:
            bool: True if settings are valid, False otherwise
        """
        pass
```

### SimulationExtractor

The `SimulationExtractor` class handles result visualization and analysis.

```python
class SimulationExtractor:
    """Base class for extracting and visualizing simulation results."""
    
    def __init__(self, simulation):
        """Initialize a new extractor.
        
        Args:
            simulation: The parent simulation
        """
        self.simulation = simulation
        
    def load_results(self, result_dir: str):
        """Load results from the specified directory.
        
        Args:
            result_dir: Path to the directory containing result files
        """
        pass
        
    def create_visualizations(self):
        """Create visualization objects for the UI.
        
        Returns:
            List of visualization objects
        """
        pass
        
    def extract_scalar(self, name: str):
        """Extract a scalar value from results.
        
        Args:
            name: Name of the scalar value to extract
            
        Returns:
            The extracted scalar value
        """
        pass
```

## Settings Classes

### SettingsBase

Base class for all settings objects in the plugin framework.

```python
class SettingsBase:
    """Base class for all settings in the S4L Plugin Framework."""
    
    def __init__(self, name: str):
        """Initialize settings.
        
        Args:
            name: The settings name
        """
        self.name = name
        self.parameters = []
        
    def add_parameter(self, parameter):
        """Add a parameter to the settings.
        
        Args:
            parameter: Parameter object to add
        """
        pass
        
    def validate(self):
        """Validate all parameters.
        
        Returns:
            bool: True if all parameters are valid
        """
        pass
        
    def to_dict(self):
        """Convert settings to dictionary.
        
        Returns:
            Dict representation of the settings
        """
        pass
```

### GridSettings

Settings class for defining simulation grid parameters.

```python
class GridSettings(SettingsBase):
    """Settings for simulation grid definition."""
    
    def __init__(self):
        """Initialize grid settings."""
        super().__init__("Grid")
        
    def define_regular_grid(self, dims, spacing, origin=(0, 0, 0)):
        """Define a regular grid.
        
        Args:
            dims: Grid dimensions (nx, ny, nz)
            spacing: Grid spacing (dx, dy, dz)
            origin: Grid origin coordinates
        """
        pass
        
    def get_vtk_grid(self):
        """Get a VTK representation of the grid.
        
        Returns:
            VTK grid object
        """
        pass
```

### MaterialSettings

Settings for material properties used in simulations.

```python
class MaterialSettings(SettingsBase):
    """Settings for simulation materials."""
    
    def __init__(self):
        """Initialize material settings."""
        super().__init__("Materials")
        
    def add_material(self, name: str, properties: dict):
        """Add a material definition.
        
        Args:
            name: Material name
            properties: Dictionary of material properties
        """
        pass
        
    def get_material_property(self, material_name: str, property_name: str):
        """Get a specific material property.
        
        Args:
            material_name: Name of the material
            property_name: Name of the property
            
        Returns:
            The property value
        """
        pass
```

## Controller Classes

### SimulationManager

Manages available simulations and their lifecycle.

```python
class SimulationManager:
    """Manages simulation instances."""
    
    def register_simulation_type(self, simulation_class):
        """Register a simulation class.
        
        Args:
            simulation_class: Class to register
        """
        pass
        
    def create_simulation(self, simulation_type: str):
        """Create a new simulation instance.
        
        Args:
            simulation_type: The simulation type to create
            
        Returns:
            New simulation instance
        """
        pass
        
    def get_available_simulations(self):
        """Get list of available simulation types.
        
        Returns:
            List of simulation types
        """
        pass
```

### SimulationBinding

Binds simulation models to the S4L UI.

```python
class SimulationBinding:
    """Binds simulation to S4L UI components."""
    
    def __init__(self, simulation):
        """Initialize binding.
        
        Args:
            simulation: The simulation to bind
        """
        self.simulation = simulation
        
    def bind_settings_to_panel(self, panel_id: str, settings_obj):
        """Bind settings to a UI panel.
        
        Args:
            panel_id: ID of the panel
            settings_obj: Settings object to bind
        """
        pass
        
    def update_ui_from_model(self):
        """Update UI components from model data."""
        pass
        
    def update_model_from_ui(self):
        """Update model data from UI components."""
        pass
```

## Parameter Components

### Parameter

Base class for all parameter types.

```python
class Parameter:
    """Base class for parameters."""
    
    def __init__(self, name: str, default_value):
        """Initialize parameter.
        
        Args:
            name: Parameter name
            default_value: Default value
        """
        self.name = name
        self.value = default_value
        
    def validate(self):
        """Validate parameter value.
        
        Returns:
            bool: True if valid
        """
        pass
        
    def to_dict(self):
        """Convert to dictionary.
        
        Returns:
            Dict representation
        """
        pass
```

### PhysicalQuantity

Parameter representing a physical quantity with units.

```python
class PhysicalQuantity(Parameter):
    """Parameter for physical quantities with units."""
    
    def __init__(self, name: str, default_value, units):
        """Initialize physical quantity.
        
        Args:
            name: Parameter name
            default_value: Default value
            units: Unit definition
        """
        super().__init__(name, default_value)
        self.units = units
        
    def convert_to(self, target_units):
        """Convert value to different units.
        
        Args:
            target_units: Target units
            
        Returns:
            Converted value
        """
        pass
```

## Solver Components

### SolverBase

Base class for all physics solvers.

```python
class SolverBase:
    """Base class for physics solvers."""
    
    def initialize(self, settings):
        """Initialize solver with settings.
        
        Args:
            settings: Solver settings
        """
        pass
        
    def solve(self, input_data):
        """Run the solver.
        
        Args:
            input_data: Input data structure
            
        Returns:
            Solution results
        """
        pass
        
    def cleanup(self):
        """Clean up solver resources."""
        pass
```

### InputData

Container for solver input data.

```python
class InputData:
    """Container for solver input data."""
    
    def __init__(self):
        """Initialize input data container."""
        self.grid = None
        self.materials = {}
        self.sources = {}
        self.boundaries = {}
        self.settings = {}
```

### OutputData

Container for solver output data.

```python
class OutputData:
    """Container for solver output data."""
    
    def __init__(self):
        """Initialize output data container."""
        self.fields = {}
        self.scalars = {}
        
    def add_field(self, name: str, data, field_type: str):
        """Add a field to results.
        
        Args:
            name: Field name
            data: Field data
            field_type: Type of field (scalar, vector, etc.)
        """
        pass
        
    def add_scalar(self, name: str, value):
        """Add a scalar to results.
        
        Args:
            name: Scalar name
            value: Scalar value
        """
        pass
```

## Next Steps

For more detailed information about specific components:

- [Settings Components](settings-components.md)
- [Controller Components](controller-components.md)
- [VTK Integration](../extractors/vtk-integration.md)