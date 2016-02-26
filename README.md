# rsMarg
Bringing Stata into R

This package does some stupid, bullshit, hacky things to integrate Stata and R, so you can calculate the marginal effects of your models. 

The intelligent thing to do would be to actually port over the econometrics, but the fast, stupid, bullshit hacky thing to do is to use R to write Stata code and then read the output back into R.

# Installation
```
library(devtools)
devtools::install_github("anniejw6/rsMarg")
?mod_marg
```

# Requirements
- You need to have Stata on your machine
- You need to have [`estout`](http://repec.org/bocode/e/estout/) installed on Stata, which you can do by running `stata ssc install estout, replace` on the command line or by opening up Stata and typing `ssc install estout, replace`

# Usage
```
> data(mtcars)
> mod_marg(model = 'logit vs c.mpg##i.am',
+          margs = list(
+            m1 = 'margins am',
+            m2 = 'margins, dydx(am)'
+          ),
+          df = mtcars[, c('vs', 'mpg', 'am')],
+          do_file_name = 'cars.do',
+          wd = '~/',
+          verbose = TRUE)
[1] "Stata is done!"
[1] "Deleting temporary files: tmp.dta"  "Deleting temporary files: mod1.txt"
[3] "Deleting temporary files: m1.txt"   "Deleting temporary files: m2.txt"  
. 
. logit vs c.mpg##i.am

Iteration 0:   log likelihood = -21.930055  
Iteration 1:   log likelihood = -9.9811941  
Iteration 2:   log likelihood =  -9.574951  
Iteration 3:   log likelihood = -9.5624566  
Iteration 4:   log likelihood = -9.5624469  
Iteration 5:   log likelihood = -9.5624469  

Logistic regression                               Number of obs   =         32
                                                  LR chi2(3)      =      24.74
                                                  Prob > chi2     =     0.0000
Log likelihood = -9.5624469                       Pseudo R2       =     0.5640

------------------------------------------------------------------------------
          vs |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         mpg |   1.108382    .576965     1.92   0.055    -.0224483    2.239213
        1.am |   10.10551   11.91037     0.85   0.396    -13.23839    33.44941
             |
    am#c.mpg |
          1  |  -.6637037   .6242263    -1.06   0.288    -1.887165    .5597574
             |
       _cons |  -20.47841   10.55255    -1.94   0.052    -41.16103    .2042051
------------------------------------------------------------------------------

. estout . using mod1.txt, cells("b se t p") stats(N) replace
NULL
$model
                     b       se         t        p
1         vs                                      
2        mpg  1.108382  .576965  1.921056 .0547246
3       0.am         0        .         .        .
4       1.am  10.10551 11.91037  .8484629 .3961802
5 0.am#c.mpg         0        .         .        .
6 1.am#c.mpg -.6637037 .6242263 -1.063242 .2876721
7      _cons -20.47841 10.55255 -1.940613 .0523053
8          N        32                            

$margins
$margins$m1
  variable margins_b margins_se
1     0.am 0.5532474  0.0495948
2     1.am 0.2958730  0.0856568

$margins$m2
  variable  margins_b margins_se
1     0.am  0.0000000  0.0000000
2     1.am -0.2573743  0.0989785
```
