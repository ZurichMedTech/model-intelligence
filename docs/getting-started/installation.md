# Installation

This guide will walk you through the installation process for the Sim4Life Plugin Framework.

## Prerequisites

Before installing the Sim4Life Plugin Framework, ensure you have the following:

- Sim4Life version 7.0 or higher
- Python 3.8 or higher
- pip (Python package manager)

## Installing the Plugin Framework

### Option 1: Using pip

The simplest way to install the Sim4Life Plugin Framework is via pip:

```bash
pip install sim4life-plugin-framework
```

### Option 2: From Source

To install from source:

1. Clone the repository:
   ```bash
   git clone https://gitlab.com/sim4life/plugin-framework.git
   ```

2. Navigate to the cloned directory:
   ```bash
   cd plugin-framework
   ```

3. Install the package in development mode:
   ```bash
   pip install -e .
   ```

## Verifying Installation

To verify the installation, open a Python interpreter and run:

```python
import sim4life.plugins

print(sim4life.plugins.__version__)
```

If the installation was successful, this will print the version number of the installed framework.

## Plugin Development Environment Setup

For plugin development, we recommend setting up a dedicated Python virtual environment:

### Using venv

```bash
# Create a virtual environment
python -m venv s4l-plugin-env

# Activate the environment
# On Windows:
s4l-plugin-env\Scripts\activate
# On Linux/macOS:
source s4l-plugin-env/bin/activate

# Install the framework and development tools
pip install sim4life-plugin-framework
pip install pytest pytest-cov
```

### Using conda

```bash
# Create a conda environment
conda create -n s4l-plugin-env python=3.8

# Activate the environment
conda activate s4l-plugin-env

# Install the framework and development tools
pip install sim4life-plugin-framework
conda install pytest pytest-cov
```

## Plugin Template

To quickly get started with a new plugin, use our plugin template:

```bash
# Install cookiecutter
pip install cookiecutter

# Create a new plugin from template
cookiecutter https://gitlab.com/sim4life/plugins/template.git
```

Follow the prompts to configure your new plugin.

## Next Steps

Once you have successfully installed the Sim4Life Plugin Framework, proceed to the [Quick Start](quick-start.md) guide to create your first plugin.