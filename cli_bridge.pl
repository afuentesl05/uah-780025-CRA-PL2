% =========================================================
% BRIDGE PROLOG PARA INTERFAZ PYTHON
% Archivo: cli_bridge.pl
%
% Capa de comunicacion entre Python y Prolog.
%
% Predicados expuestos:
%
%   analizar_id_terminal/2
%   analizar_tokens_terminal/2
%   analizar_ambiguedad_id_terminal/1
%   analizar_ambiguedad_tokens_terminal/1
%   analizar_semantica_id_terminal/1
%   analizar_semantica_tokens_terminal/1
%
% =========================================================

:- use_module(library(lists)).

:- ensure_loaded('main.pl').

:- ( exists_file('ambiguedad.pl') ->
        ensure_loaded('ambiguedad.pl')
   ;
        true
   ).

:- ( exists_file('semantico.pl') ->
        ensure_loaded('semantico.pl')
   ;
        true
   ).

:- ( exists_file('deteccion.pl') ->
        ensure_loaded('deteccion.pl')
   ;
        true
   ).

:- ( exists_file('draw.pl') ->
        use_module('draw.pl')
   ;
        true
   ).

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
% CLASIFICACION ROBUSTA
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
% RASGOS ROBUSTOS
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
            current_predicate(draw/1)
        ->
            draw(Arbol)
        ;
            write('ERROR_DIBUJO: no existe dibujar_arbol/1 ni draw/1'),
            nl
        )
    ).


% =========================================================
% DESCOMPOSICION EXPLICITA PARA TERMINAL
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


oraciones_principales_sin_relativas(oc(O1, _, O2), Oraciones) :-
    !,
    oraciones_principales_sin_relativas(O1, L1),
    oraciones_principales_sin_relativas(O2, L2),
    append(L1, L2, Oraciones).

oraciones_principales_sin_relativas(O, [OLimpia]) :-
    (
        current_predicate(quitar_relativas_term/2)
    ->
        catch(quitar_relativas_term(O, OLimpia), _, OLimpia = O)
    ;
        OLimpia = O
    ).


relativas_unicas(Arbol, Relativas) :-
    (
        current_predicate(extraer_relativas/2)
    ->
        catch(extraer_relativas(Arbol, Relativas0), _, Relativas0 = [])
    ;
        Relativas0 = []
    ),
    list_to_set(Relativas0, Relativas).


imprimir_oraciones_numeradas(_, [], _) :-
    !.

imprimir_oraciones_numeradas(Etiqueta, [O|R], N) :-
    oracion_a_texto(O, Texto),
    format('~w_~w:', [Etiqueta, N]),
    format('~s~n', [Texto]),
    N2 is N + 1,
    imprimir_oraciones_numeradas(Etiqueta, R, N2).


% =========================================================
% CONVERSION APROXIMADA DE ARBOL A TEXTO
% =========================================================

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

termino_a_tokens(det(X), [X]) :- atomic(X), !.
termino_a_tokens(n(X), [X]) :- atomic(X), !.
termino_a_tokens(v(X), [X]) :- atomic(X), !.
termino_a_tokens(adj(X), [X]) :- atomic(X), !.
termino_a_tokens(adv(X), [X]) :- atomic(X), !.
termino_a_tokens(prep(X), [X]) :- atomic(X), !.
termino_a_tokens(num(X), [X]) :- atomic(X), !.
termino_a_tokens(cuant(X), [X]) :- atomic(X), !.
termino_a_tokens(rel(X), [X]) :- atomic(X), !.
termino_a_tokens(part(X), [X]) :- atomic(X), !.
termino_a_tokens(dp(X), [X]) :- atomic(X), !.
termino_a_tokens(c(X), [X]) :- atomic(X), !.

termino_a_tokens(conj(X), Tokens) :-
    !,
    termino_a_tokens(X, Tokens).

termino_a_tokens(etc, [etc]) :-
    !.

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


tokens_a_texto([], "") :-
    !.

tokens_a_texto([T|Ts], Texto) :-
    token_a_atom(T, A),
    tokens_a_atom_acum(Ts, A, AtomFinal),
    atom_string(AtomFinal, Texto).


tokens_a_atom_acum([], Acc, Acc).

tokens_a_atom_acum([T|Ts], Acc0, AtomFinal) :-
    token_a_atom(T, AtomT),
    (
        puntuacion_sin_espacio(AtomT)
    ->
        atomic_list_concat([Acc0, AtomT], '', Acc1)
    ;
        atomic_list_concat([Acc0, AtomT], ' ', Acc1)
    ),
    tokens_a_atom_acum(Ts, Acc1, AtomFinal).


token_a_atom(Token, Token) :-
    atom(Token),
    !.

token_a_atom(Token, Atom) :-
    atomic(Token),
    !,
    term_to_atom(Token, Atom).

token_a_atom(Token, Atom) :-
    term_to_atom(Token, Atom).


puntuacion_sin_espacio(',').
puntuacion_sin_espacio(':').
puntuacion_sin_espacio('.').
puntuacion_sin_espacio(';').


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
% AMBIGUEDAD SINTACTICA
% =========================================================

detectar_ambiguedad_seguro(Tokens, EstadoAmb, NumAnalisis, Arboles) :-
    current_predicate(detectar_ambiguedad/4),
    !,
    detectar_ambiguedad(Tokens, EstadoAmb, NumAnalisis, Arboles).

detectar_ambiguedad_seguro(Tokens, EstadoAmb, NumAnalisis, Arboles) :-
    findall(Arbol, phrase(oracion(Arbol), Tokens), Arboles0),
    list_to_set(Arboles0, Arboles),
    length(Arboles, NumAnalisis),
    estado_ambiguedad_por_numero(NumAnalisis, EstadoAmb).


estado_ambiguedad_por_numero(0, no_reconocida) :-
    !.

estado_ambiguedad_por_numero(1, no_ambigua) :-
    !.

estado_ambiguedad_por_numero(_, ambigua).


analizar_ambiguedad_id_terminal(Id) :-
    (
        oracion(Id, Tokens)
    ->
        detectar_ambiguedad_seguro(Tokens, EstadoAmb, NumAnalisis, Arboles),
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


analizar_ambiguedad_tokens_terminal(Tokens) :-
    detectar_ambiguedad_seguro(Tokens, EstadoAmb, NumAnalisis, Arboles),
    write('ESTADO:OK'), nl,
    write('TOKENS:'), write(Tokens), nl,
    write('AMBIGUEDAD:'), write(EstadoAmb), nl,
    write('NUM_ANALISIS:'), write(NumAnalisis), nl,
    write('ARBOLES:'), write(Arboles), nl,
    imprimir_arboles_ambiguedad_ascii(Arboles, 1).


imprimir_arboles_ambiguedad_ascii([], _).

imprimir_arboles_ambiguedad_ascii([Arbol|Resto], N) :-
    arbol_ascii_seguro(Arbol, Ascii),
    write('ARBOL_AMBIGUEDAD_INICIO:'), write(N), nl,
    write(Ascii),
    write('ARBOL_AMBIGUEDAD_FIN:'), write(N), nl,
    N2 is N + 1,
    imprimir_arboles_ambiguedad_ascii(Resto, N2).


% =========================================================
% ANALISIS SEMANTICO Y DETECCION
% =========================================================

analizar_semantica_id_terminal(Id) :-
    (
        current_predicate(detectar_problemas_id/2)
    ->
        (
            oracion(Id, Tokens)
        ->
            detectar_problemas_id(Id, Diagnostico),
            imprimir_diagnostico_bridge(Id, Tokens, Diagnostico)
        ;
            write('ESTADO:ID_NO_EXISTE'), nl,
            write('ID:'), write(Id), nl,
            write('SEM_ESTADO:id_no_existe'), nl,
            write('SEM_CLASIFICACION:no_reconocida'), nl,
            write('SEM_ADVERTENCIAS:[]'), nl,
            write('SEM_ARBOL:none'), nl
        )
    ;
        write('ESTADO:ERROR'), nl,
        write('SEM_ESTADO:modulo_deteccion_no_cargado'), nl,
        write('SEM_CLASIFICACION:no_reconocida'), nl,
        write('SEM_ADVERTENCIAS:[]'), nl,
        write('SEM_ARBOL:none'), nl
    ).


analizar_semantica_tokens_terminal(Tokens) :-
    (
        current_predicate(detectar_problemas_tokens/2)
    ->
        detectar_problemas_tokens(Tokens, Diagnostico),
        imprimir_diagnostico_bridge(sin_id, Tokens, Diagnostico)
    ;
        write('ESTADO:ERROR'), nl,
        write('TOKENS:'), write(Tokens), nl,
        write('SEM_ESTADO:modulo_deteccion_no_cargado'), nl,
        write('SEM_CLASIFICACION:no_reconocida'), nl,
        write('SEM_ADVERTENCIAS:[]'), nl,
        write('SEM_ARBOL:none'), nl
    ).


imprimir_diagnostico_bridge(Id, Tokens,
    diagnostico(EstadoSemantico, Clasificacion, Advertencias, Arbol)
) :-
    write('ESTADO:OK'), nl,
    imprimir_id_si_procede(Id),
    write('TOKENS:'), write(Tokens), nl,
    write('SEM_ESTADO:'), write(EstadoSemantico), nl,
    write('SEM_CLASIFICACION:'), write(Clasificacion), nl,
    write('SEM_ADVERTENCIAS:'), write(Advertencias), nl,
    write('SEM_ARBOL:'), write(Arbol), nl.






% =========================================================
% ANALISIS DE FUNCIONES SINTACTICAS
% =========================================================
%
% Expone funciones_oracion/2 a la interfaz Python.
%
% Permite analizar:
% - funciones sintacticas de una oracion del corpus por ID
% - funciones sintacticas de una frase manual tokenizada
%
% =========================================================

analizar_funciones_id_terminal(Id) :-
    (
        oracion(Id, Tokens)
    ->
        (
            phrase(oracion(Arbol), Tokens)
        ->
            funciones_oracion(Arbol, Funciones),
            write('ESTADO:OK'), nl,
            write('ID:'), write(Id), nl,
            write('TOKENS:'), write(Tokens), nl,
            write('ARBOL:'), write(Arbol), nl,
            imprimir_funciones_sintacticas(Funciones)
        ;
            write('ESTADO:FALLO'), nl,
            write('ID:'), write(Id), nl,
            write('TOKENS:'), write(Tokens), nl,
            write('FUNCIONES:[]'), nl
        )
    ;
        write('ESTADO:ID_NO_EXISTE'), nl,
        write('ID:'), write(Id), nl,
        write('FUNCIONES:[]'), nl
    ).


analizar_funciones_tokens_terminal(Tokens) :-
    (
        phrase(oracion(Arbol), Tokens)
    ->
        funciones_oracion(Arbol, Funciones),
        write('ESTADO:OK'), nl,
        write('TOKENS:'), write(Tokens), nl,
        write('ARBOL:'), write(Arbol), nl,
        imprimir_funciones_sintacticas(Funciones)
    ;
        write('ESTADO:FALLO'), nl,
        write('TOKENS:'), write(Tokens), nl,
        write('FUNCIONES:[]'), nl
    ).


imprimir_funciones_sintacticas(Funciones) :-
    write('FUNCIONES:'), write(Funciones), nl,
    write('FUNCIONES_INICIO'), nl,
    imprimir_funciones_sintacticas_numeradas(Funciones, 1),
    write('FUNCIONES_FIN'), nl.


imprimir_funciones_sintacticas_numeradas([], _).

imprimir_funciones_sintacticas_numeradas([funcion(Nombre, Contenido)|Resto], N) :-
    write('FUNCION_'), write(N), write(':'),
    write(Nombre), write(' -> '), write(Contenido), nl,
    N2 is N + 1,
    imprimir_funciones_sintacticas_numeradas(Resto, N2).