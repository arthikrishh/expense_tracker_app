Expense Tracker App

A comprehensive Flutter-based Expense Tracking Application designed to help users manage their personal finances efficiently.

Built with Material Design 3, Provider state management, and SQLite local persistence, this app delivers a smooth, responsive, and scalable financial management experience.

🚀 Project Overview

The Expense Tracker App enables users to:

Track daily expenses

Categorize spending

Visualize spending trends

Manage financial data locally

Switch between light & dark themes

The app follows clean architecture principles with a modular folder structure, making it scalable and maintainable.

🏗️ Architecture & Tech Stack
🛠 Core Technologies

Flutter SDK – Cross-platform mobile development framework

Provider (v6.1.1) – State management

SQLite – Local database storage

SharedPreferences – Persistent app settings

FL Chart (v0.66.0) – Data visualization (Pie charts)

Intl – Date & currency formatting

UUID – Unique identifier generation

📂 Project Structure
lib/
│
├── models/
├── database/
├── providers/
├── screens/
├── widgets/
├── utils/
└── main.dart

📦 Models Layer
1️⃣ Category Model

Represents expense categories.

Fields:

id – Unique identifier

name – Category name (Food, Transport, etc.)

color – UI color representation

icon – Emoji/icon for identification

Includes:

toMap()

fromMap()

2️⃣ Expense Model

Represents an individual expense entry.

Fields:

id

title

amount

date

categoryId

notes

receiptUrl

Includes database conversion utilities.

🗄️ Database Layer
Database Helper (Singleton Pattern)

Manages:

Database initialization

Table creation

CRUD operations

Pre-population of default categories

📋 Database Schema
Categories Table
Column	Type
id	TEXT (PK)
name	TEXT
color	INTEGER
icon	TEXT
Expenses Table
Column	Type
id	TEXT (PK)
title	TEXT
amount	REAL
date	TEXT
categoryId	TEXT (FK)
notes	TEXT
receiptUrl	TEXT
🔄 Providers Layer
ExpenseProvider

Handles all expense-related logic:

Load data

Add expense

Update expense

Delete expense

Monthly filtering

Category-wise aggregation

Uses notifyListeners() for real-time UI updates.

ThemeProvider

Light/Dark/System theme support

Persistent theme preference

Instant theme switching

🖥️ Screens
🏠 Home Screen

Total Expense Summary

Current Month Summary

Expense List (chronological)

Pull-to-refresh

Add Expense FAB

Navigation to:

Statistics

Settings

➕ Add/Edit Expense Screen

Includes:

Title input (required)

Amount input (validated)

Date picker

Category selector grid

Notes field (optional)

Validation Rules:

Title required

Positive amount only

Category selection mandatory

📊 Statistics Screen

Period filter (Week / Month / Year)

Summary cards

Pie chart visualization

Category breakdown

Navigation between periods

⚙️ Settings Screen

Dark mode toggle

Data management options

Backup/Restore (future-ready)

Clear all data

App version info

🎯 Key Features
✅ Expense Management

Create expenses

Edit expenses

Delete with confirmation

Real-time UI updates

✅ Categorization

8 predefined categories

Color-coded UI

Icon-based identification

✅ Data Visualization

Pie charts

Category distribution

Monthly expense summary

Progress indicators

✅ Persistent Storage

SQLite database

Local data saving

Theme preference storage

✅ UI/UX Excellence

Material Design 3

Responsive layout

Smooth animations

Dark/Light theme

🔁 Data Flow
User Action
    ↓
Provider Method
    ↓
Database Operation
    ↓
notifyListeners()
    ↓
UI Rebuild

⚡ Performance Optimizations

Lazy loading

Efficient ListView.builder

Optimized database queries

Controlled widget rebuilds using Consumer

🔒 Security & Data Integrity

Input validation

Foreign key constraints

Confirmation dialogs before delete

Try-catch error handling

📱 Platform Support

✅ Android

✅ iOS

✅ Web (basic support)

✅ Desktop (experimental)

🎨 UI/UX Principles

Consistency in design

Immediate visual feedback

Accessible text & contrast

Minimal tap interaction

Clean navigation flow

📈 Scalability

Modular architecture

Provider-based state management

Optimized database schema

Easily extendable for:

Cloud sync

Budget limits

Recurring expenses

Multi-currency

Biometric lock

Reports (PDF/Excel)

🛠️ Installation
1️⃣ Clone the repository
git clone https://github.com/your-username/expense-tracker.git

2️⃣ Navigate to project folder
cd expense-tracker

3️⃣ Install dependencies
flutter pub get

4️⃣ Run the app
flutter run

📦 Dependencies
provider: ^6.1.1
fl_chart: ^0.66.0
intl:
uuid:
shared_preferences:
sqflite:
path_provider:

📌 Future Enhancements

☁️ Cloud sync (Firebase integration)

📊 Budget tracking & alerts

🧾 Receipt image capture

📑 PDF & Excel reports

🔁 Recurring expenses

💱 Multi-currency support

🔐 Biometric authentication

🔔 Smart notifications

📈 AI-powered spending insights

👥 Target Users

Individuals managing personal finances

Students tracking monthly budgets

Freelancers tracking business expenses

Families monitoring shared expenses

Travelers managing trip expenses

⭐ Contribution

Contributions, issues, and feature requests are welcome!

If you like this project, please give it a ⭐ on GitHub.

💡 Final Note

This project demonstrates:

Clean architecture

Proper state management

Database integration

Professional UI/UX implementation

Scalable Flutter development practices

It serves as a strong portfolio project showcasing real-world Flutter application development.
