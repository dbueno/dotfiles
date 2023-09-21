(block_comment) @Comment
(line_comment) @Comment

"brie" @Keyword
"btree" @Keyword
"btree_delete" @Keyword
"eqrel" @Keyword
"inline" @Keyword
"magic" @Keyword
"no_inline" @Keyword
"no_magic" @Keyword
"override" @Keyword
"overridable" @Keyword
; Deprecated:
"input" @Keyword
"output" @Keyword
"printsize" @Keyword
".functor" @Keyword
".comp" @Keyword
".init" @Keyword
".pragma" @Keyword
".plan" @Keyword
; (directive directive: (_directive_qualifier) @Keyword)
".output" @Keyword
".input" @Keyword
".limitsize" @Keyword
".printsize" @Keyword
".type" @Keyword
".decl" @Keyword

"+" @Keyword
"-" @Keyword
"*" @Keyword
"/" @Keyword
"%" @Keyword
"^" @Keyword
"land" @Keyword
"lor" @Keyword
"lxor" @Keyword
"band" @Keyword
"bor" @Keyword
"bxor" @Keyword
"bshl" @Keyword
"bshr" @Keyword
"bshru" @Keyword
; Undocumented, but appear in Soufflé parser:
"&" @Keyword
"|" @Keyword
"&&" @Keyword
"||" @Keyword
"**" @Keyword
"^^" @Keyword
"<<" @Keyword
">>" @Keyword
">>>" @Keyword

"=" @Keyword
"!=" @Keyword
"<=" @Keyword
">=" @Keyword
"<" @Keyword
">" @Keyword

":-" @Keyword

"#include" @Include
"#define" @Define
; "#if" @Precondit
; "#ifdef" @Precondit
; "#ifndef" @Keyword
; "#endif" @Precondit

(preproc) @Comment

(relation_decl
  head: (ident) @Function)
(relation_decl
  attribute: (attribute type: (qualified_name) @Type))
(relation_decl
  attribute: (attribute var: (ident) @Identifier))

;(atom :relation (qualified_name)) @constant
(primitive_type) @Type
(type_synonym left: (ident) @Type)
(subtype left: (ident) @Type)
(type_union left: (ident) @Type)
(type_record left: (ident) @Type)
(adt left: (ident) @Type)

(subsumptive_rule ("<=") @Keyword)
(subsumptive_rule
  subsumes: (atom relation: (qualified_name) @Underlined))
; (subsumptive_rule
;   subsumes: (atom relation: (qualified_name) @Identifier))
(monotonic_rule
  head: (atom relation: (qualified_name) @Underlined))

(disjunction (";") @Keyword)
(conjunction (",") @Keyword)
