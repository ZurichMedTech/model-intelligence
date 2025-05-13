# s4l-plugins-documentation
Comprehensive Documentation for the Sim4Life Simulator Plugin Framework

## Overview

This repository contains the documentation for the Sim4Life Simulator Plugin Framework. The documentation is built using MkDocs with the Material theme.

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/s4l-plugins-documentation.git
   cd s4l-plugins-documentation
   ```

2. Set up the development environment:
   ```bash
   make devenv
   ```
   This will create a virtual environment and install all required packages.

## Local Development

To serve the documentation locally during development:
```bash
make serve
```

This will start a local development server at `http://127.0.0.1:8000/` with auto-reload enabled.

## Building the Documentation

To build the documentation site:
```bash
make build
```

This will create a `site` directory with the built HTML files.

## Deploying to GitHub Pages

Before deploying, make sure to update the repository URL in `mkdocs.yml` with your actual GitHub username:
- Update `site_url` to `https://yourusername.github.io/s4l-plugins-documentation/`
- Update `repo_url` to `https://github.com/yourusername/s4l-plugins-documentation`

To deploy the documentation to GitHub Pages:
```bash
make gh-deploy
```

This command builds the site and pushes it to the `gh-pages` branch of your repository.

## GitHub Pages Setup

1. Push your repository to GitHub:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/yourusername/s4l-plugins-documentation.git
   git push -u origin main
   ```

2. Navigate to your repository on GitHub > Settings > Pages:
   - Source: Deploy from a branch
   - Branch: gh-pages
   - Folder: / (root)
   - Click Save

After deployment, your documentation will be available at `https://yourusername.github.io/s4l-plugins-documentation/`.
