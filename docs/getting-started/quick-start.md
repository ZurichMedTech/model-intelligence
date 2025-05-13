# Quick Start Guide

This guide will help you get started with creating your first Sim4Life plugin using our framework.

## Creating a New Plugin

The quickest way to create a new plugin is to use our cookiecutter template:

```bash
# Install cookiecutter if you haven't already
pip install cookiecutter

# Create a new plugin from template
cookiecutter https://gitlab.com/sim4life/plugins/template.git
```

Follow the prompts to configure your plugin with the desired name, package structure, and features.

## Plugin Structure

After creating your plugin, you'll have a directory structure similar to this:

```
my-plugin/
├── LICENSE
├── manifest.json          # Plugin metadata for Sim4Life
├── README.md              # Documentation
├── setup.py               # Package installation
├── integration/           # Integration assets
│   └── simulator_icon.png # Icon for your plugin
├── src/                   # Source code
│   └── myplugin/          # Your package
│       ├── __init__.py
│       ├── register.py    # Plugin registration point
│       ├── controller/    # Business logic
│       ├── model/         # Data models
│       └── solver/        # Simulation solvers
└── tests/                 # Unit tests
```

## Configuring Your Plugin

The main configuration for your plugin is in the `manifest.json` file:

```json
{
  "name": "My Simulation Plugin",
  "version": "0.1.0",
  "description": "A simulation plugin for Sim4Life",
  "author": "Your Name",
  "email": "your.email@example.com",
  "entryPoints": {
    "simulation": "myplugin.register:register_simulation"
  }
}
```

## Implementing a Basic Simulation

1. **Define Simulation Settings**

   Edit `src/myplugin/model/setup_settings.py` to define the inputs for your simulation:

   ```python
   from sim4life.plugins.schema import Field, FieldType
   from sim4life.plugins.settings import SettingsBase

   class MySimulationSettings(SettingsBase):
       """Settings for my simulation."""
       
       input_value = Field(
           field_type=FieldType.FLOAT,
           default=1.0,
           min_value=0.0,
           max_value=100.0,
           description="Input value for the simulation"
       )
   ```

2. **Implement Simulation Logic**

   Edit `src/myplugin/model/simulation.py` to implement your simulation:

   ```python
   from sim4life.plugins.simulation import SimulationBase
   from .setup_settings import MySimulationSettings

   class MySimulation(SimulationBase):
       """My first simulation implementation."""
       
       settings_class = MySimulationSettings
       
       def run(self):
           """Run the simulation."""
           # Access settings via self.settings
           input_value = self.settings.input_value
           
           # Implement your simulation logic here
           result = input_value * 2
           
           # Return results
           return {"result": result}
   ```

3. **Register Your Simulation**

   Edit `src/myplugin/register.py` to register your simulation with Sim4Life:

   ```python
   from sim4life.plugins.registry import SimulationRegistry
   from .model.simulation import MySimulation

   def register_simulation(registry: SimulationRegistry):
       """Register simulations with Sim4Life."""
       registry.register_simulation(
           id="my-simulation",
           name="My Simulation",
           description="My first simulation for Sim4Life",
           simulation_class=MySimulation
       )
   ```

## Testing Your Plugin

Run the tests to verify your implementation:

```bash
cd my-plugin
pytest
```

## Installing Your Plugin

Install your plugin in development mode:

```bash
cd my-plugin
pip install -e .
```

## Running Your Plugin in Sim4Life

1. Start Sim4Life
2. Go to "Plugins" in the menu
3. Select "Install Plugin" and navigate to your plugin directory
4. Your simulation should now be available in the Simulations menu

## Next Steps

Once you've created your basic plugin, you can:

- [Learn more about creating simulations](../creating-a-plugin/creating-simulation.md)
- [Define additional settings](../creating-a-plugin/defining-settings.md)
- [Add drag-and-drop support](../creating-a-plugin/drag-and-drop.md)
- [Implement a custom solver](../solver-implementation/writing-solver.md)
- [Create data extractors](../extractors/creating-extractor.md)

For more detailed information, see the [API Reference](../api-reference/core-classes.md).