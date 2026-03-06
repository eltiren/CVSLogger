# CLAUDE.md — CVSLogger

## Project Overview

CVSLogger is a lightweight Swift logging library that outputs logs in CSV format, built on top of [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack). It provides structured, parseable log files with columns: `date,category,level,file,function,message,object`.

## Build & Test

```bash
# Build
swift build

# Run tests
swift test

# Resolve dependencies
swift package resolve
```

- **Swift Tools Version**: 5.10+
- **Package Manager**: Swift Package Manager (SPM)
- **Dependency**: CocoaLumberjack 3.8.0+ (uses `CocoaLumberjackSwift` product)

## Project Structure

```
Sources/CVSLogger/
  CVSLogger.swift       # Entire library implementation (single file)
Tests/CVSLoggerTests/
  CVSLoggerTests.swift  # Test target (minimal)
Package.swift           # SPM manifest
```

## Architecture

All code lives in a single file (`Sources/CVSLogger/CVSLogger.swift`):

- **`CVSLogger` (enum)** — Public namespace and factory. Provides `CVSLogger.default` singleton and `createLogger(subsystem:category:spamToXcode:)` factory method. Manages a shared `DDFileLogger` instance.
- **`CVSLog` (class)** — Public subclass of `DDLog`. Exposes logging methods (`verbose`, `info`, `debug`, `warning`, `error`) with consistent signatures using `#file`/`#function`/`#line` defaults.
- **`CSVFileManager` (private class)** — Extends `DDLogFileManagerDefault` to inject the CSV header row.
- **`CSVFormatter` (private class)** — Implements `DDLogFormatter` to convert log messages into CSV-escaped strings.

## Code Conventions

- **Access control**: Public API types are `CVSLogger` (enum) and `CVSLog` (class). Internal helpers (`CSVFileManager`, `CSVFormatter`) are private/internal.
- **Naming**: Public methods use short names (`verbose`, `info`, `debug`, `warning`, `error`). Private helpers use `CSV` prefix.
- **Pattern**: All log-level methods delegate to a single private `addLogItem(...)` method.
- **CSV escaping**: Double quotes are escaped as `""` per the CSV standard.
- **Logging is asynchronous**: All messages are dispatched with `asynchronous: true`.
- **File rolling**: Logs roll every 24 hours, retaining up to 7 files.

## Key Things to Know

- The library has no platforms restriction in `Package.swift` but depends on `Bundle.main.bundleIdentifier!` (force-unwrapped), so it targets iOS/macOS app contexts.
- `CVSLogger.default` uses `"default"` as the category and the main bundle identifier as the subsystem.
- The `representedObject`/`tag` field on `DDLogMessage` carries a dictionary with `"category"` and optionally `"object"`.
- Tests are minimal (placeholder only) — no real test coverage exists yet.
- No CI/CD pipeline is configured.
- No linter configuration (e.g., SwiftLint) is present.
