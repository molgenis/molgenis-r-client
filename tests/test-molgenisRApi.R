library(molgenisRApi)
library(httptest)
library(httr)

context("MOLGENIS R Client API")

with_mock_api({
  test_that("Login", {
    token <- molgenisRApi::molgenis.login('dev.molgenis.org', 'admin', 'admin')
  })
})

#capture_requests({
#  molgenisRApi::molgenis.login('https://molgenis113.gcc.rug.nl', 'admin', 'Scrap Award Crib Vagabond')
#})