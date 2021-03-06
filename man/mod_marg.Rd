% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rStata.R
\name{mod_marg}
\alias{mod_marg}
\title{Marginal Effects}
\usage{
mod_marg(model, margs, df, do_file_name, wd, limit = 10,
  dta_file_name = "tmp.dta", verbose = F)
}
\arguments{
\item{model}{string of the desired model (in stata syntax)}

\item{margs}{list of strings, each of which should represent a margins command (in stata syntax) and have a name}

\item{df}{data frame}

\item{do_file_name}{string of what the do file should be called}

\item{wd}{working directory for storing stata files}

\item{limit}{time limit (in seconds) on how long stata should run, defaults to 10 seconds}

\item{dta_file_name}{string, name of dta file and defaults to 'tmp.dta'}

\item{verbose}{defaults to FALSE}
}
\value{
a list containing model output and margins output
}
\description{
Run a model in Stata and return marginal or predicted effects for you
}
\details{
You will need to install \href{http://repec.org/bocode/e/estout/}{estout}
in Stata for this to run. You can just run
\code{stata ssc install estout, replace} from the command line.

To improve performance, try to only pass the variables of the data frame that
you actually need.

If the code errors out, you should always look at the log file that is
generated from the analysis.
You should be able to find that in the working directory that you set.
The other thing that you might want to do is delete any temporary text files
that were created (they will have the names of the list items you passed in
the \code{margs} parameter).

Some notes on idiosyncratic Stata things. First, it doesn't handle periods in dataframe names,
so you'll want to fix that in your original dataset. Second, the variable names
can only be so long, so if you have very long names, you should rename them before you pass
them through this argument.
}
\examples{
data(mtcars)
mod_marg(model = 'logit vs c.mpg##i.am',
         margs = list(
           m1 = 'margins am',
           m2 = 'margins, dydx(am)'
         ),
         df = mtcars[, c('vs', 'mpg', 'am')],
         do_file_name = 'cars.do',
         wd = '~/',
         verbose = TRUE)
}
\seealso{
\url{http://www.stata.com/help.cgi?margins}
}

