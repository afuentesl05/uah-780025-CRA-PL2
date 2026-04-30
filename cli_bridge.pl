:- consult(main).

% ---------------------------------------------------------
% Convierte draw(Arbol) a texto para que Python lo reciba
% ---------------------------------------------------------

arbol_ascii(Arbol, Texto) :-
    with_output_to(string(Texto), draw(Arbol)).

% ---------------------------------------------------------
% Analizar una oración del corpus por ID
% ---------------------------------------------------------

analizar_id_terminal(Id) :-
    ( oracion(Id, Tokens) ->
        ( analizar_tokens(Tokens, Arbol) ->
            arbol_ascii(Arbol, Ascii),
            write('ESTADO:OK'), nl,
            write('ID:'), write(Id), nl,
            write('TOKENS:'), write(Tokens), nl,
            write('ARBOL:'), write(Arbol), nl,
            write('ASCII_INICIO'), nl,
            write(Ascii),
            write('ASCII_FIN'), nl
        ;
            write('ESTADO:FALLO'), nl,
            write('ID:'), write(Id), nl,
            write('TOKENS:'), write(Tokens), nl
        )
    ;
        write('ESTADO:ID_NO_EXISTE'), nl,
        write('ID:'), write(Id), nl
    ).

% ---------------------------------------------------------
% Analizar una lista de tokens enviada desde Python
% ---------------------------------------------------------

analizar_tokens_terminal(Tokens) :-
    ( analizar_tokens(Tokens, Arbol) ->
        arbol_ascii(Arbol, Ascii),
        write('ESTADO:OK'), nl,
        write('TOKENS:'), write(Tokens), nl,
        write('ARBOL:'), write(Arbol), nl,
        write('ASCII_INICIO'), nl,
        write(Ascii),
        write('ASCII_FIN'), nl
    ;
        write('ESTADO:FALLO'), nl,
        write('TOKENS:'), write(Tokens), nl
    ).