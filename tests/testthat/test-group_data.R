context("group_data")

test_that("group_rows works for 3 most important subclasses (#3489)", {
  df <- data.frame(x=c(1,1,2,2))
  expect_equal(group_rows(df), list(1:4))
  expect_equal(group_rows(group_by(df,x)), list(1:2, 3:4))
  expect_equal(group_rows(rowwise(df)), as.list(1:4))
})

test_that("group_data returns a tidy tibble (#3489)", {
  df <- tibble(x = c(1,1,2,2))

  expect_identical(
    group_data(df),
    tibble(.rows=list(1:4))
  )

  expect_identical(
    group_by(df,x) %>% group_data(),
    tibble(x = c(1,2), .rows = list(1:2, 3:4))
  )

  expect_identical(
    rowwise(df) %>% group_data(),
    tibble(.rows = as.list(1:4))
  )
})

test_that("group_rows and group_data work with 0 rows data frames (#3489)", {
  df <- tibble(x=integer())
  expect_identical(group_rows(df), list(integer()))
  expect_identical(group_rows(rowwise(df)), list())
  expect_identical(group_rows(group_by(df, x)), list(integer()))

  expect_identical(group_data(df), tibble(.rows = list(integer())))
  expect_identical(group_data(rowwise(df)), tibble(.rows =list()))
  expect_identical(group_data(group_by(df, x)), tibble(x = NA_integer_, .rows = list(integer())))
})

test_that("GroupDataFrame checks the structure of the groups attribute", {
  df <- group_by(tibble(x = 1:4, g = rep(1:2, each = 2)), g)
  groups <- attr(df, "groups")
  groups[[2]] <- 1:2
  attr(df, "groups") <- groups
  expect_error(group_data(df), "is a corrupt grouped_df")

  df <- group_by(tibble(x = 1:4, g = rep(1:2, each = 2)), g)
  groups <- attr(df, "groups")
  names(groups) <- c("g", "not.rows")
  attr(df, "groups") <- groups
  expect_error(group_data(df), "is a corrupt grouped_df")

  attr(df, "groups") <- tibble()
  expect_error(group_data(df), "is a corrupt grouped_df")

  attr(df, "groups") <- NA
  expect_error(group_data(df), "is a corrupt grouped_df")
})
