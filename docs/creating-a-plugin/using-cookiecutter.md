# Using Cookiecutter

The fastest way to create a new S4L plugin is to use the provided cookiecutter template. This approach gives you a complete plugin structure with all the necessary files and boilerplate code.

## What is Cookiecutter?

[Cookiecutter](https://cookiecutter.readthedocs.io/) is a command-line utility that creates projects from templates. For the S4L Plugin Framework, we provide a template that sets up all the required files and directory structure for a new simulation plugin.

## Prerequisites

Before using the cookiecutter template, ensure you have:

1. Python 3.11 or higher installed
2. Cookiecutter installed: `pip install cookiecutter`
3. Access to the S4L cookiecutter template repository

## Creating a New Plugin

To create a new plugin using the template:

```bash
# Navigate to your development directory
cd ~/development

# Use cookiecutter with the template repository
cookiecutter https://github.com/yourusername/cookiecutter-s4l-plugin
```

You'll be prompted to enter various configuration parameters:

```
plugin_name [heat-conduction]: my-physics-plugin
package_name [my_physics_plugin]: 
plugin_display_name [Heat Conduction]: My Physics Plugin
plugin_description [A simulation plugin for S4L]: A custom physics simulation for S4L
author_name [Your Name]: Jane Smith
author_email [your.email@example.com]: jane.smith@example.com
version [0.1.0]: 
python_requires [>=3.11]: 
```

After answering these prompts, cookiecutter will create a new directory with your plugin name, containing a complete plugin structure.

## Template Parameters

The cookiecutter template accepts the following parameters:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `plugin_name` | Name of the plugin (used for directory and package names) | heat-conduction |
| `package_name` | Python package name (automatically derived from plugin_name) | heat_conduction |
| `plugin_display_name` | Display name shown in the S4L interface | Heat Conduction |
| `plugin_description` | Short description of the plugin | A simulation plugin for S4L |
| `author_name` | Your name | Your Name |
| `author_email` | Your email address | your.email@example.com |
| `version` | Initial version number | 0.1.0 |
| `python_requires` | Python version requirement | >=3.11 |

## Generated Structure

The cookiecutter template generates the following structure:

```
my-physics-plugin/
├── .gitignore
├── LICENSE
├── README.md
├── manifest.json
├── setup.py
├── src/
│   └── my_physics_plugin/
│       ├── __init__.py
│       ├── controller/
│       │   ├── __init__.py
│       │   ├── simulation_binding.py
│       │   └── simulation_manager.py
│       ├── model/
│       │   ├── __init__.py
│       │   ├── boundary_settings.py
│       │   ├── grid_settings.py
│       │   ├── material_settings.py
│       │   ├── setup_settings.py
│       │   ├── simulation.py
│       │   ├── simulation_extractor.py
│       │   ├── solver_settings.py
│       │   └── source_settings.py
│       ├── register.py
│       └── solver/
│           ├── __init__.py
│           └── driver/
│               ├── __init__.py
│               ├── api_models.py
│               └── main.py
└── tests/
    └── test_simulation.py
```

This structure includes:

- Basic project files (LICENSE, README.md, etc.)
- The Python package structure in the `src/` directory
- A complete model-view-controller implementation
- A solver template with API models
- A basic test file

## Key Generated Files

The cookiecutter template generates several key files:

- `setup.py`: Package installation configuration with the S4L entry point
- `manifest.json`: Plugin metadata for the S4L marketplace
- `src/my_physics_plugin/register.py`: Plugin registration module
- `src/my_physics_plugin/model/simulation.py`: Main simulation class
- `src/my_physics_plugin/solver/driver/main.py`: Solver implementation template

## Post-Generation Steps

After generating your plugin with cookiecutter:

1. **Install the plugin in development mode**:
   ```bash
   cd my-physics-plugin
   pip install -e .
   ```

2. **Customize the simulation model**:
   - Modify the settings classes to match your physics model
   - Update the API models to include your parameters
   - Implement your solver algorithm

3. **Test your plugin**:
   - Launch S4L and verify that your plugin appears in the interface
   - Create a test simulation and ensure all components work as expected
   - Run the provided test cases

## Example: Customizing the Template

Let's look at a simple example of customizing the heat conduction template for a different physics problem:

1. Generate the plugin with cookiecutter:
   ```bash
   cookiecutter https://github.com/yourusername/cookiecutter-s4l-plugin
   ```

2. Update the physics equation in `simulation.py`:
   ```python
   def __init__(
       self,
       parent: "TreeItem",
       sim_desc: str = "Wave Simulation",
       sim_notes: str = "Solves ∂²u/∂t² = c² ∇²u",
   ) -> None:
       super().__init__(parent, sim_desc, sim_notes)
   ```

3. Update the solver implementation in `main.py` to solve your equation

4. Modify the settings classes to include your physics parameters

## Next Steps

Once you've created your plugin skeleton using cookiecutter, you'll want to:

- [Create a Simulation Class](creating-simulation.md): Learn how to customize the main simulation class
- [Define Settings](defining-settings.md): Create settings components for your physics model
- [Implement Drag and Drop](drag-and-drop.md): Add support for geometry assignment