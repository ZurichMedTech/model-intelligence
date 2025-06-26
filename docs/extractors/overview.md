# Extractors Overview

## What are Extractors?

Extractors are components of the Sim4Life Plugin Framework that enable visualization and analysis of simulation results. They take raw simulation output data and transform it into meaningful visual representations and quantitative metrics that help users understand the physics being simulated.

---

## Computational Flow

The main steps in the extractor's operation are:

- **DoComputeOutputAttributes**: This method is called to prepare the extractor before any data is requested. It sets up the output ports, loads metadata, and ensures that the extractor is ready to provide results.

- **DoComputeOutputData**: This method is called when the postprocessing pipeline requests data for a specific output port. It performs the actual extraction and data loading for the requested result, such as reading a field or summary from disk.

- **GetOutputDataObject**: This method returns the data object for a specific output port. It is used by Sim4Life to retrieve the results (such as a field or table) for visualization or further analysis.

These methods ensure that extractors can efficiently and reliably bring simulation results into the Sim4Life postprocessing pipeline.

---

## Next Steps

- [Creating an Extractor](creating-extractor.md)
