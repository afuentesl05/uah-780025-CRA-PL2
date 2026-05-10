% =========================================================
% BRIDGE PROLOG PARA INTERFAZ PYTHON
% Archivo: cli_bridge.pl
%
% Capa de comunicacion entre Python y Prolog.
%
% Python llama a:
%
%   analizar_id_terminal/2
%   analizar_tokens_terminal/2
%   analizar_ambiguedad_id_terminal/1
%   analizar_ambiguedad_tokens_terminal/1
%
% =========================================================

:- ensure_loaded('main.pl').
:- ensure_loaded('ambiguedad.pl').

:- ( exists_file('adaptador_draw.pl') ->
        ensure_loaded('adaptador_draw.pl')
   ;
        true
   ).

% =========================================================
% ANALISIS INTERNO
% =========================================================

analizar_tokens_bridge(Tokens, Arbol, Tipo, Rasgos) :-
    phrase(oracion(Arbol), Tokens),
    bridge_clasificar_arbol(Arbol, Tipo),
    bridge_rasgos_arbol(Arbol, Rasgos),
    !.

% =========================================================
% CLASIFICACION AUXILIAR PARA LA INTERFAZ
% =========================================================

bridge_clasificar_arbol(Arbol, Tipo) :-
    current_predicate(clasificar_arbol/2),
    catch(clasificar_arbol(Arbol, Tipo), _, fail),
    !.

bridge_clasificar_arbol(Arbol, coordinada) :-
    sub_term(oc(_, _, _), Arbol),
    !.

bridge_clasificar_arbol(Arbol, subordinada_relativo) :-
    sub_term(or(_, _), Arbol),
    !.

bridge_clasificar_arbol(Arbol, compuesta_infinitivo) :-
    sub_term(ocm(_), Arbol),
    !.

bridge_clasificar_arbol(o(_, _), simple) :-
    !.

bridge_clasificar_arbol(_, desconocida).

% =========================================================
% EXTRACCION DE RASGOS PARA LA SALIDA DE TERMINAL
% =========================================================

bridge_rasgos_arbol(Arbol, Rasgos) :-
    rasgos_candidatos(Candidatos),
    bridge_filtrar_rasgos(Candidatos, Arbol, Rasgos).

rasgos_candidatos([
    coordinada,
    subordinada_relativo,
    compuesta_infinitivo,
    existencial
]).

bridge_filtrar_rasgos([], _, []).

bridge_filtrar_rasgos([R|Rs], Arbol, [R|Filtrados]) :-
    bridge_rasgo_presente(R, Arbol),
    !,
    bridge_filtrar_rasgos(Rs, Arbol, Filtrados).

bridge_filtrar_rasgos([_|Rs], Arbol, Filtrados) :-
    bridge_filtrar_rasgos(Rs, Arbol, Filtrados).

bridge_rasgo_presente(coordinada, Arbol) :-
    sub_term(oc(_, _, _), Arbol).

bridge_rasgo_presente(subordinada_relativo, Arbol) :-
    sub_term(or(_, _), Arbol).

bridge_rasgo_presente(compuesta_infinitivo, Arbol) :-
    sub_term(ocm(_), Arbol).

bridge_rasgo_presente(existencial, Arbol) :-
    sub_term(o(suj(impersonal), pred(gv(_, v(hay), _))), Arbol).

% =========================================================
% ARBOL ASCII SEGURO
% =========================================================

arbol_ascii_seguro(Arbol, Texto) :-
    catch(
        arbol_ascii(Arbol, Texto),
        Error,
        with_output_to(
            string(Texto),
            (
                write('ERROR_DIBUJO: '),
                write(Error),
                nl
            )
        )
    ).

arbol_ascii(Arbol, Texto) :-
    with_output_to(
        string(Texto),
        (
            current_predicate(dibujar_arbol/1)
        ->
            dibujar_arbol(Arbol)
        ;
            (
                current_predicate(draw/1)
            ->
                draw(Arbol)
            ;
                write('ERROR_DIBUJO: no se encontro dibujar_arbol/1 ni draw/1'),
                nl
            )
        )
    ).

% =========================================================
% DESCOMPOSICION EXPLICITA PARA TERMINAL
% =========================================================
%
% Muestra de forma legible:
% - si hay coordinacion
% - las frases principales resultantes
% - las subordinadas de relativo detectadas
%
% No modifica el arbol real. Solo genera una salida textual
% para que Python la muestre en terminal.
% =========================================================

imprimir_descomposicion(Arbol) :-
    write('DESCOMP_INICIO'), nl,

    imprimir_estado_coordinacion(Arbol),

    oraciones_principales_sin_relativas(Arbol, Principales),
    write('ORACIONES_PRINCIPALES_INICIO'), nl,
    imprimir_oraciones_numeradas('FRASE', Principales, 1),
    write('ORACIONES_PRINCIPALES_FIN'), nl,

    relativas_unicas(Arbol, Relativas),
    write('SUBORDINADAS_RELATIVAS_INICIO'), nl,
    imprimir_oraciones_numeradas('RELATIVA', Relativas, 1),
    write('SUBORDINADAS_RELATIVAS_FIN'), nl,

    write('DESCOMP_FIN'), nl.

% ---------------------------------------------------------
% Deteccion de coordinacion oracional
% ---------------------------------------------------------

imprimir_estado_coordinacion(Arbol) :-
    (
        contiene_coordinacion_oracional(Arbol)
    ->
        write('COORDINACION:si'), nl
    ;
        write('COORDINACION:no'), nl
    ).

contiene_coordinacion_oracional(Arbol) :-
    sub_term(oc(_, _, _), Arbol),
    !.

% ---------------------------------------------------------
% Obtencion de oraciones principales
% ---------------------------------------------------------
%
% Si el arbol es coordinado:
%
%   oc(O1, Conj, O2)
%
% se descompone en O1 y O2.
%
% Si alguna de esas oraciones tiene relativas, se eliminan
% de la principal para mostrarlas aparte.
% ---------------------------------------------------------

oraciones_principales_sin_relativas(oc(O1, _, O2), Oraciones) :-
    !,
    oraciones_principales_sin_relativas(O1, L1),
    oraciones_principales_sin_relativas(O2, L2),
    append(L1, L2, Oraciones).

oraciones_principales_sin_relativas(O, [OLimpia]) :-
    quitar_relativas_term(O, OLimpia).

% ---------------------------------------------------------
% Obtencion de subordinadas relativas sin duplicados
% ---------------------------------------------------------

relativas_unicas(Arbol, Relativas) :-
    extraer_relativas(Arbol, Relativas0),
    list_to_set(Relativas0, Relativas).

% ---------------------------------------------------------
% Impresion numerada
% ---------------------------------------------------------

imprimir_oraciones_numeradas(_, [], _) :-
    !.

imprimir_oraciones_numeradas(Etiqueta, [O|R], N) :-
    oracion_a_texto(O, Texto),
    format('~w_~w:', [Etiqueta, N]),
    write(Texto),
    nl,
    N2 is N + 1,
    imprimir_oraciones_numeradas(Etiqueta, R, N2).

% ---------------------------------------------------------
% Conversion aproximada de arbol a texto
% ---------------------------------------------------------
%
% Recorre el arbol y extrae solo las hojas lexicas:
%
%   det(la)       -> la
%   n(figura)     -> figura
%   v(representa) -> representa
%   prep(de)      -> de
%
% Ignora etiquetas estructurales como:
%
%   o, suj, pred, gn, gv, gp, base...
% ---------------------------------------------------------

oracion_a_texto(Arbol, Texto) :-
    termino_a_tokens(Arbol, Tokens),
    tokens_a_texto(Tokens, Texto).

termino_a_tokens(Var, []) :-
    var(Var),
    !.

termino_a_tokens(impersonal, []) :-
    !.

termino_a_tokens([], []) :-
    !.

termino_a_tokens([X|Xs], Tokens) :-
    !,
    termino_a_tokens(X, T1),
    termino_a_tokens(Xs, T2),
    append(T1, T2, Tokens).

termino_a_tokens(det(X), [X]) :- !.
termino_a_tokens(n(X), [X]) :- !.
termino_a_tokens(v(X), [X]) :- !.
termino_a_tokens(adj(X), [X]) :- !.
termino_a_tokens(adv(X), [X]) :- !.
termino_a_tokens(prep(X), [X]) :- !.
termino_a_tokens(num(X), [X]) :- !.
termino_a_tokens(cuant(X), [X]) :- !.
termino_a_tokens(rel(X), [X]) :- !.
termino_a_tokens(conj(X), [X]) :- !.
termino_a_tokens(part(X), [X]) :- !.
termino_a_tokens(dp(X), [X]) :- !.
termino_a_tokens(c(X), [X]) :- !.
termino_a_tokens(etc, [etc]) :- !.

termino_a_tokens(Termino, Tokens) :-
    compound(Termino),
    !,
    Termino =.. [_Functor|Args],
    terminos_a_tokens(Args, Tokens).

termino_a_tokens(_, []).

terminos_a_tokens([], []).

terminos_a_tokens([A|As], Tokens) :-
    termino_a_tokens(A, T1),
    terminos_a_tokens(As, T2),
    append(T1, T2, Tokens).

% ---------------------------------------------------------
% Conversion de lista de tokens a texto
% ---------------------------------------------------------
%
% Une los tokens en una cadena, respetando los signos de
% puntuacion que no requieren espacio previo.
% ---------------------------------------------------------

tokens_a_texto([], "") :-
    !.

tokens_a_texto([T|Ts], Texto) :-
    token_a_atom(T, A0),
    tokens_a_texto_acc(Ts, A0, Atom),
    atom_string(Atom, Texto).

tokens_a_texto_acc([], Acc, Acc).

tokens_a_texto_acc([T|Ts], Acc, TextoAtom) :-
    token_a_atom(T, A),
    (
        signo_sin_espacio_antes(A)
    ->
        atomic_list_concat([Acc, A], Acc2)
    ;
        atomic_list_concat([Acc, A], ' ', Acc2)
    ),
    tokens_a_texto_acc(Ts, Acc2, TextoAtom).

token_a_atom(Token, Token) :-
    atom(Token),
    !.

token_a_atom(Token, Atom) :-
    term_to_atom(Token, Atom).

signo_sin_espacio_antes(',').
signo_sin_espacio_antes(':').
signo_sin_espacio_antes(';').

% =========================================================
% IMPRESION COMUN DE RESULTADO OK
% =========================================================

imprimir_ok(Id, Tokens, Tipo, Rasgos, Arbol, MostrarArbol) :-
    write('ESTADO:OK'), nl,

    imprimir_id_si_procede(Id),

    write('TOKENS:'), write(Tokens), nl,
    write('TIPO:'), write(Tipo), nl,
    write('RASGOS:'), write(Rasgos), nl,
    write('ARBOL:'), write(Arbol), nl,

    imprimir_descomposicion(Arbol),

    imprimir_ascii_si_procede(MostrarArbol, Arbol).

imprimir_id_si_procede(sin_id) :-
    !.

imprimir_id_si_procede(Id) :-
    write('ID:'), write(Id), nl.

imprimir_ascii_si_procede(si, Arbol) :-
    !,
    arbol_ascii_seguro(Arbol, Ascii),
    write('ASCII_INICIO'), nl,
    write(Ascii),
    write('ASCII_FIN'), nl.

imprimir_ascii_si_procede(no, _) :-
    !.

imprimir_ascii_si_procede(_, _) :-
    !.

% =========================================================
% ANALIZAR UNA ORACION DEL CORPUS POR ID
% =========================================================

analizar_id_terminal(Id, MostrarArbol) :-
    (
        oracion(Id, Tokens)
    ->
        (
            analizar_tokens_bridge(Tokens, Arbol, Tipo, Rasgos)
        ->
            imprimir_ok(Id, Tokens, Tipo, Rasgos, Arbol, MostrarArbol)
        ;
            write('ESTADO:FALLO'), nl,
            write('ID:'), write(Id), nl,
            write('TOKENS:'), write(Tokens), nl,
            write('TIPO:no_reconocida'), nl,
            write('RASGOS:[]'), nl
        )
    ;
        write('ESTADO:ID_NO_EXISTE'), nl,
        write('ID:'), write(Id), nl,
        write('TIPO:no_reconocida'), nl,
        write('RASGOS:[]'), nl
    ).

analizar_id_terminal(Id) :-
    analizar_id_terminal(Id, si).

% =========================================================
% ANALIZAR TOKENS ENVIADOS DESDE PYTHON
% =========================================================

analizar_tokens_terminal(Tokens, MostrarArbol) :-
    (
        analizar_tokens_bridge(Tokens, Arbol, Tipo, Rasgos)
    ->
        imprimir_ok(sin_id, Tokens, Tipo, Rasgos, Arbol, MostrarArbol)
    ;
        write('ESTADO:FALLO'), nl,
        write('TOKENS:'), write(Tokens), nl,
        write('TIPO:no_reconocida'), nl,
        write('RASGOS:[]'), nl
    ).

analizar_tokens_terminal(Tokens) :-
    analizar_tokens_terminal(Tokens, si).

% =========================================================
% DETECCION DE AMBIGUEDAD
% =========================================================
%
% La deteccion de ambiguedad esta implementada en
% ambiguedad.pl. Este bridge solo delega en ese archivo.
% =========================================================

detectar_ambiguedad_bridge(Tokens, EstadoAmb, NumAnalisis, Arboles) :-
    detectar_ambiguedad(Tokens, EstadoAmb, NumAnalisis, Arboles).

% =========================================================
% AMBIGUEDAD POR ID
% =========================================================

analizar_ambiguedad_id_terminal(Id) :-
    (
        oracion(Id, Tokens)
    ->
        detectar_ambiguedad_bridge(Tokens, EstadoAmb, NumAnalisis, Arboles),
        write('ESTADO:OK'), nl,
        write('ID:'), write(Id), nl,
        write('TOKENS:'), write(Tokens), nl,
        write('AMBIGUEDAD:'), write(EstadoAmb), nl,
        write('NUM_ANALISIS:'), write(NumAnalisis), nl,
        write('ARBOLES:'), write(Arboles), nl,
        imprimir_arboles_ambiguedad_ascii(Arboles, 1)
    ;
        write('ESTADO:ID_NO_EXISTE'), nl,
        write('ID:'), write(Id), nl,
        write('AMBIGUEDAD:no_reconocida'), nl,
        write('NUM_ANALISIS:0'), nl,
        write('ARBOLES:[]'), nl
    ).

% =========================================================
% AMBIGUEDAD PARA TOKENS MANUALES
% =========================================================

analizar_ambiguedad_tokens_terminal(Tokens) :-
    detectar_ambiguedad_bridge(Tokens, EstadoAmb, NumAnalisis, Arboles),
    write('ESTADO:OK'), nl,
    write('TOKENS:'), write(Tokens), nl,
    write('AMBIGUEDAD:'), write(EstadoAmb), nl,
    write('NUM_ANALISIS:'), write(NumAnalisis), nl,
    write('ARBOLES:'), write(Arboles), nl,
    imprimir_arboles_ambiguedad_ascii(Arboles, 1).

% =========================================================
% IMPRESION DE ARBOLES ASCII PARA AMBIGUEDAD
% =========================================================

imprimir_arboles_ambiguedad_ascii([], _).

imprimir_arboles_ambiguedad_ascii([Arbol|Resto], N) :-
    arbol_ascii_seguro(Arbol, Ascii),
    write('ARBOL_AMBIGUEDAD_INICIO:'), write(N), nl,
    write(Ascii),
    write('ARBOL_AMBIGUEDAD_FIN:'), write(N), nl,
    N2 is N + 1,
    imprimir_arboles_ambiguedad_ascii(Resto, N2).