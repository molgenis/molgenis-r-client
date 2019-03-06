#' Retrieve data
#'
#' @param session      the current session
#' @param entityTypeID the entityTypeID to retrieve
#' @param query        list with query parameters
#'
#' @return content of the response
#'
#' @export
setGeneric(
  name = "get",
  def = function(session, entityTypeID, query = list())
  {
    standardGeneric("get")
  }
)

#' @importFrom httr GET add_headers
#'
#' @describeIn get Get using MolgenisSession
#'
#' @export
setMethod("get", "MolgenisSession",
          function(session,
                   entityTypeID,
                   query) {
            if (session@token != "<NULL>") {
              config <- add_headers("x-molgenis-token" = session@token)
            } else {
              config <- list()
            } 
            
            content(GET(
                path = paste0("/api/v2/", entityTypeID),
                handle = session@handle,
                query = query,
                config = config
              ))
          })