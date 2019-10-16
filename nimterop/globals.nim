import sequtils, sets, tables

import regex

import "."/plugin

when not declared(CIMPORT):
  import "."/treesitter/api

const
  gAtoms {.used.} = @[
    "field_identifier",
    "identifier",
    "number_literal",
    "char_literal",
    "preproc_arg",
    "primitive_type",
    "sized_type_specifier",
    "type_identifier"
  ].toSet()

  gExpressions {.used.} = @[
    "parenthesized_expression",
    "bitwise_expression",
    "shift_expression",
    "math_expression",
    "escape_sequence"
  ].toSet()

  gEnumVals {.used.} = @[
    "identifier",
    "number_literal",
    "char_literal"
  ].concat(toSeq(gExpressions.items))

type
  Kind = enum
    exactlyOne
    oneOrMore     # +
    zeroOrMore    # *
    zeroOrOne     # ?
    orWithNext    # !

  Ast = object
    name*: string
    kind*: Kind
    recursive*: bool
    children*: seq[ref Ast]
    when not declared(CIMPORT):
      tonim*: proc (ast: ref Ast, node: TSNode, nimState: NimState)
    regex*: Regex

  AstTable {.used.} = TableRef[string, seq[ref Ast]]

  State = ref object
    compile*, defines*, headers*, includeDirs*, searchDirs*, symOverride*: seq[string]

    nocache*, nocomments*, debug*, past*, preprocess*, pnim*, pretty*, recurse*: bool

    code*, dynlib*, mode*, nim*, pluginSourcePath*: string

    onSymbol*: OnSymbol

  NimState {.used.} = ref object
    identifiers*: TableRef[string, string]

    commentStr*, constStr*, debugStr*, enumStr*, procStr*, typeStr*: string

    gState*: State

    currentHeader*, impShort*, sourceFile*: string

    data*: seq[tuple[name, val: string]]

    nodeBranch*: seq[string]

var
  gStateCT {.compiletime, used.} = new(State)

template nBl(s: typed): untyped {.used.} =
  (s.len != 0)

type CompileMode = enum
  c,
  cpp,

# TODO: can cligen accept enum instead of string?
const modeDefault {.used.} = $cpp # TODO: USE this everywhere relevant

when not declared(CIMPORT):
  export gAtoms, gExpressions, gEnumVals, Kind, Ast, AstTable, State, NimState, nBl, CompileMode, modeDefault
