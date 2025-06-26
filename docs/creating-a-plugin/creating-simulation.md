# Creating a Simulation Class

The `Simulation` class is the central component of your Sim4Life plugin. It serves as the container for all simulation settings and provides the core functionality for your physics model.

## Simulation Class Structure

The `Simulation` class inherits from `SimulationBase` and implements several key methods:

```python
class Simulation(SimulationBase):
    """
    Central model class representing a custom physics simulation.
    
    This class serves as the main container for all simulation settings and components,
    including setup parameters, material properties, boundary conditions, and solver parameters.
    """

    @classmethod
    def get_simulation_type_name(cls) -> str:
        """Display name for this simulation type in the Sim4Life interface."""
        return "My Physics Simulation"

    @classmethod
    def get_simulation_description(cls) -> str:
        """Brief description of what this simulation type does."""
        return "A simulation for solving custom physics problems"

    @classmethod
    def get_simulation_icon(cls) -> str:
        """Icon path for this simulation type in the UI."""
        return "icons/XSimulatorUI/new_simulation.ico"

    def __init__(
        self,
        parent: "TreeItem",
        sim_desc: str = "Simulation",
        sim_notes: str = "Solves physics equations",
    ) -> None:
        """Initialize a new simulation instance with default settings."""
        super().__init__(parent, sim_desc, sim_notes)
        
        # Add a help button to the properties panel
        self._properties.Add("help_button", create_help_button())
        
        # Schedule the help button connection
        asyncio.get_event_loop().call_soon(self._connect_help)
        # Note: Using call_soon ensures that the help button connection does not interfere with the initialization process, especially after deserialization from file.

    def on_initialize_settings(self) -> None:
        """Create all the settings components for this simulation."""
        self._setup_settings = setup_settings.SetupSettings(self)
        self._material_settings = material_settings.Materials(self)
        self._boundary_settings = boundary_settings.Boundaries(self)
        self._grid_settings = grid_settings.GridSettings(self)
        self._solver_settings = solver_settings.SolverSettings(self)
        
        # Add any other settings components specific to your physics model
```

## Required Methods

Your `Simulation` class must implement several required methods:

### Class Methods for Identification

```python
@classmethod
def get_simulation_type_name(cls) -> str:
    """Returns the display name used in the Sim4Life interface."""
    return "My Physics Simulation"

@classmethod
def get_simulation_description(cls) -> str:
    """Returns a brief description of this simulation type."""
    return "A simulation for solving custom physics problems"

@classmethod
def get_simulation_icon(cls) -> str:
    """Returns the path to the icon used in the UI."""
    return "icons/XSimulatorUI/new_simulation.ico"
```

These methods provide basic identification and display information for your simulation type in the Sim4Life interface.

### Initialization and Setting Creation

```python
def __init__(self, parent: "TreeItem", sim_desc: str = "Simulation", sim_notes: str = "Notes") -> None:
    """Initializes a new simulation instance with default settings."""
    super().__init__(parent, sim_desc, sim_notes)
    # Add properties, buttons, etc.

def on_initialize_settings(self) -> None:
    """Creates all the settings objects for this simulation."""
    # Create settings components
    self._setup_settings = setup_settings.SetupSettings(self)
    self._material_settings = material_settings.Materials(self)
    # ...other settings...
```

The `on_initialize_settings` method is called during initialization to set up all the settings components that make up your simulation.

### Properties and Getters

```python
@property
def setup_settings(self) -> setup_settings.SetupSettings:
    return self._setup_settings

@property
def material_settings(self) -> material_settings.Materials:
    return self._material_settings

# ...other property getters...
```

These property getters provide access to the various settings components of your simulation.

### Solver and Extractor Methods

```python
def register_extractor(self) -> pp.PythonModuleAlgorithm:
    """
    Registers a post-processing extractor for simulation results.
    
    Returns:
        A PostPro algorithm that can extract and process simulation results
    """
    return pp.PythonModuleAlgorithm(
        "my_package_name.model.simulation_extractor",
        0, # number of inputs
        1, # number of outputs
    )

def solver_backend(self) -> tuple[SolverBackend, config_type_t | None]:
    """
    Specifies which type of solver backend to use for running this simulation.
    
    Returns:
        A tuple containing the solver backend type and optional configuration
    """
    return SolverBackend.PROCESS, None
    
def get_solver_src(self) -> str:
    """
    Returns the Python module path to the solver implementation.
    
    Returns:
        The fully qualified module name for the solver implementation
    """
    return "my_package_name.solver.driver"
```

These methods provide the connections to your solver implementation and result extraction.

> **Note:** At present, only the subprocess backend is supported. This means your solver must have all required third-party libraries available after the plugin is installed via pip. In the future, a remote execution backend using Docker containerization will be introduced to simplify dependency management and execution.


### Validation and API Model Conversion

```python
def validate(self) -> bool:
    """
    Validates that the simulation configuration is complete and ready to run.
    
    Returns:
        True if the simulation is valid and ready to run, False otherwise
    """
    self.clear_status_recursively()
    # Perform validation checks
    # ...
    return True

def as_api_model(self) -> api_models.Simulation:
    """
    Converts the simulation model to a format suitable for the solver API.
    
    Returns:
        A solver API model representation of this simulation
    """
    if not self.validate():
        raise RuntimeError("Validation failed")

    # Convert settings to API model
    # ...
    
    return api_models.Simulation(
        setup_settings=self._setup_settings.as_api_model(),
        # ...other settings...
    )
```

These methods handle validation before running the simulation and conversion to the format needed by your solver.

## Adding Help Information

It's a good practice to provide help information for your simulation:

```python
def _connect_help(self):
    """Connects the help button click event to the help display handler."""
    help_button = self._properties.help_button
    assert isinstance(help_button, xc.PropertyPushButton)
    help_button.OnClicked.Connect(self._display_help)

def _display_help(self) -> None:
    """Displays help information when the help button is clicked."""
    title = "My Physics Simulation"
    text = (
        "This simulation solves the physics equation using numerical methods."
        "\n\n"
        "For more information, please refer to the documentation."
    )
    display_help(title, text)
```

## Example: Complete Simulation Class

Here's a complete example of a simulation class for a hypothetical wave equation solver:

```python
class WaveSimulation(SimulationBase):
    """
    Central model class representing a wave equation simulation.
    
    This class simulates wave propagation in various media, solving the
    wave equation: ∂²u/∂t² = c² ∇²u
    """

    @classmethod
    def get_simulation_type_name(cls) -> str:
        return "Wave Equation"

    @classmethod
    def get_simulation_description(cls) -> str:
        return "Simulation of wave propagation in various media"

    @classmethod
    def get_simulation_icon(cls) -> str:
        return "icons/XSimulatorUI/wave_simulation.ico"

    def __init__(
        self,
        parent: "TreeItem",
        sim_desc: str = "Wave Simulation",
        sim_notes: str = "Solves ∂²u/∂t² = c² ∇²u",
    ) -> None:
        super().__init__(parent, sim_desc, sim_notes)
        self._properties.Add("help_button", create_help_button())
        asyncio.get_event_loop().call_soon(self._connect_help)

    def on_initialize_settings(self) -> None:
        self._setup_settings = setup_settings.SetupSettings(self)
        self._material_settings = material_settings.Materials(self)
        self._boundary_settings = boundary_settings.Boundaries(self)
        self._grid_settings = grid_settings.GridSettings(self)
        self._time_settings = time_settings.TimeSettings(self)  # Time-domain specific
        self._solver_settings = solver_settings.SolverSettings(self)
        self._initial_conditions = initial_conditions.InitialConditions(self)  # Wave-specific

    # ... Properties, validation, etc. ...
```

> **Note:** Using call_soon ensures that the help button connection does not interfere with the initialization process, especially after deserialization from file.

## Common Patterns and Best Practices

When creating your simulation class:

1. **Organize settings logically**: Group related settings together in logical collections
2. **Provide clear validation**: Implement thorough validation to catch configuration errors
3. **Include helpful descriptions**: Make sure all properties and UI elements have clear descriptions
4. **Document physics equations**: Include the governing equations in comments and help text
5. **Prioritize extensibility**: Design your simulation to be easily extendable for future features

---

## Next Steps

- [Defining Settings](defining-settings.md)
- [Drag and Drop](drag-and-drop.md)
- [Property Types](property-types.md)
- [Solver Implementation](../solver-implementation/writing-solver.md)
- [Results Extractors Overview](../extractors/overview.md)