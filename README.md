# Fruit Hub 🍎🥭

Fruit Hub is a Flutter-based e-commerce mobile application that allows users to browse products, manage their cart, and complete purchases using online payment methods.

The app focuses on clean architecture, scalable state management, and smooth user experience.

---

## ✨ Features

- User authentication using Firebase Authentication
- Browse products with clean and responsive UI
- Product details view
- Cart management
- Secure checkout process
- Online payments using **Stripe** and **PayPal**
- Localization support
- Clean Architecture with separation of concerns
- Unit & Bloc testing for core logic

> Note:  
> This repository contains the **user-facing mobile application only**.  
> The admin/dashboard system is maintained in a separate repository.

---

## 🛠 Tech Stack

- **Flutter & Dart**
- **State Management:** Bloc / Cubit
- **Architecture:** Clean Architecture
- **Dependency Injection:** GetIt
- **Networking:** Dio (REST APIs)
- **Authentication:** Firebase Authentication
- **Database:** Cloud Firestore
- **Payments:** Stripe, PayPal
- **Environment Variables:** Envied
- **Local Storage:** SharedPreferences
- **Testing:** Unit Tests & Bloc Tests

---

## 🧱 Architecture Overview

The project follows **Clean Architecture** principles:

- **Presentation Layer**
  - UI (Screens)
  - Bloc / Cubit (State Management)

- **Domain Layer**
  - Entities
  - Use Cases
  - Repository Contracts

- **Data Layer**
  - Remote Data Sources (APIs, Firebase)
  - Repository Implementations
  - Models

This structure ensures scalability, testability, and maintainability.

---

## 🚀 Getting Started

 Clone the repository:
   ```bash
   git clone https://github.com/your-username/fruit-hub.git
