library(testthat)
setwd("~/git/Rpackage2023/test/")
source("../functions/kakezan.R")
test_that("caluculation is correct", {
  expect_that(kakezan(1,2), equals(2))
})
test_that("positive/negative is correct",{
  expect_that(kakezan(-1,-1), equals(-2))
})


test_that("caluculation is correct", {
  expect_that(kakezan(1,2), equals(2))
  expect_that(kakezan(1,2), equals(2+1e-8))
  expect_that(kakezan(1,2), equals(2+1e-7))
})

all.equal(1,1+1e-7)
all.equal(1,1+1e-8)

test_that("caluculation is correct", {
  skip("otsukare-sama-desu")
  expect_that(kakezan(1,2), is_identical_to(2+1e-8))
})

expect_warning(log(0))
expect_error(log("a"))

lambda = 100
mother_number = 10000
tolerance_mean = 0.01
tolerance_var = 0.1
tolerance_skew = 0.2
skewness = function(x) sum((x-mean(x))^3/sqrt(var(x))^3)/length(x)
offspring_number = rpois(n = mother_number, lambda = lambda)
test_that("unbiasedness of statistics", {
  expect_equal(mean(offspring_number), lambda, tolerance = tolerance_mean)
  expect_equal(var(offspring_number), lambda, tolerance = tolerance_var)
  expect_equal(skewness(offspring_number), lambda^(-1/2), tolerance = tolerance_skew)
})


lambda = 100
mother_number = 10000
tolerance_mean = 0.01
tolerance_var = 0.1
tolerance_skew = 0.2
skewness = function(x) sum((x-mean(x))^3/sqrt(var(x))^3)/length(x)
offspring_number = rpois(n = mother_number, lambda = lambda)
test_that("unbiasedness of statistics", {
  expect_stat_equal = function(stat, data, lambda, tolerance){
    tmp = switch (stat,
      "mean" = list(mean(data),lambda,tolerance),
      "var"  = list(var(data),lambda,tolerance),
      "skew" = list(skewness(data),lambda^(-1/2),tolerance),
      stop()
    )
    return(eval(expect_equal(tmp[[1]], tmp[[2]], tmp[[3]])))
  }
  expect_stat_equal("mean", offspring_number, lambda, tolerance_mean)
  expect_stat_equal("var",  offspring_number, lambda, tolerance_var)
  expect_stat_equal("skew", offspring_number, lambda, tolerance_skew)
})


