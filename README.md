# PointerPilot

A macOS utility that enhances cursor visibility and control through visual highlighting and automated clicking.

## Features

- 🔍 Visual cursor highlighting with animated rings
- 🖱️ Automated clicking at specified intervals
- ⌨️ Global keyboard shortcuts for quick control
- 🎯 Precise cursor location testing
- 🔒 Secure permissions handling
- 🎨 Modern, unobtrusive UI

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later for development
- Swift 5.9 or later

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/PointerPilot.git
   cd PointerPilot
   ```

2. Open the project in Xcode:
   ```bash
   open PointerPilot.xcodeproj
   ```

3. Build and run the project (⌘R)

## Architecture

PointerPilot follows a clean architecture pattern with clear separation of concerns:

### Core Components

- `CursorHighlighter`: Manages visual cursor effects using Core Animation
- `ClickAutomator`: Handles automated clicking functionality
- `MenuBarManager`: Controls the menu bar interface
- `ShortcutManager`: Manages global keyboard shortcuts

### Services

- `LoggingService`: Centralized logging with structured output
- `AppServices`: Core application services and permissions

### View Layer

- `AppViewModel`: Main view model managing application state
- `HelpView`: User documentation and help interface
- `MenuBarView`: Status bar menu interface

## Development

### Setup

1. Install development tools:
   ```bash
   brew install swiftlint
   ```

2. Install git hooks:
   ```bash
   ./scripts/install-hooks.sh
   ```

### Code Style

The project uses SwiftLint to enforce consistent code style. Configuration is in `.swiftlint.yml`.

Key style points:
- Use 4 spaces for indentation
- Maximum line length of 120 characters
- Follow Swift API Design Guidelines
- Document all public interfaces

### Testing

The project includes three types of tests:

1. Unit Tests:
   ```bash
   xcodebuild test -scheme PointerPilot -destination 'platform=macOS'
   ```

2. UI Tests:
   ```bash
   xcodebuild test -scheme PointerPilotUITests -destination 'platform=macOS'
   ```

3. Performance Tests:
   ```bash
   xcodebuild test -scheme PointerPilot -destination 'platform=macOS' -only-testing:PointerPilotTests/PerformanceTests
   ```

### Logging

The application uses a centralized logging system:

```swift
let logger = LoggingService.shared.logger(for: .cursorHighlighter)
logger.debug("Operation started")
```

Log levels:
- `debug`: Development information
- `info`: General operational events
- `notice`: Important events
- `error`: Errors that need attention
- `fault`: Critical system failures

### Error Handling

Use the `AppError` type for all error cases:

```swift
throw AppError.invalidAnimationParameters("Size must be greater than 0")
```

Error handling guidelines:
1. Always provide meaningful error messages
2. Include recovery suggestions
3. Log all errors appropriately
4. Present user-friendly error alerts

## Memory Management

The application uses ARC with careful attention to retain cycles:

1. Use `weak self` in closures
2. Implement proper cleanup in `deinit`
3. Use autorelease pools for resource-intensive operations
4. Monitor memory usage with logging

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Core Animation Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos/overview/themes/)
- The Swift community for their invaluable resources and tools 