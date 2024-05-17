library(shiny)
library(DESeq2)
library(ggplot2)

# Load sample data
load("sample_data.RData")

# Ensure 'condition' is a factor
colData$condition <- as.factor(colData$condition)

# Define UI
ui <- fluidPage(
  titlePanel("Differential Gene Expression Analysis"),
  sidebarLayout(
    sidebarPanel(
      selectInput("gene", "Select Gene:", choices = rownames(counts)),
      actionButton("analyze", "Run DESeq2")
    ),
    mainPanel(
      plotOutput("plot")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  dds <- reactiveVal(NULL)
  res <- reactiveVal(NULL)
  
  observeEvent(input$analyze, {
    start_time <- Sys.time()
    
    # Create DESeq2 dataset
    dds_tmp <- DESeqDataSetFromMatrix(countData = counts, colData = colData, design = ~ condition)
    
    creation_time <- Sys.time()
    print(paste("Time to create DESeqDataSet:", creation_time - start_time))
    
    # Run DESeq2 analysis
    dds_tmp <- DESeq(dds_tmp)
    res_tmp <- results(dds_tmp)
    
    analysis_time <- Sys.time()
    print(paste("Time to run DESeq2:", analysis_time - creation_time))
    
    # Store results in reactive values
    dds(dds_tmp)
    res(res_tmp)
  })
  
  output$plot <- renderPlot({
    req(res())
    
    selected_gene <- input$gene
    
    # Get normalized count data for the selected gene
    gene_data <- plotCounts(dds(), gene = selected_gene, intgroup = "condition", returnData = TRUE)
    
    plot_time <- Sys.time()
    print(paste("Time to prepare plot data:", plot_time))
    
    # Create a plot with ggplot2
    ggplot(gene_data, aes(x = condition, y = count)) +
      geom_point() +
      geom_line(aes(group = condition)) +
      labs(title = paste("Expression of", selected_gene), y = "Normalized Count", x = "Condition") +
      theme_minimal()
  })
}

# Run the application
shinyApp(ui = ui, server = server)
