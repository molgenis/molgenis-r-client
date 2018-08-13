context("MOLGENIS Client API")

with_mock_api({
  test_that("login", {
    token <- molgenisApi::molgenis.login('test.molgenis.org', 'admin', 'admin')
    expect_equal("368b92dd01b54b5ebf93e6011106c040", token)
  })
  test_that("get", {
    entity <- molgenisApi::molgenis.get('test')
    expect_is(entity, 'data.frame')
    expect_is(entity$username, 'factor')
  })
  test_that("addAll", {
    entity <- molgenisApi::molgenis.addAll('test', c('1', '2'))
  })
})