# MIS 319 Content Management Systems – Final Project

## Student Information
**Name:** Derya Turan  
**Student ID:** 2304109020  
Izmir Democracy University  
Faculty of Economics and Administrative Sciences  
MIS 319 Content Management Systems  
Asst. Prof. Dr. Can Saygıner  
January 5, 2026  

---

# Project Title
## Development of an E-Commerce Application Using R

---

# Project Overview
In this project, I developed an e-commerce application that sells home decor products using the R programming language. The application was built as an interactive web system using **Shiny** and **shinydashboard**.

The system includes basic e-commerce functions such as:
- Product listing  
- Stock tracking  
- Shopping cart management  
- Total price calculation  

Additionally, interactive data tables using the **DT package**, data visualizations using **ggplot2**, and map-based visualization using **Leaflet** were implemented. A reactive programming structure was used to ensure real-time updates based on user interactions.

---

# Features
- Product listing and management  
- Add / remove items from shopping cart  
- Stock tracking system  
- Dynamic total price calculation  
- Interactive data tables (DT)  
- Data visualization with ggplot2  
- Map integration with Leaflet  
- Contact form for user feedback  
- Reactive real-time updates  

---

# How It Works

The application is developed using the Shiny web framework.

### UI (User Interface)
- Built using `dashboardPage()`, `dashboardHeader()`, and `dashboardSidebar()`
- Navigation handled with `sidebarMenu()` and `menuItem()`
- Multi-page layout created using `tabItems()` and `tabItem()`

### Server Logic
- Reactive values managed with `reactiveVal()`
- User interactions handled using `observeEvent()`
- Tables rendered using `renderDataTable()`
- Charts created using `ggplot2` with `renderPlot()`
- Stock and cart updates handled dynamically in real-time
- Contact form inputs processed interactively

### Application Start
The application runs using:

```r
shinyApp(ui, server)
