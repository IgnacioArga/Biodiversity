# Biodiversity Data Visualization App

Welcome to the Biodiversity Data Visualization App repository! This Shiny application is designed to help you explore and visualize biodiversity observations sourced from the Global Biodiversity Information Facility (GBIF). The app allows you to interactively analyze occurrence sightings of flora and fauna, including information about species, location, date, and more. 

## Data Source

The biodiversity data used in this application is sourced from the **Global Biodiversity Information Facility (GBIF)**. It comprises a vast collection of occurrence records, including sightings of various species, each accompanied by details such as country, scientific name, common name, date, time, latitude, and longitude. The primary database table contains an impressive 39,969,765 rows and 37 columns.

## Application Overview

Upon accessing the application, you will be greeted with a login screen. Once your credentials are verified, the main Shiny dashboard will be displayed. In the sidebar, there are two tabItems, each representing a distinct module, and four actionable buttons. In the header there is a global filter, which allows you to dynamically modify the country being visualized in all the dashboard.

### Module 1: Species Location

The first module focuses on presenting the geographical distribution of observation points. This module is divided into two subtabs:

1. **Geographic Map**: This tab displays a dynamic map with markers representing the observation locations. Each marker is color-coded based on the species observed. The map provides an intuitive visualization of the species distribution across different geographical regions.

2. **Detailed Table**: In this tab, a table is presented that provides detailed information about the observations. You can filter observations by species, whether by their scientific name or common name. The table can be customized and sorted according to your preferences.

### Module 2: Time Line

The second module is designed to facilitate the analysis of sightings over time. You can explore observations based on different timeframes, such as year, month, or hour. This module also features filtering options similar to those in Module 1, allowing you to refine the data to your specific interests.

## Extras Utilized

### 1. Beautiful UI Skill

The UI of this application has been enhanced using CSS to provide an appealing and user-friendly experience:

- **Login Page Styling**: The login page is styled using CSS, featuring a background image with a caption. Additionally, the rest of the dashboard is hidden to prevent access without successful login. This approach ensures that even if users attempt to modify the HTML and CSS from their browser, access to the dashboard's information remains restricted.

- **Sidebar Icon Formatting**: The icons within the sidebar have been formatted to function seamlessly when the sidebar is collapsed.

- **Font Customization**: The font across the entire dashboard has been modified to create a cohesive visual identity.

### 2. Performance Optimization Skill

To optimize the performance of the application, the following strategies were employed:

- **Working with Full Data**: The application works with the entirety of the dataset. The data was imported into Google Cloud Platform's BigQuery via Cloud Storage, utilizing a project in GCP.

- **Utilizing Google BigQuery**: To establish a connection between Shiny and BigQuery, a service account for BigQuery with data editor and data viewer roles was created. The corresponding key was downloaded and stored securely within the app's 'gcp' folder. The `bigrquery` and `pool` packages were employed to facilitate a connection to the database.

- **Two-Stage Filtering**: To enhance the app's responsiveness, filtering was divided into two stages. The first stage involves the global filter for countries. Upon modification, it recalculates information specific to the chosen country. Simultaneously, filtering by species is performed using the available country-specific information. This approach significantly improves dashboard performance, particularly when filtering by species or using timeline filters.

### 3. JavaScript Skill

JavaScript was incorporated to address specific UI elements that couldn't be easily achieved through Shiny alone:

- **Dynamic UI Elements**: JavaScript was used to dynamically insert HTML elements into the UI. For example, the login modal's title and caption were added using JavaScript after the login modal UI had loaded.

- **Visibility Toggle**: JavaScript was employed to toggle the visibility of the sidebar and header after successful login.

- **Enhanced User Experience**: JavaScript enables users to press the 'Enter' key during login, treating it as a confirmation button click for a smoother user experience.

### 4. Infrastructure Skill

Infrastructure skills were employed to ensure efficient deployment and scaling of the application:

- **Docker and Cloud Build**: A Docker container was created and built using Cloud Build. The deployment was managed through Cloud Run. Files like `Dockerfile` and `cloudbuild.yml` were used in this process.

- **Cloud Run Deployment**: The application was deployed on Cloud Run, leveraging the built Docker container. This method provides a scalable and efficient environment for hosting the application.

- **Deployment Considerations**: While the application is available for viewing on Shiny.io, it's worth noting that challenges were encountered when deploying the container with a restored `renv` library environment. Due to these challenges, the application is currently accessible via a Shiny.io link.

Feel free to explore the rich features of this application, designed with attention to aesthetics, performance, and user interaction. If you have any feedback or encounter any issues, please consider contributing or opening an issue in this repository. Your insights are valuable in further enhancing this biodiversity data visualization tool.

## Getting Started

To run the app locally, follow these steps:

1. Clone this repository to your local machine.
2. Run the R Shiny application file clicking Run App (the libreries will be restored automaticaly from renv.lock, may be you will need to concent de restore in your console).
3. If you can't connect to bigquery it should be becouse I will have cleaned the connection key ($$$). If you want to use the code you should follow the steps to configurate BigQuery that I said before. 
4. Access the app through your web browser.

Feel free to explore the different modules, interact with the filters, and gain insights from the biodiversity data.

If you want to test the dashboard you can get into the next link:
https://ignacioarganaraz.shinyapps.io/Biodiversity/
* user: appsilon
* pass: testing

Happy exploring! 🌿🦋🌎
