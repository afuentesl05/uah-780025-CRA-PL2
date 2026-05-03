% =========================================================
% LEXICO
% Archivo: lexico.pl
%
% Contiene unicamente las categorias lexicas usadas
% en el corpus actual de 30 oraciones.
%
% Clasificacion:
% - NIVEL INICIAL  : palabras que aparecen por primera vez
%                    en las oraciones 1-10.
% - NIVEL MEDIO    : palabras que aparecen por primera vez
%                    en las oraciones 11-20.
% - NIVEL COMPLEJO : palabras que aparecen por primera vez
%                    en las oraciones 21-30.
%
% Nota:
% - La particula "se" no se define aqui porque se reconoce
%   en sintactico.pl como auxiliar verbal:
%
%       verbo_aux(v(se)) --> [se].
%
% =========================================================


% =========================================================
% DETERMINANTES
% =========================================================

% ---------------------------------------------------------
% NIVEL INICIAL
% ---------------------------------------------------------

determinante(det(el)) --> [el].
determinante(det(la)) --> [la].
determinante(det(los)) --> [los].
determinante(det(las)) --> [las].
determinante(det(un)) --> [un].
determinante(det(una)) --> [una].

% ---------------------------------------------------------
% NIVEL MEDIO
% ---------------------------------------------------------

determinante(det(alguna)) --> [alguna].
determinante(det(estos)) --> [estos].
determinante(det(su)) --> [su].

% ---------------------------------------------------------
% NIVEL COMPLEJO
% ---------------------------------------------------------
% No hay determinantes nuevos en el nivel complejo.


% =========================================================
% CUANTIFICADORES
% =========================================================

% ---------------------------------------------------------
% NIVEL INICIAL
% ---------------------------------------------------------

cuantificador(cuant(varios)) --> [varios].

% ---------------------------------------------------------
% NIVEL MEDIO
% ---------------------------------------------------------

cuantificador(cuant(diversas)) --> [diversas].

% ---------------------------------------------------------
% NIVEL COMPLEJO
% ---------------------------------------------------------

cuantificador(cuant(todas)) --> [todas].


% =========================================================
% NUMERALES
% =========================================================

% ---------------------------------------------------------
% NIVEL INICIAL
% ---------------------------------------------------------

numeral(num(cinco)) --> [cinco].
numeral(num(cuatro)) --> [cuatro].
numeral(num(siete)) --> [siete].

% ---------------------------------------------------------
% NIVEL MEDIO
% ---------------------------------------------------------

numeral(num(dos)) --> [dos].
numeral(num(tres)) --> [tres].

% ---------------------------------------------------------
% NIVEL COMPLEJO
% ---------------------------------------------------------
% No hay numerales nuevos en el nivel complejo.


% =========================================================
% VERBOS
% =========================================================

% ---------------------------------------------------------
% NIVEL INICIAL
% ---------------------------------------------------------

verbo(v(es)) --> [es].
verbo(v(son)) --> [son].
verbo(v(tiene)) --> [tiene].
verbo(v(aumenta)) --> [aumenta].
verbo(v(dividen)) --> [dividen].

% ---------------------------------------------------------
% NIVEL MEDIO
% ---------------------------------------------------------

verbo(v(hacer)) --> [hacer].
verbo(v(hay)) --> [hay].
verbo(v(toma)) --> [toma].
verbo(v(tienen)) --> [tienen].
verbo(v(corresponden)) --> [corresponden].

% ---------------------------------------------------------
% NIVEL COMPLEJO
% ---------------------------------------------------------

verbo(v(valen)) --> [valen].
verbo(v(representa)) --> [representa].
verbo(v(sirve)) --> [sirve].
verbo(v(medir)) --> [medir].
verbo(v(compone)) --> [compone].
verbo(v(resultan)) --> [resultan].
verbo(v(toman)) --> [toman].
verbo(v(vale)) --> [vale].
verbo(v(coloca)) --> [coloca].
verbo(v(une)) --> [une].
verbo(v(fijar)) --> [fijar].
verbo(v(usa)) --> [usa].
verbo(v(escribiendose)) --> [escribiendose].


% =========================================================
% PARTICIPIOS
% =========================================================

% ---------------------------------------------------------
% NIVEL INICIAL
% ---------------------------------------------------------

participio(part(dividida)) --> [dividida].

% ---------------------------------------------------------
% NIVEL MEDIO
% ---------------------------------------------------------
% No hay participios nuevos en el nivel medio.

% ---------------------------------------------------------
% NIVEL COMPLEJO
% ---------------------------------------------------------
% No hay participios nuevos en el nivel complejo.


% =========================================================
% ADJETIVOS
% =========================================================

% ---------------------------------------------------------
% NIVEL INICIAL
% ---------------------------------------------------------

adjetivo(adj(acertada)) --> [acertada].
adjetivo(adj(musicales)) --> [musicales].
adjetivo(adj(anterior)) --> [anterior].
adjetivo(adj(doble)) --> [doble].
adjetivo(adj(pequena)) --> [pequena].
adjetivo(adj(iguales)) --> [iguales].

% ---------------------------------------------------------
% NIVEL MEDIO
% ---------------------------------------------------------

adjetivo(adj(pares)) --> [pares].
adjetivo(adj(impares)) --> [impares].
adjetivo(adj(segunda)) --> [segunda].
adjetivo(adj(dobles)) --> [dobles].
adjetivo(adj(fuertes)) --> [fuertes].
adjetivo(adj(debiles)) --> [debiles].
adjetivo(adj(conjunto)) --> [conjunto].
adjetivo(adj(inmediatas)) --> [inmediatas].
adjetivo(adj(pequeno)) --> [pequeno].
adjetivo(adj(menor)) --> [menor].
adjetivo(adj(irregulares)) --> [irregulares].

% ---------------------------------------------------------
% NIVEL COMPLEJO
% ---------------------------------------------------------

adjetivo(adj(diferentes)) --> [diferentes].
adjetivo(adj(numericos)) --> [numericos].
adjetivo(adj(tercera)) --> [tercera].
adjetivo(adj(curva)) --> [curva].
adjetivo(adj(mismo)) --> [mismo].
adjetivo(adj(cuarta)) --> [cuarta].
adjetivo(adj(agudos)) --> [agudos].
adjetivo(adj(primera)) --> [primera].
adjetivo(adj(largas)) --> [largas].
adjetivo(adj(breves)) --> [breves].
adjetivo(adj(usuales)) --> [usuales].


% =========================================================
% ADVERBIOS
% =========================================================

% ---------------------------------------------------------
% NIVEL INICIAL
% ---------------------------------------------------------
% No hay adverbios nuevos en el nivel inicial.

% ---------------------------------------------------------
% NIVEL MEDIO
% ---------------------------------------------------------

adverbio(adv(bien)) --> [bien].
adverbio(adv(tambien)) --> [tambien].
adverbio(adv(ordinariamente)) --> [ordinariamente].
adverbio(adv(mas)) --> [mas].

% ---------------------------------------------------------
% NIVEL COMPLEJO
% ---------------------------------------------------------

adverbio(adv(igual)) --> [igual].
adverbio(adv(debajo)) --> [debajo].
adverbio(adv(muy)) --> [muy].


% =========================================================
% ADVERBIOS LOCATIVOS
% =========================================================
%
% Subclase de adverbios que pueden formar grupos
% adverbiales locativos del tipo:
%
%   debajo de las lineas
%
% =========================================================

% ---------------------------------------------------------
% NIVEL COMPLEJO
% ---------------------------------------------------------

adverbio_locativo(adv(debajo)) --> [debajo].

% Futuras ampliaciones:
% adverbio(adv(encima)) --> [encima].
% adverbio_locativo(adv(encima)) --> [encima].


% =========================================================
% PREPOSICIONES
% =========================================================

% ---------------------------------------------------------
% NIVEL INICIAL
% ---------------------------------------------------------

preposicion(prep(de)) --> [de].
preposicion(prep(del)) --> [del].
preposicion(prep(a)) --> [a].
preposicion(prep(al)) --> [al].
preposicion(prep(en)) --> [en].

% ---------------------------------------------------------
% NIVEL MEDIO
% ---------------------------------------------------------

preposicion(prep(para)) --> [para].
preposicion(prep(como)) --> [como].
preposicion(prep(entre)) --> [entre].

% ---------------------------------------------------------
% NIVEL COMPLEJO
% ---------------------------------------------------------
% No hay preposiciones nuevas en el nivel complejo.


% =========================================================
% CONJUNCIONES
% =========================================================

% ---------------------------------------------------------
% NIVEL INICIAL
% ---------------------------------------------------------

conjuncion(conj(y)) --> [y].

% ---------------------------------------------------------
% NIVEL MEDIO
% ---------------------------------------------------------

conjuncion(conj(o)) --> [o].
conjuncion(conj(e)) --> [e].

% ---------------------------------------------------------
% NIVEL COMPLEJO
% ---------------------------------------------------------
% No hay conjunciones nuevas en el nivel complejo.


% =========================================================
% RELATIVOS
% =========================================================

% ---------------------------------------------------------
% NIVEL INICIAL
% ---------------------------------------------------------
% No hay relativos nuevos en el nivel inicial.

% ---------------------------------------------------------
% NIVEL MEDIO
% ---------------------------------------------------------
% No hay relativos nuevos en el nivel medio.

% ---------------------------------------------------------
% NIVEL COMPLEJO
% ---------------------------------------------------------

relativo(rel(que)) --> [que].


% =========================================================
% NOMBRES
% =========================================================

% ---------------------------------------------------------
% NIVEL INICIAL
% ---------------------------------------------------------

nombre(n(melodia)) --> [melodia].
nombre(n(sucesion)) --> [sucesion].
nombre(n(sonidos)) --> [sonidos].
nombre(n(armonia)) --> [armonia].
nombre(n(conjunto)) --> [conjunto].
nombre(n(notas)) --> [notas].
nombre(n(accidentes)) --> [accidentes].
nombre(n(pentagrama)) --> [pentagrama].
nombre(n(lineas)) --> [lineas].
nombre(n(espacios)) --> [espacios].
nombre(n(intervalo)) --> [intervalo].
nombre(n(distancia)) --> [distancia].
nombre(n(sonido)) --> [sonido].
nombre(n(otro)) --> [otro].
nombre(n(puntillo)) --> [puntillo].
nombre(n(mitad)) --> [mitad].
nombre(n(valor)) --> [valor].
nombre(n(figura)) --> [figura].
nombre(n(instrumentos)) --> [instrumentos].
nombre(n(clases)) --> [clases].
nombre(n(compas)) --> [compas].
nombre(n(porcion)) --> [porcion].
nombre(n(tiempo)) --> [tiempo].
nombre(n(partes)) --> [partes].

% ---------------------------------------------------------
% NIVEL MEDIO
% ---------------------------------------------------------

nombre(n(arte)) --> [arte].
nombre(n(reglas)) --> [reglas].
nombre(n(cosa)) --> [cosa].
nombre(n(sinonimo)) --> [sinonimo].
nombre(n(medida)) --> [medida].
nombre(n(aire)) --> [aire].
nombre(n(llaves)) --> [llaves].
nombre(n(sol)) --> [sol].
nombre(n(fa)) --> [fa].
nombre(n(do)) --> [do].
nombre(n(compases)) --> [compases].
nombre(n(voz)) --> [voz].
nombre(n(tonalidad)) --> [tonalidad].
nombre(n(acepcion)) --> [acepcion].
nombre(n(tono)) --> [tono].
nombre(n(sostenidos)) --> [sostenidos].
nombre(n(bemoles)) --> [bemoles].
nombre(n(tiempos)) --> [tiempos].
nombre(n(semitono)) --> [semitono].
nombre(n(valores)) --> [valores].

% ---------------------------------------------------------
% NIVEL COMPLEJO
% ---------------------------------------------------------

nombre(n(figuras)) --> [figuras].
nombre(n(silencio)) --> [silencio].
nombre(n(intervalos)) --> [intervalos].
nombre(n(signos)) --> [signos].
nombre(n(nombres)) --> [nombres].
nombre(n(unisono)) --> [unisono].
nombre(n(redonda)) --> [redonda].
nombre(n(ligadura)) --> [ligadura].
nombre(n(linea)) --> [linea].
nombre(n(nombre)) --> [nombre].
nombre(n(posicion)) --> [posicion].
nombre(n(llave)) --> [llave].
nombre(n(signo)) --> [signo].
nombre(n(cifra)) --> [cifra].
nombre(n(pasos)) --> [pasos].
nombre(n(fagote)) --> [fagote].
nombre(n(violoncello)) --> [violoncello].
nombre(n(nota)) --> [nota].
nombre(n(escala)) --> [escala].
nombre(n(base)) --> [base].
nombre(n(sincopas)) --> [sincopas].
nombre(n(modos)) --> [modos].
nombre(n(dia)) --> [dia].


% =========================================================
% SIGNOS ESPECIALES
% =========================================================

% ---------------------------------------------------------
% NIVEL INICIAL
% ---------------------------------------------------------
% No hay signos especiales nuevos en el nivel inicial.

% ---------------------------------------------------------
% NIVEL MEDIO
% ---------------------------------------------------------

dos_puntos(dp(':')) --> [':'].
coma(c(',')) --> [','].

% ---------------------------------------------------------
% NIVEL COMPLEJO
% ---------------------------------------------------------

etcetera(etc) --> [etc].