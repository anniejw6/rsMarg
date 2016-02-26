#' Marginal Effects
#'
#' Run a model in Stata and return marginal or predicted effects for you
#'
#' You will need to install \href{http://repec.org/bocode/e/estout/}{estout}
#' in Stata for this to run. You can just run
#' \code{stata ssc install estout, replace} from the command line.
#'
#' To improve performance, try to only pass the variables of the data frame that
#' you actually need.
#'
#' If the code errors out, you should always look at the log file that is
#' generated from the analysis.
#' You should be able to find that in the working directory that you set.
#' The other thing that you might want to do is delete any temporary text files
#' that were created (they will have the names of the list items you passed in
#' the \code{margs} parameter).
#'
#' Some notes on idiosyncratic Stata things. First, it doesn't handle periods in dataframe names,
#' so you'll want to fix that in your original dataset. Second, the variable names
#' can only be so long, so if you have very long names, you should rename them before you pass
#' them through this argument.
#'
#' @param model string of the desired model (in stata syntax)
#' @param margs list of strings, each of which should represent a margins command (in stata syntax) and have a name
#' @param df data frame
#' @param do_file_name string of what the do file should be called
#' @param wd working directory for storing stata files
#' @param limit time limit (in seconds) on how long stata should run, defaults to 10 seconds
#' @param dta_file_name string, name of dta file and defaults to 'tmp.dta'
#' @param verbose defaults to FALSE
#' @export
#' @return a list containing model output and margins output
#' @examples
#' data(mtcars)
#' mod_marg(model = 'logit vs c.mpg##i.am',
#'          margs = list(
#'            m1 = 'margins am',
#'            m2 = 'margins, dydx(am)'
#'          ),
#'          df = mtcars[, c('vs', 'mpg', 'am')],
#'          do_file_name = 'cars.do',
#'          wd = '~/',
#'          verbose = TRUE)
#' @seealso \url{http://www.stata.com/help.cgi?margins}
mod_marg <- function(model, margs, df, do_file_name, wd,
                     limit = 10,
                     dta_file_name = 'tmp.dta',
                     verbose = F){
  # Setup -------
  tmp <- getwd()
  setwd(wd)

  # Create .dta
  create_dta(df, paste0(wd, dta_file_name))
  # Create .do
  do_text <- create_do_text(model, margs, paste0(wd, dta_file_name))
  #if(verbose) cat(do_text)
  write(do_text, file = paste0(wd, do_file_name))


  # Run --------
  system(sprintf("stata -b %s &", do_file_name))

  # Read in Values -------
  x <- wait_stata(margs, limit)
  if(verbose == TRUE){
    print(x)
  }

  # Model
  mod_output <- clean_stata(paste0(wd, "mod1.txt"))
  # Margins
  mgs <- lapply(names(margs), function(x)
    clean_margs(clean_stata(paste0(wd, x, '.txt'))))
  names(mgs) <- names(margs)

  # Delete .dta and other .txt files that are generated
  files <- c(dta_file_name, paste0(c('mod1',names(margs)), '.txt'))
  if(verbose){
    print(paste0('Deleting temporary files: ', files))
  }
  for(i in paste0(wd, files)){
    try(system(sprintf("rm -rf %s", i)))
  }

  if(verbose){
    f <- gsub('\\.do$', '\\.log', do_file_name)
    f <- readLines(f)
    print(writeLines(f[30:length(f)]))
  }

  setwd(tmp)

  # Returns
  list(
    model = mod_output,
    margins = mgs
  )

}


wait_stata <- function(margs, limit = 10){
  # After kicking off the stata command, need to wait for code to run
  p1 <- proc.time()
  t <- 0
  while(t < limit){
    t <- (proc.time() - p1)[3]
    # checking that all margins are stored as .txt files
    if(all(paste0(names(margs), '.txt') %in% list.files())){
      return('Stata is done!')
    }
    Sys.sleep(0.5)
  }
  return('Hit time limit -- the stata command is probably wrong')
}


create_dta <- function(df, dta_file_name){
  # Inputs:
  # df: dataframe
  # dta_file.name: name of output file

  require(readstata13)

  # make all strings factors
  df <- as.data.frame(unclass(df))

  readstata13::save.dta13(data = df, file = dta_file_name)
}


create_do_text <- function(model, margs,
                           df_file_name){
  paste0(
    # Read in data
    sprintf("use %s, clear\n\n", df_file_name),

    # Add Model
    sprintf("%s\n", model),

    # Store Model
    'estout . using mod1.txt, cells("b se t p") stats(N) replace\n',
    "estimates store t1\n\n",

    # Add margins
    paste0(sapply(seq_along(margs), function(i){

      # See if you need to add comma
      extra <- ''
      if(! grepl(',', margs[[i]])){
        extra <- ','
      }
      paste0(
        # Write margins command
        sprintf("%s\n", margs[[i]]),
        sprintf("quietly estadd %s%s replace\n", margs[[i]], extra),

        # Store output
        sprintf('estout using %s.txt, cells("margins_b margins_se") replace\n',
                names(margs)[[i]]),
        "estimates restore t1\n\n"
      )
    }), collapse = '')
  )
}

clean_stata <- function(file_name){
  df <- read.delim(file_name, header = FALSE, stringsAsFactors=FALSE)
  colnames(df) <- df[2, ]
  df <- df[-c(1,2), ]
  row.names(df) <- NULL
  df
}

clean_margs <- function(df){
  df$margins_b <- as.numeric(df$margins_b)
  df$margins_se <- as.numeric(df$margins_se)
  colnames(df)[1] <- 'variable'
  df
}

#clean_mod <- function(df){
#  n <- n = df[[2]][df[[1]] == 'N']
#}
