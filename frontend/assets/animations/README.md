# Animation Files

This directory should contain the following Lottie animation files:

1. `loading.json` - A loading spinner animation used during key/DID creation and voice verification
2. `success.json` - A success checkmark animation shown when voice identity is created

You can download free Lottie animations from:
- [LottieFiles](https://lottiefiles.com/)
- [Icons8](https://icons8.com/animated-icons)

After downloading, place the JSON files in this directory and ensure they are named correctly as mentioned above.

## Adding to pubspec.yaml

Make sure your pubspec.yaml includes these assets:

```yaml
flutter:
  assets:
    - assets/animations/loading.json
    - assets/animations/success.json
```