/* Automatically generated nanopb header */
/* Generated by nanopb-0.4.5 */

#ifndef PB_SUBSTRAIT_SUBSTRAIT_ANY_PB_H_INCLUDED
#define PB_SUBSTRAIT_SUBSTRAIT_ANY_PB_H_INCLUDED
#include <pb.h>

#if PB_PROTO_HEADER_VERSION != 40
#error Regenerate this file with the current version of nanopb generator.
#endif

/* Struct definitions */
typedef struct _substrait_Any { 
    pb_callback_t type_url; 
    pb_callback_t value; 
} substrait_Any;


#ifdef __cplusplus
extern "C" {
#endif

/* Initializer values for message structs */
#define substrait_Any_init_default               {{{NULL}, NULL}, {{NULL}, NULL}}
#define substrait_Any_init_zero                  {{{NULL}, NULL}, {{NULL}, NULL}}

/* Field tags (for use in manual encoding/decoding) */
#define substrait_Any_type_url_tag               1
#define substrait_Any_value_tag                  2

/* Struct field encoding specification for nanopb */
#define substrait_Any_FIELDLIST(X, a) \
X(a, CALLBACK, SINGULAR, STRING,   type_url,          1) \
X(a, CALLBACK, SINGULAR, BYTES,    value,             2)
#define substrait_Any_CALLBACK pb_default_field_callback
#define substrait_Any_DEFAULT NULL

extern const pb_msgdesc_t substrait_Any_msg;

/* Defines for backwards compatibility with code written before nanopb-0.4.0 */
#define substrait_Any_fields &substrait_Any_msg

/* Maximum encoded size of messages (where known) */
/* substrait_Any_size depends on runtime parameters */

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif
