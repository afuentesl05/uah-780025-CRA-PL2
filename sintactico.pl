% =========================================================
% ANALIZADOR SINTACTICO
% Corpus inicial de 10 frases
% Version reorganizada y limpiada
% =========================================================

% ---------------------------------------------------------
% ORACION
% ---------------------------------------------------------

oracion(o(suj(GN), pred(GV))) --> gn(GN), gv(GV).

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
% GV SIMPLES
% ---------------------------------------------------------

gv(gv(V)) -->
    verbo(V).

gv(gv(V, GN)) -->
    verbo(V), gn(GN).

gv(gv(V, GP)) -->
    verbo(V), gp_verbal(V, GP).

gv(gv(V, GN, GP)) -->
    verbo(V), gn(GN), gp_verbal(V, GP).

% ---------------------------------------------------------
% GV CON VERBO COMPUESTO
% ---------------------------------------------------------

gv(gv(VC)) -->
    verbo_compuesto(VC).

gv(gv(VC, GN)) -->
    verbo_compuesto(VC), gn(GN).

gv(gv(VC, GP)) -->
    verbo_compuesto(VC), gp_verbal(VC, GP).

gv(gv(VC, GN, GP)) -->
    verbo_compuesto(VC), gn(GN), gp_verbal(VC, GP).

% ---------------------------------------------------------
% GV COORDINADOS
% ---------------------------------------------------------

gv(gv(V, GN1, Conj, V2)) -->
    verbo(V), gn(GN1), conjuncion(Conj), verbo(V2).

gv(gv(V1, Conj, V2, GN)) -->
    verbo(V1), conjuncion(Conj), verbo(V2), gn(GN).

gv(gv(V1, Conj, V2, Adv)) -->
    verbo(V1), conjuncion(Conj), verbo(V2), adverbio(Adv).

gv(gv(V1, Conj, V2, Adv, GP)) -->
    verbo(V1), conjuncion(Conj), verbo(V2), adverbio(Adv), gp_verbal(V2, GP).

gv(gv(V1, GN, Conj, V2, Adv, GP)) -->
    verbo(V1), gn(GN), conjuncion(Conj), verbo(V2), adverbio(Adv), gp_verbal(V2, GP).

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

% ---------------------------------------------------------
% SIGNOS DE PUNTUACION
% ---------------------------------------------------------

dos_puntos(dp(':')) --> [':'].
coma(c(',')) --> [','].