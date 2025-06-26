# API Models

API models are the data transfer objects that connect your plugin's UI with the solver. They provide a clean, serializable representation of the simulation configuration that can be passed to the solver process.

## Purpose of API Models

API models serve several important purposes:

1. **Data Transfer**: They facilitate communication between the UI and the solver
2. **Clean Interface**: They provide a simplified representation of simulation parameters
3. **Validation**: They enforce data types and constraints
4. **Serialization**: They enable easy conversion to/from JSON

## Location and Structure

API models are defined in your plugin's `solver/driver/api_models.py` file. They use `dataclasses` and `dataclasses_json` to create serializable data objects:

```python
from dataclasses import dataclass
from enum import Enum

from dataclasses_json import dataclass_json


class LogLevel(Enum):
    """Logging verbosity levels."""
    INFO = "info"
    DEBUG = "debug"
    ERROR = "error"


@dataclass_json
@dataclass
class SetupSettings:
    """General simulation setup parameters."""
    log_level: str = LogLevel.INFO.value


@dataclass_json
@dataclass
class MaterialSettings:
    """Material properties and domain extents."""
    xmin: float
    xmax: float
    ymin: float
    ymax: float
    zmin: float
    zmax: float
    thermal_conductivity: float = 1.0


# ... other data classes ...


@dataclass_json
@dataclass
class Simulation:
    """Complete simulation configuration."""
    setup_settings: SetupSettings
    material_settings: list[MaterialSettings]
    # ... other settings ...
```

## Using Dataclasses

Python's `dataclass` decorator automatically adds special methods like `__init__` and `__repr__` to your classes. When combined with `dataclass_json`, they also gain serialization capabilities:

```python
@dataclass_json  # Add JSON serialization
@dataclass       # Create a data class
class GridSettings:
    """Computational grid parameters."""
    dx: float = 1.0
    dy: float = 1.0
    dz: float = 1.0
```

## JSON Serialization

The `dataclass_json` decorator adds methods for converting to and from JSON:

```python
# Create an instance
grid = GridSettings(dx=0.5, dy=0.5, dz=0.5)

# Convert to JSON string
json_str = grid.to_json()  # '{"dx": 0.5, "dy": 0.5, "dz": 0.5}'

# Create from JSON string
restored_grid = GridSettings.from_json(json_str)
```

## Type Validation

Use type hints and default values to enforce data types and constraints:

```python
@dataclass_json
@dataclass
class SolverSettings:
    """Numerical solver parameters."""
    solver_method: str = "jacobi"
    tolerance: float = 1e-6
    max_iter: int = 1000
```

## Enums for Constants

Use enum classes for constants like modes, types, or predefined options:

```python
class DirichletFace(Enum):
    """Domain boundary faces with fixed values."""
    XMIN = "xmin"
    XMAX = "xmax"
    YMIN = "ymin"
    YMAX = "ymax"
    ZMIN = "zmin"
    ZMAX = "zmax"


@dataclass_json
@dataclass
class BoundarySettings:
    """Boundary condition specification."""
    face: str = DirichletFace.XMIN.value
    temperature: float = 0.0
```

## Nested Data Structures

Complex models can include nested data structures or lists:

```python
@dataclass_json
@dataclass
class Simulation:
    """Complete simulation configuration."""
    setup_settings: SetupSettings
    material_settings: list[MaterialSettings]
    source_settings: list[SourceSettings]
    boundary_settings: list[BoundarySettings]
    grid_settings: GridSettings
    solver_settings: SolverSettings
```

## Connection to UI Model

In your `Simulation` class (the UI model), implement an `as_api_model` method to convert the UI model to an API model:

```python
def as_api_model(self) -> api_models.Simulation:
    """
    Converts the simulation model to a format suitable for the solver API.
    
    Returns:
        A solver API model representation of this simulation
    """
    if not self.validate():
        raise RuntimeError("Validation failed")

    # Convert materials
    api_materials: list[api_models.MaterialSettings] = []
    for material in self._material_settings.elements:
        api_materials.append(material.as_api_model())

    # Convert sources
    api_sources: list[api_models.SourceSettings] = []
    for source in self._source_settings.elements:
        api_sources.append(source.as_api_model())

    # Convert boundaries
    api_boundaries: list[api_models.BoundarySettings] = []
    for boundary in self._boundary_settings.elements:
        api_boundaries.append(boundary.as_api_model())

    # Create complete API model
    return api_models.Simulation(
        setup_settings=self._setup_settings.as_api_model(),
        material_settings=api_materials,
        source_settings=api_sources,
        boundary_settings=api_boundaries,
        grid_settings=self._grid_settings.as_api_model(),
        solver_settings=self._solver_settings.as_api_model(),
    )
```

## Example API Models

Here's a complete example of API models for a heat conduction simulation:

```python
from dataclasses import dataclass
from enum import Enum

from dataclasses_json import dataclass_json


class LogLevel(Enum):
    """Logging verbosity levels."""
    INFO = "info"
    DEBUG = "debug"
    ERROR = "error"


@dataclass_json
@dataclass
class SetupSettings:
    """General simulation setup parameters."""
    log_level: str = LogLevel.INFO.value


@dataclass_json
@dataclass
class MaterialSettings:
    """Material properties and domain extents."""
    xmin: float
    xmax: float
    ymin: float
    ymax: float
    zmin: float
    zmax: float
    thermal_conductivity: float = 1.0


@dataclass_json
@dataclass
class SourceSettings:
    """Heat source properties and location."""
    x: float
    y: float
    z: float
    volumetric_heat_source: float = 100.0


class DirichletFace(Enum):
    """Domain boundary faces with fixed values."""
    XMIN = "xmin"
    XMAX = "xmax"
    YMIN = "ymin"
    YMAX = "ymax"
    ZMIN = "zmin"
    ZMAX = "zmax"


@dataclass_json
@dataclass
class BoundarySettings:
    """Boundary condition specification."""
    face: str = DirichletFace.XMIN.value
    temperature: float = 0.0


@dataclass_json
@dataclass
class GridSettings:
    """Computational grid parameters."""
    dx: float = 1.0
    dy: float = 1.0
    dz: float = 1.0


class SolverMethod(Enum):
    """Numerical solution methods."""
    JACOBI = "jacobi"


@dataclass_json
@dataclass
class SolverSettings:
    """Numerical solver parameters."""
    solver_method: str = SolverMethod.JACOBI.value
    tolerance: float = 1e-6
    max_iter: int = 1000


@dataclass_json
@dataclass
class Simulation:
    """Complete simulation configuration."""
    setup_settings: SetupSettings
    material_settings: list[MaterialSettings]
    source_settings: list[SourceSettings]
    boundary_settings: list[BoundarySettings]
    grid_settings: GridSettings
    solver_settings: SolverSettings
```

## Best Practices

When designing API models:

1. **Keep them simple**: Include only the data needed by the solver
2. **Use meaningful defaults**: Provide sensible default values where appropriate
3. **Document carefully**: Add docstrings to explain the purpose of each class and field
4. **Validate inputs**: Add validation in the solver to ensure the API models contain valid data
5. **Version explicitly**: If you need to change API models between versions, consider versioning

---

## Next Steps

- [Results Extractors Overview](../extractors/overview.md)
