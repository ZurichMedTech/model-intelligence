# Model Intelligence Documentation

Documentation for Sim4Life's Model Intelligence framework - advanced meta-modeling tools that transform computationally intensive simulations into fast, accurate mathematical surrogates for bioelectronic applications.

## Overview

This MkDocs site documents the Model Intelligence HyperTools suite, including Response Surface Modeling (RSM) and Uncertainty Quantification (UQ) capabilities. The framework enables rapid parameter exploration, sensitivity analysis, and design optimization for complex bioelectronic simulations.

## Development Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/ZurichMedTech/model-intelligence.git
   cd model-intelligence
   ```
2. Set up the development environment:
   ```bash
   make devenv
   ```

3. Serve documentation locally:
   ```bash
   make serve
   ```
   Available at `http://0.0.0.0:8001/` with auto-reload enabled.

## Building & Deployment

4. Build the documentation:
```bash
make build
```

5. Deploy to GitHub Pages:
```bash
make gh-deploy
```

This command builds the site and pushes it to the `gh-pages` branch of your repository.

## GitHub Pages Setup

1. Push your latest changes to GitHub

2. Navigate to your repository on GitHub > Settings > Pages:
   - Source: Deploy from a branch
   - Branch: gh-pages
   - Folder: / (root)
   - Click Save

After deployment, the live documentation will be available at: https://ZurichMedTech.github.io/model-intelligence/
