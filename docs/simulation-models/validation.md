<!-- filepath: /home/guidon/devel/src/gitlab/sim4life/plugins/template/documentation/docs/simulation-models/validation.md -->
# Validation

Validation is a critical step in simulation plugin development to ensure that your model correctly represents the physical phenomena you're simulating. This page provides guidance on validation approaches for S4L plugins.

## Importance of Validation

Validation serves several key purposes in simulation development:

1. **Verification of Correctness**: Ensures your solver correctly implements the intended mathematical model
2. **Accuracy Assessment**: Quantifies how well your simulation matches known reference solutions
3. **Convergence Analysis**: Demonstrates that your numerical methods converge to the correct solution
4. **Error Estimation**: Provides confidence bounds for simulation results
5. **Identification of Limitations**: Defines the valid parameter ranges for your simulation

## Validation Approaches

### Comparison with Analytical Solutions

When available, analytical solutions provide the most rigorous validation approach:

1. Identify test cases with known analytical solutions
2. Implement the same scenario in your simulation
3. Compare numerical results with the analytical solution
4. Measure and report error metrics

**Example**: For heat conduction, compare with the analytical solution for a 1D steady-state problem with constant source:

```python
def analytical_temperature(x, L, k, q):
    """
    Analytical solution for 1D heat conduction with constant source.
    T(0) = T(L) = 0, with volumetric source q.
    
    Args:
        x: Position
        L: Domain length
        k: Thermal conductivity
        q: Heat source
        
    Returns:
        Temperature at position x
    """
    return (q / (2 * k)) * x * (L - x)

def validate_1d_conduction(simulation_results, L, k, q):
    """Validate simulation against analytical 1D heat conduction."""
    x_positions = simulation_results.grid_positions
    sim_temps = simulation_results.temperature
    
    # Calculate analytical solution at grid points
    analytical_temps = [analytical_temperature(x, L, k, q) for x in x_positions]
    
    # Compute error metrics
    max_error = max(abs(s - a) for s, a in zip(sim_temps, analytical_temps))
    mean_error = sum(abs(s - a) for s, a in zip(sim_temps, analytical_temps)) / len(x_positions)
    
    return {
        "max_error": max_error,
        "mean_error": mean_error,
        "relative_error": max_error / max(analytical_temps)
    }
```

### Method of Manufactured Solutions

When analytical solutions aren't available, the Method of Manufactured Solutions (MMS) provides an alternative:

1. Invent a solution function that's easy to differentiate
2. Compute the source term needed to make this the solution to your equation
3. Implement the problem with this source term in your simulation
4. Compare with the manufactured solution

**Example**: For a 2D heat equation, we could manufacture a solution $T(x,y) = \sin(\pi x) \sin(\pi y)$, then compute the required source term.

### Grid Convergence Studies

Evaluate how your solution converges as the grid is refined:

1. Run simulations with progressively finer grid resolutions
2. Measure a key output quantity at each resolution
3. Plot the error against grid size on a log-log scale
4. Verify that the convergence rate matches theoretical expectations

```python
def grid_convergence_study(solver_function, resolutions):
    """
    Perform a grid convergence study.
    
    Args:
        solver_function: Function that runs simulation given a grid size
        resolutions: List of grid resolutions to test
        
    Returns:
        Dictionary of results including convergence rate
    """
    results = []
    for dx in resolutions:
        result = solver_function(dx)
        results.append(result)
    
    # Compute convergence rate
    errors = [r["error"] for r in results]
    dx_values = resolutions
    
    # For second-order methods, errors should decrease as dx^2
    # Plot log(error) vs log(dx) and measure slope
    import numpy as np
    log_errors = np.log(errors)
    log_dx = np.log(dx_values)
    
    # Linear regression to find slope
    slope, _, _, _, _ = np.polyfit(log_dx, log_errors, 1, full=True)
    
    return {
        "results": results,
        "convergence_rate": slope,
        "expected_rate": -2.0  # For second-order methods
    }
```

### Comparison with Reference Codes

Validate against established simulation codes for similar physics:

1. Set up the same test case in your simulation and the reference code
2. Compare the results for key quantities
3. Investigate any significant discrepancies

### Experimental Validation

When possible, validate against experimental data:

1. Identify representative experimental setups
2. Create corresponding simulation models
3. Compare simulation predictions with measured data
4. Document key assumptions and limitations

## Validation Testing Framework

Implement automated validation tests that can be run regularly:

```python
class ValidationTest:
    """Base class for validation tests."""
    
    def __init__(self, name, description):
        self.name = name
        self.description = description
        
    def run(self):
        """Run the validation test and return results."""
        raise NotImplementedError("Subclasses must implement run()")
    
    def report(self, results):
        """Generate a report from the results."""
        print(f"Validation Test: {self.name}")
        print(f"Description: {self.description}")
        print(f"Results: {results}")


class AnalyticalValidation(ValidationTest):
    """Validation test comparing to analytical solution."""
    
    def run(self):
        # Set up and run the simulation
        simulation = self.setup_simulation()
        results = simulation.run()
        
        # Compare with analytical solution
        analytical = self.analytical_solution()
        error = self.compute_error(results, analytical)
        
        return {
            "simulation_results": results,
            "analytical_results": analytical,
            "error_metrics": error,
            "passed": error["relative_error"] < self.tolerance
        }
```

## Documentation of Validation

Document your validation results as part of your plugin:

1. **Validation Cases**: Describe the test cases used for validation
2. **Expected Results**: Document the expected reference solutions
3. **Actual Results**: Present your simulation results and error metrics
4. **Convergence Data**: Include grid convergence studies
5. **Parameter Ranges**: Document validated parameter ranges
6. **Limitations**: Clearly state known limitations or approximations

## Example: Heat Conduction Validation Report

```markdown
# Validation Report: Heat Conduction Plugin

## Test Case 1: 1D Heat Conduction with Fixed Boundaries

### Setup
- Domain: 0 ≤ x ≤ 1
- Boundary conditions: T(0) = 0, T(1) = 0
- Uniform heat source: q = 100 W/m³
- Thermal conductivity: k = 1 W/mK

### Analytical Solution
T(x) = (q/2k) * x * (1-x)

### Results
| Grid Size | Max Error | Relative Error |
|-----------|-----------|----------------|
| 0.1       | 0.0125    | 0.5%           |
| 0.05      | 0.0031    | 0.12%          |
| 0.025     | 0.0008    | 0.03%          |

### Convergence
- Observed order of convergence: 2.01
- Expected order: 2.0

## Test Case 2: 2D Heat Conduction in Square Domain
...
```

## Next Steps

After validating your simulation model:

- [Implement the Main Solver](../solver-implementation/main-solver.md) with appropriate numerical methods
- [Create Result Extractors](../extractors/creating-extractor.md) to visualize and analyze your simulation results