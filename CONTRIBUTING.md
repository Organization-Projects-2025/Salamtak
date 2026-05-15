# Contributing to Salamtak

First off, thank you for considering contributing to Salamtak! It's people like you that make Salamtak such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps which reproduce the problem**
* **Provide specific examples to demonstrate the steps**
* **Describe the behavior you observed after following the steps**
* **Explain which behavior you expected to see instead and why**
* **Include screenshots and animated GIFs** if possible
* **Include your environment details** (OS, Flutter version, device, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title**
* **Provide a step-by-step description of the suggested enhancement**
* **Provide specific examples to demonstrate the steps**
* **Describe the current behavior** and **explain which behavior you expected to see instead**
* **Explain why this enhancement would be useful**

### Pull Requests

* Fill in the required template
* Do not include issue numbers in the PR title
* Follow the Dart/Flutter style guide
* Include screenshots and animated GIFs in your pull request whenever possible
* End all files with a newline
* Avoid platform-dependent code

## Development Setup

1. **Fork the repository** and clone your fork
   ```bash
   git clone https://github.com/YOUR-USERNAME/Salamtak.git
   cd Salamtak
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Create a branch** for your changes
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Make your changes** and test thoroughly
   ```bash
   flutter test
   flutter analyze
   ```

5. **Commit your changes** with a descriptive commit message
   ```bash
   git commit -m "Add feature: description of your feature"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Open a Pull Request** from your fork to the main repository

## Style Guidelines

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line
* Consider starting the commit message with an applicable emoji:
    * 🎨 `:art:` when improving the format/structure of the code
    * 🐎 `:racehorse:` when improving performance
    * 📝 `:memo:` when writing docs
    * 🐛 `:bug:` when fixing a bug
    * 🔥 `:fire:` when removing code or files
    * ✅ `:white_check_mark:` when adding tests
    * 🔒 `:lock:` when dealing with security
    * ⬆️ `:arrow_up:` when upgrading dependencies
    * ⬇️ `:arrow_down:` when downgrading dependencies

### Dart/Flutter Style Guide

* Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
* Use `flutter format` before committing
* Run `flutter analyze` and fix all issues
* Write meaningful variable and function names
* Add comments for complex logic
* Keep functions small and focused
* Use const constructors where possible

### Code Organization

* Place new screens in `lib/screens/`
* Place new widgets in `lib/widgets/`
* Place new models in `lib/models/`
* Place new services in `lib/services/`
* Place new providers in `lib/providers/`

## Testing

* Write unit tests for new features
* Ensure all tests pass before submitting PR
* Aim for high code coverage
* Test on multiple platforms when possible

```bash
flutter test
```

## Documentation

* Update README.md if you change functionality
* Update CHANGELOG.md following the Keep a Changelog format
* Add inline documentation for public APIs
* Update relevant documentation in `/docs` if applicable

## Questions?

Feel free to open an issue with your question or reach out to the maintainers.

## Recognition

Contributors will be recognized in our README.md file and release notes.

Thank you for contributing! 🎉
