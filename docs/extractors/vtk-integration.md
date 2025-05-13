# VTK Integration

This page explains how to effectively use the Visualization Toolkit (VTK) in your S4L plugin extractors to create advanced visualizations of simulation results.

## Introduction to VTK

The Visualization Toolkit (VTK) is an open-source software system for 3D computer graphics, image processing, and visualization. In the S4L Plugin Framework, VTK provides the foundation for visualizing simulation results through:

1. Data structures for representing 3D fields and geometric objects
2. Algorithms for processing and transforming data
3. Rendering components for visualizing data
4. File I/O mechanisms for reading and writing visualization data

## VTK Data Pipeline

VTK uses a pipeline architecture where data flows through a series of filters:

```mermaid
graph LR
    Input[Source/Reader] --> Filter1[Filter]
    Filter1 --> Filter2[Filter]
    Filter2 --> Mapper[Mapper]
    Mapper --> Actor[Actor]
    Actor --> Renderer[Renderer]
```

In S4L extractors, you typically work with a simplified pipeline:

1. **Reader**: Loads data from VTK files (e.g., `vtkXMLRectilinearGridReader`)
2. **Filters**: Process data (e.g., extract isosurfaces)
3. **Output**: Integrate into S4L visualization objects

## Common VTK Data Types

When working with S4L plugins, you'll encounter these common VTK data types:

| VTK Data Type | Description | Common Use |
|---------------|-------------|------------|
| `vtkRectilinearGrid` | Grid with variable spacing along each axis | Regular grids with non-uniform spacing |
| `vtkStructuredGrid` | Structured grid with arbitrary coordinates | Curvilinear grids |
| `vtkUnstructuredGrid` | Collection of arbitrary cells | Finite element results |
| `vtkPolyData` | Collection of polygons and vertices | Surfaces, lines, and points |
| `vtkImageData` | Regular grid (identical to `vtkRectilinearGrid` with uniform spacing) | Regular grids with uniform spacing |

## Reading VTK Files

Your solver outputs results as VTK files, which you'll read in your extractor:

```python
import vtk

# Read a RectilinearGrid VTK file
reader = vtk.vtkXMLRectilinearGridReader()
reader.SetFileName("path/to/Temperature.vtr")
reader.Update()

# Get the grid data
grid = reader.GetOutput()

# Access grid dimensions
dimensions = grid.GetDimensions()  # Returns (nx, ny, nz)

# Get point data (e.g., temperature values)
point_data = grid.GetPointData()
temperature_array = point_data.GetArray("Temperature")

# Get cell data (if available)
cell_data = grid.GetCellData()
```

## Working with VTK Arrays

VTK stores field data in arrays:

```python
import numpy as np

# Get a VTK array from the data
temperature_array = grid.GetPointData().GetArray("Temperature")

# Get the number of values in the array
num_points = temperature_array.GetNumberOfTuples()

# Get the number of components per value (1 for scalar, 3 for vector, etc.)
num_components = temperature_array.GetNumberOfComponents()

# Access values directly
value_at_index_0 = temperature_array.GetValue(0)  # For scalar arrays
vector_at_index_0 = [temperature_array.GetComponent(0, i) for i in range(num_components)]  # For vector arrays

# Convert to NumPy array for more efficient operations
numpy_array = np.zeros((num_points, num_components))
for i in range(num_points):
    for j in range(num_components):
        numpy_array[i, j] = temperature_array.GetComponent(i, j)
```

For more efficient conversion to NumPy:

```python
import vtk.util.numpy_support as vtk_np

# Convert VTK array to NumPy array
numpy_array = vtk_np.vtk_to_numpy(temperature_array)

# Reshape for vector field (if needed)
if num_components > 1:
    numpy_array = numpy_array.reshape((-1, num_components))
```

## Creating VTK Data Objects

You may need to create VTK data objects from scratch:

```python
# Create a rectilinear grid with specified dimensions
import numpy as np
import vtk

# Define coordinate arrays
x = np.linspace(0, 10, 50)
y = np.linspace(0, 5, 25)
z = np.linspace(0, 3, 15)

# Create VTK arrays from NumPy arrays
x_vtk = vtk.vtkDoubleArray()
y_vtk = vtk.vtkDoubleArray()
z_vtk = vtk.vtkDoubleArray()

for value in x:
    x_vtk.InsertNextValue(value)
for value in y:
    y_vtk.InsertNextValue(value)
for value in z:
    z_vtk.InsertNextValue(value)

# Create the grid
grid = vtk.vtkRectilinearGrid()
grid.SetDimensions(len(x), len(y), len(z))
grid.SetXCoordinates(x_vtk)
grid.SetYCoordinates(y_vtk)
grid.SetZCoordinates(z_vtk)

# Create a scalar field (e.g., temperature)
temperature = vtk.vtkDoubleArray()
temperature.SetName("Temperature")
temperature.SetNumberOfComponents(1)
temperature.SetNumberOfTuples(len(x) * len(y) * len(z))

# Fill the array with values
for i in range(len(x) * len(y) * len(z)):
    temperature.SetValue(i, i * 0.01)  # Some sample data

# Add the array to the grid
grid.GetPointData().AddArray(temperature)
grid.GetPointData().SetActiveScalars("Temperature")
```

## VTK Filters for Processing Data

VTK provides numerous filters for processing data:

### Creating Isosurfaces

```python
# Create an isosurface from a scalar field
contour = vtk.vtkContourFilter()
contour.SetInputData(grid)
contour.SetInputArrayToProcess(0, 0, 0, vtk.vtkDataObject.FIELD_ASSOCIATION_POINTS, "Temperature")
contour.SetValue(0, 300.0)  # Isosurface at 300K
contour.Update()

isosurface = contour.GetOutput()  # This is a vtkPolyData object
```

### Cut Planes

```python
# Create a cut plane
plane = vtk.vtkPlane()
plane.SetOrigin(5, 2.5, 1.5)  # Middle of the domain
plane.SetNormal(1, 0, 0)      # Normal in x-direction

cutter = vtk.vtkCutter()
cutter.SetInputData(grid)
cutter.SetCutFunction(plane)
cutter.Update()

cut_plane = cutter.GetOutput()  # This is a vtkPolyData object
```

### Vector Glyph Visualization

```python
# Create a vector field visualization with arrow glyphs
arrow = vtk.vtkArrowSource()

# Create glyph filter
glyph = vtk.vtkGlyph3D()
glyph.SetInputData(grid)
glyph.SetSourceConnection(arrow.GetOutputPort())
glyph.SetVectorModeToUseVector()
glyph.SetScaleModeToScaleByVector()
glyph.SetScaleFactor(0.1)  # Adjust scale factor to fit your data
glyph.OrientOn()
glyph.SetInputArrayToProcess(0, 0, 0, vtk.vtkDataObject.FIELD_ASSOCIATION_POINTS, "HeatFlux")
glyph.Update()

vector_field = glyph.GetOutput()  # This is a vtkPolyData object
```

### Streamlines

```python
# Create streamlines from a vector field
# First, create seed points
seeds = vtk.vtkPointSource()
seeds.SetCenter(5, 2.5, 1.5)  # Center of the domain
seeds.SetNumberOfPoints(20)   # Number of streamlines
seeds.SetRadius(2.0)          # Radius of the seed region
seeds.Update()

# Create streamlines
streamlines = vtk.vtkStreamTracer()
streamlines.SetInputData(grid)
streamlines.SetSourceConnection(seeds.GetOutputPort())
streamlines.SetMaximumPropagation(10.0)  # Maximum streamline length
streamlines.SetIntegrationDirectionToBoth()
streamlines.SetInputArrayToProcess(0, 0, 0, vtk.vtkDataObject.FIELD_ASSOCIATION_POINTS, "HeatFlux")
streamlines.Update()

streamlines_output = streamlines.GetOutput()  # This is a vtkPolyData object
```

## Integrating VTK Objects with S4L

After processing your VTK data, you need to integrate it with S4L's visualization system:

```python
import s4l_core.postprocessing as pp
from s4l_core.postprocessing.fieldTypes import FieldType

def create_field_from_vtk(vtk_data, field_name, field_type, unit, description):
    """
    Create an S4L field object from a VTK data object.
    
    Args:
        vtk_data: The VTK data object
        field_name: Name of the field
        field_type: Field type (Scalar, Vector, etc.)
        unit: Unit string
        description: Field description
        
    Returns:
        An S4L PyField object
    """
    field = pp.PyField()
    field.Name = field_name
    field.VtkData = vtk_data
    field.HasPointData = True
    field.PointDataName = field_name
    field.FieldType = field_type
    field.Unit = unit
    field.Description = description
    
    return field

# Create a scalar field for temperature
temperature_field = create_field_from_vtk(
    grid,
    "Temperature",
    FieldType.Scalar,
    "K",
    "Temperature distribution"
)

# Create a vector field for heat flux
heat_flux_field = create_field_from_vtk(
    grid,
    "HeatFlux",
    FieldType.Vector,
    "W/m²",
    "Heat flux vector field"
)

# Create an extraction object for isosurface
isosurface_obj = pp.PyExtractionObject()
isosurface_obj.Name = f"Temperature Isosurface (300 K)"
isosurface_obj.VtkData = isosurface
```

## VTK Coordinate Transformations

Sometimes you need to transform coordinates:

```python
# Create a transformation matrix
transform = vtk.vtkTransform()
transform.Translate(1.0, 0.0, 0.0)  # Translate 1 unit in x direction
transform.RotateZ(45)               # Rotate 45 degrees around Z axis
transform.Scale(2.0, 2.0, 2.0)      # Scale by factor of 2

# Apply transformation to a polydata object
transform_filter = vtk.vtkTransformFilter()
transform_filter.SetInputData(isosurface)
transform_filter.SetTransform(transform)
transform_filter.Update()

transformed_data = transform_filter.GetOutput()
```

## Converting Between VTK Data Types

You may need to convert between different VTK data types:

```python
# Convert unstructured grid to polydata
geometry_filter = vtk.vtkGeometryFilter()
geometry_filter.SetInputData(unstructured_grid)
geometry_filter.Update()
polydata = geometry_filter.GetOutput()

# Extract points from any dataset
points_filter = vtk.vtkPointsFilter()
points_filter.SetInputData(any_vtk_dataset)
points_filter.Update()
points = points_filter.GetOutput()
```

## Understanding VTK Memory Management

VTK uses reference counting for memory management:

1. When you create a VTK object, it has a reference count of 1
2. VTK connections (e.g., `SetInputConnection`) increase reference counts
3. Python's garbage collector will destroy VTK objects when they go out of scope

In complex pipelines, you may need to manage memory:

```python
# Force release of large objects
large_grid = None  # Set to None to allow garbage collection
```

## Error Handling with VTK

When working with VTK, handle errors gracefully:

```python
try:
    reader = vtk.vtkXMLRectilinearGridReader()
    reader.SetFileName(filepath)
    reader.Update()
    grid = reader.GetOutput()
    
    if grid.GetNumberOfPoints() == 0:
        raise ValueError("VTK file contains no points")
        
except Exception as e:
    print(f"Error loading VTK file: {e}")
    # Create a fallback visualization
    grid = create_fallback_grid()
```

## Performance Optimization

For large datasets, consider these optimizations:

1. **Subsampling**: Use `vtkExtractGrid` to extract a subset of a large grid
2. **Level of Detail**: Use `vtkDecimatePolyData` to reduce polygon count
3. **Caching**: Cache processing results for reuse
4. **Lazy Loading**: Only load data when needed

Example of subsampling:

```python
# Extract every other point in each dimension
subsample = vtk.vtkExtractGrid()
subsample.SetInputData(large_grid)
subsample.SetVOI(0, dims[0]-1, 0, dims[1]-1, 0, dims[2]-1)
subsample.SetSampleRate(2, 2, 2)  # Take every 2nd point in each dimension
subsample.Update()

subsampled_grid = subsample.GetOutput()
```

## Working with Time Series Data

For time-dependent simulations:

```python
def create_time_series_field(file_pattern, num_timesteps):
    """
    Create a time series field from multiple VTK files.
    
    Args:
        file_pattern: Pattern for timestep files (e.g., "Temperature_{}.vtr")
        num_timesteps: Number of timesteps
        
    Returns:
        A field with time dimension
    """
    # Create a collection of grids
    grids = []
    
    for t in range(num_timesteps):
        filename = file_pattern.format(t)
        reader = vtk.vtkXMLRectilinearGridReader()
        reader.SetFileName(filename)
        reader.Update()
        
        # Deep copy to ensure independent data
        grid_copy = vtk.vtkRectilinearGrid()
        grid_copy.DeepCopy(reader.GetOutput())
        grids.append(grid_copy)
    
    # Create a time series field
    field = pp.PyField()
    field.Name = "Temperature"
    field.VtkData = grids[0]  # Initial timestep
    field.HasPointData = True
    field.PointDataName = "Temperature"
    field.FieldType = FieldType.Scalar
    field.Unit = "K"
    
    # Set time series data
    field.HasTimeSeries = True
    field.TimeSteps = list(range(num_timesteps))
    field.TimeSeriesVtkData = grids
    
    return field
```

## Integration with NumPy and SciPy

For advanced data analysis, integrate VTK with NumPy and SciPy:

```python
import numpy as np
import scipy.ndimage as ndimage
import vtk.util.numpy_support as vtk_np

# Extract data to NumPy
vtk_array = grid.GetPointData().GetArray("Temperature")
numpy_array = vtk_np.vtk_to_numpy(vtk_array)

# Reshape to 3D grid
dims = grid.GetDimensions()
numpy_3d = numpy_array.reshape(dims, order='F')

# Apply SciPy filter
filtered_data = ndimage.gaussian_filter(numpy_3d, sigma=1.0)

# Convert back to VTK
filtered_flat = filtered_data.flatten(order='F')
vtk_filtered = vtk_np.numpy_to_vtk(filtered_flat)
vtk_filtered.SetName("FilteredTemperature")

# Add to grid
grid.GetPointData().AddArray(vtk_filtered)
```

## Common Pitfalls and Solutions

### 1. Missing or Incorrect Data

**Problem**: Field data not showing or showing incorrectly.

**Solution**: Check array names, field associations, and active scalars/vectors:

```python
# Set active scalar explicitly
grid.GetPointData().SetActiveScalars("Temperature")

# Check if array exists
if grid.GetPointData().HasArray("Temperature"):
    print("Array exists")
else:
    print("Array not found!")
    
# Check array type
array = grid.GetPointData().GetArray("Temperature")
if array:
    print(f"Array type: {array.GetDataType()}")
    print(f"Number of components: {array.GetNumberOfComponents()}")
```

### 2. Transformation Issues

**Problem**: Coordinate systems don't match between different objects.

**Solution**: Use explicit transformations and check units:

```python
# Create a transform to convert between coordinate systems
transform = vtk.vtkTransform()
transform.Scale(0.001, 0.001, 0.001)  # Convert mm to m

transform_filter = vtk.vtkTransformFilter()
transform_filter.SetInputData(grid)
transform_filter.SetTransform(transform)
transform_filter.Update()

transformed_grid = transform_filter.GetOutput()
```

### 3. Memory Leaks

**Problem**: Memory usage grows over time.

**Solution**: Explicitly clean up and use more efficient data access:

```python
# Explicitly clean up large objects
reader = vtk.vtkXMLRectilinearGridReader()
reader.SetFileName(filepath)
reader.Update()
grid = vtk.vtkRectilinearGrid()
grid.DeepCopy(reader.GetOutput())
reader = None  # Allow reader to be garbage collected

# Use shallow copy when appropriate
shallow_copy = vtk.vtkRectilinearGrid()
shallow_copy.ShallowCopy(grid)
```

## Advanced VTK Features

### Custom Implicit Functions

Create custom field operations using implicit functions:

```python
# Create a custom signed distance function
sphere = vtk.vtkSphere()
sphere.SetCenter(5, 2.5, 1.5)
sphere.SetRadius(1.0)

# Sample the function on the grid
sample = vtk.vtkSampleFunction()
sample.SetImplicitFunction(sphere)
sample.SetSampleDimensions(50, 25, 15)
sample.SetModelBounds(0, 10, 0, 5, 0, 3)
sample.ComputeNormalsOff()
sample.Update()

sampled_grid = sample.GetOutput()
```

### Volume Rendering

Create direct volume renderings of 3D scalar fields:

```python
# Create a volume rendering
volumeMapper = vtk.vtkSmartVolumeMapper()
volumeMapper.SetInputData(grid)

# Create transfer functions
colorFunction = vtk.vtkColorTransferFunction()
colorFunction.AddRGBPoint(250, 0.0, 0.0, 1.0)  # Blue for low values
colorFunction.AddRGBPoint(350, 1.0, 0.0, 0.0)  # Red for high values

opacityFunction = vtk.vtkPiecewiseFunction()
opacityFunction.AddPoint(250, 0.1)  # More transparent for low values
opacityFunction.AddPoint(350, 0.9)  # More opaque for high values

# Create volume properties
volumeProperty = vtk.vtkVolumeProperty()
volumeProperty.SetColor(colorFunction)
volumeProperty.SetScalarOpacity(opacityFunction)
volumeProperty.SetInterpolationTypeToLinear()
volumeProperty.ShadeOn()

# Create volume
volume = vtk.vtkVolume()
volume.SetMapper(volumeMapper)
volume.SetProperty(volumeProperty)
```

## Next Steps

After mastering VTK integration:

- [Creating an Extractor](creating-extractor.md): Learn to implement a complete extractor
- [Solver Implementation](../solver-implementation/main-solver.md): Understand how solvers generate the VTK output
- [API Reference](../api-reference/vtk-classes.md): Browse detailed VTK class documentation