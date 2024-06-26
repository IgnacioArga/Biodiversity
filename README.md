# Biodiversity Data Visualization App

Welcome to the Biodiversity Data Visualization App repository! This Shiny application is designed to help you explore and visualize biodiversity observations sourced from the Global Biodiversity Information Facility (GBIF). The app allows you to interactively analyze occurrence sightings of flora and fauna, including information about species, location, date, and more. 

## Table of Contents

- [Data Source](#data-source)
- [Application Overview](#application-overview)
  - [Module 1: Login](#module-1-login)
  - [Module 2: Species Location](#module-2-species-location)
  - [Module 3: Time Line](#module-3-time-line)
- [Extras Utilized](#extras-utilized)
  - [1. Beautiful UI Skill](#1-beautiful-ui-skill)
  - [2. Performance Optimization Skill](#2-performance-optimization-skill)
  - [3. JavaScript Skill](#3-javascript-skill)
  - [4. Infrastructure Skill](#4-infrastructure-skill)
- [Next Steps](#next-steps)
  - [1. Refine Deployment and Infrastructure](#1-refine-deployment-and-infrastructure)
  - [2. Optimize Data Sources and Authentication](#2-optimize-data-sources-and-authentication)
  - [3. Multimedia Integration](#3-multimedia-integration)
- [Getting Started](#getting-started)

## Data Source

The biodiversity data used in this application is sourced from the **Global Biodiversity Information Facility (GBIF)**. It comprises a vast collection of occurrence records, including sightings of various species, each accompanied by details such as country, scientific name, common name, date, time, latitude, and longitude. The primary database table contains an impressive 39,969,765 rows and 37 columns.

## Application Overview

Upon accessing the application, you will be greeted with a login screen. Once your credentials are verified, the main Shiny dashboard will be displayed. In the sidebar, there are two tabItems, each representing a distinct module, and four actionable buttons. In the header there is a global filter, which allows you to dynamically modify the country being visualized in all the dashboard.

### Module 1: Login

The login module acts as the app's entry point, verifying user credentials against the database for secure access. Its functionality includes:

- **Authentication**: Users input their username and password.
- **Credential Verification**: Entered credentials are checked against the database.
- **Access Control**: Successful login grants access to the main dashboard.
- **Error Handling**: Incorrect credentials trigger a modal error message.
- **Reactive Control**: Main dashboard content loads only after successful login.

The module ensures secure data access, requiring valid credentials before users can interact with biodiversity data. 
![image](https://github.com/IgnacioArga/Biodiversity/assets/62559949/f4412242-b1b2-4942-8b56-461a6ce4658e)

### Module 2: Species Location

The first module focuses on presenting the geographical distribution of observation points. This module is divided into two subtabs:

1. **Geographic Map**: This tab displays a dynamic map with markers representing the observation locations. Each marker is color-coded based on the species observed. The map provides an intuitive visualization of the species distribution across different geographical regions.

2. **Detailed Table**: In this tab, a table is presented that provides detailed information about the observations. You can filter observations by species, whether by their scientific name or common name. The table can be customized and sorted according to your preferences.
![image](https://github.com/IgnacioArga/Biodiversity/assets/62559949/6c9cca4c-cbd4-4944-82c6-87b5ab878590)

### Module 3: Time Line

The second module is designed to facilitate the analysis of sightings over time. You can explore observations based on different timeframes, such as year, month, or hour. This module also features filtering options similar to those in Module 1, allowing you to refine the data to your specific interests.
![image](https://github.com/IgnacioArga/Biodiversity/assets/62559949/a5840a23-4a0a-48a9-a236-eb33475eacf0)

## Extras Utilized

### 1. Beautiful UI Skill

The UI of this application has been enhanced using CSS to provide an appealing and user-friendly experience:

- **Login Page Styling**: The login page is styled using CSS, featuring a background image with a caption. Additionally, the rest of the dashboard is hidden to prevent access without successful login. This approach ensures that even if users attempt to modify the HTML and CSS from their browser, access to the dashboard's information remains restricted.

- **Sidebar Icon Formatting**: The icons within the sidebar have been formatted to function seamlessly when the sidebar is collapsed.

- **Font Customization**: The font across the entire dashboard has been modified to create a cohesive visual identity.

### 2. Performance Optimization Skill

To optimize the performance of the application, the following strategies were employed:

- **Working with Full Data**: The application works with the entirety of the dataset. The data was imported into Google Cloud Platform's BigQuery via Cloud Storage, utilizing a project in GCP.
![image](https://github.com/IgnacioArga/Biodiversity/assets/62559949/a0fe9ef3-f5af-46bf-a8d1-1429e97384bd)

- **Utilizing Google BigQuery**: To establish a connection between Shiny and BigQuery, a service account for BigQuery with data editor and data viewer roles was created in IAM. The corresponding key was downloaded and stored securely within the app's 'gcp' folder. The `bigrquery` and `pool` packages were employed to facilitate a connection to the database.

- **Two-Stage Filtering**: To enhance the app's responsiveness, filtering was divided into two stages. The first stage involves the global filter for countries. Upon modification, it recalculates information specific to the chosen country. Simultaneously, filtering by species is performed using the available country-specific information. This approach significantly improves dashboard performance, particularly when filtering by species or using timeline filters.

### 3. JavaScript Skill

JavaScript was incorporated to address specific UI elements that couldn't be easily achieved through Shiny alone:

- **Dynamic UI Elements**: JavaScript was used to dynamically insert HTML elements into the UI. For example, the login modal's title and caption were added using JavaScript after the login modal UI had loaded.

- **Visibility Toggle**: JavaScript was employed to toggle the visibility of the sidebar and header after successful login.

- **Enhanced User Experience**: JavaScript enables users to press the 'Enter' key during login, treating it as a confirmation button click for a smoother user experience.

Por supuesto, aquí tienes una versión resumida que destaca que la aplicación no pudo ser montada en Google Cloud Platform (GCP):

### 4. Infrastructure Skill

- **Containerization with Docker**: A Docker container was crafted with files like `Dockerfile` and `cloudbuild.yml`. This encapsulated the app's dependencies and ensured consistent behavior across environments.

- **Cloud Build Integration**: Google Cloud Build was used to build the Docker container, automating deployment and enhancing efficiency.
![image](https://github.com/IgnacioArga/Biodiversity/assets/62559949/05a453c9-5b6c-485a-9ea0-61f5c577aa87)

- **Deployment with Cloud Run**: The app was deployed on Google Cloud Run, offering auto-scaling and serverless capabilities for flexible hosting.

- **Library Restoration Challenges**: Despite efforts, issues arose when attempting to restore libraries using the `renv` package. Consequently, successful deployment on GCP was not achieved. The app is currently accessible via a Shiny.io link as a workaround.

## Next Steps

As this Biodiversity Data Visualization App continues to evolve, there are several exciting directions you can consider for its enhancement:

### 1. Refine Deployment and Infrastructure

**Goal:** Correct build issues and successfully deploy the application on Google Cloud Platform (GCP) for seamless access.

- **GCP Deployment**: Address any issues related to the build process and successfully deploy the application on GCP. This will ensure that the app is accessible to a wider audience while benefiting from the scalability and resources of the cloud platform.

### 2. Optimize Data Sources and Authentication

**Goal:** Improve data sourcing and authentication mechanisms for a more robust and efficient experience.

- **Diverse Data Sources**: While BigQuery is excellent for handling large datasets, consider integrating with other data sources like Cloud SQL for scenarios that involve smaller tables, such as user authentication. This can enhance the app's overall performance and align data storage mechanisms with their appropriate use cases.

### 3. Multimedia Integration

**Goal:** Enrich the user experience by incorporating multimedia elements into the application.

- **Multimedia Display**: Utilize the "Multimedia" table to showcase images related to selected species. Enhance user engagement by providing visual representations of the observed species, further enriching the exploration of biodiversity.

# Getting Started

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
