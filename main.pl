:- consult(conjunto_oraciones).
:- consult(sintactico).
:- use_module(draw).

analizar_id(Id, Arbol) :-
    oracion_corpus(Id, Tokens),
    phrase(oracion(Arbol), Tokens).

probar_todas :-
    oracion_corpus(Id, Tokens),
    ( phrase(oracion(Arbol), Tokens) ->
        write('OK -> '), write(Id), write(' : '), write(Arbol), nl
    ;
        write('FALLO -> '), write(Id), write(' : '), write(Tokens), nl
    ),
    fail.
probar_todas.