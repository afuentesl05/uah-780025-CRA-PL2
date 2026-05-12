% =========================================================
% SEMANTICO.PL
%
% Conocimiento semantico basico del dominio musical.
%
% No resuelve completamente el significado.
% Proporciona:
% - sentidos posibles de palabras relevantes
% - clases semanticas simples
% - compatibilidades sujeto-verbo
% - restricciones basicas para deteccion semantica
% - normalizacion singular/plural para el detector
% - rasgos flexivos controlados del corpus
%
% Idea principal:
%
%   La gramatica sintactica decide si una oracion esta bien
%   formada estructuralmente.
%
%   Este archivo aporta conocimiento de dominio para que
%   deteccion.pl pueda emitir advertencias sobre:
%   - ambiguedad
%   - incoherencia
%   - uso no literal
%
%   Ademas, documenta y representa la flexion de palabras
%   del corpus: genero, numero, formas verbales y lema.
%
% Importante:
%
%   No se implementa una morfologia completa del espanol.
%   Se implementa una normalizacion controlada de las formas
%   que aparecen en el corpus y de variantes utiles para las
%   pruebas manuales.
% =========================================================


% =========================================================
% SENTIDOS RELEVANTES
% =========================================================
%
% sentido(+PalabraCanonica, +Sentido, +Descripcion).
%
% Una palabra puede tener mas de un sentido dentro o fuera del
% dominio musical. Si tiene varios sentidos, puede ser marcada
% como ambigua cuando aparece en un contexto que active esa duda.
% =========================================================

sentido(llave, llave_musical,
    'signo musical que fija el nombre de las notas en el pentagrama').

sentido(llave, objeto_cotidiano,
    'objeto usado para abrir una cerradura').

sentido(conjunto, sustantivo_general,
    'agrupacion o coleccion de elementos').

sentido(conjunto, adjetivo_musical,
    'intervalo formado por notas inmediatas o proximas').

sentido(linea, trazo_grafico,
    'trazo o marca visual').

sentido(linea, linea_del_pentagrama,
    'linea del pentagrama sobre la que se escriben signos musicales').

sentido(voz, sonido_humano,
    'sonido producido por una persona al hablar o cantar').

sentido(voz, termino_lexico,
    'palabra o entrada terminologica, como en la expresion la voz tonalidad').

sentido(base, fundamento_general,
    'fundamento o apoyo conceptual de algo').

sentido(base, referencia_musical,
    'nota, escala o elemento que sirve como referencia para una construccion musical').

sentido(aire, sustancia_fisica,
    'mezcla gaseosa de la atmosfera').

sentido(aire, aire_musical,
    'caracter, movimiento o manera de interpretar una pieza musical').

sentido(compas, unidad_metrica,
    'division regular del tiempo musical').

sentido(compas, instrumento_dibujo,
    'instrumento usado para trazar circunferencias').

sentido(tiempo, duracion_musical,
    'unidad o parte de medida dentro del compas').

sentido(tiempo, magnitud_general,
    'magnitud general que ordena la sucesion de acontecimientos').

sentido(sol, nota_musical,
    'nombre de una nota musical').

sentido(sol, astro,
    'estrella del sistema solar').

sentido(fa, nota_musical,
    'nombre de una nota musical').

sentido(do, nota_musical,
    'nombre de una nota musical').

sentido(redonda, figura_musical,
    'figura musical de duracion determinada').

sentido(redonda, forma_geometrica,
    'forma circular o redondeada').


% =========================================================
% CONSULTA DE SENTIDOS
% =========================================================

sentidos(Palabra, Sentidos) :-
    canon(Palabra, Canonica),
    findall(
        Sentido-Descripcion,
        sentido(Canonica, Sentido, Descripcion),
        Sentidos
    ).

palabra_ambigua(Palabra) :-
    sentidos(Palabra, Sentidos),
    length(Sentidos, N),
    N > 1.

sentidos_resumen(Palabra, Texto) :-
    sentidos(Palabra, Sentidos),
    sentidos_a_descripciones(Sentidos, Descripciones),
    (
        Descripciones = []
    ->
        Texto = 'sin sentidos registrados'
    ;
        atomic_list_concat(Descripciones, ' / ', Texto)
    ).

sentidos_a_descripciones([], []).

sentidos_a_descripciones([_-Descripcion|R], [Descripcion|RD]) :-
    sentidos_a_descripciones(R, RD).


% =========================================================
% FLEXION CONTROLADA DEL CORPUS
% =========================================================
%
% Esta seccion documenta y representa la flexion de las palabras
% usadas por el corpus.
%
% El objetivo no es implementar un analizador morfologico general,
% sino poder justificar la mejora "Flexion de palabras" del enunciado:
%
%   - manejo de plurales
%   - manejo de genero
%   - manejo de tiempos/formas verbales
%
% Para ello se definen rasgos flexivos consultables por Prolog.
% =========================================================


% ---------------------------------------------------------
% NOMBRES
% ---------------------------------------------------------
%
% rasgos_nombre(+Forma, +Genero, +Numero, +Canonica).
%
% Genero:
%   masculino | femenino | comun
%
% Numero:
%   singular | plural | invariable
% ---------------------------------------------------------

rasgos_nombre(melodia, femenino, singular, melodia).
rasgos_nombre(armonia, femenino, singular, armonia).
rasgos_nombre(sucesion, femenino, singular, sucesion).

rasgos_nombre(sonido, masculino, singular, sonido).
rasgos_nombre(sonidos, masculino, plural, sonido).

rasgos_nombre(conjunto, masculino, singular, conjunto).

rasgos_nombre(nota, femenino, singular, nota).
rasgos_nombre(notas, femenino, plural, nota).

rasgos_nombre(accidente, masculino, singular, accidente).
rasgos_nombre(accidentes, masculino, plural, accidente).

rasgos_nombre(pentagrama, masculino, singular, pentagrama).

rasgos_nombre(linea, femenino, singular, linea).
rasgos_nombre(lineas, femenino, plural, linea).

rasgos_nombre(espacio, masculino, singular, espacio).
rasgos_nombre(espacios, masculino, plural, espacio).

rasgos_nombre(intervalo, masculino, singular, intervalo).
rasgos_nombre(intervalos, masculino, plural, intervalo).

rasgos_nombre(distancia, femenino, singular, distancia).

rasgos_nombre(puntillo, masculino, singular, puntillo).

rasgos_nombre(mitad, femenino, singular, mitad).

rasgos_nombre(valor, masculino, singular, valor).
rasgos_nombre(valores, masculino, plural, valor).

rasgos_nombre(figura, femenino, singular, figura).
rasgos_nombre(figuras, femenino, plural, figura).

rasgos_nombre(instrumento, masculino, singular, instrumento).
rasgos_nombre(instrumentos, masculino, plural, instrumento).

rasgos_nombre(clase, femenino, singular, clase).
rasgos_nombre(clases, femenino, plural, clase).

rasgos_nombre(compas, masculino, singular, compas).
rasgos_nombre(compases, masculino, plural, compas).

rasgos_nombre(porcion, femenino, singular, porcion).

rasgos_nombre(tiempo, masculino, singular, tiempo).
rasgos_nombre(tiempos, masculino, plural, tiempo).

rasgos_nombre(parte, femenino, singular, parte).
rasgos_nombre(partes, femenino, plural, parte).

rasgos_nombre(arte, masculino, singular, arte).

rasgos_nombre(regla, femenino, singular, regla).
rasgos_nombre(reglas, femenino, plural, regla).

rasgos_nombre(cosa, femenino, singular, cosa).

rasgos_nombre(sinonimo, masculino, singular, sinonimo).

rasgos_nombre(medida, femenino, singular, medida).

rasgos_nombre(aire, masculino, singular, aire).

rasgos_nombre(llave, femenino, singular, llave).
rasgos_nombre(llaves, femenino, plural, llave).

rasgos_nombre(sol, masculino, singular, sol).
rasgos_nombre(fa, masculino, singular, fa).
rasgos_nombre(do, masculino, singular, do).

rasgos_nombre(voz, femenino, singular, voz).

rasgos_nombre(tonalidad, femenino, singular, tonalidad).

rasgos_nombre(acepcion, femenino, singular, acepcion).
rasgos_nombre(acepciones, femenino, plural, acepcion).

rasgos_nombre(tono, masculino, singular, tono).

rasgos_nombre(sostenido, masculino, singular, sostenido).
rasgos_nombre(sostenidos, masculino, plural, sostenido).

rasgos_nombre(bemol, masculino, singular, bemol).
rasgos_nombre(bemoles, masculino, plural, bemol).

rasgos_nombre(semitono, masculino, singular, semitono).

rasgos_nombre(silencio, masculino, singular, silencio).

rasgos_nombre(signo, masculino, singular, signo).
rasgos_nombre(signos, masculino, plural, signo).

rasgos_nombre(nombre, masculino, singular, nombre).
rasgos_nombre(nombres, masculino, plural, nombre).

rasgos_nombre(unisono, masculino, singular, unisono).

rasgos_nombre(redonda, femenino, singular, redonda).

rasgos_nombre(ligadura, femenino, singular, ligadura).

rasgos_nombre(posicion, femenino, singular, posicion).

rasgos_nombre(cifra, femenino, singular, cifra).
rasgos_nombre(cifras, femenino, plural, cifra).

rasgos_nombre(paso, masculino, singular, paso).
rasgos_nombre(pasos, masculino, plural, paso).

rasgos_nombre(fagote, masculino, singular, fagote).
rasgos_nombre(violoncello, masculino, singular, violoncello).

rasgos_nombre(escala, femenino, singular, escala).
rasgos_nombre(escalas, femenino, plural, escala).

rasgos_nombre(base, femenino, singular, base).

rasgos_nombre(sincopa, femenino, singular, sincopa).
rasgos_nombre(sincopas, femenino, plural, sincopa).

rasgos_nombre(modo, masculino, singular, modo).
rasgos_nombre(modos, masculino, plural, modo).

rasgos_nombre(dia, masculino, singular, dia).


% ---------------------------------------------------------
% ADJETIVOS
% ---------------------------------------------------------
%
% rasgos_adjetivo(+Forma, +Genero, +Numero, +Canonica).
%
% Genero:
%   masculino | femenino | comun
%
% En muchos adjetivos terminados en -e o -al se usa comun.
% ---------------------------------------------------------

rasgos_adjetivo(acertada, femenino, singular, acertado).

rasgos_adjetivo(musical, comun, singular, musical).
rasgos_adjetivo(musicales, comun, plural, musical).

rasgos_adjetivo(anterior, comun, singular, anterior).

rasgos_adjetivo(doble, comun, singular, doble).
rasgos_adjetivo(dobles, comun, plural, doble).

rasgos_adjetivo(pequena, femenino, singular, pequeno).
rasgos_adjetivo(pequeno, masculino, singular, pequeno).

rasgos_adjetivo(iguales, comun, plural, igual).

rasgos_adjetivo(pares, comun, plural, par).
rasgos_adjetivo(impares, comun, plural, impar).

rasgos_adjetivo(segunda, femenino, singular, segundo).
rasgos_adjetivo(tercera, femenino, singular, tercero).
rasgos_adjetivo(cuarta, femenino, singular, cuarto).
rasgos_adjetivo(primera, femenino, singular, primero).

rasgos_adjetivo(fuertes, comun, plural, fuerte).
rasgos_adjetivo(debiles, comun, plural, debil).

rasgos_adjetivo(conjunto, masculino, singular, conjunto).

rasgos_adjetivo(inmediatas, femenino, plural, inmediato).

rasgos_adjetivo(menor, comun, singular, menor).

rasgos_adjetivo(irregulares, comun, plural, irregular).

rasgos_adjetivo(diferentes, comun, plural, diferente).

rasgos_adjetivo(numericos, masculino, plural, numerico).

rasgos_adjetivo(curva, femenino, singular, curvo).

rasgos_adjetivo(mismo, masculino, singular, mismo).

rasgos_adjetivo(agudos, masculino, plural, agudo).

rasgos_adjetivo(largas, femenino, plural, largo).
rasgos_adjetivo(breves, comun, plural, breve).

rasgos_adjetivo(usuales, comun, plural, usual).


% ---------------------------------------------------------
% DETERMINANTES Y CUANTIFICADORES
% ---------------------------------------------------------
%
% rasgos_determinante(+Forma, +Genero, +Numero, +Canonica).
% rasgos_cuantificador(+Forma, +Genero, +Numero, +Canonica).
% rasgos_numeral(+Forma, +Numero, +Canonica).
% ---------------------------------------------------------

rasgos_determinante(el, masculino, singular, el).
rasgos_determinante(la, femenino, singular, el).
rasgos_determinante(los, masculino, plural, el).
rasgos_determinante(las, femenino, plural, el).

rasgos_determinante(un, masculino, singular, un).
rasgos_determinante(una, femenino, singular, un).

rasgos_determinante(alguna, femenino, singular, alguno).
rasgos_determinante(estos, masculino, plural, este).
rasgos_determinante(su, comun, invariable, su).

rasgos_cuantificador(varios, masculino, plural, varios).
rasgos_cuantificador(diversas, femenino, plural, diverso).
rasgos_cuantificador(todas, femenino, plural, todo).

rasgos_numeral(dos, plural, dos).
rasgos_numeral(tres, plural, tres).
rasgos_numeral(cuatro, plural, cuatro).
rasgos_numeral(cinco, plural, cinco).
rasgos_numeral(siete, plural, siete).


% ---------------------------------------------------------
% VERBOS
% ---------------------------------------------------------
%
% rasgos_verbo(+Forma, +Lema, +Tiempo, +Persona, +Numero).
%
% Tiempo:
%   presente | infinitivo | gerundio_pronominal
%
% Persona:
%   primera | segunda | tercera | no_personal
%
% Numero:
%   singular | plural | no_aplica
% ---------------------------------------------------------

rasgos_verbo(es, ser, presente, tercera, singular).
rasgos_verbo(son, ser, presente, tercera, plural).

rasgos_verbo(tiene, tener, presente, tercera, singular).
rasgos_verbo(tienen, tener, presente, tercera, plural).

rasgos_verbo(aumenta, aumentar, presente, tercera, singular).

rasgos_verbo(dividen, dividir, presente, tercera, plural).

rasgos_verbo(hacer, hacer, infinitivo, no_personal, no_aplica).

rasgos_verbo(hay, haber, presente, tercera, singular).

rasgos_verbo(toma, tomar, presente, tercera, singular).
rasgos_verbo(toman, tomar, presente, tercera, plural).

rasgos_verbo(corresponden, corresponder, presente, tercera, plural).

rasgos_verbo(vale, valer, presente, tercera, singular).
rasgos_verbo(valen, valer, presente, tercera, plural).

rasgos_verbo(representa, representar, presente, tercera, singular).

rasgos_verbo(sirve, servir, presente, tercera, singular).

rasgos_verbo(medir, medir, infinitivo, no_personal, no_aplica).

rasgos_verbo(compone, componer, presente, tercera, singular).

rasgos_verbo(resultan, resultar, presente, tercera, plural).

rasgos_verbo(coloca, colocar, presente, tercera, singular).

rasgos_verbo(une, unir, presente, tercera, singular).

rasgos_verbo(fijar, fijar, infinitivo, no_personal, no_aplica).

rasgos_verbo(usa, usar, presente, tercera, singular).

rasgos_verbo(escribiendose, escribir, gerundio_pronominal, no_personal, no_aplica).


% ---------------------------------------------------------
% CONSULTA GENERAL DE FLEXION
% ---------------------------------------------------------
%
% rasgos_flexion(+Palabra, -Categoria, -Rasgos).
%
% Ejemplos:
%
%   ?- rasgos_flexion(llaves, Categoria, Rasgos).
%
%   Categoria = nombre,
%   Rasgos = rasgos(llave, femenino, plural).
%
%   ?- rasgos_flexion(valen, Categoria, Rasgos).
%
%   Categoria = verbo,
%   Rasgos = rasgos(valer, presente, tercera, plural).
% ---------------------------------------------------------

rasgos_flexion(
    Palabra,
    nombre,
    rasgos(Canonica, Genero, Numero)
) :-
    rasgos_nombre(Palabra, Genero, Numero, Canonica).

rasgos_flexion(
    Palabra,
    adjetivo,
    rasgos(Canonica, Genero, Numero)
) :-
    rasgos_adjetivo(Palabra, Genero, Numero, Canonica).

rasgos_flexion(
    Palabra,
    determinante,
    rasgos(Canonica, Genero, Numero)
) :-
    rasgos_determinante(Palabra, Genero, Numero, Canonica).

rasgos_flexion(
    Palabra,
    cuantificador,
    rasgos(Canonica, Genero, Numero)
) :-
    rasgos_cuantificador(Palabra, Genero, Numero, Canonica).

rasgos_flexion(
    Palabra,
    numeral,
    rasgos(Canonica, numero(Numero))
) :-
    rasgos_numeral(Palabra, Numero, Canonica).

rasgos_flexion(
    Palabra,
    verbo,
    rasgos(Lema, Tiempo, Persona, Numero)
) :-
    rasgos_verbo(Palabra, Lema, Tiempo, Persona, Numero).


% ---------------------------------------------------------
% analizar_flexion(+Palabra, -Analisis)
% ---------------------------------------------------------
%
% Devuelve todos los analisis flexivos conocidos de una palabra.
%
% Es util para palabras ambiguas de categoria, por ejemplo:
%
%   conjunto
%
% puede aparecer como nombre o como adjetivo.
% ---------------------------------------------------------

analizar_flexion(Palabra, Analisis) :-
    findall(
        Categoria-Rasgos,
        rasgos_flexion(Palabra, Categoria, Rasgos),
        Analisis
    ).


% ---------------------------------------------------------
% forma_canonica(+Palabra, -Canonica)
% ---------------------------------------------------------
%
% Variante semantica de consulta. A diferencia de canon/2,
% esta pensada para explicar la flexion.
% ---------------------------------------------------------

forma_canonica(Palabra, Canonica) :-
    rasgos_nombre(Palabra, _, _, Canonica),
    !.

forma_canonica(Palabra, Canonica) :-
    rasgos_adjetivo(Palabra, _, _, Canonica),
    !.

forma_canonica(Palabra, Canonica) :-
    rasgos_verbo(Palabra, Canonica, _, _, _),
    !.

forma_canonica(Palabra, Canonica) :-
    rasgos_determinante(Palabra, _, _, Canonica),
    !.

forma_canonica(Palabra, Canonica) :-
    rasgos_cuantificador(Palabra, _, _, Canonica),
    !.

forma_canonica(Palabra, Canonica) :-
    rasgos_numeral(Palabra, _, Canonica),
    !.

forma_canonica(Palabra, Palabra).


% ---------------------------------------------------------
% Compatibilidad de numero basica
% ---------------------------------------------------------
%
% Estos predicados no sustituyen a la gramatica.
% Sirven para documentar y consultar concordancia simple.
% ---------------------------------------------------------

numero_nominal(Palabra, Numero) :-
    rasgos_nombre(Palabra, _, Numero, _).

numero_verbal(Palabra, Numero) :-
    rasgos_verbo(Palabra, _, presente, tercera, Numero).

compatible_numero_sujeto_verbo(Sujeto, Verbo) :-
    numero_nominal(Sujeto, Numero),
    numero_verbal(Verbo, Numero).


% =========================================================
% NORMALIZACION LEXICA
% =========================================================
%
% canon(+Forma, -Canonica).
%
% Convierte formas flexionadas o variantes del corpus a una
% forma canonica usada por el detector semantico.
%
% Este predicado es usado por deteccion.pl para comparar nombres
% en singular/plural y evitar que "notas" y "nota" se traten como
% entidades completamente distintas.
% =========================================================

canon(Forma, Canonica) :-
    rasgos_nombre(Forma, _, _, Canonica),
    !.

canon(Forma, Canonica) :-
    rasgos_adjetivo(Forma, _, _, Canonica),
    !.

canon(Forma, Canonica) :-
    rasgos_verbo(Forma, Canonica, _, _, _),
    !.

canon(llaves, llave) :- !.
canon(lineas, linea) :- !.
canon(compases, compas) :- !.
canon(tiempos, tiempo) :- !.
canon(instrumentos, instrumento) :- !.
canon(valores, valor) :- !.
canon(intervalos, intervalo) :- !.
canon(notas, nota) :- !.
canon(figuras, figura) :- !.
canon(signos, signo) :- !.
canon(accidentes, accidente) :- !.
canon(sonidos, sonido) :- !.
canon(clases, clase) :- !.
canon(partes, parte) :- !.
canon(sincopas, sincopa) :- !.
canon(sostenidos, sostenido) :- !.
canon(bemoles, bemol) :- !.
canon(espacios, espacio) :- !.
canon(reglas, regla) :- !.
canon(nombres, nombre) :- !.
canon(pasos, paso) :- !.
canon(modos, modo) :- !.
canon(acepciones, acepcion) :- !.
canon(cifras, cifra) :- !.
canon(escalas, escala) :- !.
canon(Palabra, Palabra).


% =========================================================
% CLASES SEMANTICAS SIMPLES
% =========================================================
%
% clase_semantica(+PalabraCanonica, +Clase).
%
% Una misma palabra puede pertenecer a varias clases.
% Esto es intencionado: permite modelar terminos musicales
% que cumplen mas de una funcion conceptual.
% =========================================================


% ---------------------------------------------------------
% Entidades musicales abstractas
% ---------------------------------------------------------

clase_semantica(melodia, entidad_musical_abstracta).
clase_semantica(armonia, entidad_musical_abstracta).
clase_semantica(arte, entidad_conceptual).
clase_semantica(sucesion, estructura_musical).
clase_semantica(conjunto, agrupacion).
clase_semantica(regla, entidad_normativa).
clase_semantica(cosa, entidad_general).


% ---------------------------------------------------------
% Sonido, nota, escala e intervalos
% ---------------------------------------------------------

clase_semantica(sonido, elemento_sonoro).
clase_semantica(sonido, elemento_musical).

clase_semantica(nota, elemento_musical).
clase_semantica(nota, entidad_denominable).

clase_semantica(intervalo, entidad_denominable).
clase_semantica(intervalo, intervalo_musical).

clase_semantica(semitono, intervalo_musical).
clase_semantica(semitono, entidad_denominable).

clase_semantica(tono, entidad_denominable).
clase_semantica(tono, entidad_musical_abstracta).

clase_semantica(tonalidad, entidad_denominable).
clase_semantica(tonalidad, entidad_musical_abstracta).

clase_semantica(escala, estructura_musical).
clase_semantica(escala, referencia_musical).

clase_semantica(base, referencia_musical).
clase_semantica(base, fundamento_conceptual).


% ---------------------------------------------------------
% Figuras, silencios, valores y duracion
% ---------------------------------------------------------

clase_semantica(figura, simbolo_duracion).
clase_semantica(figura, entidad_correspondiente).
clase_semantica(figura, entidad_denominable).

clase_semantica(redonda, simbolo_duracion).
clase_semantica(redonda, figura_musical).

clase_semantica(silencio, simbolo_duracion).
clase_semantica(silencio, entidad_correspondiente).

clase_semantica(valor, entidad_correspondiente).
clase_semantica(valor, magnitud_musical).

clase_semantica(tiempo, duracion_musical).
clase_semantica(tiempo, magnitud_musical).

clase_semantica(parte, duracion_musical).

clase_semantica(puntillo, modificador_duracion).


% ---------------------------------------------------------
% Notacion grafica y soporte
% ---------------------------------------------------------

clase_semantica(pentagrama, soporte_notacion).
clase_semantica(pentagrama, soporte_grafico).

clase_semantica(linea, trazo_grafico).
clase_semantica(linea, elemento_grafico).
clase_semantica(linea, elemento_del_pentagrama).

clase_semantica(espacio, elemento_grafico).
clase_semantica(espacio, elemento_del_pentagrama).

clase_semantica(posicion, localizacion_grafica).

clase_semantica(nombre, entidad_linguistica).
clase_semantica(nombre, entidad_denominable).

clase_semantica(cifra, signo_grafico).
clase_semantica(cifra, signo_musical).

clase_semantica(signo, signo_grafico).
clase_semantica(signo, signo_musical).

clase_semantica(llave, signo_musical).
clase_semantica(llave, entidad_funcional).

clase_semantica(ligadura, signo_union).
clase_semantica(ligadura, signo_musical).

clase_semantica(accidente, signo_musical).
clase_semantica(sostenido, signo_musical).
clase_semantica(bemol, signo_musical).


% ---------------------------------------------------------
% Compas, medida y metrica
% ---------------------------------------------------------

clase_semantica(compas, entidad_funcional).
clase_semantica(compas, unidad_metrica).
clase_semantica(compas, entidad_denominable).

clase_semantica(medida, magnitud_musical).
clase_semantica(medida, entidad_correspondiente).

clase_semantica(sincopa, fenomeno_ritmico).
clase_semantica(modo, categoria_musical).


% ---------------------------------------------------------
% Instrumentos y voces
% ---------------------------------------------------------

clase_semantica(instrumento, entidad_clasificable).
clase_semantica(instrumento, instrumento_musical).

clase_semantica(fagote, instrumento_musical).
clase_semantica(fagote, entidad_clasificable).

clase_semantica(violoncello, instrumento_musical).
clase_semantica(violoncello, entidad_clasificable).

clase_semantica(voz, termino_lexico).
clase_semantica(voz, entidad_denominable).

clase_semantica(aire, entidad_musical_abstracta).
clase_semantica(aire, sustancia_fisica).


% ---------------------------------------------------------
% Numerales, clases y categorias
% ---------------------------------------------------------

clase_semantica(clase, categoria).
clase_semantica(unisono, intervalo_musical).
clase_semantica(unisono, entidad_denominable).

clase_semantica(sol, elemento_musical).
clase_semantica(sol, nota_musical).

clase_semantica(fa, elemento_musical).
clase_semantica(fa, nota_musical).

clase_semantica(do, elemento_musical).
clase_semantica(do, nota_musical).


% =========================================================
% CONSULTA DE CLASES SEMANTICAS
% =========================================================

clases_palabra(Palabra, Clases) :-
    canon(Palabra, Canonica),
    findall(Clase, clase_semantica(Canonica, Clase), Clases0),
    sort(Clases0, Clases).


% ---------------------------------------------------------
% Alias tipo/2
% ---------------------------------------------------------
%
% El enunciado usa ejemplos del estilo:
%
%   tipo(banco, institucion_financiera).
%
% En este proyecto usamos clase_semantica/2 como nombre mas
% descriptivo, pero se proporciona tipo/2 como alias para
% mantener compatibilidad conceptual con el enunciado.
% ---------------------------------------------------------

tipo(Palabra, Clase) :-
    canon(Palabra, Canonica),
    clase_semantica(Canonica, Clase).


% =========================================================
% COMPATIBILIDAD SUJETO-VERBO
% =========================================================
%
% Solo se declaran restricciones para verbos donde tiene
% sentido comprobar compatibilidad semantica.
%
% Si un verbo no aparece aqui, el detector no fuerza ninguna
% restriccion semantica.
%
% sujeto_admisible(+Verbo, +ClaseSemanticaDelSujeto).
% =========================================================


% ---------------------------------------------------------
% aumentar
% ---------------------------------------------------------
%
% El sujeto que aumenta el valor de una figura debe ser un
% modificador de duracion, como el puntillo.
% ---------------------------------------------------------

sujeto_admisible(aumenta, modificador_duracion).


% ---------------------------------------------------------
% dividirse
% ---------------------------------------------------------
%
% Los instrumentos se dividen en clases.
% ---------------------------------------------------------

sujeto_admisible(dividen, entidad_clasificable).


% ---------------------------------------------------------
% servir
% ---------------------------------------------------------
%
% Puede servir un compas, una llave, un intervalo o una escala
% cuando funcionan como herramienta, signo o referencia musical.
% ---------------------------------------------------------

sujeto_admisible(sirve, entidad_funcional).
sujeto_admisible(sirve, signo_musical).
sujeto_admisible(sirve, intervalo_musical).
sujeto_admisible(sirve, referencia_musical).
sujeto_admisible(sirve, estructura_musical).


% ---------------------------------------------------------
% usar
% ---------------------------------------------------------
%
% En el corpus, lo que "se usa" es una llave musical.
% ---------------------------------------------------------

sujeto_admisible(usa, signo_musical).
sujeto_admisible(usa, entidad_funcional).


% ---------------------------------------------------------
% tomar / tomarse
% ---------------------------------------------------------
%
% El sujeto puede ser un termino o entidad que recibe una
% denominacion o una acepcion.
% ---------------------------------------------------------

sujeto_admisible(toma, entidad_denominable).
sujeto_admisible(toma, termino_lexico).
sujeto_admisible(toma, entidad_linguistica).

sujeto_admisible(toman, entidad_denominable).
sujeto_admisible(toman, intervalo_musical).


% ---------------------------------------------------------
% corresponder
% ---------------------------------------------------------
%
% Valores y medidas pueden corresponder a notas o figuras.
% ---------------------------------------------------------

sujeto_admisible(corresponden, entidad_correspondiente).
sujeto_admisible(corresponden, magnitud_musical).


% ---------------------------------------------------------
% unir
% ---------------------------------------------------------
%
% Una ligadura o linea puede unir notas.
% ---------------------------------------------------------

sujeto_admisible(une, signo_union).
sujeto_admisible(une, trazo_grafico).
sujeto_admisible(une, elemento_grafico).


% =========================================================
% CONSULTA DE RESTRICCIONES SUJETO-VERBO
% =========================================================

verbo_con_restriccion(Verbo) :-
    sujeto_admisible(Verbo, _).


clases_admisibles_verbo(Verbo, Clases) :-
    findall(Clase, sujeto_admisible(Verbo, Clase), Clases0),
    sort(Clases0, Clases).