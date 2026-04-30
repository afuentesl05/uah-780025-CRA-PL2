:- consult(conjunto_oraciones).
:- consult(sintactico).
:- use_module(draw).

analizar_id(Id, Arbol) :-
    oracion(Id, Tokens),
    phrase(oracion(Arbol), Tokens).

probar_todas :-
    oracion(Id, Tokens),
    ( phrase(oracion(Arbol), Tokens) ->
        write('OK -> '), write(Id), write(' : '), write(Arbol), nl
    ;
        write('FALLO -> '), write(Id), write(' : '), write(Tokens), nl
    ),
    fail.
probar_todas.


analizar_tokens(Tokens, Arbol) :-
    phrase(oracion(Arbol), Tokens).