/* Automatically generated nanopb header */
/* Generated by nanopb-0.4.6 */

#ifndef PB_SUBSTRAIT_SUBSTRAIT_PLAN_PB_H_INCLUDED
#define PB_SUBSTRAIT_SUBSTRAIT_PLAN_PB_H_INCLUDED
#include <pb.h>
#include "substrait/algebra.pb.h"
#include "substrait/extensions/extensions.pb.h"

#if PB_PROTO_HEADER_VERSION != 40
#error Regenerate this file with the current version of nanopb generator.
#endif

/* Struct definitions */
/* Describe a set of operations to complete.
 For compactness sake, identifiers are normalized at the plan level. */
typedef struct _substrait_Plan { 
    /* a list of yaml specifications this plan may depend on */
    pb_size_t extension_uris_count;
    struct _substrait_extensions_SimpleExtensionURI *extension_uris;
    /* a list of extensions this plan may depend on */
    pb_size_t extensions_count;
    struct _substrait_extensions_SimpleExtensionDeclaration *extensions;
    /* one or more relation trees that are associated with this plan. */
    pb_size_t relations_count;
    struct _substrait_PlanRel *relations;
    /* additional extensions associated with this plan. */
    struct _substrait_extensions_AdvancedExtension *advanced_extensions;
    /* A list of com.google.Any entities that this plan may use. Can be used to
 warn if some embedded message types are unknown. Note that this list may
 include message types that are ignorable (optimizations) or that are
 unused. In many cases, a consumer may be able to work with a plan even if
 one or more message types defined here are unknown. */
    pb_size_t expected_type_urls_count;
    char **expected_type_urls;
    /* Substrait version of the plan. Optional up to 0.17.0, required for later
 versions. */
    struct _substrait_Version *version;
} substrait_Plan;

/* Either a relation or root relation */
typedef struct _substrait_PlanRel { 
    pb_size_t which_rel_type;
    union {
        /* Any relation (used for references and CTEs) */
        struct _substrait_Rel *rel;
        /* The root of a relation tree */
        struct _substrait_RelRoot *root;
    } rel_type;
} substrait_PlanRel;

/* This message type can be used to deserialize only the version of a Substrait
 Plan message. This prevents deserialization errors when there were breaking
 changes between the Substrait version of the tool that produced the plan and
 the Substrait version used to deserialize it, such that a consumer can emit
 a more helpful error message in this case. */
typedef struct _substrait_PlanVersion { 
    struct _substrait_Version *version;
} substrait_PlanVersion;

typedef struct _substrait_Version { 
    /* Substrait version number. */
    uint32_t *major_number;
    uint32_t *minor_number;
    uint32_t *patch_number;
    /* If a particular version of Substrait is used that does not correspond to
 a version number exactly (for example when using an unofficial fork or
 using a version that is not yet released or is between versions), set this
 to the full git hash of the utilized commit of
 https://github.com/substrait-io/substrait (or fork thereof), represented
 using a lowercase hex ASCII string 40 characters in length. The version
 number above should be set to the most recent version tag in the history
 of that commit. */
    char *git_hash;
    /* Identifying information for the producer that created this plan. Under
 ideal circumstances, consumers should not need this information. However,
 it is foreseen that consumers may need to work around bugs in particular
 producers in practice, and therefore may need to know which producer
 created the plan. */
    char *producer;
} substrait_Version;


#ifdef __cplusplus
extern "C" {
#endif

/* Initializer values for message structs */
#define substrait_PlanRel_init_default           {0, {NULL}}
#define substrait_Plan_init_default              {0, NULL, 0, NULL, 0, NULL, NULL, 0, NULL, NULL}
#define substrait_PlanVersion_init_default       {NULL}
#define substrait_Version_init_default           {NULL, NULL, NULL, NULL, NULL}
#define substrait_PlanRel_init_zero              {0, {NULL}}
#define substrait_Plan_init_zero                 {0, NULL, 0, NULL, 0, NULL, NULL, 0, NULL, NULL}
#define substrait_PlanVersion_init_zero          {NULL}
#define substrait_Version_init_zero              {NULL, NULL, NULL, NULL, NULL}

/* Field tags (for use in manual encoding/decoding) */
#define substrait_Plan_extension_uris_tag        1
#define substrait_Plan_extensions_tag            2
#define substrait_Plan_relations_tag             3
#define substrait_Plan_advanced_extensions_tag   4
#define substrait_Plan_expected_type_urls_tag    5
#define substrait_Plan_version_tag               6
#define substrait_PlanRel_rel_tag                1
#define substrait_PlanRel_root_tag               2
#define substrait_PlanVersion_version_tag        6
#define substrait_Version_major_number_tag       1
#define substrait_Version_minor_number_tag       2
#define substrait_Version_patch_number_tag       3
#define substrait_Version_git_hash_tag           4
#define substrait_Version_producer_tag           5

/* Struct field encoding specification for nanopb */
#define substrait_PlanRel_FIELDLIST(X, a) \
X(a, POINTER,  ONEOF,    MESSAGE,  (rel_type,rel,rel_type.rel),   1) \
X(a, POINTER,  ONEOF,    MESSAGE,  (rel_type,root,rel_type.root),   2)
#define substrait_PlanRel_CALLBACK NULL
#define substrait_PlanRel_DEFAULT NULL
#define substrait_PlanRel_rel_type_rel_MSGTYPE substrait_Rel
#define substrait_PlanRel_rel_type_root_MSGTYPE substrait_RelRoot

#define substrait_Plan_FIELDLIST(X, a) \
X(a, POINTER,  REPEATED, MESSAGE,  extension_uris,    1) \
X(a, POINTER,  REPEATED, MESSAGE,  extensions,        2) \
X(a, POINTER,  REPEATED, MESSAGE,  relations,         3) \
X(a, POINTER,  OPTIONAL, MESSAGE,  advanced_extensions,   4) \
X(a, POINTER,  REPEATED, STRING,   expected_type_urls,   5) \
X(a, POINTER,  OPTIONAL, MESSAGE,  version,           6)
#define substrait_Plan_CALLBACK NULL
#define substrait_Plan_DEFAULT NULL
#define substrait_Plan_extension_uris_MSGTYPE substrait_extensions_SimpleExtensionURI
#define substrait_Plan_extensions_MSGTYPE substrait_extensions_SimpleExtensionDeclaration
#define substrait_Plan_relations_MSGTYPE substrait_PlanRel
#define substrait_Plan_advanced_extensions_MSGTYPE substrait_extensions_AdvancedExtension
#define substrait_Plan_version_MSGTYPE substrait_Version

#define substrait_PlanVersion_FIELDLIST(X, a) \
X(a, POINTER,  OPTIONAL, MESSAGE,  version,           6)
#define substrait_PlanVersion_CALLBACK NULL
#define substrait_PlanVersion_DEFAULT NULL
#define substrait_PlanVersion_version_MSGTYPE substrait_Version

#define substrait_Version_FIELDLIST(X, a) \
X(a, POINTER,  SINGULAR, UINT32,   major_number,      1) \
X(a, POINTER,  SINGULAR, UINT32,   minor_number,      2) \
X(a, POINTER,  SINGULAR, UINT32,   patch_number,      3) \
X(a, POINTER,  SINGULAR, STRING,   git_hash,          4) \
X(a, POINTER,  SINGULAR, STRING,   producer,          5)
#define substrait_Version_CALLBACK NULL
#define substrait_Version_DEFAULT NULL

extern const pb_msgdesc_t substrait_PlanRel_msg;
extern const pb_msgdesc_t substrait_Plan_msg;
extern const pb_msgdesc_t substrait_PlanVersion_msg;
extern const pb_msgdesc_t substrait_Version_msg;

/* Defines for backwards compatibility with code written before nanopb-0.4.0 */
#define substrait_PlanRel_fields &substrait_PlanRel_msg
#define substrait_Plan_fields &substrait_Plan_msg
#define substrait_PlanVersion_fields &substrait_PlanVersion_msg
#define substrait_Version_fields &substrait_Version_msg

/* Maximum encoded size of messages (where known) */
/* substrait_PlanRel_size depends on runtime parameters */
/* substrait_Plan_size depends on runtime parameters */
/* substrait_PlanVersion_size depends on runtime parameters */
/* substrait_Version_size depends on runtime parameters */

#ifdef __cplusplus
} /* extern "C" */
#endif

#endif
