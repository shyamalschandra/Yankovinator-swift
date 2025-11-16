# Yankovinator GitHub Pages

This directory contains the source files for the Yankovinator GitHub Pages website.

## Structure

- `index.html` - Main HTML page
- `styles.css` - CSS styles and animations
- `script.ts` - TypeScript source for interactivity
- `script.js` - Compiled JavaScript (generated, do not edit)

## Development

### Prerequisites

- Node.js 20 or later
- npm

### Setup

```bash
npm install
```

### Build

```bash
npm run build
```

This compiles `script.ts` to `script.js`.

### Watch Mode

```bash
npm run watch
```

This will automatically recompile TypeScript on file changes.

## Deployment

The website is automatically deployed to GitHub Pages via GitHub Actions when changes are pushed to the `main` branch. The workflow:

1. Checks out the repository
2. Sets up Node.js
3. Installs dependencies
4. Builds TypeScript
5. Deploys to GitHub Pages

## Features

- **Interactive UI**: TypeScript-powered interactivity with smooth animations
- **SVG Animations**: Animated background elements and icons
- **Responsive Design**: Works on desktop and mobile devices
- **Modern Styling**: Gradient effects, glow animations, and 3D transforms
- **Smooth Scrolling**: Enhanced navigation experience

## Technologies

- HTML5
- CSS3 (with animations and transforms)
- TypeScript
- SVG (for animations and icons)
- GitHub Actions (for CI/CD)
