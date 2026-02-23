# Automated Vermicomposting - Flutter App

A **Flutter** application designed to monitor and control an **Automated Vermicomposting System**.  
The app provides **real-time sensor data**, interactive controls, real-time inference and thermal monitoring video feed, and advanced analytics.  
It integrates with **Supabase** for persistent data storage and **HiveMQ MQTT** for real-time messaging between the mobile app, Raspberry Pi, and Arduino controllers.

## Features

- **Real-Time Monitoring**
    - Live sensor readings (**temperature**, **humidity**, **NPK**, **load cells**, **thermal camera**, **reservoir** and **vermitea** levels).
    - Dynamic dashboards and visual analytics.

- **System Control**
    - Toggle pumps, fans, misting, and conveyor/rake/sifter mechanisms.
    - Adjust Raspberry Pi board configurations and system settings.

- **Composting Management**
    - Create, update, and track composting schedules (CRUD operations).
    - Monitor compost production progress.

- **Calibration & Configuration**
    - Calibrate load cells directly from the app.
    - Modify sensor reading intervals and other board parameters.

- **Data & Notifications**
    - Store sensor logs, schedules, and operational history in **Supabase**.
    - Receive push notifications for system alerts or threshold breaches.

## Architecture Overview

```
         ┌─────────────────────────┐
         │     Flutter App         │
         │ (BLoC State Management) │
         └───────────┬─────────────┘
                     │ MQTT (HiveMQ)
                     ▼
        ┌─────────────────────────┐
        │    Raspberry Pi         │
        │  (Python services)      │
        └────────────┬────────────┘
                     │
           ┌──────────────────┐
           │ Serial    Serial │
           ▼                  ▼
    ┌─────────────┐    ┌──────────────┐
    │ Arduino Uno │    │ Arduino Mega │
    └─────────────┘    └──────────────┘
            │                 │ 
            └─────────────────┘
                     │
                     ▼
          ┌─────────────────────────┐
          │ Supabase (DB & Storage) │
          └─────────────────────────┘
```

- **Flutter + BLoC**: Manages app state and business logic.
- **HiveMQ MQTT Broker**: Handles low-latency messaging between mobile client and hardware.
- **Supabase**: Stores logs, schedules, notifications, sensor readings, etc.

## Tech Stack

| Layer                | Technology                     |
|----------------------|--------------------------------|
| Mobile App           | Flutter (Dart)                 |
| State Management     | BLoC                           |
| Realtime Messaging   | HiveMQ MQTT                    |
| Database & Storage   | Supabase                       |
| CRUD API             | Cloudflare Workers             |
| Backend Integration  | Raspberry Pi (Python services) |
| Hardware Controllers | Arduino Mega & Arduino Uno     |

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- An active **Supabase** project (URL and service key)
- Access to a **HiveMQ MQTT broker**
- Raspberry Pi and Arduino boards running the companion control firmware.

### Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/bnckmnlt/verminator_flutter.git
   cd verminator_flutter
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure environment:
    - Create a `.env` file and use `flutter_dotenv` to provide:
        - `HIVEMQ_CLUSTER_IDENTIFIER`
        - `HIVEMQ_CLUSTER_URL`
        - `HIVEMQ_CLUSTER_PORT`
        - `HIVEMQ_CLUSTER_USERNAME`
        - `HIVEMQ_CLUSTER_PASSWORD`
        - `SUPABASE_URL`
        - `SUPABASE_ANONKEY`
        - `DOMAIN_URL`

4. Run the app:
   ```bash
   flutter run
   ```

## Key Modules

| Module                   | Description                                                                                        |
|--------------------------|----------------------------------------------------------------------------------------------------|
| **Home Screen**          | Displays real-time sensor data with brief charts and analytics as well as the realtime video feed. |
| **Schedule List**        | CRUD operations for composting schedule list and progress tracking.                                |
| **Control Screen**       | Allows toggling of pumps, fans, misting, and other actuators.                                      |
| **Notifications & Logs** | Stores sensor logs, progress and status changes, and sends alerts through Supabase.                |
| **Settings**             | Raspberry Pi board configuration, sensor interval adjustments, and load cell calibration.          |

## Development Notes
- **BLoC pattern** is used for scalable, testable state management.
- Sensor updates and control commands flow through **MQTT** topics subscribed/published by the app.
- Supabase functions and real-time capabilities enable persistent data storage and notifications.

## Android/Gradle Troubleshooting

### Common Issues
- **Gradle Version Mismatch**: If you encounter errors related to Gradle version incompatibilities, update the Gradle plugin in `android/build.gradle` and the Gradle wrapper in `android/gradle/wrapper/gradle-wrapper.properties`.
- **Android SDK Updates**: Ensure you have the latest Android SDK installed via Android Studio's SDK Manager. Missing SDK components may cause build failures.
- **Cleaning and Rebuilding**: Run `flutter clean` followed by `flutter pub get` to clear old build artifacts.
- **JDK Version**: Verify the correct JDK version (e.g., Java 17 for Flutter 3.x) is installed and configured.

### Useful Commands
```bash
flutter doctor
flutter clean
flutter pub get
```

## License
This project is licensed under the MIT License.  
See [LICENSE](LICENSE) for details.

## Author
Developed and maintained by Think I/O.
