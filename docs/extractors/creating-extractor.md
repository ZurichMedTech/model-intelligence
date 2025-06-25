# Creating an Extractor

This guide walks you through the process of creating a custom result extractor for your Sim4Life plugin. Extractors are responsible for visualizing and analyzing simulation results, providing users with meaningful insights into the physics simulations.

## Prerequisites

Before creating an extractor, ensure you have:

- A working solver that produces result files (typically VTK format)
- An understanding of the physical quantities your simulation produces
- Basic knowledge of VTK for visualization (see [VTK Integration](vtk-integration.md))

## Extractor Structure

A typical extractor consists of:

1. A Python module with a `create_engine()` function as the entry point
2. An extractor class that implements core functionality
3. Methods for creating visualizations from result files
4. A UI panel to control visualization settings

## Step 1: Create the Extractor Module

Create a new Python file called `simulation_extractor.py` in the `model` directory of your plugin:

```python
import os
import vtk
import json
import numpy as np

# Import Sim4Life post-processing API
import S4L.postprocessing as pp
from S4L.postprocessing import fieldTypes

def create_engine():
    """Entry point function called by the Sim4Life post-processing system."""
    return SimulationExtractor()

class SimulationExtractor:
    """Extractor for simulation results."""
    
    def __init__(self):
        """Initialize the extractor."""
        # Initialize properties
        self.result_path = None
        self.show_temperature = True
        self.show_flux = True
        self.iso_value = 310.0  # Default temperature isosurface value (K)
        
    def set_parameters(self, params):
        """
        Set extraction parameters from UI.
        
        Args:
            params: Parameters dictionary from the UI panel
        """
        if params is None:
            return
        
        # Update settings based on UI parameters
        if "ShowTemperature" in params:
            self.show_temperature = params["ShowTemperature"]
        
        if "ShowFlux" in params:
            self.show_flux = params["ShowFlux"]
            
        if "IsoValue" in params:
            self.iso_value = params["IsoValue"]
    
    def extract(self):
        """
        Process results and create visualization objects.
        
        Returns:
            List of visualization objects (fields, extraction objects)
        """
        # Get the result path from the context
        context = pp.PyExtractorContext.GetInstance()
        self.result_path = context.GetResultPath()
        
        if not os.path.exists(self.result_path):
            print(f"Error: Result path does not exist: {self.result_path}")
            return []
        
        # Create the results
        results = []
        
        # Add temperature field if enabled
        if self.show_temperature:
            temperature_field = self.create_temperature_field()
            if temperature_field:
                results.append(temperature_field)
                
            # Add temperature isosurface
            isosurface = self.create_temperature_isosurface(self.iso_value)
            if isosurface:
                results.append(isosurface)
        
        # Add heat flux field and streamlines if enabled
        if self.show_flux:
            flux_field = self.create_flux_field()
            if flux_field:
                results.append(flux_field)
                
            streamlines = self.create_flux_streamlines()
            if streamlines:
                results.append(streamlines)
        
        return results
    
    def get_ui_panel(self):
        """
        Return a property panel for UI controls.
        
        Returns:
            PyPropertyGroup containing UI controls
        """
        panel = pp.PyPropertyGroup()
        panel.Name = "Visualization Settings"
        
        # Create controls
        
        # Temperature visibility
        show_temp = pp.PyPropertyBool(self.show_temperature)
        show_temp.Name = "ShowTemperature"
        show_temp.Description = "Show Temperature Field"
        panel.Properties.Add(show_temp)
        
        # Isosurface value
        iso_value = pp.PyPropertyDouble(self.iso_value)
        iso_value.Name = "IsoValue"
        iso_value.Description = "Temperature Isosurface Value (K)"
        iso_value.Min = 290.0
        iso_value.Max = 350.0
        panel.Properties.Add(iso_value)
        
        # Heat flux visibility
        show_flux = pp.PyPropertyBool(self.show_flux)
        show_flux.Name = "ShowFlux"
        show_flux.Description = "Show Heat Flux"
        panel.Properties.Add(show_flux)
        
        return panel
    
    # Visualization creation methods below
```

## Step 2: Implement Visualization Methods

Add methods to create various visualizations:

```python
def create_temperature_field(self):
    """
    Create a temperature field visualization.
    
    Returns:
        PyField object for temperature visualization
    """
    # Check if temperature file exists
    temperature_file = os.path.join(self.result_path, "Temperature.vtr")
    if not os.path.exists(temperature_file):
        print(f"Warning: Temperature file not found: {temperature_file}")
        return None
    
    # Load the VTK file
    reader = vtk.vtkXMLRectilinearGridReader()
    reader.SetFileName(temperature_file)
    reader.Update()
    
    # Create the field
    field = pp.PyField()
    field.Name = "Temperature"
    field.VtkData = reader.GetOutput()
    field.HasPointData = True
    field.PointDataName = "Temperature"
    field.FieldType = fieldTypes.FieldType.Scalar
    field.Unit = "K"
    
    return field

def create_temperature_isosurface(self, iso_value):
    """
    Create an isosurface at the specified temperature.
    
    Args:
        iso_value: Temperature value for the isosurface (K)
        
    Returns:
        PyExtractionObject for the isosurface
    """
    # Check if temperature file exists
    temperature_file = os.path.join(self.result_path, "Temperature.vtr")
    if not os.path.exists(temperature_file):
        print(f"Warning: Temperature file not found: {temperature_file}")
        return None
    
    # Load the VTK file
    reader = vtk.vtkXMLRectilinearGridReader()
    reader.SetFileName(temperature_file)
    reader.Update()
    
    # Create isosurface
    contour = vtk.vtkContourFilter()
    contour.SetInputData(reader.GetOutput())
    contour.SetInputArrayToProcess(
        0, 0, 0, vtk.vtkDataObject.FIELD_ASSOCIATION_POINTS, "Temperature"
    )
    contour.SetValue(0, iso_value)
    contour.Update()
    
    # Create the extraction object
    isosurface = pp.PyExtractionObject()
    isosurface.Name = f"Temperature Isosurface ({iso_value} K)"
    isosurface.VtkData = contour.GetOutput()
    
    return isosurface

def create_flux_field(self):
    """
    Create a heat flux vector field visualization.
    
    Returns:
        PyField object for heat flux visualization
    """
    # Check if heat flux file exists
    flux_file = os.path.join(self.result_path, "HeatFlux.vtr")
    if not os.path.exists(flux_file):
        print(f"Warning: Heat flux file not found: {flux_file}")
        return None
    
    # Load the VTK file
    reader = vtk.vtkXMLRectilinearGridReader()
    reader.SetFileName(flux_file)
    reader.Update()
    
    # Create the field
    field = pp.PyField()
    field.Name = "Heat Flux"
    field.VtkData = reader.GetOutput()
    field.HasPointData = True
    field.PointDataName = "HeatFlux"
    field.FieldType = fieldTypes.FieldType.Vector
    field.Unit = "W/m²"
    
    return field

def create_flux_streamlines(self):
    """
    Create streamlines following the heat flux field.
    
    Returns:
        PyExtractionObject for the streamlines
    """
    # Check if heat flux file exists
    flux_file = os.path.join(self.result_path, "HeatFlux.vtr")
    if not os.path.exists(flux_file):
        print(f"Warning: Heat flux file not found: {flux_file}")
        return None
    
    # Load the VTK file
    reader = vtk.vtkXMLRectilinearGridReader()
    reader.SetFileName(flux_file)
    reader.Update()
    
    # Create seed points
    bounds = reader.GetOutput().GetBounds()
    center_x = (bounds[0] + bounds[1]) / 2
    center_y = (bounds[2] + bounds[3]) / 2
    center_z = (bounds[4] + bounds[5]) / 2
    
    # Create seed points in a plane
    seed_points = []
    for i in range(-2, 3):
        for j in range(-2, 3):
            seed_points.append((
                center_x + i * (bounds[1] - bounds[0]) / 10,
                center_y + j * (bounds[3] - bounds[2]) / 10,
                center_z
            ))
    
    # Create streamlines
    seeds = vtk.vtkProgrammableSource()
    
    def make_seeds():
        output = seeds.GetPolyDataOutput()
        points = vtk.vtkPoints()
        for i, point in enumerate(seed_points):
            points.InsertPoint(i, point)
        output.SetPoints(points)
    
    seeds.SetExecuteMethod(make_seeds)
    seeds.Update()
    
    # Create streamlines
    streamline = vtk.vtkStreamTracer()
    streamline.SetInputData(reader.GetOutput())
    streamline.SetSourceData(seeds.GetPolyDataOutput())
    streamline.SetMaximumPropagation(100)
    streamline.SetIntegrationDirectionToBoth()
    streamline.SetInputArrayToProcess(
        0, 0, 0, vtk.vtkDataObject.FIELD_ASSOCIATION_POINTS, "HeatFlux"
    )
    streamline.Update()
    
    # Create the extraction object
    streamlines = pp.PyExtractionObject()
    streamlines.Name = "Heat Flux Streamlines"
    streamlines.VtkData = streamline.GetOutput()
    
    return streamlines
```

## Step 3: Register the Extractor

Register the extractor in your simulation model. Open `simulation.py` and update the `register_extractor` method:

```python
def register_extractor(self) -> pp.PythonModuleAlgorithm:
    """Register a post-processing extractor."""
    return pp.PythonModuleAlgorithm(
        # Use the fully qualified module path for your package
        "{}.model.simulation_extractor".format(self.package_name),
        0,  # Number of inputs
        1,  # Number of outputs
    )
```

## Step 4: Add Simulation Metadata

When your solver runs, it should save metadata to help the extractor. Create a function in your solver to save metadata:

```python
def save_metadata(self, result_path, simulation_parameters):
    """
    Save simulation metadata for the extractor.
    
    Args:
        result_path: Path to save the metadata
        simulation_parameters: Dictionary of simulation parameters
    """
    metadata = {
        "simulationName": self.simulation_name,
        "timeStamp": self.time_stamp,
        "parameters": simulation_parameters,
        "gridDimensions": self.grid_dimensions,
        "domain": {
            "minX": self.domain_min[0],
            "maxX": self.domain_max[0],
            "minY": self.domain_min[1],
            "maxY": self.domain_max[1],
            "minZ": self.domain_min[2],
            "maxZ": self.domain_max[2]
        }
    }
    
    with open(os.path.join(result_path, "metadata.json"), "w") as f:
        json.dump(metadata, f, indent=2)
```

## Step 5: Add Advanced UI Controls

Enhance your extractor's UI with more sophisticated controls:

```python
def get_ui_panel(self):
    """
    Return a property panel for UI controls.
    
    Returns:
        PyPropertyGroup containing UI controls
    """
    panel = pp.PyPropertyGroup()
    panel.Name = "Visualization Settings"
    
    # Create controls
    
    # Temperature visualization section
    temp_group = pp.PyPropertyGroup()
    temp_group.Name = "Temperature"
    panel.Properties.Add(temp_group)
    
    # Temperature visibility
    show_temp = pp.PyPropertyBool(self.show_temperature)
    show_temp.Name = "ShowTemperature"
    show_temp.Description = "Show Temperature Field"
    temp_group.Properties.Add(show_temp)
    
    # Isosurface value
    iso_value = pp.PyPropertyDouble(self.iso_value)
    iso_value.Name = "IsoValue"
    iso_value.Description = "Temperature Isosurface Value (K)"
    iso_value.Min = 290.0
    iso_value.Max = 350.0
    temp_group.Properties.Add(iso_value)
    
    # Isosurface color
    iso_color = pp.PyPropertyColor()
    iso_color.Name = "IsoColor"
    iso_color.Description = "Isosurface Color"
    iso_color.SetValue(255, 200, 128)  # Orange-ish
    temp_group.Properties.Add(iso_color)
    
    # Heat flux visualization section
    flux_group = pp.PyPropertyGroup()
    flux_group.Name = "HeatFlux"
    panel.Properties.Add(flux_group)
    
    # Heat flux visibility
    show_flux = pp.PyPropertyBool(self.show_flux)
    show_flux.Name = "ShowFlux"
    show_flux.Description = "Show Heat Flux"
    flux_group.Properties.Add(show_flux)
    
    # Vector scale
    vector_scale = pp.PyPropertyDouble(0.01)
    vector_scale.Name = "VectorScale"
    vector_scale.Description = "Vector Scale"
    vector_scale.Min = 0.001
    vector_scale.Max = 0.1
    flux_group.Properties.Add(vector_scale)
    
    # Streamline density
    streamline_density = pp.PyPropertyInteger(5)
    streamline_density.Name = "StreamlineDensity"
    streamline_density.Description = "Streamline Density"
    streamline_density.Min = 1
    streamline_density.Max = 10
    flux_group.Properties.Add(streamline_density)
    
    return panel
```

## Step 6: Handling the UI Parameter Changes

Update the `set_parameters` method to handle the new UI controls:

```python
def set_parameters(self, params):
    """
    Set extraction parameters from UI.
    
    Args:
        params: Parameters dictionary from the UI panel
    """
    if params is None:
        return
    
    # Temperature settings
    if "ShowTemperature" in params:
        self.show_temperature = params["ShowTemperature"]
    
    if "IsoValue" in params:
        self.iso_value = params["IsoValue"]
    
    if "IsoColor" in params:
        self.iso_color = params["IsoColor"]
    
    # Heat flux settings
    if "ShowFlux" in params:
        self.show_flux = params["ShowFlux"]
    
    if "VectorScale" in params:
        self.vector_scale = params["VectorScale"]
    
    if "StreamlineDensity" in params:
        self.streamline_density = params["StreamlineDensity"]
        
        # Update the number of streamlines based on density
        self.streamline_count = self.streamline_density * self.streamline_density
```

## Step 7: Add Statistics and Data Analysis

Add methods to perform quantitative analysis on the simulation results:

```python
def calculate_statistics(self):
    """
    Calculate statistics from the temperature field.
    
    Returns:
        Dictionary of statistics
    """
    # Check if temperature file exists
    temperature_file = os.path.join(self.result_path, "Temperature.vtr")
    if not os.path.exists(temperature_file):
        print(f"Warning: Temperature file not found: {temperature_file}")
        return None
    
    # Load the VTK file
    reader = vtk.vtkXMLRectilinearGridReader()
    reader.SetFileName(temperature_file)
    reader.Update()
    
    # Get the temperature array
    temp_data = reader.GetOutput().GetPointData().GetArray("Temperature")
    
    # Calculate statistics
    temp_range = temp_data.GetRange()
    temp_min = temp_range[0]
    temp_max = temp_range[1]
    
    # Calculate mean using vtkArrayCalculator
    calculator = vtk.vtkArrayCalculator()
    calculator.SetInputData(reader.GetOutput())
    calculator.AddScalarVariable("temp", "Temperature", 0)
    calculator.SetFunction("temp")
    calculator.SetResultArrayName("TempCopy")
    calculator.Update()
    
    temp_mean = vtk.vtkStatisticsAlgorithm.ComputeMean(
        calculator.GetOutput().GetPointData().GetArray("TempCopy"),
        0, temp_data.GetNumberOfTuples()
    )
    
    # Create statistics dictionary
    stats = {
        "min": temp_min,
        "max": temp_max,
        "mean": temp_mean,
        "range": temp_max - temp_min
    }
    
    return stats
```

## Step 8: Export Results

Add methods to export processed data:

```python
def export_temperature_profile(self, line_start, line_end, num_points=100):
    """
    Export temperature values along a line.
    
    Args:
        line_start: (x, y, z) starting point
        line_end: (x, y, z) ending point
        num_points: Number of sample points
        
    Returns:
        Tuple of (distances, temperatures)
    """
    # Check if temperature file exists
    temperature_file = os.path.join(self.result_path, "Temperature.vtr")
    if not os.path.exists(temperature_file):
        print(f"Warning: Temperature file not found: {temperature_file}")
        return None, None
    
    # Load the VTK file
    reader = vtk.vtkXMLRectilinearGridReader()
    reader.SetFileName(temperature_file)
    reader.Update()
    
    # Create line and probe filter
    line = vtk.vtkLineSource()
    line.SetPoint1(line_start)
    line.SetPoint2(line_end)
    line.SetResolution(num_points - 1)
    line.Update()
    
    probe = vtk.vtkProbeFilter()
    probe.SetInputData(line.GetOutput())
    probe.SetSourceData(reader.GetOutput())
    probe.Update()
    
    # Extract results
    distances = []
    temperatures = []
    
    points = probe.GetOutput().GetPoints()
    temp_data = probe.GetOutput().GetPointData().GetArray("Temperature")
    
    line_length = np.sqrt(sum((np.array(line_end) - np.array(line_start))**2))
    
    for i in range(num_points):
        point = points.GetPoint(i)
        point_distance = np.sqrt(sum((np.array(point) - np.array(line_start))**2))
        relative_distance = point_distance / line_length
        
        distances.append(relative_distance)
        temperatures.append(temp_data.GetValue(i))
    
    return distances, temperatures
```

## Step 9: Handling Time-Dependent Data

If your simulation produces time-dependent data, add support for time steps:

```python
def load_time_steps(self):
    """
    Load available time steps from the result directory.
    
    Returns:
        List of time step values
    """
    # Check for time series metadata
    time_file = os.path.join(self.result_path, "time_steps.json")
    if os.path.exists(time_file):
        with open(time_file, "r") as f:
            time_data = json.load(f)
            return time_data["timeSteps"]
    
    # If no metadata, look for time step folders
    time_steps = []
    for item in os.listdir(self.result_path):
        if item.startswith("time_") and os.path.isdir(os.path.join(self.result_path, item)):
            try:
                time_value = float(item.split("_")[1])
                time_steps.append(time_value)
            except:
                pass
    
    time_steps.sort()
    return time_steps

def get_result_path_for_time_step(self, time_step):
    """
    Get the result directory for a specific time step.
    
    Args:
        time_step: Time step value
        
    Returns:
        Path to the time step directory
    """
    return os.path.join(self.result_path, f"time_{time_step}")
```

## Step 10: Creating Animations

Add support for generating animations from time-dependent data:

```python
def create_animation_frames(self, time_steps):
    """
    Create animation frames for a sequence of time steps.
    
    Args:
        time_steps: List of time step values
        
    Returns:
        List of visualization objects lists, one for each time step
    """
    animation_frames = []
    
    # Store the original result path
    original_path = self.result_path
    
    for time_step in time_steps:
        # Set the path to the current time step
        self.result_path = self.get_result_path_for_time_step(time_step)
        
        # Extract visualizations for this time step
        frame = self.extract()
        animation_frames.append(frame)
    
    # Restore the original path
    self.result_path = original_path
    
    return animation_frames
```

## Step 11: Error Handling and Logging

Add comprehensive error handling and logging:

```python
def initialize_logging(self):
    """Initialize logging for the extractor."""
    import logging
    
    # Configure logging
    log_file = os.path.join(self.result_path, "extractor.log")
    logging.basicConfig(
        filename=log_file,
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )
    
    self.logger = logging.getLogger("SimulationExtractor")
    self.logger.info("Initializing extractor")

def safe_load_vtk_file(self, file_path, reader_type):
    """
    Safely load a VTK file with error handling.
    
    Args:
        file_path: Path to the VTK file
        reader_type: VTK reader class to use
        
    Returns:
        VTK data object or None if loading failed
    """
    if not os.path.exists(file_path):
        self.logger.warning(f"File not found: {file_path}")
        return None
    
    try:
        reader = reader_type()
        reader.SetFileName(file_path)
        reader.Update()
        return reader.GetOutput()
    except Exception as e:
        self.logger.error(f"Error loading {file_path}: {str(e)}")
        return None
```

## Example: Complete Extractor Implementation

Here's a complete example of a temperature field extractor:

```python
import os
import vtk
import json
import numpy as np
import logging

# Import Sim4Life post-processing API
import S4L.postprocessing as pp
from S4L.postprocessing import fieldTypes

def create_engine():
    """Entry point function called by the Sim4Life post-processing system."""
    return TemperatureExtractor()

class TemperatureExtractor:
    """Extractor for temperature simulation results."""
    
    def __init__(self):
        """Initialize the extractor."""
        # Initialize properties
        self.result_path = None
        self.logger = None
        
        # Visualization settings
        self.show_field = True
        self.show_isosurface = True
        self.iso_value = 310.0
        self.iso_color = (255, 200, 128)
        self.current_time_step = None
        self.time_steps = []
        
    def set_parameters(self, params):
        """Set extraction parameters from UI."""
        if params is None:
            return
        
        # Field visibility
        if "ShowField" in params:
            self.show_field = params["ShowField"]
            
        # Isosurface settings
        if "ShowIsosurface" in params:
            self.show_isosurface = params["ShowIsosurface"]
            
        if "IsoValue" in params:
            self.iso_value = params["IsoValue"]
            
        if "IsoColor" in params:
            self.iso_color = params["IsoColor"]
            
        # Time step
        if "TimeStep" in params:
            self.current_time_step = params["TimeStep"]
    
    def extract(self):
        """Process results and create visualization objects."""
        # Get the result path from the context
        context = pp.PyExtractorContext.GetInstance()
        self.result_path = context.GetResultPath()
        
        if not os.path.exists(self.result_path):
            print(f"Error: Result path does not exist: {self.result_path}")
            return []
        
        # Initialize logging
        self.initialize_logging()
        
        # Load time steps if available
        self.time_steps = self.load_time_steps()
        if self.time_steps and self.current_time_step is None:
            self.current_time_step = self.time_steps[0]
        
        # Adjust result path for time step if needed
        result_path = self.result_path
        if self.current_time_step is not None and self.time_steps:
            result_path = self.get_result_path_for_time_step(self.current_time_step)
        
        # Create the results
        results = []
        
        # Add temperature field if enabled
        if self.show_field:
            temperature_field = self.create_temperature_field(result_path)
            if temperature_field:
                results.append(temperature_field)
        
        # Add isosurface if enabled
        if self.show_isosurface:
            isosurface = self.create_temperature_isosurface(
                result_path, self.iso_value, self.iso_color
            )
            if isosurface:
                results.append(isosurface)
        
        return results
    
    def get_ui_panel(self):
        """Return a property panel for UI controls."""
        panel = pp.PyPropertyGroup()
        panel.Name = "Temperature Visualization"
        
        # Field visibility
        show_field = pp.PyPropertyBool(self.show_field)
        show_field.Name = "ShowField"
        show_field.Description = "Show Temperature Field"
        panel.Properties.Add(show_field)
        
        # Isosurface settings
        iso_group = pp.PyPropertyGroup()
        iso_group.Name = "Isosurface"
        panel.Properties.Add(iso_group)
        
        show_iso = pp.PyPropertyBool(self.show_isosurface)
        show_iso.Name = "ShowIsosurface"
        show_iso.Description = "Show Isosurface"
        iso_group.Properties.Add(show_iso)
        
        iso_value = pp.PyPropertyDouble(self.iso_value)
        iso_value.Name = "IsoValue"
        iso_value.Description = "Temperature Value (K)"
        iso_value.Min = 290.0
        iso_value.Max = 350.0
        iso_group.Properties.Add(iso_value)
        
        iso_color = pp.PyPropertyColor()
        iso_color.Name = "IsoColor"
        iso_color.Description = "Isosurface Color"
        iso_color.SetValue(*self.iso_color)
        iso_group.Properties.Add(iso_color)
        
        # Time step selector (if time steps are available)
        if self.time_steps:
            time_step = pp.PyPropertyDouble(self.current_time_step or self.time_steps[0])
            time_step.Name = "TimeStep"
            time_step.Description = "Time Step (s)"
            time_step.EnumValues = self.time_steps
            panel.Properties.Add(time_step)
        
        return panel
    
    def initialize_logging(self):
        """Initialize logging for the extractor."""
        log_file = os.path.join(self.result_path, "extractor.log")
        logging.basicConfig(
            filename=log_file,
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        
        self.logger = logging.getLogger("TemperatureExtractor")
        self.logger.info("Initializing extractor")
    
    def load_time_steps(self):
        """Load available time steps from the result directory."""
        # Check for time series metadata
        time_file = os.path.join(self.result_path, "time_steps.json")
        if os.path.exists(time_file):
            with open(time_file, "r") as f:
                time_data = json.load(f)
                self.logger.info(f"Loaded {len(time_data['timeSteps'])} time steps from metadata")
                return time_data["timeSteps"]
        
        # If no metadata, look for time step folders
        time_steps = []
        for item in os.listdir(self.result_path):
            if item.startswith("time_") and os.path.isdir(os.path.join(self.result_path, item)):
                try:
                    time_value = float(item.split("_")[1])
                    time_steps.append(time_value)
                except:
                    pass
        
        time_steps.sort()
        self.logger.info(f"Found {len(time_steps)} time step directories")
        return time_steps
    
    def get_result_path_for_time_step(self, time_step):
        """Get the result directory for a specific time step."""
        return os.path.join(self.result_path, f"time_{time_step}")
    
    def create_temperature_field(self, result_path):
        """Create a temperature field visualization."""
        # Check if temperature file exists
        temperature_file = os.path.join(result_path, "Temperature.vtr")
        if not os.path.exists(temperature_file):
            self.logger.warning(f"Temperature file not found: {temperature_file}")
            return None
        
        try:
            # Load the VTK file
            self.logger.info(f"Loading temperature field from {temperature_file}")
            reader = vtk.vtkXMLRectilinearGridReader()
            reader.SetFileName(temperature_file)
            reader.Update()
            
            # Create the field
            field = pp.PyField()
            field.Name = "Temperature"
            field.VtkData = reader.GetOutput()
            field.HasPointData = True
            field.PointDataName = "Temperature"
            field.FieldType = fieldTypes.FieldType.Scalar
            field.Unit = "K"
            
            return field
            
        except Exception as e:
            self.logger.error(f"Error creating temperature field: {str(e)}")
            return None
    
    def create_temperature_isosurface(self, result_path, iso_value, color):
        """Create an isosurface at the specified temperature."""
        # Check if temperature file exists
        temperature_file = os.path.join(result_path, "Temperature.vtr")
        if not os.path.exists(temperature_file):
            self.logger.warning(f"Temperature file not found: {temperature_file}")
            return None
        
        try:
            # Load the VTK file
            self.logger.info(f"Creating isosurface at {iso_value} K")
            reader = vtk.vtkXMLRectilinearGridReader()
            reader.SetFileName(temperature_file)
            reader.Update()
            
            # Create isosurface
            contour = vtk.vtkContourFilter()
            contour.SetInputData(reader.GetOutput())
            contour.SetInputArrayToProcess(
                0, 0, 0, vtk.vtkDataObject.FIELD_ASSOCIATION_POINTS, "Temperature"
            )
            contour.SetValue(0, iso_value)
            contour.Update()
            
            # Create the extraction object
            isosurface = pp.PyExtractionObject()
            isosurface.Name = f"Temperature Isosurface ({iso_value} K)"
            isosurface.VtkData = contour.GetOutput()
            
            # Set isosurface color if provided
            if color:
                isosurface.Color = color
            
            return isosurface
            
        except Exception as e:
            self.logger.error(f"Error creating isosurface: {str(e)}")
            return None
```

## Testing the Extractor

To test your extractor:

1. Generate simulation results with your solver
2. Run S4L and open your plugin
3. Run a simulation to generate results
4. Open the post-processing view to see the extractor in action

## Debugging Tips

If your extractor doesn't work as expected:

1. Check the extractor log file in the result directory
2. Verify that the result files exist and have the expected format
3. Test the VTK operations separately with a simple script
4. Add more logging to trace the execution flow

## Next Steps

Once you have a working extractor, consider:

- Adding more visualization types (cut planes, volume rendering, etc.)
- Implementing more sophisticated data analysis
- Creating custom UI widgets for interactive exploration
- Supporting time-dependent data and animations

For more advanced VTK techniques, see the [VTK Integration](vtk-integration.md) guide.