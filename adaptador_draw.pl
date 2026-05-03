% =========================================================
% ADAPTADOR PARA DRAW
% Archivo: adaptador_draw.pl
%
% Convierte el arbol sintactico real en un arbol compatible
% con draw.pl.
%
% Reglas de visualizacion:
% - Las listas vacias [] se eliminan.
% - Las listas con un solo elemento [X] se muestran como X.
% - Las listas con varios elementos [A,B,C] se muestran como lista(A,B,C).
% - Las enumeraciones se compactan:
%
%     enum(elem_gn(sol), seg(coma, elem_gn(fa), seg(conj(y), elem_gn(do), fin)))
%
%   se dibuja como:
%
%     enum(sol, fa, do)
%
% Esto no cambia el arbol sintactico real. Solo cambia su
% representacion visual para draw.pl.
% =========================================================

dibujar_arbol(Arbol) :-
    arbol_para_draw(Arbol, ArbolDraw),
    draw(ArbolDraw).

% =========================================================
% TRANSFORMACION PRINCIPAL
% =========================================================

arbol_para_draw(Var, Var) :-
    var(Var),
    !.

arbol_para_draw([], eliminado) :-
    !.

arbol_para_draw([X], XD) :-
    !,
    arbol_para_draw(X, XD).

arbol_para_draw([X|Xs], TerminoLista) :-
    !,
    transformar_lista_draw([X|Xs], ElementosDraw),
    TerminoLista =.. [lista|ElementosDraw].

% ---------------------------------------------------------
% ENUMERACION CON DOS PUNTOS
% ---------------------------------------------------------
%
% Caso:
%
%   enum(dp(:), enum(...))
%
% Se compacta visualmente a:
%
%   enum(E1, E2, E3, ...)
%
% ---------------------------------------------------------

arbol_para_draw(enum(DP, Enum), EnumDraw) :-
    es_dos_puntos(DP),
    !,
    enum_a_lista_draw(Enum, ElementosDraw),
    EnumDraw =.. [enum|ElementosDraw].

% ---------------------------------------------------------
% ENUMERACION INTERNA
% ---------------------------------------------------------
%
% Caso:
%
%   enum(Elem, Tail)
%
% Se compacta visualmente a:
%
%   enum(E1, E2, E3, ...)
%
% ---------------------------------------------------------

arbol_para_draw(enum(Elem, Tail), EnumDraw) :-
    es_elemento_enum(Elem),
    !,
    enum_a_lista_draw(enum(Elem, Tail), ElementosDraw),
    EnumDraw =.. [enum|ElementosDraw].

arbol_para_draw(Atomo, Atomo) :-
    atomic(Atomo),
    !.

arbol_para_draw(Termino, TerminoDraw) :-
    compound(Termino),
    Termino =.. [Functor|Args],
    transformar_argumentos_draw(Args, ArgsDraw),
    TerminoDraw =.. [Functor|ArgsDraw].

% =========================================================
% TRANSFORMACION DE ARGUMENTOS
% =========================================================
%
% Aqui se eliminan visualmente los argumentos que sean [].
% =========================================================

transformar_argumentos_draw([], []).

transformar_argumentos_draw([[]|Xs], XDs) :-
    !,
    transformar_argumentos_draw(Xs, XDs).

transformar_argumentos_draw([X|Xs], [XD|XDs]) :-
    arbol_para_draw(X, XD),
    transformar_argumentos_draw(Xs, XDs).

% =========================================================
% TRANSFORMACION DE LISTAS NO VACIAS
% =========================================================

transformar_lista_draw([], []).

transformar_lista_draw([X|Xs], [XD|XDs]) :-
    arbol_para_draw(X, XD),
    transformar_lista_draw(Xs, XDs).

% =========================================================
% COMPACTACION DE ENUMERACIONES
% =========================================================

enum_a_lista_draw(enum(Elem, Tail), [ElemDraw|RestoDraw]) :-
    elemento_enum_draw(Elem, ElemDraw),
    cola_enum_draw(Tail, RestoDraw).

cola_enum_draw(fin, []) :-
    !.

cola_enum_draw(seg(_, Elem, Tail), [ElemDraw|RestoDraw]) :-
    !,
    elemento_enum_draw(Elem, ElemDraw),
    cola_enum_draw(Tail, RestoDraw).

elemento_enum_draw(elem_gn(GN), GNDraw) :-
    !,
    arbol_para_draw(GN, GNDraw).

elemento_enum_draw(elem_gadj(GAdj), GAdjDraw) :-
    !,
    arbol_para_draw(GAdj, GAdjDraw).

elemento_enum_draw(elem_adj(Adj), AdjDraw) :-
    !,
    arbol_para_draw(Adj, AdjDraw).

elemento_enum_draw(elem_etc(Etc), Etc) :-
    !.

elemento_enum_draw(Elem, ElemDraw) :-
    arbol_para_draw(Elem, ElemDraw).

% =========================================================
% RECONOCIMIENTO DE ESTRUCTURAS DE ENUMERACION
% =========================================================

es_dos_puntos(dp(_)).

es_elemento_enum(elem_gn(_)).
es_elemento_enum(elem_gadj(_)).
es_elemento_enum(elem_adj(_)).
es_elemento_enum(elem_etc(_)).