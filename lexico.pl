% =========================================================
% LEXICO
% Archivo: lexico.pl
%
% Contiene unicamente las categorias lexicas:
% - determinantes
% - cuantificadores
% - numerales
% - verbos
% - participios
% - adjetivos
% - adverbios
% - preposiciones
% - conjunciones
% - relativos
% - nombres
% - signos especiales
%
% =========================================================

% =========================================================
% DETERMINANTES
% =========================================================

% NIVEL INICIAL

determinante(det(el)) --> [el].
determinante(det(la)) --> [la].
determinante(det(los)) --> [los].
determinante(det(las)) --> [las].
determinante(det(un)) --> [un].
determinante(det(una)) --> [una].

% NIVEL MEDIO

determinante(det(alguna)) --> [alguna].

% NIVEL COMPLEJO

determinante(det(mi)) --> [mi].
determinante(det(lo)) --> [lo].
determinante(det(esos)) --> [esos].
determinante(det(su)) --> [su].

% =========================================================
% CUANTIFICADORES
% =========================================================

% NIVEL INICIAL

cuantificador(cuant(todas)) --> [todas].
cuantificador(cuant(varios)) --> [varios].

% NIVEL COMPLEJO

cuantificador(cuant(tantas)) --> [tantas].
cuantificador(cuant(cuantas)) --> [cuantas].

% =========================================================
% NUMERALES
% =========================================================

% NIVEL INICIAL

numeral(num(tres)) --> [tres].
numeral(num(cuatro)) --> [cuatro].
numeral(num(cinco)) --> [cinco].
numeral(num(siete)) --> [siete].

% NIVEL MEDIO

numeral(num(dos)) --> [dos].

% NIVEL COMPLEJO

numeral(num(ocho)) --> [ocho].

% =========================================================
% VERBOS
% =========================================================

% NIVEL INICIAL

verbo(v(es)) --> [es].
verbo(v(son)) --> [son].
verbo(v(tiene)) --> [tiene].
verbo(v(tienen)) --> [tienen].
verbo(v(valen)) --> [valen].
verbo(v(representa)) --> [representa].
verbo(v(aumenta)) --> [aumenta].
verbo(v(dividen)) --> [dividen].

% NIVEL MEDIO

verbo(v(hay)) --> [hay].
verbo(v(sirve)) --> [sirve].
verbo(v(hacer)) --> [hacer].
verbo(v(medir)) --> [medir].
verbo(v(compone)) --> [compone].
verbo(v(escriben)) --> [escriben].
verbo(v(resultan)) --> [resultan].
verbo(v(toman)) --> [toman].
verbo(v(toma)) --> [toma].
verbo(v(escribiendose)) --> [escribiendose].

% NIVEL COMPLEJO

verbo(v(ha)) --> [ha].
verbo(v(sido)) --> [sido].
verbo(v(sea)) --> [sea].
verbo(v(vayan)) --> [vayan].
verbo(v(estudiando)) --> [estudiando].
verbo(v(graben)) --> [graben].
verbo(v(poder)) --> [poder].
verbo(v(llegar)) --> [llegar].
verbo(v(he)) --> [he].
verbo(v(consultado)) --> [consultado].
verbo(v(han)) --> [han].
verbo(v(escrito)) --> [escrito].
verbo(v(aceptando)) --> [aceptando].
verbo(v(creido)) --> [creido].
verbo(v(combinar)) --> [combinar].
verbo(v(recrear)) --> [recrear].
verbo(v(elevar)) --> [elevar].
verbo(v(produce)) --> [produce].
verbo(v(hablar)) --> [hablar].
verbo(v(escribir)) --> [escribir].
verbo(v(hace)) --> [hace].
verbo(v(colocan)) --> [colocan].
verbo(v(formando)) --> [formando].
verbo(v(coloca)) --> [coloca].
verbo(v(suspender)) --> [suspender].
verbo(v(teniendo)) --> [teniendo].
verbo(v(quiere)) --> [quiere].
verbo(v(volver)) --> [volver].
verbo(v(pondra)) --> [pondra].
verbo(v(encuentran)) --> [encuentran].
verbo(v(alteran)) --> [alteran].
verbo(v(encuentra)) --> [encuentra].
verbo(v(hara)) --> [hara].
verbo(v(subir)) --> [subir].
verbo(v(bajar)) --> [bajar].
verbo(v(convierten)) --> [convierten].
verbo(v(convierte)) --> [convierte].
verbo(v(colocandolo)) --> [colocandolo].
verbo(v(siendo)) --> [siendo].
verbo(v(representan)) --> [representan].
verbo(v(faltando)) --> [faltando].

% =========================================================
% PARTICIPIOS
% =========================================================

% NIVEL INICIAL

participio(part(dividida)) --> [dividida].

% =========================================================
% ADJETIVOS
% =========================================================

% NIVEL INICIAL

adjetivo(adj(acertada)) --> [acertada].
adjetivo(adj(musicales)) --> [musicales].
adjetivo(adj(anterior)) --> [anterior].
adjetivo(adj(pequena)) --> [pequena].
adjetivo(adj(iguales)) --> [iguales].

% NIVEL MEDIO

adjetivo(adj(doble)) --> [doble].
adjetivo(adj(largas)) --> [largas].
adjetivo(adj(breves)) --> [breves].
adjetivo(adj(diferentes)) --> [diferentes].
adjetivo(adj(numericos)) --> [numericos].
adjetivo(adj(usuales)) --> [usuales].
adjetivo(adj(pares)) --> [pares].
adjetivo(adj(impares)) --> [impares].
adjetivo(adj(segunda)) --> [segunda].
adjetivo(adj(tercera)) --> [tercera].
adjetivo(adj(cuarta)) --> [cuarta].

% NIVEL COMPLEJO

adjetivo(adj(indispensable)) --> [indispensable].
adjetivo(adj(extenso)) --> [extenso].
adjetivo(adj(dificil)) --> [dificil].
adjetivo(adj(corta)) --> [corta].
adjetivo(adj(conveniente)) --> [conveniente].
adjetivo(adj(musical)) --> [musical].
adjetivo(adj(determinada)) --> [determinada].
adjetivo(adj(tirante)) --> [tirante].
adjetivo(adj(posible)) --> [posible].
adjetivo(adj(adicionales)) --> [adicionales].
adjetivo(adj(nuevos)) --> [nuevos].
adjetivo(adj(simple)) --> [simple].
adjetivo(adj(inmediatos)) --> [inmediatos].
adjetivo(adj(accidentadas)) --> [accidentadas].
adjetivo(adj(misma)) --> [misma].
adjetivo(adj(interrumpida)) --> [interrumpida].
adjetivo(adj(octavo)) --> [octavo].
adjetivo(adj(primero)) --> [primero].
adjetivo(adj(tipicas)) --> [tipicas].
adjetivo(adj(mayor)) --> [mayor].
adjetivo(adj(menor)) --> [menor].
adjetivo(adj(semicirculo)) --> [semicirculo].

% =========================================================
% ADVERBIOS
% =========================================================

% NIVEL INICIAL

adverbio(adv(igual)) --> [igual].

% NIVEL MEDIO

adverbio(adv(bien)) --> [bien].
adverbio(adv(tambien)) --> [tambien].
adverbio(adv(muy)) --> [muy].
adverbio(adv(mas)) --> [mas].
adverbio(adv(ordinariamente)) --> [ordinariamente].

% NIVEL COMPLEJO

adverbio(adv(no)) --> [no].
adverbio(adv(demasiado)) --> [demasiado].
adverbio(adv(paulatinamente)) --> [paulatinamente].
adverbio(adv(facilmente)) --> [facilmente].
adverbio(adv(momentaneamente)) --> [momentaneamente].
adverbio(adv(antes)) --> [antes].
adverbio(adv(despues)) --> [despues].
adverbio(adv(inmediatamente)) --> [inmediatamente].
adverbio(adv(arriba)) --> [arriba].
adverbio(adv(debajo)) --> [debajo].
adverbio(adv(encima)) --> [encima].
adverbio(adv(sobre)) --> [sobre].
adverbio(adv(viceversa)) --> [viceversa].

% =========================================================
% PREPOSICIONES
% =========================================================

% NIVEL INICIAL

preposicion(prep(de)) --> [de].
preposicion(prep(del)) --> [del].
preposicion(prep(a)) --> [a].
preposicion(prep(en)) --> [en].

% NIVEL MEDIO

preposicion(prep(para)) --> [para].
preposicion(prep(entre)) --> [entre].
preposicion(prep(al)) --> [al].
preposicion(prep(como)) --> [como].

% NIVEL COMPLEJO

preposicion(prep(con)) --> [con].
preposicion(prep(por)) --> [por].
preposicion(prep(durante)) --> [durante].

% =========================================================
% CONJUNCIONES
% =========================================================

% NIVEL INICIAL

conjuncion(conj(y)) --> [y].

% NIVEL MEDIO

conjuncion(conj(o)) --> [o].
conjuncion(conj(e)) --> [e].

% NIVEL COMPLEJO

conjuncion(conj(ni)) --> [ni].

% =========================================================
% RELATIVOS
% =========================================================

% NIVEL INICIAL

relativo(rel(que)) --> [que].

% =========================================================
% NOMBRES
% =========================================================

% NIVEL INICIAL

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
nombre(n(compases)) --> [compases].
nombre(n(porcion)) --> [porcion].
nombre(n(tiempo)) --> [tiempo].
nombre(n(partes)) --> [partes].
nombre(n(sucesion)) --> [sucesion].
nombre(n(conjunto)) --> [conjunto].
nombre(n(sonidos)) --> [sonidos].
nombre(n(lineas)) --> [lineas].
nombre(n(espacios)) --> [espacios].
nombre(n(otro)) --> [otro].

% NIVEL MEDIO

nombre(n(arte)) --> [arte].
nombre(n(reglas)) --> [reglas].
nombre(n(cosa)) --> [cosa].
nombre(n(sinonimo)) --> [sinonimo].
nombre(n(medida)) --> [medida].
nombre(n(aire)) --> [aire].
nombre(n(tiempos)) --> [tiempos].
nombre(n(sincopas)) --> [sincopas].
nombre(n(modos)) --> [modos].
nombre(n(accidentes)) --> [accidentes].
nombre(n(intervalos)) --> [intervalos].
nombre(n(signos)) --> [signos].
nombre(n(nombres)) --> [nombres].
nombre(n(unisono)) --> [unisono].
nombre(n(llave)) --> [llave].
nombre(n(linea)) --> [linea].
nombre(n(dia)) --> [dia].
nombre(n(voz)) --> [voz].
nombre(n(tonalidad)) --> [tonalidad].
nombre(n(acepcion)) --> [acepcion].
nombre(n(tono)) --> [tono].

% NIVEL COMPLEJO

nombre(n(proposito)) --> [proposito].
nombre(n(experiencia)) --> [experiencia].
nombre(n(ensenanza)) --> [ensenanza].
nombre(n(compendio)) --> [compendio].
nombre(n(dificultades)) --> [dificultades].
nombre(n(musica)) --> [musica].
nombre(n(explicacion)) --> [explicacion].
nombre(n(memoria)) --> [memoria].
nombre(n(fines)) --> [fines].
nombre(n(obras)) --> [obras].
nombre(n(solfeo)) --> [solfeo].
nombre(n(teoria)) --> [teoria].
nombre(n(maestros)) --> [maestros].
nombre(n(pedrell)) --> [pedrell].
nombre(n(eslava)) --> [eslava].
nombre(n(menozzi)) --> [menozzi].
nombre(n(panseron)) --> [panseron].
nombre(n(germer)) --> [germer].
nombre(n(mertke)) --> [mertke].
nombre(n(asioli)) --> [asioli].
nombre(n(objeto)) --> [objeto].
nombre(n(sentidos)) --> [sentidos].
nombre(n(alma)) --> [alma].
nombre(n(uno)) --> [uno].
nombre(n(ruido)) --> [ruido].
nombre(n(vibracion)) --> [vibracion].
nombre(n(cuerda)) --> [cuerda].
nombre(n(ferro)) --> [ferro].
nombre(n(carril)) --> [carril].
nombre(n(personas)) --> [personas].
nombre(n(uso)) --> [uso].
nombre(n(pentagramas)) --> [pentagramas].
nombre(n(calderon)) --> [calderon].
nombre(n(corona)) --> [corona].
nombre(n(punto)) --> [punto].
nombre(n(discurso)) --> [discurso].
nombre(n(gusto)) --> [gusto].
nombre(n(ejecutante)) --> [ejecutante].
nombre(n(nota)) --> [nota].
nombre(n(sostenido)) --> [sostenido].
nombre(n(bemol)) --> [bemol].
nombre(n(becuadro)) --> [becuadro].
nombre(n(pieza)) --> [pieza].
nombre(n(cambio)) --> [cambio].
nombre(n(posicion)) --> [posicion].
nombre(n(octava)) --> [octava].
nombre(n(escala)) --> [escala].
nombre(n(repeticion)) --> [repeticion].
nombre(n(formas)) --> [formas].

% =========================================================
% SIGNOS ESPECIALES
% =========================================================

% NIVEL INICIAL

dos_puntos(dp(':')) --> [':'].
coma(c(',')) --> [','].

% NIVEL MEDIO

etcetera(etc) --> [etc].

% NIVEL COMPLEJO

punto_y_coma(pyc(';')) --> [';'].