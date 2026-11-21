# Contributing to android_device_samsung_a02q

Thank you for considering contributing to this TWRP device tree for the Samsung Galaxy A02s (SM-A025F).

## How to Contribute

1. **Fork** this repository.
2. **Clone** your fork:
   ```bash
   git clone https://github.com/<your-username>/android_device_samsung_a02q.git
   cd android_device_samsung_a02q
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Make your changes** and test them on a real device if possible.
5. **Commit** with a clear message:
   ```bash
   git commit -m "feat: describe your change"
   ```
6. **Push** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Open a Pull Request** against the `main` branch of this repository.

## Code Style

- Follow existing AOSP/TWRP Makefile conventions.
- Keep comments in English where possible for broader collaboration.
- Do not commit secrets (keys, tokens, passwords).
- Prebuilt binaries (kernel, dtb, dtbo, mkbootimg, firmware blobs) should be documented in `prebuilt/README.md`.

## Testing

- Build using the GitHub Actions workflow or locally with `make recoveryimage`.
- Flash to a test device with an unlocked bootloader.
- Verify touch, display, brightness, and partition mounts before reporting success.

## Reporting Issues

Use the issue templates under `.github/ISSUE_TEMPLATE/`. Include:
- Device model and firmware version
- Steps to reproduce
- Logcat or build error output
- What you expected vs. what happened

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).