# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Porcelain is a 3D game engine written in Swift 5, built on Apple's Metal 2. It is structured as a reusable Swift framework (`Engine.framework`) consumed by game/demo projects.

## Commands

### Build

```bash
xcodebuild build -project Engine.xcodeproj -scheme Engine archive \
  -derivedDataPath /tmp/engine-build -configuration Release \
  -destination "generic/platform=macOS"
```

### Run All Tests

```bash
xcodebuild -project Engine.xcodeproj -scheme EngineTests test \
  -destination "platform=macOS"
```

### Run a Single Test

```bash
xcodebuild -project Engine.xcodeproj -scheme EngineTests test \
  -destination "platform=macOS" \
  -only-testing "EngineTests/TestClassName/testMethodName"
```

### Lint

```bash
swiftlint        # Swift lint (strict, 80+ opt-in rules)
yamllint .       # YAML files
mdl .            # Markdown files
```

## Architecture

### Rendering Pipeline

The engine uses a **deferred rendering pipeline** implemented in Metal. Shaders live in `Engine/Shaders/` and cover:

- PBR shading with normal mapping and translucency
- Shadow mapping for point, spot, and directional lights (PCF soft shadows)
- Post-processing: bloom, motion blur, film grain, vignette, distance fog
- SSAO, environment mapping, particle effects

### Scene Graph

Scenes are built from nodes in `Engine/Core/Organization/`. The scene graph supports skeletal animation, rigid body animation, and ray-traced bounds queries. `Engine/Core/Scene/` holds scene management, bounds computation, and ray intersection logic.

### Pipeline from Asset to Frame

- **Import** (`Engine/Core/Import/`) — USDZ models and height-map meshes are loaded via Model I/O.
- **Translation** (`Engine/Core/Translation/`) — Scene descriptions are validated and converted to render-ready representations with render masks.
- **Rendering** (`Engine/Core/Rendering/`) — The `Transcriber` drives the deferred pipeline each frame, consuming scene descriptions.
- **Buffers** (`Engine/Core/Buffers/`) — `DynamicBuffer` and `FlatTree` manage GPU-visible memory; `DataBuffer` wraps raw Metal buffers.

### Engine Entry Point

`PNEngine` / `PNIEngine` (in `Engine/Core/Engine/`) is the public interface integrators use to configure and tick the engine. A `RepeatableTaskQueue` (in `Engine/Core/Task/`) drives per-frame update tasks.

### Key Dependencies (Git Submodules)

- **DependencyGraph** — custom dependency injection used throughout the engine.
- **ZPack** — SIMD/Metal utility extensions (also exposed via `Engine/Core/Extensions/`).

### Platform Abstraction

`Engine/Core/UI/` provides platform-specific screen interaction helpers for both macOS (AppKit) and iOS/tvOS (UIKit), keeping the rest of the engine platform-agnostic.

### Code Style Constraints (SwiftLint)

- Line length warning at 160, error at 180.
- Function body warning at 150 lines, error at 200.
- Cyclomatic complexity max: 12.
- `// TODO:` comments and implicit unwrapped optionals are disabled in lint; avoid introducing them.
