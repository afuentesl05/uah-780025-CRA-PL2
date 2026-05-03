% =========================================================
% DETECCION DE AMBIGUEDAD
% Archivo: ambiguedad.pl
%
% Detecta si una lista de tokens tiene:
% - ningun analisis
% - un unico analisis
% - varios analisis posibles
%
% No modifica la gramatica. Solo explora soluciones de:
%
%   phrase(oracion(Arbol), Tokens)
%
% =========================================================

:- use_module(library(solution_sequences)).

% ---------------------------------------------------------
% analisis_posibles(+Tokens, -Arboles)
%
% Devuelve todos los arboles distintos encontrados.
% Puede ser costoso si la frase genera muchas alternativas.
% ---------------------------------------------------------

analisis_posibles(Tokens, ArbolesUnicos) :-
    findall(
        Arbol,
        phrase(oracion(Arbol), Tokens),
        Arboles
    ),
    sort(Arboles, ArbolesUnicos).

% ---------------------------------------------------------
% analisis_posibles_limitados(+Tokens, +Limite, -Arboles)
%
% Devuelve como maximo Limite arboles distintos.
% Es mas seguro para usar desde la interfaz.
% ---------------------------------------------------------

analisis_posibles_limitados(Tokens, Limite, ArbolesUnicos) :-
    findnsols(
        Limite,
        Arbol,
        phrase(oracion(Arbol), Tokens),
        Arboles
    ),
    sort(Arboles, ArbolesUnicos).

% ---------------------------------------------------------
% detectar_ambiguedad(+Tokens, -Estado, -NumArboles, -Arboles)
%
% Estados posibles:
%
%   no_reconocida
%   no_ambigua
%   ambigua
%
% Nota:
% Se limita la busqueda a 10 arboles para evitar problemas
% de backtracking excesivo.
% ---------------------------------------------------------

detectar_ambiguedad(Tokens, Estado, NumArboles, Arboles) :-
    analisis_posibles_limitados(Tokens, 10, Arboles),
    length(Arboles, NumArboles),
    estado_ambiguedad(NumArboles, Estado).

estado_ambiguedad(0, no_reconocida) :-
    !.

estado_ambiguedad(1, no_ambigua) :-
    !.

estado_ambiguedad(_, ambigua).

% ---------------------------------------------------------
% es_ambigua(+Tokens)
%
% Tiene exito si hay al menos dos analisis distintos.
% ---------------------------------------------------------

es_ambigua(Tokens) :-
    analisis_posibles_limitados(Tokens, 2, Arboles),
    length(Arboles, N),
    N >= 2.

% ---------------------------------------------------------
% informe_ambiguedad(+Tokens)
%
% Imprime un informe simple por terminal.
% ---------------------------------------------------------

informe_ambiguedad(Tokens) :-
    detectar_ambiguedad(Tokens, Estado, NumArboles, Arboles),
    write('TOKENS: '), write(Tokens), nl,
    write('ESTADO_AMBIGUEDAD: '), write(Estado), nl,
    write('NUM_ANALISIS: '), write(NumArboles), nl,
    imprimir_arboles_ambiguedad(Arboles, 1).

imprimir_arboles_ambiguedad([], _).

imprimir_arboles_ambiguedad([A|R], N) :-
    write('ANALISIS_'), write(N), write(': '),
    write(A), nl,
    N2 is N + 1,
    imprimir_arboles_ambiguedad(R, N2).