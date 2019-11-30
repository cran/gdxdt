context("test-read")


test_that("round-trip of a mtcars as variable, single dimension", {
    test_gdx <- "test.gdx"
    test_var <- "mtcars"
    ## mtcars
    dt <- as.data.table(mtcars, keep.rownames = T)
    writegdx.variable(test_gdx, dt, test_var, "wt", "rn")
    ## read back in
    dt2 <- readgdx(test_gdx, test_var)

    expect_is(dt2, "data.table")
    expect_equal(dt$wt, dt2$value)
    expect_equal(dt$rn, dt2$rn)

    file.remove(test_gdx)
})


test_that("round-trip of a mtcars as variable, two dimensions", {
    test_gdx <- "test.gdx"
    test_var <- "mtcars"
    ## mtcars
    dt <- as.data.table(mtcars, keep.rownames = T)
    writegdx.variable(test_gdx, dt, test_var, "wt", c("rn", "gear"))
    ## read back in
    dt2 <- readgdx(test_gdx, test_var)

    expect_is(dt2, "data.table")
    expect_equal(dt$wt, dt2$value)
    expect_equal(dt$rn, dt2$rn)

    ## gear dimension is numerical!
    dt2[, gear := as.numeric(gear)]
    expect_equal(dt[order(gear)]$gear, dt2[order(gear)]$gear)

    file.remove(test_gdx)
})


test_that("round-trip of a mtcars as parameter, single dimension", {
    test_gdx <- "test.gdx"
    test_var <- "mtcars"
    ## mtcars
    dt <- as.data.table(mtcars, keep.rownames = T)
    writegdx.parameter(test_gdx, dt, test_var, "wt", "rn")
    ## read back in
    dt2 <- readgdx(test_gdx, test_var)

    expect_is(dt2, "data.table")

    expect_equal(dt$wt, dt2$value)
    file.remove(test_gdx)
})
