% =========================================================
% ANALIZADOR SINTACTICO
% Corpus inicial de 10 frases
% Version reorganizada y limpiada
% =========================================================

% ---------------------------------------------------------
% ORACION
% ---------------------------------------------------------
%
% La oracion se organiza por niveles para poder clasificar
% despues segun la estructura reconocida:
% - o(...)   : oracion simple
% - oc(...)  : oracion coordinada
% - or(...)  : oracion con subordinada de relativo
% - ocm(...) : oracion compuesta
%
% Se evita la recursion izquierda: las coordinadas se forman
% siempre a partir de oraciones simples o de un sujeto compartido
% con dos grupos verbales simples.
% ---------------------------------------------------------

oracion(Arbol) -->
    oracion_compuesta(Arbol).

oracion(Arbol) -->
    oracion_coordinada(Arbol).

oracion(Arbol) -->
    oracion_relativo(Arbol).

oracion(Arbol) -->
    oracion_simple(Arbol).

oracion_simple(o(suj(GN), pred(GV))) -->
    gn(GN), gv_simple(GV).

oracion_coordinada(oc(O1, Conj, O2)) -->
    oracion_simple(O1), conj_coord(Conj), oracion_simple(O2).

oracion_coordinada(oc(o(suj(GN), pred(GV1)), Conj, o(suj(GN), pred(GV2)))) -->
    gn(GN), gv_simple(GV1), conj_coord(Conj), gv_simple(GV2).

oracion_relativo(or(O)) -->
    oracion_simple(O),
    { contiene_relativo(O) }.

oracion_compuesta(ocm(OC)) -->
    oracion_coordinada(OC),
    { contiene_relativo(OC) }.

conj_coord(conj(y)) -->
    [y].

% =========================================================
% GRUPO NOMINAL (GN)
% =========================================================
%
% Idea general:
% - Primero definimos GN nucleares / basicos.
% - Despues GN extendidos con GP, relativo o GAdj.
% - Finalmente GN coordinados y enumeraciones.
%
% =========================================================

% ---------------------------------------------------------
% GN PRINCIPAL
% ---------------------------------------------------------

gn(GN) --> gn_completo(GN).
gn(gn_coord(GN1, Conj, GN2)) -->
    gn_completo(GN1), conjuncion(Conj), gn_completo(GN2).

% ---------------------------------------------------------
% GN NUCLEAR
% ---------------------------------------------------------
%
% Son GN que pueden aparecer por si solos, sin coordinacion.
% Incluyen:
% - GN basicos
% - GN extendidos con GP
% - GN con relativo
% - GN con grupo adjetival
% - GN enumerativos
% ---------------------------------------------------------

gn_completo(GN) --> gn_basico(GN).

gn_completo(gn(Det, N, GP)) -->
    determinante(Det), nombre(N), gp_nominal(N, GP).

gn_completo(gn(Det, Adj, N, GP)) -->
    determinante(Det), adjetivo(Adj), nombre(N), gp_nominal(N, GP).

gn_completo(gn(N, GP)) -->
    nombre(N), gp_nominal(N, GP).

gn_completo(gn(Det, N, GP1, GP2)) -->
    determinante(Det), nombre(N), gp_nominal(N, GP1), gp_nominal(N, GP2).

gn_completo(gn(Det, N, OrRel)) -->
    determinante(Det), nombre(N), or_rel(OrRel).

gn_completo(gn(Det, Adj, N, GP, GAdj)) -->
    determinante(Det), adjetivo(Adj), nombre(N), gp_nominal(N, GP), gadj(GAdj).

gn_completo(gn(Det, N, GP, GAdj)) -->
    determinante(Det), nombre(N), gp_nominal(N, GP), gadj(GAdj).

gn_completo(gn(Num, DP, Enum)) -->
    numeral(Num), dos_puntos(DP), enumeracion_nominal(Enum).

% ---------------------------------------------------------
% GN BASICO
% ---------------------------------------------------------
%
% Estructuras simples del grupo nominal.
% ---------------------------------------------------------

gn_basico(gn(N)) -->
    nombre(N).

gn_basico(gn(Det, N)) -->
    determinante(Det), nombre(N).

gn_basico(gn(Det, Adj, N)) -->
    determinante(Det), adjetivo(Adj), nombre(N).

gn_basico(gn(Det, N, Adj)) -->
    determinante(Det), nombre(N), adjetivo(Adj).

gn_basico(gn(N, Adj)) -->
    nombre(N), adjetivo(Adj).

gn_basico(gn(N1, N2)) -->
    nombre(N1), nombre(N2).

gn_basico(gn(Det, N1, N2)) -->
    determinante(Det), nombre(N1), nombre(N2).

% ---------------------------------------------------------
% GN CUANTIFICADOS Y NUMERALES
% ---------------------------------------------------------

gn_basico(gn(Cuant, Det, N)) -->
    cuantificador(Cuant), determinante(Det), nombre(N).

gn_basico(gn(Cuant, N)) -->
    cuantificador(Cuant), nombre(N).

gn_basico(gn(Num, N)) -->
    numeral(Num), nombre(N).

gn_basico(gn(Num)) -->
    numeral(Num).

% ---------------------------------------------------------
% ENUMERACION NOMINAL
% ---------------------------------------------------------
%
% Ejemplo:
% tres : sol , fa y do
% ---------------------------------------------------------

enumeracion_nominal(enum(N, Resto)) -->
    nombre(N), resto_enumeracion(Resto).

resto_enumeracion(ultimo(Conj, N)) -->
    conjuncion(Conj), nombre(N).

resto_enumeracion(sig(Coma, N, Resto)) -->
    coma(Coma), nombre(N), resto_enumeracion(Resto).

% =========================================================
% GRUPO VERBAL (GV)
% =========================================================
%
% Se distinguen:
% - GV simples
% - GV con verbo compuesto
% - GV coordinados
% =========================================================

% DEFINICION VERBO COMPUESTO
verbo_compuesto(vc(V1, V2)) -->
    verbo(V1), verbo(V2).
%----------------------------------------------------------

% ---------------------------------------------------------
% GV PRINCIPAL
% ---------------------------------------------------------

gv(GV) -->
    gv_simple(GV).

gv(GV) -->
    gv_coordinado(GV).

% ---------------------------------------------------------
% GV SIMPLES
% ---------------------------------------------------------

gv_simple(gv(V)) -->
    verbo(V).

gv_simple(gv(V, GN)) -->
    verbo(V), gn(GN).

gv_simple(gv(V, GP)) -->
    verbo(V), gp_verbal(V, GP).

gv_simple(gv(V, GN, GP)) -->
    verbo(V), gn(GN), gp_verbal(V, GP).

gv_simple(gv(V, Adv)) -->
    verbo(V), adverbio(Adv).

gv_simple(gv(V, Adv, GP)) -->
    verbo(V), adverbio(Adv), gp_verbal(V, GP).

% ---------------------------------------------------------
% GV CON VERBO COMPUESTO
% ---------------------------------------------------------

gv_simple(gv(VC)) -->
    verbo_compuesto(VC).

gv_simple(gv(VC, GN)) -->
    verbo_compuesto(VC), gn(GN).

gv_simple(gv(VC, GP)) -->
    verbo_compuesto(VC), gp_verbal(VC, GP).

gv_simple(gv(VC, GN, GP)) -->
    verbo_compuesto(VC), gn(GN), gp_verbal(VC, GP).

% ---------------------------------------------------------
% GV COORDINADOS
% ---------------------------------------------------------
%
% Esta regla permite reconocer una coordinacion interna de GV
% cuando se consulte gv//1 directamente. La clasificacion como
% oracion coordinada se hace en oracion_coordinada//1.
% ---------------------------------------------------------

gv_coordinado(gv_coord(GV1, Conj, GV2)) -->
    gv_simple(GV1), conj_coord(Conj), gv_simple(GV2).

% =========================================================
% GRUPO PREPOSICIONAL (GP)
% =========================================================

gp(gp(Prep, GN)) -->
    preposicion(Prep), gn(GN).

gp_nominal(Nucleo, GP) -->
    gp(GP),
    { gp_valido_nominal(Nucleo, GP) }.

gp_verbal(Verbo, GP) -->
    gp(GP),
    { gp_valido_verbal(Verbo, GP) }.

gp_valido_nominal(Nucleo, gp(Prep, _)) :-
    nombre_lexema(Nucleo, Nombre),
    prep_lexema(Prep, PrepAtom),
    admite_gp_nominal(Nombre, PrepAtom).

gp_valido_verbal(Verbo, gp(Prep, _)) :-
    verbo_lexema(Verbo, VerboAtom),
    prep_lexema(Prep, PrepAtom),
    admite_gp_verbal(VerboAtom, PrepAtom).

% =========================================================
% RESTRICCIONES LEXICO-SINTACTICAS DE GP
% =========================================================

admite_gp_nominal(sucesion, de).
admite_gp_nominal(conjunto, de).
admite_gp_nominal(mitad, del).
admite_gp_nominal(distancia, de).
admite_gp_nominal(distancia, a).
admite_gp_nominal(porcion, de).

admite_gp_verbal(aumenta, a).
admite_gp_verbal(dividen, en).
admite_gp_verbal(valen, a).

nombre_lexema(n(X), X).

verbo_lexema(v(X), X).
verbo_lexema(vc(_, v(X)), X).

prep_lexema(prep(X), X).

% =========================================================
% GRUPO ADJETIVAL (GADJ)
% =========================================================

gadj(gadj(Adj)) -->
    adjetivo(Adj).

gadj(gadj(Participio, GP)) -->
    participio(Participio), gp(GP).

% =========================================================
% ORACION DE RELATIVO SIMPLE
% =========================================================

or_rel(or_rel(Rel, GV)) -->
    relativo(Rel), gv(GV).

% =========================================================
% CLASIFICACION Y SIMPLIFICACION
% =========================================================

tipo_oracion(Tokens, Tipo, Arbol) :-
    phrase(oracion(Arbol), Tokens),
    !,
    tipo_arbol(Arbol, Tipo).

tipo_oracion(_, no_reconocida, no_reconocida).

tipo_arbol(ocm(_), compuesta) :-
    !.

tipo_arbol(Arbol, compuesta) :-
    Arbol = oc(_, _, _),
    contiene_relativo(Arbol),
    !.

tipo_arbol(oc(_, _, _), coordinada) :-
    !.

tipo_arbol(or(_), relativo) :-
    !.

tipo_arbol(Arbol, relativo) :-
    Arbol = o(_, _),
    contiene_relativo(Arbol),
    !.

tipo_arbol(o(_, _), simple).

simplificar(ocm(OC), Simples) :-
    !,
    simplificar(OC, Simples).

simplificar(oc(O1, _, O2), [O1, O2]) :-
    !.

simplificar(or(O), [O]) :-
    !.

simplificar(O, [O]).

contiene_relativo(Arbol) :-
    sub_term(or_rel(_, _), Arbol).

% =========================================================
% LEXICO
% =========================================================

% ---------------------------------------------------------
% DETERMINANTES
% ---------------------------------------------------------

determinante(det(el)) --> [el].
determinante(det(la)) --> [la].
determinante(det(los)) --> [los].
determinante(det(las)) --> [las].
determinante(det(un)) --> [un].
determinante(det(una)) --> [una].

% ---------------------------------------------------------
% CUANTIFICADORES
% ---------------------------------------------------------

cuantificador(cuant(todas)) --> [todas].
cuantificador(cuant(varios)) --> [varios].

% ---------------------------------------------------------
% NUMERALES
% ---------------------------------------------------------

numeral(num(tres)) --> [tres].
numeral(num(cuatro)) --> [cuatro].
numeral(num(cinco)) --> [cinco].
numeral(num(siete)) --> [siete].

% ---------------------------------------------------------
% VERBOS
% ---------------------------------------------------------

verbo(v(es)) --> [es].
verbo(v(son)) --> [son].
verbo(v(tiene)) --> [tiene].
verbo(v(tienen)) --> [tienen].
verbo(v(valen)) --> [valen].
verbo(v(representa)) --> [representa].
verbo(v(aumenta)) --> [aumenta].
verbo(v(dividen)) --> [dividen].
verbo(v(se)) --> [se].
verbo(v(come)) --> [come].
verbo(v(bebe)) --> [bebe].
verbo(v(comen)) --> [comen].
verbo(v(estudia)) --> [estudia].

% ---------------------------------------------------------
% PARTICIPIOS
% ---------------------------------------------------------

participio(part(dividida)) --> [dividida].

% ---------------------------------------------------------
% ADJETIVOS
% ---------------------------------------------------------

adjetivo(adj(acertada)) --> [acertada].
adjetivo(adj(musicales)) --> [musicales].
adjetivo(adj(anterior)) --> [anterior].
adjetivo(adj(pequena)) --> [pequena].
adjetivo(adj(iguales)) --> [iguales].

% ---------------------------------------------------------
% ADVERBIOS
% ---------------------------------------------------------

adverbio(adv(igual)) --> [igual].

% ---------------------------------------------------------
% PREPOSICIONES
% ---------------------------------------------------------

preposicion(prep(de)) --> [de].
preposicion(prep(del)) --> [del].
preposicion(prep(a)) --> [a].
preposicion(prep(en)) --> [en].
preposicion(prep(con)) --> [con].

% ---------------------------------------------------------
% CONJUNCIONES
% ---------------------------------------------------------

conjuncion(conj(y)) --> [y].

% ---------------------------------------------------------
% RELATIVOS
% ---------------------------------------------------------

relativo(rel(que)) --> [que].

% ---------------------------------------------------------
% NOMBRES
% ---------------------------------------------------------

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
nombre(n(jose)) --> [jose].
nombre(n(maria)) --> [maria].
nombre(n(juan)) --> [juan].
nombre(n(filosofia)) --> [filosofia].
nombre(n(derecho)) --> [derecho].
nombre(n(tenedor)) --> [tenedor].
nombre(n(cuchillo)) --> [cuchillo].

% ---------------------------------------------------------
% SIGNOS DE PUNTUACION
% ---------------------------------------------------------

dos_puntos(dp(':')) --> [':'].
coma(c(',')) --> [','].
