

#' Title: Convert CSV to Parquet in Chunks
#'
#' @param csv_path Path to the input CSV file.
#' @param output_dir Directory to save the output Parquet files.
#' @param chunk_size Number of rows per chunk to read from the CSV file.
#' @param combine_all Logical indicating whether to combine all chunks into a single Parquet file.
#' @param combined_file Name of the combined Parquet file if `combine_all` is TRUE. 
#'
#' @returns All parquet files saved in the specified output directory, and optionally a combined Parquet file.

csv_to_parquet_chunks <- function(csv_path,
                                  output_dir = "chunks_parquet",
                                  chunk_size = 100000,
                                  combine_all = FALSE,
                                  combined_file = "combined_output.parquet") {
  # Create output directory
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)}
  # Initialize chunk counter
  chunk_num <- 1
  # Define callback function
  process_chunk <- function(df, pos) {
    cat("Processing chunk",
        chunk_num,
        "starting at row", 
        pos, "\n")
    # Optional: Add processing here 
    # (e.g., df <- df %>% filter(...))
    # Save each chunk to Parquet
    chunk_file <- file.path(output_dir, 
                            paste0("chunk_", 
                                   chunk_num, 
                                   ".parquet"))
    write_parquet(df, chunk_file)
    chunk_num <<- chunk_num + 1
  }
  
  # Read in chunks using readr
  read_csv_chunked(file = csv_path,
                   callback = SideEffectChunkCallback$new(process_chunk),
                   chunk_size = chunk_size)
  
  # Optional: combine all chunks into a single Parquet file
  if (combine_all) {
    cat("Combining all chunks into one Parquet file...\n")
    files <- list.files(output_dir, pattern = "\\.parquet$",
                        full.names = TRUE)
    tables <- lapply(files, read_parquet)
    combined_table <- do.call(rbind, tables)
    write_parquet(combined_table, combined_file)
  }
}
