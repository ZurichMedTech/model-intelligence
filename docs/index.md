# S4L Plugin Framework

Welcome to the Sim4Life Plugin Framework documentation. This framework enables you to develop custom simulation plugins for the Sim4Life simulation platform.

<div class="grid cards" markdown>

- :material-rocket-launch: **Quick Start**  
  [Get started quickly](getting-started/quick-start.md) with a new simulation plugin

- :material-puzzle: **Plugin Structure**  
  [Learn about the plugin architecture](plugin-structure/overview.md) and organization

- :material-code-braces: **Create Your Plugin**  
  [Create your own simulation plugin](creating-a-plugin/using-cookiecutter.md) using cookiecutter templates

- :fontawesome-solid-graduation-cap: **Simulation Models**  
  [Implement physics models](simulation-models/overview.md) for your simulations

</div>

## What is Sim4Life Plugin Framework?

The Sim4Life Plugin Framework is an extensible architecture for creating custom physics simulations within the Sim4Life platform. It provides a structured way to:

- Define simulation models with physics-specific parameters
- Create interactive UI components for simulation setup and configuration 
- Implement numerical solvers for the simulation equations
- Visualize and analyze simulation results

The framework follows a Model-View-Controller (MVC) pattern to separate simulation logic from user interface components, making it easier to develop, test, and maintain simulation plugins.

## Key Features

- **Tree-based UI Structure**: Organize simulation components in an intuitive tree structure
- **From Views**: Automatically generate form views for simulation configuration and options
- **Drag-and-Drop Geometry Support**: Easily associate geometry with simulation components
- **Solver API**: Streamlined data transfer between UI and numerical solvers
- **Extractor Framework**: Powerful result visualization and post-processing capabilities

## Example: Heat Conduction Plugin

This documentation uses a heat conduction simulation plugin as a comprehensive example. This plugin solves the steady-state heat equation:

$$\nabla \cdot (k \nabla T) + Q = 0$$

Where:
- $T$ is the temperature field
- $k$ is the thermal conductivity
- $Q$ is the volumetric heat source

![Heat Conduction Simulation](assets/images/heat_conduction.png)

The heat conduction example demonstrates all core aspects of plugin development:

- Creating a tree-structured simulation model
- Defining material properties and boundary conditions
- Implementing a finite difference solver
- Extracting and visualizing temperature fields and heat flux

## Getting Started

Ready to start developing? Check out the [Quick Start Guide](getting-started/quick-start.md) to create your first simulation plugin!