% =========================================================
% ANALIZADOR SINTACTICO INICIAL
% Adaptado al corpus inicial de 10 frases
% =========================================================

% ---------------------------------------------------------
% ORACION
% ---------------------------------------------------------

oracion(o(suj(GN), pred(GV))) --> gn(GN), gv(GV).
% ---------------------------------------------------------
% GRUPO NOMINAL
% ---------------------------------------------------------

gn(GN) --> gn_simple(GN).
gn(gn_coord(GN1, Conj, GN2)) --> gn_simple(GN1), conjuncion(Conj), gn_simple(GN2).

gn_simple(gn(N)) --> nombre(N).
gn_simple(gn(Det, N)) --> determinante(Det), nombre(N).
gn_simple(gn(Det, Adj, N)) --> determinante(Det), adjetivo(Adj), nombre(N).
gn_simple(gn(Det, N, Adj)) --> determinante(Det), nombre(N), adjetivo(Adj).
gn_simple(gn(N1, N2)) --> nombre(N1), nombre(N2).
gn_simple(gn(Det, N1, N2)) --> determinante(Det), nombre(N1), nombre(N2).
gn_simple(gn(Det, N, GP)) --> determinante(Det), nombre(N), gp(GP).
gn_simple(gn(Det, Adj, N, GP)) --> determinante(Det), adjetivo(Adj), nombre(N), gp(GP).
gn_simple(gn(N, GP)) --> nombre(N), gp(GP).
gn_simple(gn(Det, N, OrRel)) --> determinante(Det), nombre(N), or_rel(OrRel).
gn_simple(gn(Det, Adj, N, GP, Participio, GP2)) -->
    determinante(Det), adjetivo(Adj), nombre(N), gp(GP), participio(Participio), gp(GP2).
gn_simple(gn(Det, N, GP, Participio, GP2)) -->
    determinante(Det), nombre(N), gp(GP), participio(Participio), gp(GP2).
gn_simple(gn(N1, N2, N3, Conj, N4)) -->
    nombre(N1), nombre(N2), nombre(N3), conjuncion(Conj), nombre(N4).


% ---------------------------------------------------------
% GRUPO VERBAL
% ---------------------------------------------------------

gv(gv(V)) --> verbo(V).
gv(gv(V, GN)) --> verbo(V), gn(GN).
gv(gv(V, GP)) --> verbo(V), gp(GP).
gv(gv(V, GN, GP)) --> verbo(V), gn(GN), gp(GP).
gv(gv(V, GN1, Conj, V2)) --> verbo(V), gn(GN1), conjuncion(Conj), verbo(V2).
gv(gv(V1, Conj, V2, GN)) --> verbo(V1), conjuncion(Conj), verbo(V2), gn(GN).
gv(gv(V1, Conj, V2, Adv, GP)) --> verbo(V1), conjuncion(Conj), verbo(V2), adverbio(Adv), gp(GP).
gv(gv(V1, Conj, V2, Adv)) --> verbo(V1), conjuncion(Conj), verbo(V2), adverbio(Adv).
gv(gv(VC, GP)) --> verbo_compuesto(VC), gp(GP).
gv(gv(VC, GN, GP)) --> verbo_compuesto(VC), gn(GN), gp(GP).
gv(gv(VC, GN)) --> verbo_compuesto(VC), gn(GN).
gv(gv(V, Participio, GP)) --> verbo(V), participio(Participio), gp(GP).
gv(gv(V, Participio)) --> verbo(V), participio(Participio).
gv(gv(V1, GN, Conj, V2, Adv, GP)) -->
    verbo(V1), gn(GN), conjuncion(Conj), verbo(V2), adverbio(Adv), gp(GP).
% ---------------------------------------------------------
% GRUPO PREPOSICIONAL
% ---------------------------------------------------------

gp(gp(Prep, GN)) --> preposicion(Prep), gn(GN).

% ---------------------------------------------------------
% ORACION DE RELATIVO MUY SIMPLE
% ---------------------------------------------------------

or_rel(or_rel(Rel, GV)) --> relativo(Rel), gv(GV).

% ---------------------------------------------------------
% VERBO COMPUESTO SIMPLE
% ---------------------------------------------------------

verbo_compuesto(vc(V1, V2)) --> verbo(V1), verbo(V2).

% ---------------------------------------------------------
% LEXICO
% ---------------------------------------------------------

% -------------------------
% DETERMINANTES
% -------------------------

determinante(det(el)) --> [el].
determinante(det(la)) --> [la].
determinante(det(los)) --> [los].
determinante(det(las)) --> [las].
determinante(det(un)) --> [un].
determinante(det(una)) --> [una].
determinante(det(todas)) --> [todas].

% -------------------------
% VERBOS
% -------------------------

verbo(v(es)) --> [es].
verbo(v(son)) --> [son].
verbo(v(tiene)) --> [tiene].
verbo(v(tienen)) --> [tienen].
verbo(v(valen)) --> [valen].
verbo(v(representa)) --> [representa].
verbo(v(aumenta)) --> [aumenta].
verbo(v(dividen)) --> [dividen].
verbo(v(se)) --> [se].

% -------------------------
% PARTICIPIOS
% -------------------------

participio(part(dividida)) --> [dividida].

% -------------------------
% ADJETIVOS
% -------------------------

adjetivo(adj(acertada)) --> [acertada].
adjetivo(adj(musicales)) --> [musicales].
adjetivo(adj(anterior)) --> [anterior].
adjetivo(adj(pequena)) --> [pequena].
adjetivo(adj(iguales)) --> [iguales].

% -------------------------
% ADVERBIOS
% -------------------------

adverbio(adv(igual)) --> [igual].

% -------------------------
% PREPOSICIONES
% -------------------------

preposicion(prep(de)) --> [de].
preposicion(prep(del)) --> [del].
preposicion(prep(a)) --> [a].
preposicion(prep(en)) --> [en].

% -------------------------
% CONJUNCIONES
% -------------------------

conjuncion(conj(y)) --> [y].

% -------------------------
% RELATIVOS
% -------------------------

relativo(rel(que)) --> [que].

% -------------------------
% NOMBRES
% -------------------------

nombre(n(melodia)) --> [melodia].
nombre(n(armonia)) --> [armonia].
nombre(n(pentagrama)) --> [pentagrama].
nombre(n(notas)) --> [notas].
nombre(n(figuras)) --> [figuras].
nombre(n(silencio)) --> [silencio].
nombre(n(figura)) --> [figura].
nombre(n(puntillo)) --> [puntillo].
nombre(n(mitad)) --> [mitad].
nombre(n(valor)) --> [valor].
nombre(n(intervalo)) --> [intervalo].
nombre(n(distancia)) --> [distancia].
nombre(n(sonido)) --> [sonido].
nombre(n(llaves)) --> [llaves].
nombre(n(sol)) --> [sol].
nombre(n(fa)) --> [fa].
nombre(n(do)) --> [do].
nombre(n(instrumentos)) --> [instrumentos].
nombre(n(clases)) --> [clases].
nombre(n(compas)) --> [compas].
nombre(n(porcion)) --> [porcion].
nombre(n(tiempo)) --> [tiempo].
nombre(n(partes)) --> [partes].
nombre(n(sucesion)) --> [sucesion].
nombre(n(conjunto)) --> [conjunto].
nombre(n(sonidos)) --> [sonidos].
nombre(n(lineas)) --> [lineas].
nombre(n(espacios)) --> [espacios].
nombre(n(otro)) --> [otro].

% -------------------------
% NUMERALES / CUANTIFICADORES
% Los metemos como nombres por simplicidad inicial
% -------------------------

nombre(n(varios)) --> [varios].
nombre(n(cinco)) --> [cinco].
nombre(n(cuatro)) --> [cuatro].
nombre(n(siete)) --> [siete].
nombre(n(tres)) --> [tres].