package haxeFormatter;

import hxParser.ParseTree;
import hxParser.WalkStack;

class Indenter {
    var config:Config;
    var indentLevel:Int = 0;
    var inNoBlockExpr:Bool = false;

    public function new(config:Config) {
        this.config = config;
    }

    public function reindent(prevToken:Token, token:Token, stack:WalkStack) {
        inline function indentToken()
            reindentToken(prevToken, token);

        inline function isSwitchEdge(edge:String):Bool
            return stack.match(Edge(edge, Node(Expr_ESwitch(_,_,_,_,_), _)));

        function indentNoBlockExpr(expr:Expr) {
            if (!expr.match(EBlock(_,_,_))) {
                inNoBlockExpr = true;
                indentLevel++;
            }
        }

        function dedentNoBlockExpr() {
            if (inNoBlockExpr) {
                inNoBlockExpr = false;
                indentLevel--;
            }
        }

        switch (token.text) {
            case '{':
                indentToken();
                indentLevel++;
                if (!config.indent.indentSwitches && isSwitchEdge("braceOpen")) indentLevel--;
            case '}':
                if (config.indent.indentSwitches && isSwitchEdge("braceClose")) indentLevel--;
                indentLevel--;
                indentToken();
            case ')':
                switch (stack) {
                    case Edge("parenClose", Node(kind, _)):
                        switch (kind) {
                            case Expr_EIf(_,_,_,_,exprBody,_),
                                Expr_EFor(_,_,_,_,exprBody),
                                Expr_EWhile(_,_,_,_,exprBody):
                                indentNoBlockExpr(exprBody);
                            case Catch(node):
                                indentNoBlockExpr(node.expr);
                            case _:
                        }
                    case _:
                }
                indentToken();
            case ';':
                dedentNoBlockExpr();
                indentToken();
            case 'else':
                dedentNoBlockExpr();
                switch (stack) {
                    case Edge("elseKeyword", Node(ExprElse({ elseKeyword:_, expr:expr }), _)):
                        indentToken();
                        indentNoBlockExpr(expr);
                    case _:
                        indentToken();
                }
            case 'try':
                switch (stack) {
                    case Edge("tryKeyword", Node(Expr_ETry(_,exprBody,_), _)):
                        indentToken();
                        indentNoBlockExpr(exprBody);
                    case _:
                        indentToken();
                }
            case 'catch' | 'while':
                dedentNoBlockExpr();
                indentToken();
            case 'do':
                switch (stack) {
                    case Edge("doKeyword", Node(Expr_EDo(_,exprBody,_), _)):
                        indentToken();
                        indentNoBlockExpr(exprBody);
                    case _:
                        indentToken();
                }
            case 'function':
                switch (stack) {
                    case Edge("functionKeyword", Node(kind, _)):
                        switch (kind) {
                            case ClassField_Function(_,_,_,_,_,_,_,_,_,expr):
                                indentToken();
                                switch (expr) {
                                    case Expr(expr, _):
                                        indentToken();
                                        indentNoBlockExpr(expr);
                                    case _:
                                        indentToken();
                                }
                            case Expr_EFunction(_,fun):
                                indentToken();
                                indentNoBlockExpr(fun.expr);
                            case _:
                                indentToken();
                        }
                    case _:
                        indentToken();
                }
            case _:
                switch (stack) {
                    case Edge("caseKeyword", Node(Case_Case(_,_,_,_,_), Element(index, _))):
                        if (index > 0) indentLevel--;
                        indentToken();
                        indentLevel++;
                    case _:
                        indentToken();
                }
        }
    }

    function reindentToken(prevToken:Token, token:Token) {
        if (prevToken == null) return;

        var prevLastTrivia = prevToken.trailingTrivia[prevToken.trailingTrivia.length - 1];
        if (prevLastTrivia == null || !prevLastTrivia.text.isNewline()) return;

        var indent = config.indent.whitespace.times(indentLevel);
        var lastTrivia = token.leadingTrivia[token.leadingTrivia.length - 1];
        if (lastTrivia != null && lastTrivia.text.isTabOrSpace())
            lastTrivia.text = indent;
        else
            token.leadingTrivia.push(new Trivia(indent));
    }
}