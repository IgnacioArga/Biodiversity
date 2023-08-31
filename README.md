## Biodiversity Data Visualization App

Welcome to the Biodiversity Data Visualization App repository! This Shiny application is designed to help you explore and visualize biodiversity observations sourced from the Global Biodiversity Information Facility (GBIF). The app allows you to interactively analyze occurrence sightings of flora and fauna, including information about species, location, date, and more. 

### Data Source

The biodiversity data used in this application is sourced from the **Global Biodiversity Information Facility (GBIF)**. It comprises a vast collection of occurrence records, including sightings of various species, each accompanied by details such as country, scientific name, common name, date, time, latitude, and longitude. The primary database table contains an impressive 39,969,765 rows and 37 columns.

### Application Overview

Upon accessing the application, you will be greeted with a login screen. Once your credentials are verified, the main Shiny dashboard will be displayed. In the sidebar, there are two tabItems, each representing a distinct module, and four actionable buttons. In the header there is a global filter, which allows you to dynamically modify the country being visualized in all the dashboard.

#### Module 1: Species Location

The first module focuses on presenting the geographical distribution of observation points. This module is divided into two subtabs:

1. **Geographic Map**: This tab displays a dynamic map with markers representing the observation locations. Each marker is color-coded based on the species observed. The map provides an intuitive visualization of the species distribution across different geographical regions.

2. **Detailed Table**: In this tab, a table is presented that provides detailed information about the observations. You can filter observations by species, whether by their scientific name or common name. The table can be customized and sorted according to your preferences.

#### Module 2: Time Line

The second module is designed to facilitate the analysis of sightings over time. You can explore observations based on different timeframes, such as year, month, or hour. This module also features filtering options similar to those in Module 1, allowing you to refine the data to your specific interests.

### Getting Started

To run the app locally, follow these steps:

1. Clone this repository to your local machine.
2. Ensure you have the necessary dependencies and packages installed (list them if applicable).
3. Run the R Shiny application file (provide file name and location).
4. Access the app through your web browser.

Feel free to explore the different modules, interact with the filters, and gain insights from the biodiversity data.

**Note:** Make sure to adhere to the usage terms and guidelines of the GBIF when utilizing the biodiversity data for your research or projects.

We hope you find this application informative and useful for your biodiversity exploration. If you encounter any issues or have suggestions for improvements, please feel free to open an issue or contribute to the repository.

Happy exploring! 🌿🦋🌎
