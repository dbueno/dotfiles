; comments

(block_comment) @comment
(line_comment) @comment

; keywords

(primitive_type) @type.builtin
"brie" @keyword
"btree" @keyword
"btree_delete" @keyword
"eqrel" @keyword
; "inline" @keyword
"magic" @keyword
"no_inline" @keyword
"no_magic" @keyword
"override" @keyword
"overridable" @keyword
; Deprecated:
"input" @keyword
"output" @keyword
"printsize" @keyword
".functor" @keyword
".comp" @keyword
".init" @keyword
".pragma" @keyword
".plan" @keyword
".type" @keyword
".decl" @keyword
;(relation_decl choice: (choice_domain (ident)) @keyword)

"+" @keyword
"-" @keyword
"*" @keyword
"/" @keyword
"%" @keyword
"^" @keyword
"land" @keyword
"lor" @keyword
"lxor" @keyword
"band" @keyword
"bor" @keyword
"bxor" @keyword
"bshl" @keyword
"bshr" @keyword
"bshru" @keyword
; Undocumented, but appear in Soufflé parser:
"&" @keyword
"|" @keyword
"&&" @keyword
"||" @keyword
"**" @keyword
"^^" @keyword
"<<" @keyword
">>" @keyword
">>>" @keyword

"=" @keyword
"!=" @keyword
"<=" @keyword
">=" @keyword
"<" @keyword
">" @keyword
[".input" ".limitsize" ".output" ".printsize"] @keyword
["brie" "btree" "btree_delete" "eqrel" "inline" "magic" "no_inline" "no_magic" "override" "overridable" "input" "output" "printsize"] @keyword

["acos" "acosh" "asin" "asinh" "atan" "atanh" "cos" "cosh" "exp" "log" "sin" "sinh" "tan" "tanh" "autoinc" "cat" "max" "min" "ord" "strlen" "substr" "to_float" "to_number" "to_string" "to_unsigned" "mean" "sum" "count" "range"] @keyword


;(intrinsic_functor) @keyword

(unary_op operator: "bnot" @keyword)
(unary_op operator: "lnot" @keyword)
(unary_op operator: "~" @keyword)
(unary_op operator: "!" @keyword)

(preprocessor) @keyword

(preproc_include (string)) @string.special

(preprocessor) @keyword

(pragma key: (string) @string)
(pragma value: (string) @string)

(functor_decl name: (ident) @function)

(component_decl (":" (component_type)* @type))
(component_type name: (ident) @function)
(component_type param: (ident) @type)

(directive key: (ident) @tag)

(monotonic_rule (atom relation: (qualified_name) @constructor))
(monotonic_rule ":-" @keyword)

(subsumptive_rule subsumes: (atom relation: (qualified_name) @underlined))
(subsumptive_rule ":-" @keyword)

(disjunction (";") @keyword)
(conjunction (",") @keyword)

(match "match" @keyword)
(contains "contains" @keyword)

(fact (atom relation: (qualified_name) @constructor))

(adt_constructor constructor: (qualified_name) @constructor)

(string) @string
(include_string) @string
(constant) @constant.builtin

(as "as") @keyword

(user_defined_functor ("@" (ident)) @constructor)


(relation_decl (ident) @function)
(relation_decl
  attribute: (attribute var: (ident) @variable.parameter))
(relation_decl
  attribute: (attribute type: (qualified_name) @type))

(relation_decl choice: (choice_domain (ident) @variable.parameter) @keyword)

(primitive_type) @type
(type_synonym left: (ident) @type)
(subtype left: (ident) @type)
(type_union left: (ident) @type)
(type_record left: (ident) @type)
(adt left: (ident) @type)


