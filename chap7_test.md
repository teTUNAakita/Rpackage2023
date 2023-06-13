---
marp: true
theme: gaia
class: invert
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
library(testthat)
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