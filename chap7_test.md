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