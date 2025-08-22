# Shared Electricity Bill Calculator

Fairly and accurately split your electricity bill among roommates or family members in seconds! This app takes the guesswork out of sharing costs by calculating each person's share based on their individual meter readings. Keep track of your monthly usage and payments with the built-in history feature to see your energy consumption over time.

---

## 📸 Screenshots

| Calculator Page | Past Reports Page |
| :-------------: |:-------------:|
| ![Calculator Page](screenshots/main_calculator_screen.png) | ![Reports Page](screenshots/reports_page_yearly.png) |

---

## 📖 How to Use This App

Getting started is simple! Follow these three easy steps to calculate and save your bill:

**Step 1: Select the Billing Period**
*   Choose the correct **Month** and **Year** for the bill you are calculating using the dropdown menus at the top.

**Step 2: Enter the Bill Details**
*   **Total Units (KWh):** Enter the total kilowatt-hours used for the entire household, as shown on your official electricity bill.
*   **Your New Meter Reading:** Enter the current reading from your personal sub-meter.
*   **Your Old Meter Reading:** Enter the reading from your sub-meter from the previous month.
*   **Total Bill Amount (₹):** Enter the total amount of the electricity bill that needs to be paid.

**Step 3: Calculate and View Your Share**
*   Tap the **"Calculate & Save"** button.
*   The app will instantly display **Your Share** of the bill in the results card, along with a clear summary of how it was calculated. Your result is automatically saved for future reference.

**Viewing Your History:**
*   To see your past payments and usage, simply tap the **"View Past Reports"** button. Here, you can filter by year to see a complete history and a summary of your total annual costs.

---

## ✨ Features

-   **Fair Bill Splitting:** Calculates your exact share of the total bill based on the units you consumed.
-   **Historical Tracking:** Automatically saves each month's calculation to a persistent history.
-   **Annual Reports:** A dedicated "Past Reports" page to view all saved data, filterable by year.
-   **Yearly Summary:** Instantly see your total units consumed and total amount paid for any selected year.
-   **Modern UI:** A clean, responsive, and modern user interface with a dark theme.
-   **Data Persistence:** Your data is saved locally on your device using `shared_preferences`, so it's always there when you come back.
-   **Input Validation:** Robust error handling to prevent incorrect calculations.
-   **User-Friendly Inputs:** Uses dropdowns for month and year selection to minimize errors.

---

## 🚀 Getting Started (for Developers)

To get a local copy up and running, follow these simple steps.

### Prerequisites

-   You must have [Flutter](https://flutter.dev/docs/get-started/install) installed on your machine.

### Installation

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/ravikrsna9/Electricity-Bill-Splitter.git
    ```
2.  **Navigate to the project directory:**
    ```sh
    cd Electricity-Bill-Splitter
    ```
3.  **Install dependencies:**
    ```sh
    flutter pub get
    ```
4.  **Run the app:**
    ```sh
    flutter run
    ```

---

## 🔧 Built With

This project utilizes a variety of modern tools and packages:

-   **[Flutter](https://flutter.dev/)** - The UI toolkit for building beautiful, natively compiled applications.
-   **[Dart](https://dart.dev/)** - The programming language used.
-   **[shared_preferences](https://pub.dev/packages/shared_preferences)** - For saving key-value data persistently on the device.
-   **[intl](https://pub.dev/packages/intl)** - For date formatting.
-   **[url_launcher](https://pub.dev/packages/url_launcher)** - For opening external links.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


Designed & Developed by GOSIDDHI INFOTECH