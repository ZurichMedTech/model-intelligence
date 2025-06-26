# Plugin Structure Overview

The Sim4Life Plugin Framework uses a clear, modular architecture to simplify simulation plugin development. This page summarizes the main concepts and directory layout.

## Architecture at a Glance

The framework follows a Model-View-Controller (MVC) pattern:

- **Model**: Simulation logic, settings, and data structures
- **Controller**: Connects the model to the UI, handles user actions
- **Solver**: Runs the simulation and processes results
- **View**: Provided by the Sim4Life UI (tree view, property panels)

## Key Components

- **Simulation Class**: Central container for simulation logic
- **Settings Classes**: Define simulation parameters (materials, boundaries, etc.)
- **API Models**: Data objects connecting UI and solver
- **Simulation Binding**: Maps model to the UI tree
- **Simulation Manager**: Handles UI actions and updates
- **Solver Driver**: Runs the core simulation algorithms
- **Result Extractor**: Prepares results for visualization

## Directory Structure

```bash
s4l-plugin-heat-conduction/
├── LICENSE
├── README.md
├── manifest.json
├── setup.py
├── integration/
│   └── simulator_icon.png
└── src/
    └── heat_conduction/
        ├── __init__.py
        ├── controller/
        │   ├── __init__.py
        │   ├── simulation_binding.py
        │   └── simulation_manager.py
        ├── model/
        │   ├── __init__.py
        │   ├── boundary_settings.py
        │   ├── example_plots.py
        │   ├── grid_settings.py
        │   ├── material_settings.py
        │   ├── setup_settings.py
        │   ├── simulation.py
        │   ├── simulation_extractor.py
        │   ├── solver_settings.py
        │   └── source_settings.py
        ├── register.py
        └── solver/
            ├── __init__.py
            └── driver/
                ├── __init__.py
                ├── api_models.py
                └── main.py
```

## Plugin Registration Flow

When Sim4Life starts, it loads plugins as follows:

1. Discovers the entry point in `setup.py`
2. Calls the `register()` function in `register.py`
3. Registers the simulation type and UI factories
4. Makes the simulation available in the Sim4Life interface

> **Tip:** If a runtime error occurs during loading, the plugin will not appear in Sim4Life. Check the **LOGGER** in Sim4Life for error details.

---

## Next Steps

- [Entry Points](entry-points.md)
- [Tree Structure](tree-structure.md)
- [Creating a Simulation Plugin](../creating-a-plugin/creating-simulation.md)
- [Solver Implementation](../solver-implementation/writing-solver.md)
- [Results Extractors Overview](../extractors/overview.md)
