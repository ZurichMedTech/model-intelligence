# Plugin Entry Points

Entry points are how your plugin integrates with the Sim4Life platform. They define how your plugin is discovered, loaded, and registered with the system.

## Setup File Configuration

The primary integration point is defined in your plugin's `setup.py` file. This is where you register your plugin with the Sim4Life framework:

```python
from setuptools import find_packages, setup

setup(
    name="s4l-my-plugin-name",
    version="0.1.0",
    description="My simulation plugin for S4L",
    author="Your Name",
    author_email="your.email@example.com",
    package_dir={"": "src"},
    packages=find_packages(where="src"),
    python_requires=">=3.11",
    install_requires=[
        "s4l_core",  # Core dependency
    ],
    entry_points={
        "s4l.simulator_plugins": [
            "my_package_name = my_package_name.register:register",
        ],
    },
)
```

The key part is the `entry_points` section, which tells Sim4Life:

1. This package provides a plugin in the `s4l.simulator_plugins` category
2. The plugin's entry point is the `register` function in the `my_package_name.register` module

## Registration Module

The `register.py` module is the main connection point between your plugin and Sim4Life. It handles:

1. Registering your simulation type with the Sim4Life plugin registry
2. Providing factory functions to create UI bindings and managers for your simulation

Here's an example of a typical registration module:

```python
import logging
from typing import cast

from s4l_core.simulator_plugins.base.controller.simulation_binding_interface import (
    ISimulationBinding,
)
from s4l_core.simulator_plugins.base.controller.simulation_manager_interface import (
    ISimulationManager,
)
from s4l_core.simulator_plugins.base.model.simulation_base import SimulationBase
from s4l_core.simulator_plugins.common.registry import PluginRegistry
from my_package_name.controller.simulation_binding import (
    SimulationBinding,
)
from my_package_name.controller.simulation_manager import (
    SimulationManager,
)
from my_package_name.model.simulation import (
    Simulation,
)

logger = logging.getLogger(__name__)


def create_binding(simulation: SimulationBase) -> ISimulationBinding:
    """Factory function to create the simulation binding."""
    return SimulationBinding(cast(Simulation, simulation))


def create_manager(simulation: SimulationBase) -> ISimulationManager:
    """Factory function to create the simulation manager."""
    return SimulationManager(cast(Simulation, simulation))


def register():
    """
    Registers all simulation components with the Sim4Life plugin system.
    
    This function is the main entry point for the plugin and is called by Sim4Life during startup.
    """
    logger.info("Registering My Plugin...")

    # Register the simulation type
    PluginRegistry.register_simulation(Simulation)

    # Register binding factory
    sim_type = Simulation.get_simulation_type_name()
    PluginRegistry.register_binding_factory(sim_type, create_binding)

    # Register manager factory
    PluginRegistry.register_manager_factory(sim_type, create_manager)

    logger.info("Registered My Plugin components successfully")
```

## Registration Process

When Sim4Life starts, it performs the following steps to load your plugin:

1. Discovers all entry points in the `s4l.simulator_plugins` category
2. For each entry point, calls the specified function (in this case, `register()`)
3. The `register()` function registers:
   - Your `Simulation` class as a new simulation type
   - The `create_binding` factory function to handle UI tree mapping
   - The `create_manager` factory function to handle property panels and UI actions

Once registered, your simulation type becomes available in the Sim4Life interface and users can create new simulations of your type.

## Plugin Manifest

In addition to the Python entry points, your plugin should include a `manifest.json` file in its root directory, which provides metadata for the plugin marketplace:

```json
{
    "icon": "integration/simulator_icon.png",
    "title": "My Simulation Plugin",
    "description": "A plugin for simulating...",
    "version": "0.1.0",
    "sim4life": "9.0.0",
    "author": "Your Name",
    "author_email": "your.email@example.com",
    "details": "README.md",
    "license": "LICENSE",
    "tags": ["Physics", "Category1", "Category2"],
    "links": {
        "repository": "github.com/yourusername/yourrepository",
        "website": "https://yourwebsite.com",
        "documentation": "https://yourwebsite.com/docs"
    }
}
```

This metadata is used to display your plugin in the Sim4Life plugin marketplace, allowing users to discover and install your plugin.

## Next Steps

Now that you understand how plugins are registered, learn about:

- [Tree Structure](tree-structure.md): How the UI tree hierarchy is generated
- [Creating a Simulation Class](../creating-a-plugin/creating-simulation.md): How to define your own simulation type