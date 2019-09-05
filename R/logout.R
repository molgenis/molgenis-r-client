#' Logout
#'
#' @param session the session to log out of
#'
#' @export
setGeneric(
  name = "logout",
  def = function(session)
  {
    standardGeneric("logout")
  }
)

#' @importFrom httr GET add_headers
#'
#' @describeIn logout Logout session
#'
#' @export
setMethod("logout", "MolgenisSession",
          function(session) {
            POST(
              path = "/api/v1/logout",
              handle = session@handle,
              config = add_headers('x-molgenis-token' = session@token)
            )
            session@token <<- "<NULL>"
          })