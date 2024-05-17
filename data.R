# data.R
# Create a sample RNA-seq count dataset and metadata

counts <- matrix(
  sample(1:1000, 100, replace = TRUE),
  ncol = 10,
  dimnames = list(paste0("gene", 1:10), paste0("sample", 1:10))
)

colData <- data.frame(
  condition = rep(c("A", "B"), each = 5),
  row.names = paste0("sample", 1:10)
)

save(counts, colData, file = "sample_data.RData")
