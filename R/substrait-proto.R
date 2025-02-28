
#' Create 'Substrait' message objects
#'
#' The 'Substrait' system of objects is made up of a series of
#' nested types serializable to the Protocol Buffer binary format.
#' You can create these objects using [substrait_create()],
#' or the namespace-style constructor object [substrait]. Convert
#' an existing object to a Substrait message using [as_substrait()],
#' and convert an existing object back to an R object using
#' [from_substrait()].
#'
#' Under the hood, substrait objects are [raw()] vectors containing the
#' underlying binary protocol buffer serialization. This may not be
#' the case in the future, but is done here to separate the protocol
#' buffer reader/writer (currently RProtoBuf) from object conversion
#' to facilitate getting started on the conversion code.
#'
#' @param .qualified_name The fully qualified name of the message type
#'   or enum (e.g., "substrait.Type.Boolean")
#' @param ... Arguments passed to the constructor. rlang-style
#'   tidy dots are supported.
#'
#' @return An object of class "substrait_proto".
#' @export
#'
#' @examples
#' substrait_create("substrait.Type.Boolean", type_variation_reference = 1)
#' substrait$Type$Boolean$create(type_variation_reference = 1)
#'
substrait_create <- function(.qualified_name, ...) {
  stopifnot(is.character(.qualified_name), length(.qualified_name) == 1)
  parts <- strsplit(.qualified_name, ".", fixed = TRUE)[[1]]

  # This bit of indirection is to get a nice stack trace when an error
  # is thrown and to support tidy dots in ... (might not be necessary).
  expr <- substrait_create_constructor_expr(c(parts, "create"))
  call <- rlang::call2(expr, ...)
  rlang::eval_tidy(call, env = parent.frame())
}

substrait_create_constructor_expr <- function(item) {
  if (length(item) == 1) {
    call("::", as.symbol("substrait"), as.symbol(item))
  } else {
    call(
      "$",
      substrait_create_constructor_expr(item[-length(item)]),
      as.symbol(item[length(item)])
    )
  }
}

substrait_proto_auto <- function(...) {
  values <- rlang::list2(...)
  stopifnot(rlang::is_named2(values))
  structure(values, class = "substrait_proto_auto")
}

#' Convert to and from 'Substrait' messages
#'
#' @param x An object to convert to or from a 'Substrait' message.
#'   Note that both `as_substrait()` and `from_substrait()` dispatch
#'   on `x`.
#' @param msg A substrait message (e.g., created using [substrait_create()]).
#' @param ... Passed to S3 methods
#' @param .ptype A string of the `.qualified_name` or a prototype message
#'   of the correct type.
#'
#' @return An RProtoBuf::Message or substrait_proto_message (e.g.,
#'   created by [substrait_create()])
#' @export
#'
#' @examples
#' as_substrait(substrait$Type$Boolean$create(type_variation_reference = 1))
#'
as_substrait <- function(x, .ptype = NULL, ...) {
  UseMethod("as_substrait", x)
}

#' @rdname as_substrait
#' @export
from_substrait <- function(msg, x, ...) {
  stopifnot(inherits(msg, "substrait_proto_message"))
  UseMethod("from_substrait", x)
}

#' @export
as_substrait.default <- function(x, .ptype = NULL, ...) {
  if (is.null(.ptype)) {
    stop(
      sprintf(
        "Can't create substrait message from object of type '%s'",
        paste(class(x), collapse = " / ")
      )
    )
  } else {
    stop(
      sprintf(
        "Can't create %s from object of type '%s'",
        make_qualified_name(.ptype),
        paste(class(x), collapse = " / ")
      )
    )
  }
}

#' @export
from_substrait.default <- function(msg, x, ...) {
  .qualified_name <- gsub("_", ".", class(msg)[1])
  stop(
    sprintf(
      "Can't restore %s to object of type '%s'",
      .qualified_name,
      paste(class(x), collapse = " / ")
    )
  )
}

#' @export
from_substrait.substrait_proto_message <- function(msg, x, ...) {
  .qualified_name <- make_qualified_name(msg)
  qualified_name_x <- make_qualified_name(x)
  stopifnot(identical(.qualified_name, qualified_name_x))
  msg
}

#' @export
as_substrait.substrait_proto_message <- function(x, .ptype = NULL, ...) {
  .qualified_name <- make_qualified_name(.ptype)
  if (is.null(.qualified_name)) {
    return(x)
  }

  x_qualified_name <- gsub("_", ".", class(x)[1])
  stopifnot(identical(x_qualified_name, .qualified_name))

  x
}

# these helpers help get the .ptype to and from a .qualified_name
make_ptype <- function(.qualified_name) {
  if (inherits(.qualified_name, "substrait_proto_message")) {
    .qualified_name
  } else {
    structure(
      list(content = raw()),
      class = c(
        gsub("\\.", "_", .qualified_name),
        "substrait_proto_message",
        "substrait_proto"
      )
    )
  }
}

make_qualified_name <- function(.ptype) {
  if (inherits(.ptype, "substrait_proto_message")) {
    gsub("_", ".", class(.ptype)[1])
  } else {
    .ptype
  }
}

# The above functions should be the entry point to creating these objects
# to other code in this package. The below functions are internal and
# designed to make the generated code in types-generated.R work. The idea
# is that creating objects using `substrait$Something$create()` and
# `substrait_create("substrait.Something", ...)` will both be stable regardless
# of the backend used to serialize and deserialize protobufs.
create_substrait_message <- function(..., .qualified_name) {
  lst <- rlang::list2(...)
  lst <- lst[!vapply(lst, inherits, logical(1), "substrait_proto_unspecified")]

  descriptor <- RProtoBuf::P(.qualified_name)
  message <- rlang::exec(descriptor$new, !!!lst)

  structure(
    list(content = message$serialize(NULL)),
    class = c(
      gsub("\\.", "_", .qualified_name),
      "substrait_proto_message",
      "substrait_proto"
    )
  )
}

create_substrait_enum <- function(value, .qualified_name, descriptor = NULL) {
  descriptor <- descriptor %||% RProtoBuf::P(.qualified_name)

  if (length(value) != 1) {
    result <- vapply(value, create_substrait_enum, integer(1), .qualified_name, descriptor)
    return(
      structure(
        result,
        class = c(
          gsub("\\.", "_", .qualified_name),
          "substrait_proto_enum",
          "substrait_proto"
        )
      )
    )
  }

  if (is.character(value)) {
    pb_value <- descriptor$value(name = value)
  } else if (is.numeric(value)) {
    pb_value <- descriptor$value(number = value)
  } else {
    stop("Expected character identifier or integer for enum value", call. = FALSE)
  }

  if (is.null(pb_value)) {
    stop(
      sprintf(
        "'%s' is not a valid identifier for enum %s",
        value,
        .qualified_name
      ),
      call. = FALSE
    )
  }

  structure(
    pb_value$number(),
    class = c(
      gsub("\\.", "_", .qualified_name),
      "substrait_proto_enum",
      "substrait_proto"
    )
  )
}

arg_unspecified <- function() {
  structure(list(), class = "substrait_proto_unspecified")
}

clean_value <- function(value, type, .qualified_name, repeated = FALSE) {
  if (inherits(value, "substrait_proto_unspecified")) {
    return(value)
  }

  switch(type,
    TYPE_ENUM = create_substrait_enum(value, .qualified_name),
    TYPE_MESSAGE = {
      if (repeated && !rlang::is_bare_list(value)) {
        stop(
          sprintf(
            "Repeated %s field must be wrapped in `list()`",
            .qualified_name
          ),
          call. = FALSE
        )
      }

      if (repeated) {
        lapply(value, clean_value, type, .qualified_name)
      } else if (inherits(value, "Message")) {
        value
      } else if (inherits(value, "substrait_proto_message")) {
        descriptor <- RProtoBuf::P(.qualified_name)
        return(descriptor$read(as.raw(value)))
      } else if (inherits(value, "substrait_proto_auto")) {
        clean_value(
          substrait_create(.qualified_name, !!!unclass(value)),
          type,
          .qualified_name
        )
      } else {
        stop(
          sprintf(
            "Can't create %s from object of type %s",
            .qualified_name,
            paste0("'", class(value), "'", collapse = " / ")
          ),
          call. = FALSE
        )
      }
    },
    # eventually this should validate the value in some way...as it is now
    # this will get validated by RProtoBuf in the call to descriptor$new()
    value
  )
}

#' @export
print.substrait_proto_message <- function(x, ...) {
  .qualified_name <- gsub("_", ".", class(x)[1])
  descriptor <- RProtoBuf::P(.qualified_name)
  pb_message <- descriptor$read(as.raw(x))

  print(pb_message, ...)
  cat(pb_message$toString())

  invisible(x)
}

#' @export
as.list.substrait_proto_message <- function(x, ..., recursive = FALSE) {
  .qualified_name <- make_qualified_name(x)
  descriptor <- RProtoBuf::P(.qualified_name)
  pb_message <- descriptor$read(as.raw(x))

  msg_names <- names(pb_message)
  msg_names <- msg_names[vapply(msg_names, pb_message$has, logical(1))]
  out <- lapply(msg_names, function(e) pb_message[[e]])
  names(out) <- msg_names

  fields <- lapply(seq_len(descriptor$field_count()), function(i) descriptor$field(i))
  names(fields) <- vapply(fields, function(f) f$name(), character(1))
  is_message <- vapply(
    names(out),
    function(name) fields[[name]]$type() == RProtoBuf::TYPE_MESSAGE,
    logical(1)
  )
  is_repeated <- vapply(
    names(out),
    function(name) fields[[name]]$is_repeated(),
    logical(1)
  )

  out[is_message & is_repeated] <- lapply(
    out[is_message & is_repeated],
    lapply,
    as_substrait
  )

  out[is_message & !is_repeated] <- lapply(
    out[is_message & !is_repeated],
    as_substrait
  )

  if (recursive) {
    out[is_message] <- lapply(
      out[is_message],
      as.list,
      list(),
      recursive = TRUE
    )
  }

  out
}

#' @export
names.substrait_proto_message <- function(x) {
  lst <- as.list(x)
  nm <- names(lst)
  nm %||% rep("", length(x))
}

#' @export
length.substrait_proto_message <- function(x) {
  lst <- as.list(x)
  length(lst)
}

#' @export
`[[.substrait_proto_message` <- function(x, i) {
  as.list(x)[[i]]
}

#' @export
`[[<-.substrait_proto_message` <- function(x, i, value) {
  lst <- as.list(x)
  lst[[i]] <- value
  substrait_create(gsub("_", ".", class(x)[1]), !!!lst)
}

#' @export
`$.substrait_proto_message` <- function(x, name) {
  as.list(x)[[name]]
}

#' @export
`$<-.substrait_proto_message` <- function(x, name, value) {
  lst <- as.list(x)
  lst[[name]] <- value
  substrait_create(gsub("_", ".", class(x)[1]), !!!lst)
}

#' @export
as.raw.substrait_proto_message <- function(x, ...) {
  unclass(x)$content
}

#' @export
print.substrait_proto_enum <- function(x, ...) {
  .qualified_name <- gsub("_", ".", class(x)[1])
  descriptor <- RProtoBuf::P(.qualified_name)

  pb_value <- lapply(unclass(x), function(e) descriptor$value(number = e))
  numbers <- vapply(pb_value, function(e) e$number(), integer(1))
  labels <- vapply(pb_value, function(e) e$name(), character(1))

  cat(sprintf("<%s[%d]>\n", .qualified_name, length(pb_value)))
  for (i in seq_along(numbers)) {
    cat(sprintf("- %s = %d\n", labels[i], numbers[i]))
  }

  invisible(x)
}
