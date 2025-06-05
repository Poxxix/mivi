# Mivi - Modern Movie App

A beautiful and modern Flutter movie app with a scalable architecture, ready for Firebase and TMDB API integration.

## Features

- 🎬 Browse movies by categories (Trending, Popular, Top Rated)
- 🔍 Search movies with filters
- ❤️ Save favorite movies
- 👤 User profile and settings
- 🎨 Modern dark theme UI
- 📱 Responsive design for all screen sizes

## Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/mivi.git
cd mivi
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_dimensions.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
├── data/
│   ├── models/
│   │   ├── movie_model.dart
│   │   └── genre_model.dart
│   └── mock_data/
│       └── mock_movies.dart
├── presentation/
│   ├── screens/
│   │   ├── home/
│   │   ├── movie_detail/
│   │   ├── search/
│   │   ├── favorites/
│   │   └── profile/
│   ├── widgets/
│   │   ├── common/
│   │   ├── movie_card.dart
│   │   ├── movie_slider.dart
│   │   └── custom_app_bar.dart
│   └── navigation/
│       └── app_router.dart
└── services/
    └── (placeholder for Firebase & API services)
```

## Architecture

The app follows Clean Architecture principles with a clear separation of concerns:

- **Presentation Layer**: UI components, screens, and widgets
- **Domain Layer**: Business logic and use cases
- **Data Layer**: Data sources, repositories, and models

## Dependencies

- **State Management**: Provider
- **Navigation**: Go Router
- **UI Components**: Material Design 3
- **Networking**: (Prepared for Dio)
- **Storage**: (Prepared for Firebase)
- **Images**: Cached Network Image
- **Fonts**: Google Fonts (Poppins)

## Future Integrations

- Firebase Authentication
- Firestore for user data
- TMDB API for movie data
- Push Notifications
- Offline Support
- Video Player Integration

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [TMDB](https://www.themoviedb.org/) for movie data
- [Flutter](https://flutter.dev/) for the amazing framework
- [Material Design](https://material.io/) for design guidelines
