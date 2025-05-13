# Main Solver Implementation

This page provides a comprehensive guide to implementing the main solver module for your S4L plugin. The main solver is the core component that performs the actual physics computations in your simulation.

## Overview

The main solver in the S4L Plugin Framework is typically implemented in Python and is responsible for:

1. Loading input settings from the S4L interface
2. Setting up the computational domain
3. Implementing the numerical methods to solve the physics equations
4. Executing the time-stepping or iterative solution procedure
5. Saving results to files that can be visualized by your extractor

## Solver Architecture

A typical solver implementation consists of these key components:

```
main.py                 # Entry point that orchestrates the solution process
api_models.py           # Data models that define the API between S4L and your solver
numerical_methods.py    # Implementation of the numerical methods
grid.py                 # Grid/mesh management functionality
material_properties.py  # Material property handling
boundary_conditions.py  # Boundary condition implementation
output_writer.py        # Functionality for writing output files
```

## Main Solver Entry Point

The `main.py` file serves as the entry point for your solver and typically follows this structure:

```python
import os
import json
import numpy as np
import sys
from . import api_models
from . import numerical_methods
from . import grid
from . import output_writer

def main():
    """
    Main entry point for the solver.
    
    This function is called when the solver is executed and orchestrates
    the entire solution process.
    """
    # Parse command-line arguments
    if len(sys.argv) < 2:
        print("Usage: python -m my_package_name.solver.driver.main <settings_file>")
        sys.exit(1)
    
    settings_file = sys.argv[1]
    output_dir = os.path.dirname(settings_file)
    
    # Load settings
    with open(settings_file, 'r') as f:
        settings_json = json.load(f)
    
    # Convert JSON to settings object
    settings = api_models.SimulationSettings.from_dict(settings_json)
    
    # Set up the computational grid
    computational_grid = grid.create_grid(settings.grid)
    
    # Set up material properties
    materials = setup_materials(settings.materials, computational_grid)
    
    # Set up boundary conditions
    boundaries = setup_boundaries(settings.boundaries, computational_grid)
    
    # Set up sources
    sources = setup_sources(settings.sources, computational_grid)
    
    # Create the solver with appropriate numerical methods
    solver = create_solver(settings.solver, computational_grid, materials, boundaries, sources)
    
    # Run the simulation
    results = run_simulation(solver, settings.time_steps)
    
    # Write output files
    output_writer.write_results(results, output_dir)
    
    # Write summary statistics
    write_summary(results, output_dir)
    
    print("Simulation completed successfully")
    return 0

def setup_materials(material_settings, grid):
    """
    Set up material properties on the computational grid.
    
    Args:
        material_settings: Material settings from the API
        grid: Computational grid
        
    Returns:
        Material properties object
    """
    # Implementation details...
    pass

def setup_boundaries(boundary_settings, grid):
    """
    Set up boundary conditions on the computational grid.
    
    Args:
        boundary_settings: Boundary settings from the API
        grid: Computational grid
        
    Returns:
        Boundary conditions object
    """
    # Implementation details...
    pass

def setup_sources(source_settings, grid):
    """
    Set up sources on the computational grid.
    
    Args:
        source_settings: Source settings from the API
        grid: Computational grid
        
    Returns:
        Sources object
    """
    # Implementation details...
    pass

def create_solver(solver_settings, grid, materials, boundaries, sources):
    """
    Create the solver with appropriate numerical methods.
    
    Args:
        solver_settings: Solver settings from the API
        grid: Computational grid
        materials: Material properties
        boundaries: Boundary conditions
        sources: Sources
        
    Returns:
        Solver object
    """
    # Implementation details...
    pass

def run_simulation(solver, time_steps):
    """
    Run the simulation for the specified time steps.
    
    Args:
        solver: Solver object
        time_steps: Number of time steps to simulate
        
    Returns:
        Simulation results
    """
    # Implementation details...
    pass

def write_summary(results, output_dir):
    """
    Write summary statistics to a JSON file.
    
    Args:
        results: Simulation results
        output_dir: Output directory
    """
    # Calculate summary statistics
    summary = {
        "min_temperature": float(np.min(results.temperature)),
        "max_temperature": float(np.max(results.temperature)),
        "avg_temperature": float(np.mean(results.temperature)),
        "total_energy": float(np.sum(results.energy)),
        # Add other relevant statistics...
    }
    
    # Write to JSON file
    summary_file = os.path.join(output_dir, "summary.json")
    with open(summary_file, 'w') as f:
        json.dump(summary, f, indent=2)

if __name__ == "__main__":
    sys.exit(main())
```

## API Models

The `api_models.py` file defines the data models that serve as the interface between S4L and your solver:

```python
import json
from typing import List, Dict, Any, Optional

class GridSettings:
    """Settings for the computational grid."""
    
    def __init__(self, 
                 x_min: float = 0.0, 
                 x_max: float = 1.0,
                 y_min: float = 0.0,
                 y_max: float = 1.0,
                 z_min: float = 0.0,
                 z_max: float = 1.0,
                 num_cells_x: int = 10,
                 num_cells_y: int = 10,
                 num_cells_z: int = 10):
        """
        Initialize grid settings.
        
        Args:
            x_min: Minimum x-coordinate
            x_max: Maximum x-coordinate
            y_min: Minimum y-coordinate
            y_max: Maximum y-coordinate
            z_min: Minimum z-coordinate
            z_max: Maximum z-coordinate
            num_cells_x: Number of cells in x-direction
            num_cells_y: Number of cells in y-direction
            num_cells_z: Number of cells in z-direction
        """
        self.x_min = x_min
        self.x_max = x_max
        self.y_min = y_min
        self.y_max = y_max
        self.z_min = z_min
        self.z_max = z_max
        self.num_cells_x = num_cells_x
        self.num_cells_y = num_cells_y
        self.num_cells_z = num_cells_z
    
    @classmethod
    def from_dict(cls, d: Dict[str, Any]) -> 'GridSettings':
        """
        Create grid settings from a dictionary.
        
        Args:
            d: Dictionary with grid settings
            
        Returns:
            GridSettings object
        """
        return cls(
            x_min=d.get('x_min', 0.0),
            x_max=d.get('x_max', 1.0),
            y_min=d.get('y_min', 0.0),
            y_max=d.get('y_max', 1.0),
            z_min=d.get('z_min', 0.0),
            z_max=d.get('z_max', 1.0),
            num_cells_x=d.get('num_cells_x', 10),
            num_cells_y=d.get('num_cells_y', 10),
            num_cells_z=d.get('num_cells_z', 10)
        )

class MaterialSettings:
    """Settings for material properties."""
    
    def __init__(self, 
                 name: str,
                 density: float = 1000.0,
                 specific_heat: float = 4200.0,
                 thermal_conductivity: float = 0.6,
                 properties: Optional[Dict[str, Any]] = None):
        """
        Initialize material settings.
        
        Args:
            name: Material name
            density: Material density in kg/m³
            specific_heat: Specific heat capacity in J/(kg·K)
            thermal_conductivity: Thermal conductivity in W/(m·K)
            properties: Additional material properties
        """
        self.name = name
        self.density = density
        self.specific_heat = specific_heat
        self.thermal_conductivity = thermal_conductivity
        self.properties = properties or {}
    
    @classmethod
    def from_dict(cls, d: Dict[str, Any]) -> 'MaterialSettings':
        """
        Create material settings from a dictionary.
        
        Args:
            d: Dictionary with material settings
            
        Returns:
            MaterialSettings object
        """
        return cls(
            name=d.get('name', 'material'),
            density=d.get('density', 1000.0),
            specific_heat=d.get('specific_heat', 4200.0),
            thermal_conductivity=d.get('thermal_conductivity', 0.6),
            properties=d.get('properties', {})
        )

class BoundarySettings:
    """Settings for boundary conditions."""
    
    def __init__(self, 
                 name: str,
                 type: str,
                 value: float = 0.0,
                 faces: List[str] = None,
                 properties: Optional[Dict[str, Any]] = None):
        """
        Initialize boundary settings.
        
        Args:
            name: Boundary name
            type: Boundary type (dirichlet, neumann, robin)
            value: Boundary value
            faces: List of faces to apply the boundary to (x_min, x_max, y_min, y_max, z_min, z_max)
            properties: Additional boundary properties
        """
        self.name = name
        self.type = type
        self.value = value
        self.faces = faces or []
        self.properties = properties or {}
    
    @classmethod
    def from_dict(cls, d: Dict[str, Any]) -> 'BoundarySettings':
        """
        Create boundary settings from a dictionary.
        
        Args:
            d: Dictionary with boundary settings
            
        Returns:
            BoundarySettings object
        """
        return cls(
            name=d.get('name', 'boundary'),
            type=d.get('type', 'dirichlet'),
            value=d.get('value', 0.0),
            faces=d.get('faces', []),
            properties=d.get('properties', {})
        )

class SourceSettings:
    """Settings for sources."""
    
    def __init__(self, 
                 name: str,
                 type: str,
                 value: float = 0.0,
                 geometry: Dict[str, Any] = None,
                 properties: Optional[Dict[str, Any]] = None):
        """
        Initialize source settings.
        
        Args:
            name: Source name
            type: Source type (heat, current, etc.)
            value: Source value
            geometry: Geometry definition for the source
            properties: Additional source properties
        """
        self.name = name
        self.type = type
        self.value = value
        self.geometry = geometry or {}
        self.properties = properties or {}
    
    @classmethod
    def from_dict(cls, d: Dict[str, Any]) -> 'SourceSettings':
        """
        Create source settings from a dictionary.
        
        Args:
            d: Dictionary with source settings
            
        Returns:
            SourceSettings object
        """
        return cls(
            name=d.get('name', 'source'),
            type=d.get('type', 'heat'),
            value=d.get('value', 0.0),
            geometry=d.get('geometry', {}),
            properties=d.get('properties', {})
        )

class SolverSettings:
    """Settings for the solver."""
    
    def __init__(self, 
                 time_step: float = 0.1,
                 max_iterations: int = 1000,
                 convergence_tolerance: float = 1e-6,
                 algorithm: str = 'implicit',
                 properties: Optional[Dict[str, Any]] = None):
        """
        Initialize solver settings.
        
        Args:
            time_step: Time step size in seconds
            max_iterations: Maximum number of iterations
            convergence_tolerance: Convergence tolerance
            algorithm: Solution algorithm (explicit, implicit, etc.)
            properties: Additional solver properties
        """
        self.time_step = time_step
        self.max_iterations = max_iterations
        self.convergence_tolerance = convergence_tolerance
        self.algorithm = algorithm
        self.properties = properties or {}
    
    @classmethod
    def from_dict(cls, d: Dict[str, Any]) -> 'SolverSettings':
        """
        Create solver settings from a dictionary.
        
        Args:
            d: Dictionary with solver settings
            
        Returns:
            SolverSettings object
        """
        return cls(
            time_step=d.get('time_step', 0.1),
            max_iterations=d.get('max_iterations', 1000),
            convergence_tolerance=d.get('convergence_tolerance', 1e-6),
            algorithm=d.get('algorithm', 'implicit'),
            properties=d.get('properties', {})
        )

class SimulationSettings:
    """Top-level settings for the simulation."""
    
    def __init__(self, 
                 name: str,
                 grid: GridSettings,
                 materials: List[MaterialSettings],
                 boundaries: List[BoundarySettings],
                 sources: List[SourceSettings],
                 solver: SolverSettings,
                 time_steps: int = 100,
                 output_interval: int = 10,
                 properties: Optional[Dict[str, Any]] = None):
        """
        Initialize simulation settings.
        
        Args:
            name: Simulation name
            grid: Grid settings
            materials: List of material settings
            boundaries: List of boundary settings
            sources: List of source settings
            solver: Solver settings
            time_steps: Number of time steps to simulate
            output_interval: Interval for writing output files
            properties: Additional simulation properties
        """
        self.name = name
        self.grid = grid
        self.materials = materials
        self.boundaries = boundaries
        self.sources = sources
        self.solver = solver
        self.time_steps = time_steps
        self.output_interval = output_interval
        self.properties = properties or {}
    
    @classmethod
    def from_dict(cls, d: Dict[str, Any]) -> 'SimulationSettings':
        """
        Create simulation settings from a dictionary.
        
        Args:
            d: Dictionary with simulation settings
            
        Returns:
            SimulationSettings object
        """
        return cls(
            name=d.get('name', 'simulation'),
            grid=GridSettings.from_dict(d.get('grid', {})),
            materials=[MaterialSettings.from_dict(m) for m in d.get('materials', [])],
            boundaries=[BoundarySettings.from_dict(b) for b in d.get('boundaries', [])],
            sources=[SourceSettings.from_dict(s) for s in d.get('sources', [])],
            solver=SolverSettings.from_dict(d.get('solver', {})),
            time_steps=d.get('time_steps', 100),
            output_interval=d.get('output_interval', 10),
            properties=d.get('properties', {})
        )

class SimulationResults:
    """Container for simulation results."""
    
    def __init__(self, 
                 temperature: Optional[Any] = None,
                 heat_flux: Optional[Any] = None,
                 energy: Optional[Any] = None,
                 time_points: Optional[List[float]] = None,
                 grid: Optional[Any] = None):
        """
        Initialize simulation results.
        
        Args:
            temperature: Temperature field
            heat_flux: Heat flux field
            energy: Energy field
            time_points: List of time points
            grid: Computational grid
        """
        self.temperature = temperature
        self.heat_flux = heat_flux
        self.energy = energy
        self.time_points = time_points or []
        self.grid = grid
```