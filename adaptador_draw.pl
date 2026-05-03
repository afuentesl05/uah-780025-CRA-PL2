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
%
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