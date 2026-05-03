% =========================================================
% MAIN
% Archivo: main.pl
%
% Punto de entrada principal del proyecto.
%
% Carga:
% - conjunto_oraciones.pl
% - sintactico.pl
% - ambiguedad.pl
% - draw.pl
% - adaptador_draw.pl
% =========================================================

:- ensure_loaded('conjunto_oraciones.pl').
:- ensure_loaded('sintactico.pl').
:- ensure_loaded('ambiguedad.pl').

:- use_module('draw.pl').
:- ensure_loaded('adaptador_draw.pl').

% ---------------------------------------------------------
% Analizar una oracion del corpus por ID
% ---------------------------------------------------------

analizar_id(Id, Arbol) :-
    oracion(Id, Tokens),
    phrase(oracion(Arbol), Tokens).

% ---------------------------------------------------------
% Analizar directamente una lista de tokens
% ---------------------------------------------------------

analizar_tokens(Tokens, Arbol) :-
    phrase(oracion(Arbol), Tokens).

% ---------------------------------------------------------
% Probar todas las oraciones del corpus
% ---------------------------------------------------------

probar_todas :-
    oracion(Id, Tokens),
    (
        phrase(oracion(Arbol), Tokens)
    ->
        write('OK -> '),
        write(Id),
        write(' : '),
        write(Arbol),
        nl
    ;
        write('FALLO -> '),
        write(Id),
        write(' : '),
        write(Tokens),
        nl
    ),
    fail.

probar_todas.