library(testthat)
setwd("~/git/Rpackage2023/test/")
source("../functions/kakezan.R")
test_that("caluculation is correct", {
  expect_that(kakezan(1,2), equals(2))
})
test_that("positive/negative is correct",{
  expect_that(kakezan(-1,-1), equals(-2))
})
