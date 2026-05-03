% =========================================================
% ANALIZADOR SINTACTICO
% Archivo: sintactico.pl
%
% Contiene:
% - reglas DCG sintacticas
% - restricciones lexico-sintacticas
% - clasificacion de oraciones
% - simplificacion recursiva
% - separacion de relativas
%
% El lexico se carga desde lexico.pl
% =========================================================

:- ensure_loaded('lexico.pl').

% =========================================================
% ORACION
% =========================================================

oracion(O) -->
    oracion_simple(O).

oracion(O) -->
    oracion_coordinada(O).

% ---------------------------------------------------------
% ORACION SIMPLE
% ---------------------------------------------------------

oracion_simple(o(suj(impersonal), pred(GV))) -->
    gv_existencial(GV).

oracion_simple(o(suj(GN), pred(GV))) -->
    gn(GN),
    gv_no_coord(GV).

% ---------------------------------------------------------
% ORACION COORDINADA
% ---------------------------------------------------------
%
% Caso 1:
%   Coordinacion de dos o mas oraciones completas.
%
% Caso 2:
%   Coordinacion de dos o mas predicados con sujeto compartido.
%
% =========================================================

oracion_coordinada(OC) -->
    oracion_simple(O1),
    conj_coord(Conj),
    cola_oraciones_coordinadas(O1, Conj, OC).

oracion_coordinada(
    oc(o(suj(GN), pred(GV1)), Conj, O2)
) -->
    gn(GN),
    gv_no_coord(GV1),
    conj_coord(Conj),
    cola_predicados_coordinados(GN, O2).

cola_oraciones_coordinadas(O1, Conj, oc(O1, Conj, O2)) -->
    oracion_simple(O2).

cola_oraciones_coordinadas(O1, Conj1, oc(O1, Conj1, OC2)) -->
    oracion_simple(O2),
    conj_coord(Conj2),
    cola_oraciones_coordinadas(O2, Conj2, OC2).

cola_predicados_coordinados(
    GN,
    oc(o(suj(GN), pred(GV)), Conj, O2)
) -->
    gv_no_coord(GV),
    conj_coord(Conj),
    cola_predicados_coordinados(GN, O2).

cola_predicados_coordinados(
    GN,
    o(suj(GN), pred(GV))
) -->
    gv_no_coord(GV).

% =========================================================
% GRUPO NOMINAL
% =========================================================
%
% Representacion:
%
%   gn(Base, Extensiones)
%
% =========================================================

gn(GN) -->
    gn_coordinable(GN).

gn_coordinable(GN) -->
    gn_no_coord(GN).

gn_coordinable(gn_coord(GN1, Conj, GN2)) -->
    gn_no_coord(GN1),
    conj_coord(Conj),
    gn_no_coord(GN2).

gn_no_coord(gn(Base, Exts)) -->
    gn_nucleo(Nucleo, Base),
    extensiones_nominales(Nucleo, Exts),
    { extensiones_nominales_validas(Exts) }.



% ---------------------------------------------------------
% NUCLEO NOMINAL
% ---------------------------------------------------------

gn_nucleo(NLex, base(N)) -->
    nombre(N),
    { nombre_lexema(N, NLex) }.

gn_nucleo(NLex, base(Det, N)) -->
    determinante(Det),
    nombre(N),
    { nombre_lexema(N, NLex) }.

gn_nucleo(NLex, base(Det, Adj, N)) -->
    determinante(Det),
    adjetivo(Adj),
    nombre(N),
    { nombre_lexema(N, NLex) }.

gn_nucleo(NLex, base(Det, N, Adj)) -->
    determinante(Det),
    nombre(N),
    adjetivo(Adj),
    { nombre_lexema(N, NLex) }.

gn_nucleo(NLex, base(Adj, N)) -->
    adjetivo(Adj),
    nombre(N),
    { nombre_lexema(N, NLex) }.

gn_nucleo(NLex, base(N, Adj)) -->
    nombre(N),
    adjetivo(Adj),
    { nombre_lexema(N, NLex) }.

gn_nucleo(NLex, base(N1, N2)) -->
    nombre(N1),
    nombre(N2),
    { nombre_lexema(N2, NLex) }.

gn_nucleo(NLex, base(Det, N1, N2)) -->
    determinante(Det),
    nombre(N1),
    nombre(N2),
    { nombre_lexema(N2, NLex) }.

gn_nucleo(NLex, base(Cuant, Det, N)) -->
    cuantificador(Cuant),
    determinante(Det),
    nombre(N),
    { nombre_lexema(N, NLex) }.

gn_nucleo(NLex, base(Cuant, N)) -->
    cuantificador(Cuant),
    nombre(N),
    { nombre_lexema(N, NLex) }.

gn_nucleo(NLex, base(Num, N, Adj)) -->
    numeral(Num),
    nombre(N),
    adjetivo(Adj),
    { nombre_lexema(N, NLex) }.

gn_nucleo(NLex, base(Num, N)) -->
    numeral(Num),
    nombre(N),
    { nombre_lexema(N, NLex) }.

gn_nucleo(none, base(Num)) -->
    numeral(Num).

% ---------------------------------------------------------
% EXTENSIONES NOMINALES
% ---------------------------------------------------------

extensiones_nominales(Nucleo, [Ext|Resto]) -->
    extension_nominal(Nucleo, Ext),
    extensiones_nominales(Nucleo, Resto).

extensiones_nominales(_, []) -->
    [].

extension_nominal(Nucleo, gp(GP)) -->
    gp_nominal(Nucleo, GP).

extension_nominal(_, or(OR)) -->
    or_rel(OR).

extension_nominal(_, gadj(GAdj)) -->
    gadj_extension(GAdj).

extension_nominal(_, enum(DP, Enum)) -->
    dos_puntos(DP),
    enumeracion_general(Enum).

% ---------------------------------------------------------
% VALIDACION DE EXTENSIONES NOMINALES
% ---------------------------------------------------------

extensiones_nominales_validas(Exts) :-
    ext_counts(Exts, NumOr, NumGAdj, NumEnum),
    NumOr =< 1,
    NumGAdj =< 1,
    NumEnum =< 1,
    enum_al_final(Exts).

ext_counts([], 0, 0, 0).

ext_counts([Ext|R], NumOr, NumGAdj, NumEnum) :-
    ext_counts(R, OrR, GAdjR, EnumR),
    ext_increment(Ext, DOr, DGAdj, DEnum),
    NumOr is OrR + DOr,
    NumGAdj is GAdjR + DGAdj,
    NumEnum is EnumR + DEnum.

ext_increment(gp(_), 0, 0, 0).
ext_increment(or(_), 1, 0, 0).
ext_increment(gadj(_), 0, 1, 0).
ext_increment(enum(_, _), 0, 0, 1).

enum_al_final([]).

enum_al_final([enum(_, _)]).

enum_al_final([Ext|R]) :-
    Ext \= enum(_, _),
    enum_al_final(R).

% =========================================================
% ENUMERACIONES GENERALES
% =========================================================
%
% Se usan en:
%
%   Las llaves son tres: sol, fa y do.
%   Hay dos clases de compases: pares e impares.
%
% Los adjetivos de enumeracion se representan siempre como
% grupos adjetivales:
%
%   pares      -> elem_gadj(gadj(adj(pares)))
%   muy breves -> elem_gadj(gadj(gadv(adv(muy)), adj(breves)))
%
% =========================================================

enumeracion_general(enum(Elem, Tail)) -->
    elemento_enumeracion(Elem),
    cola_enumeracion(Tail).

cola_enumeracion(seg(Sep, Elem, Tail)) -->
    separador_enumeracion(Sep),
    elemento_enumeracion(Elem),
    cola_enumeracion(Tail).

cola_enumeracion(fin, Tokens, Tokens) :-
    \+ phrase(separador_enumeracion(_), Tokens, _).

separador_enumeracion(coma(C)) -->
    coma(C).

separador_enumeracion(conj(Conj)) -->
    conj_coord(Conj).

elemento_enumeracion(elem_gn(GN)) -->
    gn_no_coord(GN).

elemento_enumeracion(elem_gadj(GAdj)) -->
    gadj_enumeracion(GAdj).

elemento_enumeracion(elem_etc(Etc)) -->
    etcetera(Etc).

% ---------------------------------------------------------
% GRUPOS ADJETIVALES DENTRO DE ENUMERACIONES
% ---------------------------------------------------------

gadj_enumeracion(gadj(Adj)) -->
    adjetivo(Adj).

gadj_enumeracion(gadj(GAdv, Adj)) -->
    gadv(GAdv),
    adjetivo(Adj).
% =========================================================
% ENUMERACIONES PREPOSICIONALES
% =========================================================
%
% Se usan cuando una enumeracion aparece como termino de una
% preposicion.
%
% Solo se aceptan si terminan en "etc".
%
% Se permite:
%
%   de dos, tres o cuatro tiempos, etc
%   de unisono, segunda, tercera, etc
%
% Se evita aceptar la frase 18:
%
%   en segunda linea, la llave de fa en cuarta linea, ...
%
% =========================================================

enumeracion_preposicional(enum(Elem, Tail)) -->
    elemento_enumeracion_no_etc(Elem),
    cola_enumeracion_preposicional(Tail).

cola_enumeracion_preposicional(seg(Sep, elem_etc(Etc), fin)) -->
    separador_enumeracion(Sep),
    etcetera(Etc).

cola_enumeracion_preposicional(seg(Sep, Elem, Tail)) -->
    separador_enumeracion(Sep),
    elemento_enumeracion_no_etc(Elem),
    cola_enumeracion_preposicional(Tail).

elemento_enumeracion_no_etc(elem_gn(GN)) -->
    gn_no_coord(GN).

elemento_enumeracion_no_etc(elem_gadj(GAdj)) -->
    gadj_enumeracion(GAdj).

% =========================================================
% GRUPO VERBAL
% =========================================================
%
% Representacion:
%
%   gv(PreAdvs, Nucleo, Complementos)
%
% =========================================================

gv(GV) -->
    gv_coordinable(GV).

gv_coordinable(gv_coord(GV1, Conj, GV2)) -->
    gv_no_coord(GV1),
    conj_coord(Conj),
    gv_no_coord(GV2).

gv_coordinable(GV) -->
    gv_no_coord(GV).

gv_no_coord(gv(PreAdvs, Nucleo, Compls)) -->
    adverbiales_preverbales(PreAdvs),
    nucleo_verbal(Nucleo),
    complementos_verbales(Nucleo, Compls),
    { complementos_verbales_validos(Nucleo, Compls) }.

% ---------------------------------------------------------
% GV EXISTENCIAL
% ---------------------------------------------------------

gv_existencial(gv([], v(hay), [gn(GN)])) -->
    [hay],
    gn(GN).

% ---------------------------------------------------------
% ADVERBIALES PREVERBALES
% ---------------------------------------------------------

adverbiales_preverbales([GAdv|Resto]) -->
    gadv(GAdv),
    adverbiales_preverbales(Resto).

adverbiales_preverbales([]) -->
    [].

% ---------------------------------------------------------
% NUCLEO VERBAL
% ---------------------------------------------------------

nucleo_verbal(V) -->
    verbo(V).

nucleo_verbal(VC) -->
    verbo_compuesto(VC).

% ---------------------------------------------------------
% VERBO COMPUESTO
% ---------------------------------------------------------

verbo_compuesto(vc(VAux, V)) -->
    verbo_aux(VAux),
    verbo(V).

verbo_aux(v(se)) -->
    [se].

% ---------------------------------------------------------
% COMPLEMENTOS VERBALES
% ---------------------------------------------------------

complementos_verbales(Nucleo, [Comp|Resto]) -->
    complemento_verbal(Nucleo, Comp),
    complementos_verbales(Nucleo, Resto).

complementos_verbales(_, []) -->
    [].

complemento_verbal(_, gn(GN)) -->
    gn(GN).

complemento_verbal(_, gp(GP)) -->
    gp(GP).

complemento_verbal(_, gadj(GAdj)) -->
    gadj_verbal(GAdj).

complemento_verbal(_, gadv(GAdv)) -->
    gadv(GAdv).



% ---------------------------------------------------------
% VALIDACION DE COMPLEMENTOS VERBALES
% ---------------------------------------------------------

complementos_verbales_validos(Nucleo, Compls) :-
    tipos_complementos(Compls, Tipos),
    patron_tipos_complementos(Tipos),
    gps_validos_para_verbo(Nucleo, Compls).

tipos_complementos([], []).

tipos_complementos([C|R], [T|TR]) :-
    tipo_complemento(C, T),
    tipos_complementos(R, TR).

tipo_complemento(gn(_), gn).
tipo_complemento(gp(_), gp).
tipo_complemento(gadj(_), gadj).
tipo_complemento(gadv(_), gadv).

patron_tipos_complementos(Tipos) :-
    gadv_prefix(Tipos, R1),
    opt_prefix(gn, R1, R2),
    gp_prefix(R2, R3),
    opt_prefix(gadj, R3, []).

gadv_prefix([gadv|R], Rest) :-
    !,
    gadv_prefix(R, Rest).

gadv_prefix(Rest, Rest).

opt_prefix(T, [T|R], R) :-
    !.

opt_prefix(_, R, R).

gp_prefix([gp|R], Rest) :-
    !,
    gp_prefix(R, Rest).

gp_prefix(Rest, Rest).

gps_validos_para_verbo(_, []).

gps_validos_para_verbo(Nucleo, [Comp|R]) :-
    gp_valido_si_procede(Nucleo, Comp),
    gps_validos_para_verbo(Nucleo, R).

gp_valido_si_procede(_, gn(_)).
gp_valido_si_procede(_, gadj(_)).
gp_valido_si_procede(_, gadv(_)).

gp_valido_si_procede(Nucleo, gp(GP)) :-
    gp_valido_verbal_estructura(Nucleo, GP).

gp_valido_verbal_estructura(Nucleo, gp(Prep, _)) :-
    verbo_lexema(Nucleo, VerboAtom),
    prep_lexema(Prep, PrepAtom),
    admite_gp_verbal(VerboAtom, PrepAtom).

gp_valido_verbal_estructura(Nucleo, gp_coord(GP1, _, GP2)) :-
    gp_valido_verbal_estructura(Nucleo, GP1),
    gp_valido_verbal_estructura(Nucleo, GP2).

% =========================================================
% GRUPO PREPOSICIONAL
% =========================================================

gp(GP) -->
    gp_coordinable(GP).

gp_coordinable(gp_coord(GP1, Conj, GP2)) -->
    gp_simple(GP1),
    conj_coord(Conj),
    gp_simple(GP2).

gp_coordinable(GP) -->
    gp_simple(GP).

gp_simple(gp(Prep, Term)) -->
    preposicion(Prep),
    termino_preposicional(Term).

termino_preposicional(gn(GN)) -->
    gn(GN).

termino_preposicional(enum(Enum)) -->
    enumeracion_preposicional(Enum).

termino_preposicional(ocm(GVInf)) -->
    gv_infinitivo(GVInf).

% ---------------------------------------------------------
% GP NOMINAL
% ---------------------------------------------------------

gp_nominal(Nucleo, GP) -->
    gp(GP),
    { gp_valido_nominal_estructura(Nucleo, GP) }.

gp_valido_nominal_estructura(Nucleo, gp(Prep, _)) :-
    Nucleo \= none,
    prep_lexema(Prep, PrepAtom),
    admite_gp_nominal(Nucleo, PrepAtom).

gp_valido_nominal_estructura(Nucleo, gp_coord(GP1, _, GP2)) :-
    gp_valido_nominal_estructura(Nucleo, GP1),
    gp_valido_nominal_estructura(Nucleo, GP2).

% =========================================================
% CONSTRUCCION INFINITIVA / COMPUESTA
% =========================================================

gv_infinitivo(gv_inf(V, Compls)) -->
    verbo(V),
    complementos_verbales(V, Compls),
    { complementos_verbales_validos(V, Compls) }.

% =========================================================
% RESTRICCIONES LEXICO-SINTACTICAS
% =========================================================
%
% Estas reglas controlan que no cualquier nombre o verbo
% pueda combinarse con cualquier preposicion.
%
% La idea es agrupar los nombres y verbos en clases
% semantico-sintacticas, para evitar escribir una regla
% aislada para cada frase del corpus.
%
% =========================================================


% =========================================================
% CLASES NOMINALES
% =========================================================

% ---------------------------------------------------------
% Nombres que admiten complementos con "de" o "del"
% ---------------------------------------------------------


clase_nominal(sucesion, relacional_de_del).
clase_nominal(conjunto, relacional_de_del).
clase_nominal(porcion, relacional_de_del).
clase_nominal(sinonimo, relacional_de_del).
clase_nominal(nombres, relacional_de_del).
clase_nominal(nombre, relacional_de_del).
clase_nominal(acepcion, relacional_de_del).
clase_nominal(valor, relacional_de_del).
clase_nominal(clases, relacional_de_del).
clase_nominal(notas, relacional_de_del).
clase_nominal(silencio, relacional_de_del).
clase_nominal(pasos, relacional_de_del).
clase_nominal(nota, relacional_de_del).

% ---------------------------------------------------------
% Nombres que admiten complementos de finalidad con "para"
% ---------------------------------------------------------

clase_nominal(reglas, finalidad).

% ---------------------------------------------------------
% Nombres de distancia u origen/destino
% ---------------------------------------------------------

clase_nominal(distancia, origen_destino).

% ---------------------------------------------------------
% Nombre que aparece con la contraccion "del"
% ---------------------------------------------------------

clase_nominal(mitad, contraccion_del).

% ---------------------------------------------------------
% Nombres asociados a llaves musicales
% ---------------------------------------------------------

clase_nominal(llave, clave_musical).
clase_nominal(llaves, clave_musical).

% ---------------------------------------------------------
% Nombres de elementos musicales localizables
% ---------------------------------------------------------


clase_nominal(notas, localizable_en).


% =========================================================
% COMPATIBILIDAD NOMINAL POR CLASE
% =========================================================

% ---------------------------------------------------------
% Complementos relacionales con "de" y "del"
% ---------------------------------------------------------

admite_gp_nominal_clase(relacional_de_del, de).
admite_gp_nominal_clase(relacional_de_del, del).

% ---------------------------------------------------------
% Complementos de finalidad
% ---------------------------------------------------------

admite_gp_nominal_clase(finalidad, para).

% ---------------------------------------------------------
% Complementos de origen, destino o relacion entre elementos
% ---------------------------------------------------------

admite_gp_nominal_clase(origen_destino, de).
admite_gp_nominal_clase(origen_destino, a).
admite_gp_nominal_clase(origen_destino, entre).

% ---------------------------------------------------------
% Complemento con contraccion "del"
% ---------------------------------------------------------

admite_gp_nominal_clase(contraccion_del, del).

% ---------------------------------------------------------
% Complementos propios de llaves musicales
% ---------------------------------------------------------

admite_gp_nominal_clase(clave_musical, de).
admite_gp_nominal_clase(clave_musical, en).

% ---------------------------------------------------------
% Complementos locativos con "en"
% ---------------------------------------------------------

admite_gp_nominal_clase(localizable_en, en).


% =========================================================
% ENTRADA PUBLICA PARA GP NOMINALES
% =========================================================

admite_gp_nominal(Nucleo, Prep) :-
    clase_nominal(Nucleo, Clase),
    admite_gp_nominal_clase(Clase, Prep).

admite_gp_nominal(Nucleo, Prep) :-
    admite_gp_nominal_directo(Nucleo, Prep).

% Compatibilidades directas excepcionales.
% Se dejan aqui para poder ampliar sin tocar las clases.

admite_gp_nominal_directo(_, _) :-
    fail.


% =========================================================
% CLASES VERBALES
% =========================================================

% ---------------------------------------------------------
% Verbos de cambio de valor
% ---------------------------------------------------------

clase_verbal(aumenta, cambio_valor).

% ---------------------------------------------------------
% Verbos de clasificacion
% ---------------------------------------------------------

clase_verbal(dividen, clasificacion).

% ---------------------------------------------------------
% Verbos de resultado o relacion entre elementos
% ---------------------------------------------------------

clase_verbal(resultan, relacion_resultado).

% ---------------------------------------------------------
% Verbos de composicion
% ---------------------------------------------------------

clase_verbal(compone, composicion).

% ---------------------------------------------------------
% Verbos de finalidad o uso
% ---------------------------------------------------------

clase_verbal(sirve, finalidad).
clase_verbal(usa, finalidad).

% ---------------------------------------------------------
% Verbos de equivalencia
% ---------------------------------------------------------

clase_verbal(valen, equivalencia).

% ---------------------------------------------------------
% Verbos de denominacion
% ---------------------------------------------------------

clase_verbal(toman, denominacion).
clase_verbal(toma, denominacion).

% ---------------------------------------------------------
% Verbos de correspondencia
% ---------------------------------------------------------

clase_verbal(corresponden, correspondencia).

% ---------------------------------------------------------
% Verbos de union o enlace
% ---------------------------------------------------------


clase_verbal(une, enlace).

% ---------------------------------------------------------
% Verbos de fijacion o ubicacion
% ---------------------------------------------------------


clase_verbal(fijar, ubicacion).

% ---------------------------------------------------------
% Verbo "servir" con complemento "de"
% ---------------------------------------------------------


clase_verbal(sirve, funcion).


% =========================================================
% COMPATIBILIDAD VERBAL POR CLASE
% =========================================================

% ---------------------------------------------------------
% Cambio de valor
% ---------------------------------------------------------

admite_gp_verbal_clase(cambio_valor, a).
admite_gp_verbal_clase(cambio_valor, al).

% ---------------------------------------------------------
% Clasificacion
% ---------------------------------------------------------

admite_gp_verbal_clase(clasificacion, en).

% ---------------------------------------------------------
% Resultado o relacion entre elementos
% ---------------------------------------------------------

admite_gp_verbal_clase(relacion_resultado, entre).

% ---------------------------------------------------------
% Composicion
% ---------------------------------------------------------

admite_gp_verbal_clase(composicion, de).

% ---------------------------------------------------------
% Finalidad o uso
% ---------------------------------------------------------

admite_gp_verbal_clase(finalidad, para).

% ---------------------------------------------------------
% Equivalencia
% ---------------------------------------------------------

admite_gp_verbal_clase(equivalencia, a).

% ---------------------------------------------------------
% Denominacion
% ---------------------------------------------------------

admite_gp_verbal_clase(denominacion, de).
admite_gp_verbal_clase(denominacion, como).

% ---------------------------------------------------------
% Correspondencia
% ---------------------------------------------------------

admite_gp_verbal_clase(correspondencia, a).

% ---------------------------------------------------------
% Union o enlace
% ---------------------------------------------------------

admite_gp_verbal_clase(enlace, a).

% ---------------------------------------------------------
% Ubicacion o fijacion
% ---------------------------------------------------------

admite_gp_verbal_clase(ubicacion, en).

% ---------------------------------------------------------
% Funcion
% ---------------------------------------------------------

admite_gp_verbal_clase(funcion, de).


% =========================================================
% ENTRADA PUBLICA PARA GP VERBALES
% =========================================================

admite_gp_verbal(Verbo, Prep) :-
    clase_verbal(Verbo, Clase),
    admite_gp_verbal_clase(Clase, Prep).

admite_gp_verbal(Verbo, Prep) :-
    admite_gp_verbal_directo(Verbo, Prep).

% Compatibilidades directas excepcionales.
% Se dejan aqui para poder ampliar sin tocar las clases.

admite_gp_verbal_directo(_, _) :-
    fail.
% ---------------------------------------------------------
% EXTRACCION DE LEXEMAS
% ---------------------------------------------------------

nombre_lexema(n(X), X).

verbo_lexema(v(X), X).
verbo_lexema(vc(_, v(X)), X).

prep_lexema(prep(X), X).

% =========================================================
% GRUPO ADJETIVAL
% =========================================================

gadj(gadj(Adj)) -->
    adjetivo(Adj).

gadj(gadj(GAdv, Adj)) -->
    gadv(GAdv),
    adjetivo(Adj).

gadj(gadj(Participio, GP)) -->
    participio(Participio),
    gp_simple(GP).
% ---------------------------------------------------------
% GRUPO ADJETIVAL COMO COMPLEMENTO VERBAL
% ---------------------------------------------------------
%
% No se permiten adjetivos simples como complemento verbal:
%
%   * aumenta ... anterior
%   * tienen ... debiles
%
% Sí se conservan grupos adjetivales complejos, por si aparecen
% como predicativos o estructuras participiales:
%
%   muy breve
%   dividida en partes iguales
%
% =========================================================

gadj_verbal(gadj(GAdv, Adj)) -->
    gadv(GAdv),
    adjetivo(Adj).

gadj_verbal(gadj(Participio, GP)) -->
    participio(Participio),
    gp_simple(GP).

% =========================================================
% GRUPO ADJETIVAL COMO EXTENSION NOMINAL
% =========================================================
%
% Solo se permiten como extensiones nominales los grupos
% adjetivales complejos.
%
% Los adjetivos simples pospuestos se analizan dentro del
% nucleo nominal:
%
%   las notas musicales
%   la figura anterior
%   una linea curva
%
% En cambio, se mantienen como extensiones casos como:
%
%   las llaves mas usuales
%   tiempo dividida en partes iguales
%
% Esto evita ambigüedades espurias.
% =========================================================

gadj_extension(gadj(GAdv, Adj)) -->
    gadv(GAdv),
    adjetivo(Adj).

gadj_extension(gadj(Participio, GP)) -->
    participio(Participio),
    gp_simple(GP).

% =========================================================
% GRUPO ADVERBIAL
% =========================================================
%
% Se reconocen dos tipos:
%
% 1. Grupo adverbial locativo:
%
%      debajo de las lineas
%
% 2. Grupo adverbial simple:
%
%      bien
%      tambien
%      igual
%      ordinariamente
%      muy
% =========================================================

gadv(gadv_loc(Adv, GP)) -->
    adverbio_locativo(Adv),
    gp_locativo(GP).

gadv(gadv(Adv)) -->
    adverbio(Adv).

% ---------------------------------------------------------
% GP LOCATIVO
% ---------------------------------------------------------
%
% Complemento del adverbio locativo.
%
% Se permite:
%
%   de + GN
%   del + GN
%
% Ejemplos:
%
%   debajo de las lineas
%   debajo del pentagrama
%
% =========================================================

gp_locativo(gp(Prep, gn(GN))) -->
    preposicion_locativa(Prep),
    gn(GN).

preposicion_locativa(Prep) -->
    preposicion(Prep),
    { prep_locativa(Prep) }.

prep_locativa(prep(de)).
prep_locativa(prep(del)).

% =========================================================
% ORACION DE RELATIVO
% =========================================================

or_rel(or(Rel, GV)) -->
    relativo(Rel),
    gv(GV).

% =========================================================
% CONJUNCION COORDINANTE
% =========================================================

conj_coord(Conj) -->
    conjuncion(Conj).

% =========================================================
% CLASIFICACION DE ORACIONES
% =========================================================

tipo_oracion(Tokens, Tipo, Arbol) :-
    phrase(oracion(Arbol), Tokens),
    clasificar_arbol(Arbol, Tipo),
    !.

tipo_oracion(_, no_reconocida, none).

clasificar_arbol(oc(_, _, _), coordinada) :-
    !.

clasificar_arbol(Arbol, compuesta) :-
    contiene_compuesta(Arbol),
    !.

clasificar_arbol(o(_, _), simple).

contiene_compuesta(Term) :-
    sub_term(or(_, _), Term).

contiene_compuesta(Term) :-
    sub_term(ocm(_), Term).

% =========================================================
% SIMPLIFICACION RECURSIVA
% =========================================================

simplificar(oc(O1, _, O2), Simples) :-
    !,
    simplificar(O1, S1),
    simplificar(O2, S2),
    concatenar(S1, S2, Simples).

simplificar(O, Simples) :-
    extraer_relativas(O, Relativas),
    quitar_relativas_term(O, Principal),
    concatenar(Relativas, [Principal], Simples).

% ---------------------------------------------------------
% EXTRACCION DE RELATIVAS
% ---------------------------------------------------------

extraer_relativas(Term, Relativas) :-
    findall(
        OracionRelativa,
        (
            sub_term(GN, Term),
            relativa_de_gn(GN, OracionRelativa)
        ),
        Relativas
    ).

relativa_de_gn(gn(Base, Exts), OracionRelativa) :-
    pertenece(or(or(_, GVRel)), Exts),
    quitar_relativas_term(gn(Base, Exts), GNSujeto),
    quitar_relativas_term(GVRel, GVRelLimpio),
    OracionRelativa = o(suj(GNSujeto), pred(GVRelLimpio)).

% ---------------------------------------------------------
% ELIMINACION DE RELATIVAS EN TERMINOS
% ---------------------------------------------------------

quitar_relativas_term(Var, Var) :-
    var(Var),
    !.

quitar_relativas_term([], []) :-
    !.

quitar_relativas_term([X|Xs], [Y|Ys]) :-
    !,
    quitar_relativas_term(X, Y),
    quitar_relativas_term(Xs, Ys).

quitar_relativas_term(gn(Base, Exts), gn(BaseLimpia, ExtsLimpias)) :-
    !,
    quitar_relativas_term(Base, BaseLimpia),
    quitar_relativas_extensiones(Exts, ExtsLimpias).

quitar_relativas_term(Term, Term) :-
    atomic(Term),
    !.

quitar_relativas_term(Term, TermLimpio) :-
    compound(Term),
    Term =.. [Functor|Args],
    quitar_relativas_argumentos(Args, ArgsLimpios),
    TermLimpio =.. [Functor|ArgsLimpios].

quitar_relativas_argumentos([], []).

quitar_relativas_argumentos([A|As], [AL|ALs]) :-
    quitar_relativas_term(A, AL),
    quitar_relativas_argumentos(As, ALs).

quitar_relativas_extensiones([], []).

quitar_relativas_extensiones([or(_)|R], Limpias) :-
    !,
    quitar_relativas_extensiones(R, Limpias).

quitar_relativas_extensiones([Ext|R], [ExtLimpia|RLimpias]) :-
    quitar_relativas_term(Ext, ExtLimpia),
    quitar_relativas_extensiones(R, RLimpias).

% =========================================================
% UTILIDADES BASICAS DE LISTAS
% =========================================================

concatenar([], L, L).

concatenar([X|Xs], L, [X|R]) :-
    concatenar(Xs, L, R).

pertenece(X, [X|_]).

pertenece(X, [_|R]) :-
    pertenece(X, R).