% =========================================================
% ADAPTADOR PARA DRAW
% Archivo: adaptador_draw.pl
%
% Convierte el arbol sintactico real en un arbol compatible
% con draw.pl.
%
% Reglas de visualizacion:
% - Las listas vacias [] se eliminan visualmente.
% - Las listas con un solo elemento [X] se muestran como X.
% - Las listas con varios elementos [A,B,C] se muestran como lista(A,B,C).
% - Las enumeraciones se compactan.
%
% Esto no cambia el arbol sintactico real. Solo cambia su
% representacion visual para draw.pl.
% =========================================================


% Dibuja un arbol sintactico transformandolo antes a una
% estructura mas legible para draw.pl.
% Ejemplo:
%   o(suj(GN), pred(GV))
%   -> arbol adaptado
%   -> draw(arbol adaptado)
dibujar_arbol(Arbol) :-
    arbol_para_draw(Arbol, ArbolDraw),
    draw(ArbolDraw).


% =========================================================
% TRANSFORMACION PRINCIPAL
% =========================================================


% Si el termino es una variable, se deja igual.
% Ejemplo:
%   X -> X
arbol_para_draw(Var, Var) :-
    var(Var),
    !.


% Si aparece una lista vacia como termino principal, se
% sustituye por una marca visual.
% Ejemplo:
%   [] -> eliminado
arbol_para_draw([], eliminado) :-
    !.


% Si una lista tiene un unico elemento, se muestra directamente
% ese elemento, sin crear un nodo lista.
% Ejemplo:
%   [gn(base(n(sol)), [])]
%   -> gn(base(n(sol)))
arbol_para_draw([X], XD) :-
    !,
    arbol_para_draw(X, XD).


% Si una lista tiene varios elementos, se convierte en un
% termino lista(...), que draw.pl puede dibujar mejor.
% Ejemplo:
%   [gp(...), or(...)]
%   -> lista(gp(...), or(...))
arbol_para_draw([X|Xs], TerminoLista) :-
    !,
    transformar_lista_draw([X|Xs], ElementosDraw),
    TerminoLista =.. [lista|ElementosDraw].


% ---------------------------------------------------------
% ENUMERACION CON DOS PUNTOS
% ---------------------------------------------------------
%
% Caso real:
%
%   enum(dp(:), enum(...))
%
% Se dibuja como:
%
%   enum(E1, E2, E3, ...)
%
% ---------------------------------------------------------


% Compacta una enumeracion introducida por dos puntos,
% eliminando el nodo dp(:) de la vista.
% Ejemplo:
%   enum(dp(':'), enum(elem_gn(sol), Tail))
%   -> enum(sol, ...)
arbol_para_draw(enum(DP, Enum), EnumDraw) :-
    es_dos_puntos(DP),
    !,
    enum_a_lista_draw(Enum, ElementosDraw),
    EnumDraw =.. [enum|ElementosDraw].


% ---------------------------------------------------------
% ENUMERACION INTERNA
% ---------------------------------------------------------
%
% Caso real:
%
%   enum(Elem, Tail)
%
% Se dibuja como:
%
%   enum(E1, E2, E3, ...)
%
% ---------------------------------------------------------


% Compacta una enumeracion interna convirtiendo la estructura
% encadenada enum(Elem, Tail) en un termino plano enum(...).
% Ejemplo:
%   enum(elem_gn(sol), seg(',', elem_gn(fa), fin))
%   -> enum(sol, fa)
arbol_para_draw(enum(Elem, Tail), EnumDraw) :-
    es_elemento_enum(Elem),
    !,
    enum_a_lista_draw(enum(Elem, Tail), ElementosDraw),
    EnumDraw =.. [enum|ElementosDraw].


% Si el termino es atomico, se deja igual.
% Ejemplo:
%   melodia -> melodia
%   etc     -> etc
arbol_para_draw(Atomo, Atomo) :-
    atomic(Atomo),
    !.


% Para cualquier termino compuesto, transforma recursivamente
% sus argumentos y reconstruye el mismo functor.
% Ejemplo:
%   gn(base(det(la), n(melodia)), [])
%   -> gn(base(det(la), n(melodia)))
arbol_para_draw(Termino, TerminoDraw) :-
    compound(Termino),
    Termino =.. [Functor|Args],
    transformar_argumentos_draw(Args, ArgsDraw),
    TerminoDraw =.. [Functor|ArgsDraw].


% =========================================================
% TRANSFORMACION DE ARGUMENTOS
% =========================================================


% Una lista vacia de argumentos se mantiene vacia.
% Ejemplo:
%   [] -> []
transformar_argumentos_draw([], []).


% Si un argumento es una lista vacia, se elimina de la
% representacion visual.
% Ejemplo:
%   [base(det(la), n(melodia)), []]
%   -> [base(det(la), n(melodia))]
transformar_argumentos_draw([[]|Xs], XDs) :-
    !,
    transformar_argumentos_draw(Xs, XDs).


% Transforma recursivamente cada argumento del termino.
% Ejemplo:
%   [suj(GN), pred(GV)]
%   -> [suj(GNDraw), pred(GVDraw)]
transformar_argumentos_draw([X|Xs], [XD|XDs]) :-
    arbol_para_draw(X, XD),
    transformar_argumentos_draw(Xs, XDs).


% =========================================================
% TRANSFORMACION DE LISTAS NO VACIAS
% =========================================================


% Una lista vacia no tiene elementos que transformar.
% Ejemplo:
%   [] -> []
transformar_lista_draw([], []).


% Transforma cada elemento de una lista antes de convertirla
% en un termino lista(...).
% Ejemplo:
%   [gp(...), or(...)]
%   -> [gpDraw, orDraw]
transformar_lista_draw([X|Xs], [XD|XDs]) :-
    arbol_para_draw(X, XD),
    transformar_lista_draw(Xs, XDs).


% =========================================================
% COMPACTACION DE ENUMERACIONES
% =========================================================


% Convierte una enumeracion encadenada en una lista de
% elementos visuales.
% Ejemplo:
%   enum(elem_gn(sol), seg(',', elem_gn(fa), fin))
%   -> [sol, fa]
enum_a_lista_draw(enum(Elem, Tail), [ElemDraw|RestoDraw]) :-
    elemento_enum_draw(Elem, ElemDraw),
    cola_enum_draw(Tail, RestoDraw).


% Si la cola de la enumeracion es fin, no quedan mas elementos.
% Ejemplo:
%   fin -> []
cola_enum_draw(fin, []) :-
    !.


% Si la cola contiene otro elemento, se ignora el separador
% y se conserva solo el elemento enumerado.
% Ejemplo:
%   seg(coma(','), elem_gn(fa), fin)
%   -> [fa]
cola_enum_draw(seg(_, Elem, Tail), [ElemDraw|RestoDraw]) :-
    !,
    elemento_enum_draw(Elem, ElemDraw),
    cola_enum_draw(Tail, RestoDraw).


% Dibuja un elemento de enumeracion que contiene un grupo nominal.
% Ejemplo:
%   elem_gn(gn(base(n(sol)), []))
%   -> gn(base(n(sol)))
elemento_enum_draw(elem_gn(GN), GNDraw) :-
    !,
    arbol_para_draw(GN, GNDraw).


% Dibuja un elemento de enumeracion que contiene un grupo adjetival.
% Ejemplo:
%   elem_gadj(gadj(adj(pares)))
%   -> gadj(adj(pares))
elemento_enum_draw(elem_gadj(GAdj), GAdjDraw) :-
    !,
    arbol_para_draw(GAdj, GAdjDraw).


% Dibuja un elemento de enumeracion formado directamente por
% un adjetivo.
% Ejemplo:
%   elem_adj(adj(pares))
%   -> adj(pares)
elemento_enum_draw(elem_adj(Adj), AdjDraw) :-
    !,
    arbol_para_draw(Adj, AdjDraw).


% Dibuja el elemento etcetera como el atomo etc.
% Ejemplo:
%   elem_etc(etc)
%   -> etc
elemento_enum_draw(elem_etc(Etc), Etc) :-
    !.


% Caso general para cualquier otro tipo de elemento de
% enumeracion.
% Ejemplo:
%   elem_extra(...)
%   -> elem_extra adaptado recursivamente
elemento_enum_draw(Elem, ElemDraw) :-
    arbol_para_draw(Elem, ElemDraw).


% =========================================================
% RECONOCIMIENTO DE ESTRUCTURAS DE ENUMERACION
% =========================================================


% Reconoce el marcador de dos puntos usado en enumeraciones.
% Ejemplo:
%   dp(':') -> verdadero
es_dos_puntos(dp(_)).


% Reconoce un elemento de enumeracion de tipo grupo nominal.
% Ejemplo:
%   elem_gn(GN) -> verdadero
es_elemento_enum(elem_gn(_)).


% Reconoce un elemento de enumeracion de tipo grupo adjetival.
% Ejemplo:
%   elem_gadj(GAdj) -> verdadero
es_elemento_enum(elem_gadj(_)).


% Reconoce un elemento de enumeracion formado por un adjetivo.
% Ejemplo:
%   elem_adj(Adj) -> verdadero
es_elemento_enum(elem_adj(_)).


% Reconoce el elemento etcetera dentro de una enumeracion.
% Ejemplo:
%   elem_etc(etc) -> verdadero
es_elemento_enum(elem_etc(_)).