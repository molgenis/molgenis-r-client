#' @importFrom httr handle
setOldClass("handle")

#' Class MolgenisSession.
#'
#' A Session on a MOLGENIS server.
#'
#' @slot handle handle to access the server using httr
#' @slot token  authentication token, or "<NULL>" if not authenticated
#'
#' @import methods
#' @export
setClass(
  "MolgenisSession",
  representation = representation(handle = "handle", token = "character")
)

#' Create a MOLGENIS Session
#'
#' @return a [MolgenisSession] object.
#'
#' @param host  the MOLGENIS hostname
#'
#' @examples
#' Session("https://master.dev.molgenis.org/")
#'
#' @export
Session <- function(host) {
  new("MolgenisSession", handle = handle(host), token = "<NULL>")
}
