/**
 * Copyright (c) 2015-present, Jim Kynde Meyer
 * All rights reserved.
 * <p>
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
package com.intellij.lang.jsgraphql.endpoint.lexer;
import java.util.Stack;
import com.intellij.lexer.*;
import com.intellij.psi.tree.IElementType;
import static com.intellij.lang.jsgraphql.endpoint.JSGraphQLEndpointTokenTypes.*;

%%

%{

    protected final Stack<Integer> myStateStack = new Stack<>();

    private void pushState(int state) {
        myStateStack.push(yystate());
        yybegin(state);
    }

    private void popState() {
        yybegin(myStateStack.pop());
    }


    public JSGraphQLEndpointLexer() {
        this((java.io.Reader)null);
    }
%}

%public
%class JSGraphQLEndpointLexer
%implements FlexLexer
%function advance
%type IElementType
%unicode

EOL="\r"|"\n"|"\r\n"
LINE_WS=[\ \t\f]
WHITE_SPACE=({LINE_WS}|{EOL})+

IDENTIFIER=[_A-Za-z][_0-9A-Za-z]*
AT_ANNOTATION=@([_A-Za-z][_0-9A-Za-z]*)?
NUMBER=-?[0-9]+(\.[0-9+])?
LINE_COMMENT=#.*

%state STRING

%%
<YYINITIAL> {
  {WHITE_SPACE}       { return com.intellij.psi.TokenType.WHITE_SPACE; }

  "type"              { return TYPE; }
  "interface"         { return INTERFACE; }
  "implements"        { return IMPLEMENTS; }
  "input"             { return INPUT; }
  "enum"              { return ENUM; }
  "union"             { return UNION; }
  "("                 { return LPAREN; }
  ")"                 { return RPAREN; }
  "{"                 { return LBRACE; }
  "}"                 { return RBRACE; }
  "["                 { return LBRACKET; }
  "]"                 { return RBRACKET; }
  ","                 { return COMMA; }
  ":"                 { return COLON; }
  "="                 { return EQUALS; }
  "|"                 { return PIPE; }
  "true"              { return TRUE; }
  "false"             { return FALSE; }
  "!"                 { return REQUIRED; }
  "scalar"            { return SCALAR; }
  "import"            { return IMPORT; }
  "schema"            { return SCHEMA; }
  "query"             { return QUERY; }
  "mutation"          { return MUTATION; }
  "subscription"      { return SUBSCRIPTION; }

  \"                  { pushState(STRING); return OPEN_QUOTE; }

  {IDENTIFIER}        { return IDENTIFIER; }
  {AT_ANNOTATION}     { return AT_ANNOTATION; }
  {NUMBER}            { return NUMBER; }
  {LINE_COMMENT}      { return LINE_COMMENT; }

  [^] { return com.intellij.psi.TokenType.BAD_CHARACTER; }
}

<STRING> {
    \" { popState(); return CLOSING_QUOTE; }
    [^\n\r\"]+ { return STRING_BODY; }
    [^] { popState(); return com.intellij.psi.TokenType.BAD_CHARACTER; }
}
