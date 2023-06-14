---
marp: true
theme: gaia
class: invert
math: mathjax
---
<!-- paginate: true -->
<!-- テストの理解と、パッケージに組み込まれるテストの２つに大別 -->
# ７章　テスト（P.81〜92）
- `testthat`パッケージを利用したテストの自動化
    - 思いつきで対話的なテストを再現可能なスクリプトに変える

- メリット
    - **バグ** :arrow_down: ：振る舞いをコードとテストの２箇所で記載
    - **コードの構造** :arrow_up:：複雑なコードはテストのために単独なパーツに分割
    - **コーディングの再開が容易** :cupid:：次に実装したい機能のためのテスト作成しておくなど
    - **堅牢性** :arrow_up:：コードに大胆な変更をかけやすい

---
# ７章　テスト（P.81〜92）
1. テストのワークフロー
2. テストの構造
2.1 期待値の検証
3. テストを書く
3.1 何をテストするか
3.2 テストをスキップする
3.3 独自のテストツールを作成
4. テストファイル
5. CRANに関する補足

---
# 下記はテストを自動化できていない
1. 関数を書く
2. `devtools::load_all()`でその関数をロードする
3. コンソールで動作を確認する
4. 完成するまでこの流れを繰り返す
---
<!-- footer: testthat.R -->
~~~R
library(testthat)# install.packages("testthat")
setwd("~/git/Rpackage2023/test/")
source("../functions/kakezan.R")
test_that("caluculation is correct", {
  expect_that(kakezan(1,2), equals(2))
})
test_that("positive/negative is correct",{
  expect_that(kakezan(-1,-1), equals(-2))
})

> test_file("testthat.R")
[ FAIL 1 | WARN 0 | SKIP 0 | PASS 1 ]

── Failure (testthat.R:8:3): positive/negative is correct
`x` not equal to `expected`.
1/1 mismatches
[1] 1 - -2 == 3
~~~

---
<!-- footer: https://sites.google.com/site/scriptofbioinformatics/r-tong-ji-guan-xi/rnotesuto-qu-dong-kai-fanitsuite-r -->
~~~R
# ショートカットVer関数
# Full                                           ＃Short cut
expect_that(x, is_true())                       expect_ture(x)
expect_that(x, is_false())                      expect_false(x)
expect_that(x, is_a(y))                         expect_is(x,y)
expect_that(x, equals(y))                       expect_equal(x,y)
expect_that(x, is_equivalent_to(y))             expect_equivalent(x, y)
expect_that(x, is_identical_to(y))              expect_identical(x, y)
expect_that(x, matches(y))                      expect_matches(x, y)
expect_that(x, prints_text(y))                  expect_output(x, y)
expect_that(x, shows_message(y))                expect_message(x, y)
expect_that(x, gives_warning(y))                expect_warning(x, y)
expect_that(x, throws_error(y))                 expect_error(x,y)

~~~
---
<!-- footer: "" -->
# 期待値の検証
~~~R
> test_that("caluculation is correct", {
  expect_that(kakezan(1,2), equals(2))
  expect_that(kakezan(1,2), equals(2+1e-8))
  expect_that(kakezan(1,2), equals(2+1e-7))
})

── Failure (Line 4): caluculation is correct
`x` not equal to `expected`.
1/1 mismatches
[1] 2 - 2 == -1e-07

# equal系だと、1e-7程度の差分が限界っぽい
~~~

---
# 期待値の検証
~~~R
# equal系だと、1e-7程度の差分が限界っぽい
> all.equal(1,1+1e-7)
[1] "Mean relative difference: 1e-07"
> all.equal(1,1+1e-8)
[1] TRUE

# identical系だと、完全一致のみpassする
> test_that("caluculation is correct", {
  expect_that(kakezan(1,2), is_identical_to(2+1e-8))
})
── Failure (Line 2): caluculation is correct
`x` not identical to `expected`.
Objects equal but not identical
~~~
---
# Tolerance（許容率）
$$
\frac{E[|x-y|]}{E[|y|]} < torelance
$$
~~~R
> expect_equal(100,101,tolerance = 0.01)  #  1%までの誤差は許容
> expect_equal(100,101,tolerance = 0.001) #0.1%までの誤差は許容
Error: 100 not equal to 101.
1/1 mismatches
[1] 100 - 101 == -1
~~~
---
# 警告やエラー
~~~R
> expect_warning(log(-1), "NaNs produced")#OK
> log(-1)
[1] NaN
Warning message:
In log(-1) : NaNs produced

> expect_warning(log(0))
Error: `log(0)` did not produce any warnings.

> expect_error(log("a"), "non-numeric argument to mathematical function")#OK
~~~

---
# 何をテストするか
「何らかの情報をコンソールに出力したくなったとき、あるいはデバッグ用のコードを書きたくなったときには、それをテストとして書くべきである」by Martin Fowler 😊

- 外部に向けて提供されるインターフェイスに着目したテスト
- １つのテストでは、１つの振る舞いのみテストするように努める
- 不安定なコードや、複雑な相互以前性を持つコードをテストすることに注力
- バグを発見した時には必ずテストを書く

---
# テストのスキップ
~~~R
> test_that("caluculation is correct", {
  skip("otsukare-sama-desu")
  expect_that(kakezan(1,2), is_identical_to(2+1e-8))
})
── Skip (Line 2): caluculation is correct
Reason: otsukare-sama-desu
~~~
- データが不在
- 該当OSではない場合
- ネット接続していない場合

---
# 独自のテストツール作成
- テストコードの（部分的な）重複
- 可読性の高いテストほど正しいテスト

---
~~~R
# 子の数がポアソン分布に従う場合、各母親が残した子の数の平均・分散・歪度の不偏性テスト
> lambda = 100 # 子の数の平均値
> mother_number = 10000
> tolerance_mean = 0.01
> tolerance_var = 0.1
> tolerance_skew = 0.2
> skewness = function(x) sum((x-mean(x))^3/sqrt(var(x))^3)/length(x)
> offspring_number = rpois(n = mother_number, lambda = lambda)
> test_that("unbiasedness of statistics", {
  expect_equal(mean(offspring_number), lambda, tolerance = tolerance_mean)
  expect_equal(var(offspring_number), lambda, tolerance = tolerance_var)
  expect_equal(skewness(offspring_number), lambda^(-1/2), tolerance = tolerance_skew)
})
Test passed 🥇
~~~

- ３行のテストが重複しているので、まとめたい
  - ヘルパー関数を作成
- `test_that()`の枠組みは保持

---
~~~R
lambda = 100
mother_number = 10000
tolerance_mean = 0.01
tolerance_var = 0.1
tolerance_skew = 0.2
skewness = function(x) sum((x-mean(x))^3/sqrt(var(x))^3)/length(x)
offspring_number = rpois(n = mother_number, lambda = lambda)
test_that("unbiasedness of statistics", { # ヘルバー関数の作成
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
~~~
この場合、見通しが良くなったかは謎

---
# テストファイル
- `context()`の使用は非推奨なので避ける
- 適切な粒度に分割してテストを実施
  - 複雑な関数ごとにテストファイルを用意するのか良いらしい

---
# CRANに関する補足
- CRANに上げる人はもういないでしょう（個人的観測）
- 短時間で完了するテスト
- 英語環境`LANGUAGE=EN`およびCソート`LC_COLLATE=C`で
- 数値の精度がプラットフォーム依存なので、`identical`系は避け`equal`系を

---
# ここからは教科書外の内容（一部最新版）

- 実際にRパッケージを開発して、testthatがどう機能するか見てみる

---
新しいパッケージのdirectoryにいることを確認しつつ
~~~R
> library(usethis)
> usethis::use_testthat()
✔ Adding 'testthat' to Suggests field in DESCRIPTION
✔ Adding '3' to Config/testthat/edition
✔ Creating 'tests/testthat/'
✔ Writing 'tests/testthat.R'
• Call `use_test()` to initialize a basic test file and open it for editing.
~~~

---
<!-- footer: "DESCRIPTION" -->
~~~R
Package: kerokero
Type: Package
Title: What the Package Does (Title Case)
Version: 0.1.0
Author: Who wrote it
Maintainer: The package maintainer <yourself@somewhere.net>
Description: More about what it does (maybe more than one line)
    Use four spaces when indenting paragraphs within the Description.
License: MIT + file LICENSE
Encoding: UTF-8
LazyData: true
RoxygenNote: 7.2.3
Suggests: 
    testthat (>= 3.0.0)
Config/testthat/edition: 3
~~~

---
<!-- footer: "tests/testthat.R" -->
~~~R
# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
# * https://testthat.r-lib.org/articles/special-files.html

library(testthat)
library(kerokero)

test_check("kerokero")
~~~

---
<!-- footer: "tests/testthat/test-kakezan.R" -->
~~~R
# library(testthat)しちゃだめ
test_that("caluculation is correct", {
  expect_that(kakezan(1,2), equals(2))
  expect_that(kakezan(1,2), equals(2+1e-8))
  expect_that(kakezan(1,2), equals(2+1e-7))
})
~~~

---
<!-- footer: "" -->
~~~R
> devtools::test()
ℹ Testing kerokero
✔ | F W S  OK | Context
✖ | 1 3     2 | kakezan [0.5s]                                                   
────────────────────────
Warning (test-kakezan.R:2:3): caluculation is correct
`expect_that()` was deprecated in the 3rd edition.

Failure (test-kakezan.R:4:3): caluculation is correct
`x` (`actual`) not equal to `expected` (`expected`).

  `actual`: 2.0000000
`expected`: 2.0000001
────────────────────────

══ Results ══
Duration: 1.1 s

[ FAIL 1 | WARN 3 | SKIP 0 | PASS 2 ]
~~~

---
<!-- footer: "https://r-pkgs.org/testing-basics.html" -->
- Micro-iteration / Mezzo-iteration / Macro-iteration
~~~R
# tweak the foofy() function and re-load it
devtools::load_all()
# interactively explore and refine expectations and tests
expect_equal(foofy(...), EXPECTED_FOOFY_OUTPUT)
test_that("foofy does good things", {...})
~~~
~~~R
testthat::test_file("tests/testthat/test-foofy.R")
~~~
~~~R
devtools::test()
devtools::check()
~~~

---
<!-- footer: "https://r-pkgs.org/testing-design.html" -->
# テストカバレッジ`covr`
- ローカルでインタラクティブな使用
~~~R
> devtools::test_coverage_active_file(file = "./R/kakezan.R")
> devtools::test_coverage()
~~~
- GitHub Actions (GHA) による自動的なリモート使用
~~~R
usethis::use_github_action("test-coverage")
~~~

---
<!-- footer: "" -->
# High-level principles for testing
- self-sufficient and self-contained
- interactive workflow
- obvious >> DRY (don't repeat yourself)
- interactive workflow shouldn’t “leak” into and undermine the test suite.

---
# Self-sufficient tests
- test_that()の外にあるコードは排除すべき
~~~R
dat <- data.frame(x= c("a","b","c"), y= c(1,2,3))
skip_if(today_is_a_monday())
test_that("foofy() does this",{)
expect_equal(foofy(dat),...)
})

dat2 <- data.frame(x= c("x","y","z"), y= c(4,5,6))
skip_on_os("windows")
test_that("foofy2() does that",{)
expect_snapshot(foofy2(dat,dat2))
})
~~~

---
~~~R
test_that("foofy() does this",{
skip_if(today_is_a_monday())  
dat <- data.frame(x= c("a","b","c"), y= c(1,2,3))  
expect_equal(foofy(dat),...)
})

test_that("foofy() does that",{
skip_if(today_is_a_monday())
skip_on_os("windows")  
dat <- data.frame(x= c("a","b","c"), y= c(1,2,3))
dat2 <- data.frame(x= c("x","y","z"), y= c(4,5,6))  
expect_snapshot(foofy(dat,dat2))
})
~~~

---
# Self-contained tests
- テストの中で作成したRオブジェクトは、テスト終了後には通常存在しない
- `library()`、`options()`、`Sys.setenv()`などの呼び出しが、`test_that()`の中で実行されると、テスト終了後も影響する
- `withr` package

---
~~~R
grep("jsonlite", search(), value = TRUE)
#> character(0)
getOption("opt_whatever")
#> NULL
Sys.getenv("envvar_whatever")
#> [1] ""
test_that("withr makes landscape changes local to a test", {
  withr::local_package("jsonlite")
  withr::local_options(opt_whatever = "whatever")
  withr::local_envvar(envvar_whatever = "whatever")
  expect_match(search(), "jsonlite", all = FALSE)
  expect_equal(getOption("opt_whatever"), "whatever")
  expect_equal(Sys.getenv("envvar_whatever"), "whatever")
})
#> Test passed 🎊
grep("jsonlite", search(), value = TRUE)
#> character(0)
getOption("opt_whatever")
#> NULL
Sys.getenv("envvar_whatever")
#> [1] ""
~~~

---
# 繰り返してもOK
~~~R
test_that("掛け算が効く",{)
useful_thing <- 3
expect_equal(2 * useful_thing,6)
})
#> テスト合格 😸。

test_that("subtraction works",{)
useful_thing <- 3
expect_equal(5 - useful_thing,2)
})
#> テスト合格しました🎊。
~~~