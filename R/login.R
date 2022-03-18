#' Log in on a MOLGENIS server
#'
#' @param session  the current session
#' @param username the username to use to log in
#' @param password the password to use to log in
#'
#' @export
setGeneric(
  name = "login",
  def = function(session, username, password)
  {
    standardGeneric("login")
  }
)

#' @importFrom httr POST content
#'
#' @describeIn login Log in using username and password
#'
#' @export
setMethod("login", "MolgenisSession",
          function(session,
                   username,
                   password) {
            response <- POST(
              path = "/api/v1/login",
              body = list(username = username, password = password),
              encode = "json",
              handle = session@handle
            )
            session@token <<- content(response)$token
          })