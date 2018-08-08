#' Write tikz drawing
#'
#' Creates a tikz drawing from a simple document based on the `standalone` LaTeX
#' document class. Optionally converts to an image in the format specified by
#' the `path` extension.
#'
#' @examples
#' write_tikz("\\draw [step=0.5] (-1.4,-1.4) grid (1.4,1.4);",
#'            tempfile(fileext = ".pdf"))
#'
#' @param tikz_text <chr> Character string of tikz commands
#' @param path <chr> File name for drawing output
#' @param tikz_library <chr> A vector or character string of tikz libraries that
#'   are required to compile the tikz drawing. Ex.
#'   `c("calc", "fit", "shapes", "arrows")`
#' @param tikz_style <list> A named list of tikz style definitions, e.g.
#'   `list(circle = "draw, ellipse")` will be converted to
#'   `\\tikzstyle{cloud} = [draw, ellipse]`.
#' @param tikz_picture <chr> A vector or character string of options to be
#'   passed to the `\\begin{tikzpicture}[...]` command.
#' @param class_options <chr> A vector of character string of options to be
#'   passed to the `standalone` document class.
#' @inheritDotParams tinytex::latexmk
#' @param density resolution to render raster image output via
#'   [magick::image_write]
#' @export
write_tikz <- function(
  tikz_text,
  path,
  tikz_library = NULL,
  tikz_style = NULL,
  tikz_picture = NULL,
  class_options = NULL,
  ...,
  density = 72
) {
  out_format <- tools::file_ext(tolower(path))
  if (!out_format %in% c("pdf", "png", "jpeg", "gif")) {
    rlang::abort(
      glue::glue("'{out_format}' is not a supported extension of `write_tikz()`")
    )
  }

  tikz_text <- collapse_line(tikz_text)
  tikz_library <- if_not_missing(tikz_library,
    wrap(collapse_comma(tikz_library), "\\usetikzlibrary{", "}"))
  class_options <- if_not_missing(class_options,
    wrap(collapse_comma(class_options), "[", "]"))
  tikz_style <- if (!is.null(tikz_style)) {
    tikz_style %>%
      purrr::imap_chr(~ glue::glue("\\tikzstyle{{{.y}}} = [{.x}]")) %>%
      paste(collapse = "\n")
  } else ""

  tikz_picture <- if_not_missing(tikz_picture, collapse_comma(tikz_picture))


  tmpfile <- tempfile(fileext = ".tex")
  x <- readLines(system.file("base_tikz.tex", package = "flowchaRt"))
  x <- glue::glue(collapse_line(x), .open = "{{", .close = "}}")

  message("writing temp tex file to: ", tmpfile)
  cat(x, file = tmpfile)

  tex_path <- if (out_format == "pdf") path else tempfile(fileext = ".pdf")
  tinytex::latexmk(tmpfile, pdf_file = tex_path, ...)

  if (out_format %in% c("png", "jpeg", "gif")) {
    message("converting to ", out_format, ": ", tex_path)
    magick::image_write(
      magick::image_read_pdf(tex_path),
      path,
      format = out_format,
      density = density
    )
  }

  if (interactive()) utils::browseURL(path)
  path
}