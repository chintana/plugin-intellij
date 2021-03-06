grammar Ballerina;

//todo comment statment
//todo revisit blockStatement

// starting point for parsing a bal file
compilationUnit
    :   packageDeclaration?
        importDeclaration*
        (annotationAttachment* definition)*
        EOF
    ;

packageDeclaration
    :   'package' packagePath ';'
    ;

importDeclaration
    :   'import' packagePath ('as' alias)? ';'
    ;

packagePath
    :   (packageName '.')* packageName
    ;

packageName
    :   Identifier
    ;

alias
    :   packageName
    ;

definition
    :   serviceDefinition
    |   functionDefinition
    |   connectorDefinition
    |   structDefinition
    |   typeMapperDefinition
    |   constantDefinition
    |   annotationDefinition
    ;

serviceDefinition
    :   'service' Identifier '{' serviceBody '}'
    ;

serviceBody
    :   variableDefinitionStatement* resourceDefinition*
    ;

resourceDefinition
    :   annotationAttachment* 'resource' Identifier '(' parameterList ')' '{' callableUnitBody '}'
    ;

callableUnitBody
    :   workerDeclaration* statement*
    ;

functionDefinition
    :   'native' 'function' Identifier '(' parameterList? ')' returnParameters? ('throws' 'exception')? ';'
    |   'function' Identifier '(' parameterList? ')' returnParameters? ('throws' 'exception')? '{' callableUnitBody '}'
    ;

connectorDefinition
    :   'connector' Identifier '(' parameterList? ')' '{' connectorBody '}'
    ;

connectorBody
    :   variableDefinitionStatement* actionDefinition*
    ;

actionDefinition
    :   annotationAttachment* 'native' 'action' Identifier '(' parameterList? ')' returnParameters? ('throws' 'exception')? ';'
    |   annotationAttachment* 'action' Identifier '(' parameterList? ')' returnParameters? ('throws' 'exception')? '{' callableUnitBody '}'
    ;

structDefinition
    :   'struct' Identifier '{' structBody '}'
    ;

structBody
    :   fieldDefinition*
    ;

annotationDefinition
    : 'annotation' Identifier ('attach' attachmentPoint (',' attachmentPoint)*)? '{' annotationBody '}'
    ;

attachmentPoint
     : 'service'
     | 'resource'
     | 'connector'
     | 'action'
     | 'function'
     | 'typemapper'
     | 'struct'
     | 'const'
     | 'parameter'
     ;

annotationBody
    :   fieldDefinition*
    ;

typeMapperDefinition
    :   'native' 'typemapper' Identifier '(' parameter ')' '('typeName')' ';'
    |   'typemapper' Identifier '(' parameter ')' '('typeName')' '{' typeMapperBody '}'
    ;

typeMapperBody
    :   statement*
    ;

constantDefinition
    :   'const' valueTypeName Identifier '=' simpleLiteral ';'
    ;

workerDeclaration
    :   'worker' Identifier '(' 'message' Identifier ')'  '{' statement* '}'
    ;

typeName
    :   'any'
    |   valueTypeName
    |   referenceTypeName
    |   typeName ('[' ']')+
    ;

referenceTypeName
    :   builtInReferenceTypeName
    |   nameReference
    ;

valueTypeName
    :   'boolean'
    |   'int'
    |   'float'
    |   'string'
    ;

builtInReferenceTypeName
    :   'message'
    |   'map' ('<' typeName '>')?
    |   'exception'
    |   'xml' ('<' ('{' xmlNamespaceName '}')? xmlLocalName '>')?
    |   'xmlDocument' ('<' ('{' xmlNamespaceName '}')? xmlLocalName '>')?
    |   'json' ('<' '{' QuotedStringLiteral '}' '>')?
    |   'datatable'
    ;

xmlNamespaceName
    :   QuotedStringLiteral
    ;

xmlLocalName
    :   Identifier
    ;

 annotationAttachment
     :   '@' nameReference '{' annotationAttributeList? '}'
     ;

 annotationAttributeList
     :   annotationAttribute (',' annotationAttribute)*
     ;

 annotationAttribute
     :    Identifier ':' annotationAttributeValue
     ;

 annotationAttributeValue
     :   simpleLiteral
     |   annotationAttachment
     |   annotationAttributeArray
     ;

 annotationAttributeArray
     :   '[' (annotationAttributeValue (',' annotationAttributeValue)*)? ']'
     ;

 //============================================================================================================
// STATEMENTS / BLOCKS

statement
    :   variableDefinitionStatement
    |   assignmentStatement
    |   ifElseStatement
    |   iterateStatement
    |   whileStatement
    |   continueStatement
    |   breakStatement
    |   forkJoinStatement
    |   tryCatchStatement
    |   throwStatement
    |   returnStatement
    |   replyStatement
    |   workerInteractionStatement
    |   commentStatement
    |   actionInvocationStatement
    |   functionInvocationStatement
    ;

variableDefinitionStatement
    :   typeName Identifier ('=' (connectorInitExpression | actionInvocation | expression) )? ';'
    ;

mapStructLiteral
    :   '{' (mapStructKeyValue (',' mapStructKeyValue)*)? '}'
    ;

mapStructKeyValue
    :   expression ':' expression
    ;

arrayLiteral
    :   '[' expressionList? ']'
    ;

connectorInitExpression
    :   'create' nameReference '(' expressionList? ')'
    ;

assignmentStatement
    :   variableReferenceList '=' (connectorInitExpression | actionInvocation | expression) ';'
    ;

variableReferenceList
    :   variableReference (',' variableReference)*
    ;

ifElseStatement
    :   'if' '(' expression ')' '{' statement* '}' ('else' 'if' '(' expression ')' '{' statement* '}')* ('else' '{' statement* '}')?
    ;

//todo replace with 'foreach'
iterateStatement
    :   'iterate' '(' typeName Identifier ':' expression ')' '{' statement* '}'
    ;

whileStatement
    :   'while' '(' expression ')' '{' statement* '}'
    ;

continueStatement
    :   'continue' ';'
    ;

breakStatement
    :   'break' ';'
    ;

// typeName is only message
forkJoinStatement
    :   'fork' '(' variableReference ')' '{' workerDeclaration* '}' joinClause? timeoutClause?
    ;

// below typeName is only 'message[]'
joinClause
    :   'join' ('(' joinConditions ')')? '(' typeName Identifier ')' '{' statement* '}'
    ;

joinConditions
    :   'some' IntegerLiteral (Identifier (',' Identifier)*)? 	# anyJoinCondition
    |   'all' (Identifier (',' Identifier)*)? 		            # allJoinCondition
    ;

// below typeName is only 'message[]'
timeoutClause
    :   'timeout' '(' expression ')' '(' typeName Identifier ')'  '{' statement* '}'
    ;

tryCatchStatement
    :   'try' '{' statement* '}' 'catch' '(' 'exception' Identifier ')' '{' statement* '}'
    ;

throwStatement
    :   'throw' expression ';'
    ;

returnStatement
    :   'return' expressionList? ';'
    ;

// below Identifier is only a type of 'message'
replyStatement
    :   'reply' expression ';'
    ;

workerInteractionStatement
    :   triggerWorker
    |   workerReply
    ;

// below left Identifier is of type 'message' and the right Identifier is of type 'worker'
triggerWorker
    :   Identifier '->' Identifier ';'
    ;

// below left Identifier is of type 'worker' and the right Identifier is of type 'message'
workerReply
    :   Identifier '<-' Identifier ';'
    ;

commentStatement
    :   LINE_COMMENT
    ;

variableReference
    :   Identifier                                  # simpleVariableIdentifier// simple identifier
    |   Identifier ('['expression']')+              # mapArrayVariableIdentifier// arrays and map reference
    |   variableReference ('.' variableReference)+  # structFieldIdentifier// struct field reference
    ;

expressionList
    :   expression (',' expression)*
    ;

functionInvocationStatement
    :   nameReference '(' expressionList? ')' ';'
    ;

actionInvocationStatement
    :   actionInvocation ';'
    |   variableReferenceList '=' actionInvocation ';'
    ;

actionInvocation
    :   nameReference '.' Identifier '(' expressionList? ')'
    ;

backtickString
    :   BacktickStringLiteral
    ;

expression
    :   simpleLiteral                                   # simpleLiteralExpression
    |   arrayLiteral                                    # arrayLiteralExpression
    |   mapStructLiteral                                # mapStructLiteralExpression
    |   valueTypeName '.' Identifier                    # valueTypeTypeExpression
    |   builtInReferenceTypeName '.' Identifier         # builtInReferenceTypeTypeExpression
    |   variableReference                               # variableReferenceExpression
    |   backtickString                                  # templateExpression
    |   nameReference '(' expressionList? ')'           # functionInvocationExpression
    |   '(' typeName ')' expression                     # typeCastingExpression
    |   ('+' | '-' | '!') expression                    # unaryExpression
    |   '(' expression ')'                              # bracedExpression
    |   expression '^' expression                       # binaryPowExpression
    |   expression ('/' | '*' | '%') expression         # binaryDivMulModExpression
    |   expression ('+' | '-') expression               # binaryAddSubExpression
    |   expression ('<=' | '>=' | '>' | '<') expression # binaryCompareExpression
    |   expression ('==' | '!=') expression             # binaryEqualExpression
    |   expression '&&' expression                      # binaryAndExpression
    |   expression '||' expression                      # binaryOrExpression
    ;

//reusable productions

nameReference
    :   (packageName ':')? Identifier
    ;

returnParameters
    : '(' (parameterList | returnTypeList) ')'
    ;

returnTypeList
    :   typeName (',' typeName)*
    ;

parameterList
    :   parameter (',' parameter)*
    ;

parameter
    :   annotationAttachment* typeName Identifier
    ;

fieldDefinition
    :   typeName Identifier ('=' simpleLiteral)? ';'
    ;

simpleLiteral
    :   IntegerLiteral
    |   FloatingPointLiteral
    |   QuotedStringLiteral
    |   BooleanLiteral
    |   NullLiteral
    ;

// LEXER

// §3.9 Ballerina keywords
ACTION          : 'action';
ALL             : 'all';
ANNOTATION      : 'annotation';
ANY             : 'any';
AS              : 'as';
ATTACH          : 'attach';
BREAK           : 'break';
CATCH           : 'catch';
CONNECTOR       : 'connector';
CONST           : 'const';
CONTINUE        : 'continue';
CREATE          : 'create';
ELSE            : 'else';
FORK            : 'fork';
FUNCTION        : 'function';
IF              : 'if';
IMPORT          : 'import';
ITERATE         : 'iterate';
JOIN            : 'join';
NATIVE          : 'native';
NULL            : 'null';
PACKAGE         : 'package';
REPLY           : 'reply';
RESOURCE        : 'resource';
RETURN          : 'return';
SERVICE         : 'service';
SOME            : 'some';
STRUCT          : 'struct';
THROW           : 'throw';
THROWS          : 'throws';
TIMEOUT         : 'timeout';
TRY             : 'try';
TYPEMAPPER      : 'typemapper';
WHILE           : 'while';
WORKER          : 'worker';

BOOLEAN         : 'boolean';
INT             : 'int';
FLOAT           : 'float';
STRING          : 'string';

MESSAGE         : 'message';
MAP             : 'map';
EXCEPTION       : 'exception';
XML             : 'xml';
XML_DOCUMENT    : 'xmlDocument';
JSON            : 'json';
DATATABLE       : 'datatable';

// Other tokens
SENDARROW       : '->';
RECEIVEARROW    : '<-';

LPAREN          : '(';
RPAREN          : ')';
LBRACE          : '{';
RBRACE          : '}';
LBRACK          : '[';
RBRACK          : ']';
SEMI            : ';';
COMMA           : ',';
DOT             : '.';

ASSIGN          : '=';
GT              : '>';
LT              : '<';
BANG            : '!';
TILDE           : '~';
COLON           : ':';
EQUAL           : '==';
LE              : '<=';
GE              : '>=';
NOTEQUAL        : '!=';
AND             : '&&';
OR              : '||';
ADD             : '+';
SUB             : '-';
MUL             : '*';
DIV             : '/';
BITAND          : '&';
BITOR           : '|';
CARET           : '^';
MOD             : '%';
AT              : '@';
SINGLEQUOTE     : '\'';
DOUBLEQUOTE     : '"';
BACKTICK        : '`';

// §3.10.1 Integer Literals
IntegerLiteral
    :   DecimalIntegerLiteral
    |   HexIntegerLiteral
    |   OctalIntegerLiteral
    |   BinaryIntegerLiteral
    ;

fragment
DecimalIntegerLiteral
    :   DecimalNumeral IntegerTypeSuffix?
    ;

fragment
HexIntegerLiteral
    :   HexNumeral IntegerTypeSuffix?
    ;

fragment
OctalIntegerLiteral
    :   OctalNumeral IntegerTypeSuffix?
    ;

fragment
BinaryIntegerLiteral
    :   BinaryNumeral IntegerTypeSuffix?
    ;

fragment
IntegerTypeSuffix
    :   [lL]
    ;

fragment
DecimalNumeral
    :   '0'
    |   NonZeroDigit (Digits? | Underscores Digits)
    ;

fragment
Digits
    :   Digit (DigitOrUnderscore* Digit)?
    ;

fragment
Digit
    :   '0'
    |   NonZeroDigit
    ;

fragment
NonZeroDigit
    :   [1-9]
    ;

fragment
DigitOrUnderscore
    :   Digit
    |   '_'
    ;

fragment
Underscores
    :   '_'+
    ;

fragment
HexNumeral
    :   '0' [xX] HexDigits
    ;

fragment
HexDigits
    :   HexDigit (HexDigitOrUnderscore* HexDigit)?
    ;

fragment
HexDigit
    :   [0-9a-fA-F]
    ;

fragment
HexDigitOrUnderscore
    :   HexDigit
    |   '_'
    ;

fragment
OctalNumeral
    :   '0' Underscores? OctalDigits
    ;

fragment
OctalDigits
    :   OctalDigit (OctalDigitOrUnderscore* OctalDigit)?
    ;

fragment
OctalDigit
    :   [0-7]
    ;

fragment
OctalDigitOrUnderscore
    :   OctalDigit
    |   '_'
    ;

fragment
BinaryNumeral
    :   '0' [bB] BinaryDigits
    ;

fragment
BinaryDigits
    :   BinaryDigit (BinaryDigitOrUnderscore* BinaryDigit)?
    ;

fragment
BinaryDigit
    :   [01]
    ;

fragment
BinaryDigitOrUnderscore
    :   BinaryDigit
    |   '_'
    ;

// §3.10.2 Floating-Point Literals

FloatingPointLiteral
    :   DecimalFloatingPointLiteral
    |   HexadecimalFloatingPointLiteral
    ;

fragment
DecimalFloatingPointLiteral
    :   Digits '.' Digits? ExponentPart? FloatTypeSuffix?
    |   '.' Digits ExponentPart? FloatTypeSuffix?
    |   Digits ExponentPart FloatTypeSuffix?
    |   Digits FloatTypeSuffix
    ;

fragment
ExponentPart
    :   ExponentIndicator SignedInteger
    ;

fragment
ExponentIndicator
    :   [eE]
    ;

fragment
SignedInteger
    :   Sign? Digits
    ;

fragment
Sign
    :   [+-]
    ;

fragment
FloatTypeSuffix
    :   [fFdD]
    ;

fragment
HexadecimalFloatingPointLiteral
    :   HexSignificand BinaryExponent FloatTypeSuffix?
    ;

fragment
HexSignificand
    :   HexNumeral '.'?
    |   '0' [xX] HexDigits? '.' HexDigits
    ;

fragment
BinaryExponent
    :   BinaryExponentIndicator SignedInteger
    ;

fragment
BinaryExponentIndicator
    :   [pP]
    ;

// §3.10.3 Boolean Literals

BooleanLiteral
    :   'true'
    |   'false'
    ;

// §3.10.5 String Literals

QuotedStringLiteral
    :   '"' StringCharacters? ('"')?
    ;

BacktickStringLiteral
   :   '`' ValidBackTickStringCharacters '`'
   ;
fragment
ValidBackTickStringCharacters
   :     ValidBackTickStringCharacter+
   ;

fragment
ValidBackTickStringCharacter
   :   ~[`]
   |   '\\' [btnfr\\]
   |   OctalEscape
   |   UnicodeEscape
   ;

fragment
StringCharacters
    :   StringCharacter+
    ;

fragment
StringCharacter
    :   ~["]
    |   EscapeSequence
    ;

// §3.10.6 Escape Sequences for Character and String Literals

fragment
EscapeSequence
    :   '\\' ["'\\]
    |   OctalEscape
    |   UnicodeEscape
    ;

fragment
OctalEscape
    :   '\\' OctalDigit
    |   '\\' OctalDigit OctalDigit
    |   '\\' ZeroToThree OctalDigit OctalDigit
    ;

fragment
UnicodeEscape
    :   '\\' 'u' HexDigit HexDigit HexDigit HexDigit
    ;

fragment
ZeroToThree
    :   [0-3]
    ;

// §3.10.7 The Null Literal

NullLiteral
    :   'null'
    ;

Identifier
    :   Letter LetterOrDigit*
    ;

fragment
Letter
    :   [a-zA-Z$_] // these are the "letters" below 0x7F
    |   // covers all characters above 0x7F which are not a surrogate
        ~[\u0000-\u007F\uD800-\uDBFF]
    |   // covers UTF-16 surrogate pairs encodings for U+10000 to U+10FFFF
        [\uD800-\uDBFF] [\uDC00-\uDFFF]
    ;

fragment
LetterOrDigit
    :   [a-zA-Z0-9$_] // these are the "letters or digits" below 0x7F
    |   // covers all characters above 0x7F which are not a surrogate
        ~[\u0000-\u007F\uD800-\uDBFF]
    |   // covers UTF-16 surrogate pairs encodings for U+10000 to U+10FFFF
        [\uD800-\uDBFF] [\uDC00-\uDFFF]
    ;

//
// Whitespace and comments
//

WS  :  [ \t\r\n\u000C]+ -> channel(HIDDEN)
    ;

LINE_COMMENT
    :   '//' ~[\r\n]* -> channel(HIDDEN)
    ;

ERRCHAR
	:	.	-> channel(HIDDEN)
	;
