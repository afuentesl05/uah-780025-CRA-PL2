% =========================================================
% DETECCION.PL
%
% Analisis semantico y deteccion de advertencias.
%
% Detecta:
% - ambiguedad semantica contextual
% - ambiguedad en relaciones de sinonimia
% - incoherencias sujeto-verbo
% - incoherencias verbo-complemento
% - usos no literales / metaforas simples
%
% La deteccion se basa en reglas generales sobre el arbol,
% no en frases completas del corpus.
% =========================================================

:- ensure_loaded('main.pl').
:- ensure_loaded('semantico.pl').

:- use_module(library(lists)).


% =========================================================
% ENTRADAS PUBLICAS
% =========================================================

analizar_semantico_id_detallado(
    Id,
    Estado,
    Clasificacion,
    Advertencias,
    Explicaciones,
    Arbol
) :-
    (
        oracion(Id, Tokens)
    ->
        analizar_semantico_tokens_detallado(
            Tokens,
            Estado,
            Clasificacion,
            Advertencias,
            Explicaciones,
            Arbol
        )
    ;
        Estado = fallo_id,
        Clasificacion = no_reconocida,
        Advertencias = [],
        Explicaciones = ['No existe una oracion con ese identificador.'],
        Arbol = none
    ).


analizar_semantico_tokens_detallado(
    Tokens,
    ok,
    Clasificacion,
    Advertencias,
    Explicaciones,
    Arbol
) :-
    phrase(oracion(Arbol), Tokens),
    !,
    advertencias_semanticas(Arbol, Advertencias),
    clasificar_advertencias(Advertencias, Clasificacion),
    explicaciones_desde_advertencias(Advertencias, Explicaciones).

analizar_semantico_tokens_detallado(
    _Tokens,
    fallo_sintactico,
    no_reconocida,
    [],
    ['No reconocida por la gramatica sintactica.'],
    none
).


% ---------------------------------------------------------
% Compatibilidad con llamadas antiguas
% ---------------------------------------------------------

analizar_semantico_id(Id, Estado, Clasificacion, Advertencias, Arbol) :-
    analizar_semantico_id_detallado(
        Id,
        Estado,
        Clasificacion,
        Advertencias,
        _Explicaciones,
        Arbol
    ).

analizar_semantico_tokens(Tokens, Estado, Clasificacion, Advertencias, Arbol) :-
    analizar_semantico_tokens_detallado(
        Tokens,
        Estado,
        Clasificacion,
        Advertencias,
        _Explicaciones,
        Arbol
    ).


% =========================================================
% GENERACION DE ADVERTENCIAS
% =========================================================

advertencias_semanticas(Arbol, Advertencias) :-
    findall(
        Advertencia,
        advertencia_semantica(Arbol, Advertencia),
        Advertencias0
    ),
    sort(Advertencias0, Advertencias).


advertencia_semantica(Arbol, Advertencia) :-
    advertencia_ambiguedad_sinonimia(Arbol, Advertencia).

advertencia_semantica(Arbol, Advertencia) :-
    advertencia_ambiguedad_contextual(Arbol, Advertencia).

advertencia_semantica(Arbol, Advertencia) :-
    advertencia_incoherencia_sujeto_verbo(Arbol, Advertencia).

advertencia_semantica(Arbol, Advertencia) :-
    advertencia_incoherencia_verbo_complemento(Arbol, Advertencia).

advertencia_semantica(Arbol, Advertencia) :-
    advertencia_uso_no_literal(Arbol, Advertencia).


% =========================================================
% AMBIGUEDAD POR SINONIMIA
% =========================================================
%
% Regla general:
%
%   X es sinonimo de Y
%
% Si X o Y tienen varios sentidos registrados, se genera una
% advertencia. Esto permite detectar frases manuales como:
%
%   El tiempo es sinonimo de aire.
%   El compas es sinonimo de aire.
%   La llave es sinonimo de signo.
%
% sin depender de una frase concreta del corpus.
% =========================================================

advertencia_ambiguedad_sinonimia(
    Arbol,
    advertencia(
        ambiguedad_semantica,
        sinonimia(X, Y),
        sentidos(X, SX, Y, SY)
    )
) :-
    relacion_sinonimia(Arbol, X, Y),
    (
        palabra_ambigua(X)
    ;
        palabra_ambigua(Y)
    ),
    sentidos_resumen(X, SX),
    sentidos_resumen(Y, SY).


relacion_sinonimia(Arbol, X, Y) :-
    sub_term(o(suj(Sujeto), pred(gv(_, v(es), Complementos))), Arbol),
    sujeto_principal(Sujeto, X),
    member(gn(GN), Complementos),
    atributo_sinonimo_de(GN, Ys),
    member(Y, Ys),
    X \= Y.


atributo_sinonimo_de(gn(Base, Exts), Ys) :-
    contiene_nombre(Base, sinonimo),
    findall(
        Y,
        (
            member(gp(GP), Exts),
            gp_de_o_del(GP, Termino),
            nombre_canonico_en_term(Termino, Y)
        ),
        Ys0
    ),
    sort(Ys0, Ys).


gp_de_o_del(gp(prep(de), Termino), Termino).

gp_de_o_del(gp(prep(del), Termino), Termino).

gp_de_o_del(gp_coord(GP1, _, _), Termino) :-
    gp_de_o_del(GP1, Termino).

gp_de_o_del(gp_coord(_, _, GP2), Termino) :-
    gp_de_o_del(GP2, Termino).


% =========================================================
% AMBIGUEDAD CONTEXTUAL
% =========================================================
%
% Regla general:
%
% Una palabra solo se marca como ambigua si:
% - tiene sentidos alternativos registrados en semantico.pl
% - aparece en un contexto que realmente puede activar esa duda
%
% Asi se evita que todo el corpus salga ambiguo solo porque
% existan palabras polisemicas.
% =========================================================

advertencia_ambiguedad_contextual(
    Arbol,
    advertencia(
        ambiguedad_semantica,
        palabra(Palabra),
        contexto(Motivo, Sentidos)
    )
) :-
    contexto_ambiguo(Arbol, Palabra, Motivo),
    palabra_ambigua(Palabra),
    sentidos_resumen(Palabra, Sentidos).


% ---------------------------------------------------------
% conjunto
% ---------------------------------------------------------

contexto_ambiguo(
    Arbol,
    conjunto,
    'aparece como adjetivo, pero tambien existe como sustantivo dentro del corpus'
) :-
    sub_term(adj(conjunto), Arbol).


% ---------------------------------------------------------
% linea
% ---------------------------------------------------------

contexto_ambiguo(
    Arbol,
    linea,
    'aparece en la expresion linea curva, que puede entenderse como trazo visual general o como signo grafico musical'
) :-
    base_contiene(Arbol, n(linea)),
    base_contiene(Arbol, adj(curva)).


% ---------------------------------------------------------
% voz
% ---------------------------------------------------------

contexto_ambiguo(
    Arbol,
    voz,
    'aparece en una construccion terminologica, como la voz tonalidad, y no necesariamente como sonido humano'
) :-
    base_contiene(Arbol, n(voz)),
    base_contiene(Arbol, n(tonalidad)).


% ---------------------------------------------------------
% base
% ---------------------------------------------------------

contexto_ambiguo(
    Arbol,
    base,
    'aparece en la construccion servir de base, con posible lectura conceptual o musical'
) :-
    sub_term(gp(prep(de), Termino), Arbol),
    nombre_canonico_en_term(Termino, base).


% =========================================================
% INCOHERENCIA SUJETO-VERBO
% =========================================================
%
% Si un verbo tiene restricciones semanticas declaradas,
% se comprueba que el sujeto pertenezca a alguna clase
% admisible para ese verbo.
%
% Si el verbo no tiene restricciones, no se fuerza nada.
% =========================================================

advertencia_incoherencia_sujeto_verbo(
    Arbol,
    advertencia(
        incoherencia_semantica,
        verbo_sujeto(Verbo, Sujeto),
        clases(SujetoClases, ClasesEsperadas)
    )
) :-
    sujeto_verbo(Arbol, Sujeto, Verbo),
    verbo_con_restriccion(Verbo),
    clases_palabra(Sujeto, SujetoClases),
    SujetoClases \= [],
    clases_admisibles_verbo(Verbo, ClasesEsperadas),
    \+ interseccion_no_vacia(SujetoClases, ClasesEsperadas).


sujeto_verbo(Arbol, Sujeto, Verbo) :-
    predicado_con_sujeto(Arbol, Sujeto, Verbo, _Complementos),
    Sujeto \= impersonal.


% =========================================================
% INCOHERENCIA VERBO-COMPLEMENTO
% =========================================================
%
% La incoherencia sujeto-verbo no basta para detectar todos
% los problemas semanticos. A veces el sujeto es compatible
% con el verbo, pero el complemento no lo es.
%
% Ejemplos manuales que esta capa permite detectar:
%
%   La ligadura es una linea curva que une a dos compases.
%   Estos valores irregulares corresponden al pentagrama.
%   El puntillo aumenta la mitad del valor al pentagrama.
%
% La regla no fuerza nada si:
% - el verbo no tiene restriccion declarada para ese complemento
% - el complemento no tiene clase semantica registrada
%
% Asi se evitan falsos positivos excesivos.
% =========================================================

advertencia_incoherencia_verbo_complemento(
    Arbol,
    advertencia(
        incoherencia_semantica,
        verbo_complemento(Verbo, TipoComplemento, Complemento),
        clases(ComplementoClases, ClasesEsperadas)
    )
) :-
    predicado_con_sujeto(Arbol, _Sujeto, Verbo, Complementos),
    complemento_del_predicado(Complementos, TipoComplemento, Complemento),
    clases_requeridas_complemento(Verbo, TipoComplemento, ClasesEsperadas),
    clases_palabra(Complemento, ComplementoClases),
    ComplementoClases \= [],
    \+ interseccion_no_vacia(ComplementoClases, ClasesEsperadas).


% ---------------------------------------------------------
% Predicados con sujeto
% ---------------------------------------------------------
%
% predicado_con_sujeto/4 devuelve la informacion basica:
%
%   Sujeto, Verbo, Complementos
%
% predicado_con_sujeto_detallado/5 conserva tambien el termino
% verbal completo:
%
%   v(toma)
%   vc(v(se), v(toma))
%
% Esto permite saber si el verbo es pronominal sin buscar "se"
% de forma global en todo el arbol.
%
% Caso 1: oracion principal:
%
%   o(suj(GN), pred(GV))
%
% Caso 2: subordinada de relativo:
%
%   GN que GV
%
% En una relativa como:
%
%   linea curva que une a dos notas
%
% el sujeto semantico de "une" se recupera desde el nucleo
% del GN antecedente: linea.
% ---------------------------------------------------------

predicado_con_sujeto(Arbol, Sujeto, Verbo, Complementos) :-
    predicado_con_sujeto_detallado(
        Arbol,
        Sujeto,
        Verbo,
        _VerboTerm,
        Complementos
    ).


predicado_con_sujeto_detallado(Arbol, Sujeto, Verbo, VerboTerm, Complementos) :-
    sub_term(o(suj(SujetoTerm), pred(GV)), Arbol),
    sujeto_principal(SujetoTerm, Sujeto),
    gv_simple(GV, VerboTerm, Complementos),
    verbo_atom(VerboTerm, Verbo).

predicado_con_sujeto_detallado(Arbol, Sujeto, Verbo, VerboTerm, Complementos) :-
    sub_term(gn(Base, Exts), Arbol),
    nucleo_base(Base, Sujeto),
    member(or(or(_, GVRel)), Exts),
    gv_simple(GVRel, VerboTerm, Complementos),
    verbo_atom(VerboTerm, Verbo).


% ---------------------------------------------------------
% Grupo verbal simple o coordinado
% ---------------------------------------------------------

gv_simple(gv(_, VerboTerm, Complementos), VerboTerm, Complementos).

gv_simple(gv_coord(GV1, _, _), VerboTerm, Complementos) :-
    gv_simple(GV1, VerboTerm, Complementos).

gv_simple(gv_coord(_, _, GV2), VerboTerm, Complementos) :-
    gv_simple(GV2, VerboTerm, Complementos).


% ---------------------------------------------------------
% Extraccion de complementos
% ---------------------------------------------------------

complemento_del_predicado(Complementos, complemento_directo, Complemento) :-
    member(gn(GN), Complementos),
    nucleo_gn(GN, Complemento).

complemento_del_predicado(Complementos, complemento_preposicional(Prep), Complemento) :-
    member(gp(GP), Complementos),
    gp_complemento(GP, Prep, Complemento).


nucleo_gn(gn(Base, _), Palabra) :-
    nucleo_base(Base, Palabra).

nucleo_gn(gn_coord(GN1, _, _), Palabra) :-
    nucleo_gn(GN1, Palabra).

nucleo_gn(gn_coord(_, _, GN2), Palabra) :-
    nucleo_gn(GN2, Palabra).


gp_complemento(gp(prep(Prep), Termino), Prep, Complemento) :-
    termino_preposicional_nucleo(Termino, Complemento).

gp_complemento(gp_coord(GP1, _, _), Prep, Complemento) :-
    gp_complemento(GP1, Prep, Complemento).

gp_complemento(gp_coord(_, _, GP2), Prep, Complemento) :-
    gp_complemento(GP2, Prep, Complemento).


termino_preposicional_nucleo(gn(GN), Complemento) :-
    nucleo_gn(GN, Complemento).

termino_preposicional_nucleo(Termino, Complemento) :-
    nombre_canonico_en_term(Termino, Complemento).


% ---------------------------------------------------------
% Restricciones semanticas verbo-complemento
% ---------------------------------------------------------
%
% Estas restricciones representan seleccion semantica basica.
% No dicen que la frase sea imposible en todos los contextos;
% solo que, dentro del dominio musical, el complemento esperado
% deberia pertenecer a alguna de estas clases.
% ---------------------------------------------------------

clases_requeridas_complemento(Verbo, TipoComplemento, Clases) :-
    findall(
        Clase,
        clase_admisible_complemento(Verbo, TipoComplemento, Clase),
        Clases0
    ),
    sort(Clases0, Clases),
    Clases \= [].


% aumentar algo a/al X
%
% En el corpus:
%   El puntillo aumenta ... a la figura anterior.
%   El doble puntillo aumenta ... al puntillo anterior.
%
% El destino de aumento debe ser una figura, un silencio u otro
% modificador de duracion, no un soporte grafico como pentagrama.

clase_admisible_complemento(aumenta, complemento_preposicional(a), simbolo_duracion).
clase_admisible_complemento(aumenta, complemento_preposicional(a), modificador_duracion).
clase_admisible_complemento(aumenta, complemento_preposicional(al), simbolo_duracion).
clase_admisible_complemento(aumenta, complemento_preposicional(al), modificador_duracion).


% corresponder a X
%
% En el corpus:
%   Estos valores irregulares corresponden a diversas notas...
%
% El complemento esperable son notas, figuras u otros elementos
% de notacion/duracion.

clase_admisible_complemento(corresponden, complemento_preposicional(a), elemento_musical).
clase_admisible_complemento(corresponden, complemento_preposicional(a), simbolo_duracion).


% unir a X
%
% En el corpus:
%   una linea curva que une a dos notas...
%
% La ligadura o linea une notas, no entidades metricas como
% compases ni soportes graficos como pentagramas.

clase_admisible_complemento(une, complemento_preposicional(a), elemento_musical).


% valer igual a X
%
% En el corpus:
%   valen igual a la figura que representa.
%
% La comparacion de valor se hace con figuras o simbolos de duracion.

clase_admisible_complemento(vale, complemento_preposicional(a), simbolo_duracion).
clase_admisible_complemento(valen, complemento_preposicional(a), simbolo_duracion).


% medir X
%
% En el corpus:
%   sirve para medir el valor de las figuras.
%
% Medir se aplica al valor/duracion, no a cualquier objeto.

clase_admisible_complemento(medir, complemento_directo, entidad_correspondiente).


% fijar X en Y
%
% En el corpus:
%   fijar el nombre de las notas en el pentagrama.
%
% El lugar grafico esperado para fijar nombres/notas es un soporte
% de notacion.

clase_admisible_complemento(fijar, complemento_preposicional(en), soporte_notacion).


% =========================================================
% VERBOS Y AUXILIARES VERBALES
% =========================================================

verbo_atom(v(V), V).

verbo_atom(vc(_, v(V)), V).

verbo_es_pronominal(vc(v(se), _)).


% =========================================================
% USO NO LITERAL / METAFORAS SIMPLES
% =========================================================
%
% El enunciado pide detectar verbos usados fuera de su
% contexto habitual. No se pretende resolver completamente
% el significado, sino generar advertencias interpretativas.
%
% En el dominio musical hay verbos que no se usan siempre
% con su significado fisico literal:
%
%   - tomar el nombre       -> recibir una denominacion
%   - tomarse como acepcion -> interpretarse terminologicamente
%   - servir de base        -> funcionar como fundamento o referencia
%   - usarse para           -> expresar funcion convencional
%
% Estas reglas detectan construcciones generales sobre el arbol,
% no frases completas memorizadas.
% =========================================================

advertencia_uso_no_literal(
    Arbol,
    advertencia(
        uso_no_literal,
        construccion(Construccion),
        contexto(Verbo, Sujeto, Motivo)
    )
) :-
    construccion_no_literal(Arbol, Construccion, Verbo, Sujeto, Motivo).


% ---------------------------------------------------------
% TOMAR EL NOMBRE / TOMAR LOS NOMBRES
% ---------------------------------------------------------

construccion_no_literal(
    Arbol,
    tomar_nombre,
    Verbo,
    Sujeto,
    'el verbo tomar expresa una denominacion terminologica, no una accion fisica de coger algo'
) :-
    predicado_con_sujeto(Arbol, Sujeto, Verbo, Complementos),
    verbo_tomar(Verbo),
    member(gn(GN), Complementos),
    gn_contiene_nombre_canonico(GN, nombre).


% ---------------------------------------------------------
% SE TOMA COMO ACEPCION
% ---------------------------------------------------------

construccion_no_literal(
    Arbol,
    tomarse_como_acepcion,
    Verbo,
    Sujeto,
    'la construccion se toma como expresa una clasificacion terminologica, no una accion literal'
) :-
    predicado_con_sujeto_detallado(
        Arbol,
        Sujeto,
        Verbo,
        VerboTerm,
        Complementos
    ),
    verbo_tomar(Verbo),
    verbo_es_pronominal(VerboTerm),
    member(gp(GP), Complementos),
    gp_con_prep(GP, como),
    gp_contiene_nombre_canonico(GP, acepcion).


% ---------------------------------------------------------
% SERVIR DE BASE
% ---------------------------------------------------------

construccion_no_literal(
    Arbol,
    servir_de_base,
    sirve,
    Sujeto,
    'la expresion servir de base funciona como fundamento o referencia musical, no necesariamente como apoyo fisico literal'
) :-
    predicado_con_sujeto(Arbol, Sujeto, sirve, Complementos),
    member(gp(GP), Complementos),
    gp_con_prep(GP, de),
    gp_contiene_nombre_canonico(GP, base).


% ---------------------------------------------------------
% SE USA PARA
% ---------------------------------------------------------

construccion_no_literal(
    Arbol,
    usarse_para,
    usa,
    Sujeto,
    'la construccion se usa para expresa una funcion convencional del signo musical, no una accion fisica realizada por el sujeto'
) :-
    predicado_con_sujeto_detallado(
        Arbol,
        Sujeto,
        usa,
        VerboTerm,
        Complementos
    ),
    verbo_es_pronominal(VerboTerm),
    member(gp(GP), Complementos),
    gp_con_prep(GP, para).


% ---------------------------------------------------------
% AUXILIARES PARA USO NO LITERAL
% ---------------------------------------------------------

verbo_tomar(toma).
verbo_tomar(toman).

gn_contiene_nombre_canonico(GN, Palabra) :-
    nombre_canonico_en_term(GN, Palabra).

gp_contiene_nombre_canonico(GP, Palabra) :-
    nombre_canonico_en_term(GP, Palabra).

gp_con_prep(gp(prep(Prep), _), Prep).

gp_con_prep(gp_coord(GP1, _, _), Prep) :-
    gp_con_prep(GP1, Prep).

gp_con_prep(gp_coord(_, _, GP2), Prep) :-
    gp_con_prep(GP2, Prep).


% =========================================================
% CLASIFICACION FINAL
% =========================================================

clasificar_advertencias(Advertencias, problematica) :-
    member(advertencia(incoherencia_semantica, _, _), Advertencias),
    !.

clasificar_advertencias(Advertencias, problematica) :-
    member(advertencia(uso_no_literal, _, _), Advertencias),
    !.

clasificar_advertencias(Advertencias, ambigua) :-
    member(advertencia(ambiguedad_semantica, _, _), Advertencias),
    !.

clasificar_advertencias(_, correcta).


% =========================================================
% EXPLICACIONES EN LENGUAJE NATURAL
% =========================================================

explicaciones_desde_advertencias([], [
    'No se han detectado advertencias semanticas relevantes para esta oracion.'
]) :-
    !.

explicaciones_desde_advertencias(Advertencias, Explicaciones) :-
    findall(
        Texto,
        (
            member(Advertencia, Advertencias),
            explicar_advertencia(Advertencia, Texto)
        ),
        Explicaciones
    ).


explicar_advertencia(
    advertencia(
        ambiguedad_semantica,
        sinonimia(X, Y),
        sentidos(X, SX, Y, SY)
    ),
    Texto
) :-
    atomic_list_concat([
        '[ambiguedad semantica] Se detecta una relacion de sinonimia entre "',
        X,
        '" y "',
        Y,
        '". La interpretacion puede variar porque "',
        X,
        '" puede entenderse como: ',
        SX,
        '; y "',
        Y,
        '" puede entenderse como: ',
        SY,
        '.'
    ], Texto).


explicar_advertencia(
    advertencia(
        ambiguedad_semantica,
        palabra(Palabra),
        contexto(Motivo, Sentidos)
    ),
    Texto
) :-
    atomic_list_concat([
        '[ambiguedad semantica] La palabra "',
        Palabra,
        '" admite varias lecturas. En esta oracion, ',
        Motivo,
        '. Sentidos posibles: ',
        Sentidos,
        '.'
    ], Texto).


explicar_advertencia(
    advertencia(
        incoherencia_semantica,
        verbo_sujeto(Verbo, Sujeto),
        clases(SujetoClases, ClasesEsperadas)
    ),
    Texto
) :-
    termino_a_texto(SujetoClases, SujetoClasesTexto),
    termino_a_texto(ClasesEsperadas, ClasesEsperadasTexto),
    atomic_list_concat([
        '[incoherencia semantica] El verbo "',
        Verbo,
        '" no encaja claramente con el sujeto "',
        Sujeto,
        '". El sujeto pertenece a las clases ',
        SujetoClasesTexto,
        ', pero el verbo espera alguna de estas clases: ',
        ClasesEsperadasTexto,
        '.'
    ], Texto).


explicar_advertencia(
    advertencia(
        incoherencia_semantica,
        verbo_complemento(Verbo, TipoComplemento, Complemento),
        clases(ComplementoClases, ClasesEsperadas)
    ),
    Texto
) :-
    termino_a_texto(TipoComplemento, TipoComplementoTexto),
    termino_a_texto(ComplementoClases, ComplementoClasesTexto),
    termino_a_texto(ClasesEsperadas, ClasesEsperadasTexto),
    atomic_list_concat([
        '[incoherencia semantica] El complemento "',
        Complemento,
        '" no encaja claramente con el verbo "',
        Verbo,
        '" en la funcion ',
        TipoComplementoTexto,
        '. El complemento pertenece a las clases ',
        ComplementoClasesTexto,
        ', pero el verbo espera alguna de estas clases: ',
        ClasesEsperadasTexto,
        '.'
    ], Texto).


explicar_advertencia(
    advertencia(
        uso_no_literal,
        construccion(Construccion),
        contexto(Verbo, Sujeto, Motivo)
    ),
    Texto
) :-
    atomic_list_concat([
        '[uso no literal] Se detecta la construccion "',
        Construccion,
        '" con el verbo "',
        Verbo,
        '" aplicado al sujeto "',
        Sujeto,
        '". ',
        Motivo,
        '.'
    ], Texto).


% =========================================================
% EXTRACCION DE INFORMACION DEL ARBOL
% =========================================================

sujeto_principal(impersonal, impersonal) :-
    !.

sujeto_principal(gn(Base, _), Palabra) :-
    !,
    nucleo_base(Base, Palabra).

sujeto_principal(gn_coord(GN1, _, _), Palabra) :-
    sujeto_principal(GN1, Palabra).

sujeto_principal(gn_coord(_, _, GN2), Palabra) :-
    sujeto_principal(GN2, Palabra).


nucleo_base(Base, Palabra) :-
    findall(N, sub_term(n(N), Base), Nombres),
    Nombres \= [],
    last(Nombres, Ultimo),
    canon(Ultimo, Palabra).


contiene_nombre(Termino, Nombre) :-
    sub_term(n(N), Termino),
    canon(N, Nombre).


nombre_canonico_en_term(Termino, Palabra) :-
    sub_term(n(N), Termino),
    canon(N, Palabra).


base_contiene(Arbol, Elemento) :-
    sub_term(Base, Arbol),
    compound(Base),
    Base =.. [base|Args],
    member(Elemento, Args).


interseccion_no_vacia([X|_], Ys) :-
    member(X, Ys),
    !.

interseccion_no_vacia([_|Xs], Ys) :-
    interseccion_no_vacia(Xs, Ys).


termino_a_texto(Termino, Texto) :-
    term_to_atom(Termino, Texto).


% =========================================================
% COMPATIBILIDAD CON CLI_BRIDGE.PL
% =========================================================
%
% cli_bridge.pl expone una interfaz semantica basada en los
% predicados detectar_problemas_id/2 y detectar_problemas_tokens/2.
% La logica real del detector esta implementada mediante
% analizar_semantico_id_detallado/6 y
% analizar_semantico_tokens_detallado/6.
%
% Estos predicados actuan como adaptadores: no cambian el analisis,
% solo empaquetan el resultado en el termino diagnostico/4 que espera
% la capa de terminal.
% =========================================================

detectar_problemas_id(
    Id,
    diagnostico(Estado, Clasificacion, Advertencias, Arbol)
) :-
    analizar_semantico_id_detallado(
        Id,
        Estado,
        Clasificacion,
        Advertencias,
        _Explicaciones,
        Arbol
    ).


detectar_problemas_tokens(
    Tokens,
    diagnostico(Estado, Clasificacion, Advertencias, Arbol)
) :-
    analizar_semantico_tokens_detallado(
        Tokens,
        Estado,
        Clasificacion,
        Advertencias,
        _Explicaciones,
        Arbol
    ).