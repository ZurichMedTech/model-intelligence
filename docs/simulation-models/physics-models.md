<!-- filepath: /home/guidon/devel/src/gitlab/sim4life/plugins/template/documentation/docs/simulation-models/physics-models.md -->
# Physics Models

Physics models define the underlying equations and parameters that represent specific physical phenomena within your S4L plugin. This page provides guidance on implementing various physics models in the framework.

## Implementing Physics Models

In the S4L Plugin Framework, implementing a physics model involves:

1. **Defining the Governing Equations**: Identify the mathematical equations that describe your physical phenomenon
2. **Determining Parameters**: Define the physical parameters needed to characterize the model
3. **Choosing Discretization Methods**: Select appropriate numerical techniques for solving the equations
4. **Implementing Boundary Conditions**: Define how the model behaves at domain boundaries
5. **Specifying Output Quantities**: Determine which results to extract and visualize

## Common Physics Models

The framework can support a wide range of physics models, including:

### Heat Transfer

Heat transfer models solve the heat equation to determine temperature distributions:

$$\rho c_p \frac{\partial T}{\partial t} = \nabla \cdot (k \nabla T) + Q$$

Where:
- $\rho$ is the material density
- $c_p$ is the specific heat capacity
- $T$ is the temperature field
- $k$ is the thermal conductivity
- $Q$ is the volumetric heat source

**Key Settings:**
- Material properties (thermal conductivity, density, heat capacity)
- Boundary conditions (fixed temperature, insulation, heat flux)
- Heat sources (point sources, distributed sources)
- Initial conditions (for transient simulations)

### Electromagnetic Wave Propagation

Electromagnetic models solve Maxwell's equations for wave propagation:

$$\nabla \times \nabla \times \mathbf{E} - k_0^2 \varepsilon_r \mathbf{E} = 0$$

Where:
- $\mathbf{E}$ is the electric field
- $k_0$ is the free-space wave number
- $\varepsilon_r$ is the relative permittivity

**Key Settings:**
- Material properties (permittivity, permeability, conductivity)
- Boundary conditions (perfect electric conductor, radiation, etc.)
- Source configurations (antennas, waveguides, etc.)
- Frequency settings

### Mechanical Deformation

Mechanical models solve equations of elasticity for deformation and stress:

$$\nabla \cdot \boldsymbol{\sigma} + \mathbf{f} = \rho \frac{\partial^2 \mathbf{u}}{\partial t^2}$$

Where:
- $\boldsymbol{\sigma}$ is the stress tensor
- $\mathbf{f}$ is the body force
- $\rho$ is the density
- $\mathbf{u}$ is the displacement field

**Key Settings:**
- Material properties (Young's modulus, Poisson's ratio)
- Boundary conditions (fixed surfaces, applied forces)
- Loading conditions
- Contact interfaces

### Fluid Flow

Fluid models solve the Navier-Stokes equations for fluid velocity and pressure:

$$\rho \left(\frac{\partial \mathbf{v}}{\partial t} + \mathbf{v} \cdot \nabla \mathbf{v}\right) = -\nabla p + \mu \nabla^2 \mathbf{v} + \mathbf{f}$$

$$\nabla \cdot \mathbf{v} = 0$$

Where:
- $\mathbf{v}$ is the velocity field
- $p$ is pressure
- $\mu$ is dynamic viscosity
- $\mathbf{f}$ is a body force per unit volume

**Key Settings:**
- Fluid properties (density, viscosity)
- Boundary conditions (inlets, outlets, walls)
- Initial conditions
- Flow parameters (Reynolds number, etc.)

## Coupling Physics Models

S4L allows coupling multiple physics phenomena in a single simulation:

### Types of Coupling

1. **One-way Coupling**: One physics model affects another without feedback
2. **Two-way Coupling**: Multiple physics models influence each other
3. **Sequential Coupling**: Physics models are solved in sequence
4. **Fully Coupled**: All physics models are solved simultaneously

### Implementation Strategies

To implement coupled physics:

1. Create API models that include parameters for all physics domains
2. Implement appropriate transfer mechanisms between physics models
3. Define solution strategies that handle the coupled equations
4. Extract and visualize results from all physics domains

## Numerical Considerations

When implementing physics models, consider:

### Stability

Ensure your numerical scheme is stable for the parameter ranges expected in your application. This might require:
- Appropriate time step selection in transient problems
- Suitable mesh refinement in regions with high gradients
- Well-conditioned system matrices

### Accuracy

Balance computational efficiency with sufficient accuracy:
- Choose appropriate discretization orders
- Implement adaptive refinement where needed
- Validate against known analytical solutions

### Convergence

Ensure your iterative solvers converge reliably:
- Provide good initial guesses
- Implement appropriate preconditioners
- Monitor convergence metrics
- Set reasonable convergence criteria

## Example: Implementing a Wave Equation Model

Here's an example of how to implement a wave equation model:

```python
class WaveEquationSettings(TreeItem):
    """Wave equation physical parameters."""
    
    def __init__(self, parent: TreeItem) -> None:
        super().__init__(parent)
        
        self._properties = XCoreHeadless.DialogOptions()
        self._properties.Description = "Wave Equation Settings"
        
        # Wave speed parameter
        wave_speed = XCore.PropertyReal(340.0, 0.0, 10000.0, XCore.Unit("m/s"))
        wave_speed.Description = "Wave Speed"
        self._properties.Add("wave_speed", wave_speed)
        
        # Damping parameter
        damping = XCore.PropertyReal(0.01, 0.0, 1.0)
        damping.Description = "Damping Coefficient"
        self._properties.Add("damping", damping)
```

## Next Steps

After defining your physics model:

- [Implement a numerical solver](../solver-implementation/writing-solver.md) to solve the equations
- [Create an extractor](../extractors/creating-extractor.md) to visualize the results