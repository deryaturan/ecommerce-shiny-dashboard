library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(leaflet)

products_data <- data.frame(
  ID = 1:5,
  Name = c("Candle", "Painting", "Plant", "Desk Lamp", "Decorative Item"),
  Description = c("Scented candle", "Modern art painting", "Indoor plant", "LED desk lamp", "Wooden decorative item"),
  Price = c(250, 500, 150, 300, 200),
  Stock = c(10, 5, 20, 7, 15),
  Rating = c(4.5, 4.8, 4.2, 4.6, 4.1),
  Image = c("candle.jpg","painting.jpg","plant.jpg","lamp.jpg","decor.jpg"),
  stringsAsFactors = FALSE
)

ui <- dashboardPage(
  dashboardHeader(title = "derya HOME"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("home")),
      menuItem("About Us", tabName = "about", icon = icon("info-circle")),
      menuItem("Products", tabName = "products", icon = icon("th")),
      menuItem("Cart", tabName = "cart", icon = icon("shopping-cart")),
      menuItem("Contact", tabName = "contact", icon = icon("envelope")),
      menuItem("Dashboard", tabName = "dashboard", icon = icon("tachometer-alt")),
      menuItem("Data Analysis", tabName = "analysis", icon = icon("chart-bar"))
    )
  ),
  dashboardBody(
    
    tags$head(
      tags$style(HTML("
   body,
    h1, h2, h3, h4, h5, h6 {
      font-family: Georgia, serif;
      font-style: italic;
    }

    .skin-blue .main-header .logo {
      font-family: Georgia, serif;
      font-style: italic;
      font-size: 24px;
      letter-spacing: 1px;
    }

    .box-title {
      font-weight: 600;
    }

    .skin-blue .main-header .navbar,
    .skin-blue .main-header .logo {
      background-color: #B03060;
    }

    .skin-blue .main-sidebar {
      background-color: #E8AEB7;
    }

    .skin-blue .sidebar-menu > li > a {
      background-color: transparent;
      color: #FFFFFF;
    }

    .skin-blue .sidebar-menu > li.active > a {
      background-color: #D996A3;
      color: #FFFFFF;
    }

    .skin-blue .sidebar-menu > li > a:hover {
      background-color: #D996A3;
      color: #FFFFFF;
    }

  "))
    ),
    
    tabItems(
      tabItem(tabName = "home",
              fluidRow(
                valueBoxOutput("totalProducts"),
                valueBoxOutput("totalSales"),
                valueBoxOutput("totalOrders")
              ),
              fluidRow(
                box(title = "Welcome!", width = 12,
                    p("Welcome to deryaHOME! Explore our curated collection of home decoration products.")
                )
              )
      ),
      
      tabItem(tabName = "about",
              box(title = "About Us", width = 12,
                  p("This company, HOME Derya, was founded with the mission to provide high-quality and stylish home decoration products.")
              ),
              box(title = "Our Vision", width = 12,
                  p("To become a leading brand in home decoration worldwide.")
              ),
              box(title = "Our Mission", width = 12,
                  p("To offer aesthetic, functional and affordable home decor products.")
              )
      ),
      
      tabItem(tabName = "products",
              box(title = "Product List", width = 12,
                  dataTableOutput("productsTable"),
                  actionButton("add_to_cart", "Add to Cart", icon = icon("cart-plus"))
              )
      ),
      
      tabItem(tabName = "cart",
              box(title = "Your Cart", width = 12,
                  dataTableOutput("cartTable"),
                  h4("Total Price:"),
                  textOutput("totalPrice"),
                  actionButton("remove_item", "Remove Selected Product"),
                  actionButton("clear_cart", "Clear Cart")
              )
      ),
      
      tabItem(tabName = "contact",
              box(title = "Contact", width = 12,
                  textInput("name", "Name"),
                  textInput("email", "Email"),
                  textAreaInput("message", "Message"),
                  actionButton("send", "Send")
              ),
              box(title = "Location", width = 12, leafletOutput("map"))
      ),
      
      tabItem(tabName = "dashboard",
              box(title = "Stock Levels", width = 12,
                  plotOutput("stockPlot"))
      ),
      
      tabItem(tabName = "analysis",
              box(title = "Price Analysis", width = 12,
                  plotOutput("pricePlot"))
      )
    )
  )
)

server <- function(input, output, session) {
  
  products <- reactiveVal(products_data)
  cart <- reactiveVal(data.frame(ID = integer(), Name = character(), Price = numeric()))
  
  output$productsTable <- renderDataTable({
    df <- products()
    df$Image <- paste0('<img src="', df$Image, '" height="80"/>')
    datatable(df[,c("Image","Name","Description","Price","Stock","Rating")],
              escape = FALSE, selection = "single")
  })
  
  observeEvent(input$add_to_cart, {
    row <- input$productsTable_rows_selected
    if (length(row) > 0) {
      df <- products()
      if (df$Stock[row] <= 0) {
        showModal(modalDialog("Out of stock!", easyClose = TRUE))
        return()
      }
      cart(rbind(cart(), df[row,c("ID","Name","Price")]))
      df$Stock[row] <- df$Stock[row] - 1
      products(df)
    }
  })
  
  output$cartTable <- renderDataTable({
    datatable(cart(), selection = "single")
  })
  
  observeEvent(input$remove_item, {
    sel <- input$cartTable_rows_selected
    if (length(sel) > 0) {
      removed <- cart()[sel, ]
      df <- products()
      idx <- which(df$ID == removed$ID)
      df$Stock[idx] <- df$Stock[idx] + 1
      products(df)
      cart(cart()[-sel, ])
    }
  })
  
  observeEvent(input$clear_cart, {
    removed_items <- cart()
    df <- products()
    if (nrow(removed_items) > 0) {
      for (i in seq_len(nrow(removed_items))) {
        idx <- which(df$ID == removed_items$ID[i])
        df$Stock[idx] <- df$Stock[idx] + 1
      }
      products(df)
    }
    cart(cart()[0,])
  })
  
  output$totalPrice <- renderText({
    paste(sum(cart()$Price), "TL")
  })
  
  output$totalProducts <- renderValueBox({
    valueBox(sum(products()$Stock), "Total Products", icon = icon("box"), color = "maroon")
  })
  
  output$totalSales <- renderValueBox({
    valueBox(sum(cart()$Price), "Total Sales", icon = icon("lira-sign"), color = "maroon")
  })
  
  output$totalOrders <- renderValueBox({
    valueBox(nrow(cart()), "Orders", icon = icon("shopping-bag"), color = "maroon")
  })
  
  output$map <- renderLeaflet({
    leaflet() %>% addTiles() %>%
      setView(lng = 27.1287, lat = 38.4192, zoom = 12) %>%
      addMarkers(lng = 27.1287, lat = 38.4192)
  })
  
  output$stockPlot <- renderPlot({
    ggplot(products(), aes(Name, Stock, fill = Name)) +
      geom_bar(stat = "identity") +
      theme_minimal()
  })
  
  output$pricePlot <- renderPlot({
    ggplot(products(), aes(x = Name, y = Price, group = 1)) +
      geom_area(fill = "#B03060", alpha = 0.6) +
      theme_minimal() +
      labs(title = "Price Distribution (Area Chart)",
           x = "Product",
           y = "Price (TL)")
  })
  
  observeEvent(input$send, {
    showModal(modalDialog(
      title = "Message Sent",
      paste(
        "Thank you", input$name,
        "! Your message has been received. We will get back to you via",
        input$email, "."
      ),
      easyClose = TRUE
    ))
  })

}

shinyApp(ui = ui, server = server)
