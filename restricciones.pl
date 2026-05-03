% =========================================================
% RESTRICCIONES LEXICO-SINTACTICAS
% Archivo: restricciones.pl
%
% Contiene:
% - clases nominales
% - compatibilidad nombre + preposicion
% - clases verbales
% - compatibilidad verbo + preposicion
% - extraccion de lexemas
%
% Objetivo:
% Evitar que cualquier nombre o verbo pueda combinarse con
% cualquier grupo preposicional.
%
% Este archivo separa el conocimiento lexico-sintactico de
% la gramatica DCG principal.
% =========================================================


% =========================================================
% CLASES NOMINALES
% =========================================================

% ---------------------------------------------------------
% Nombres que admiten complementos con "de" o "del"
% ---------------------------------------------------------
%
% Ejemplos:
%
%   sucesion de varios sonidos
%   conjunto de varios sonidos
%   valor de las figuras
%   nombre de las notas
%   notas de su figura
%   notas del mismo nombre
%   pasos del fagote
%   silencio de redonda
%   nota de la escala
%
% =========================================================

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
clase_nominal(nota, relacional_de_del).
clase_nominal(silencio, relacional_de_del).
clase_nominal(pasos, relacional_de_del).

% ---------------------------------------------------------
% Nombres que admiten complementos de finalidad con "para"
% ---------------------------------------------------------

clase_nominal(reglas, finalidad).

% ---------------------------------------------------------
% Nombres de distancia u origen/destino
% ---------------------------------------------------------
%
% Ejemplos:
%
%   distancia de un sonido
%   distancia a otro
%   distancia entre dos notas
%
% =========================================================

clase_nominal(distancia, origen_destino).

% ---------------------------------------------------------
% Nombre que aparece con la contraccion "del"
% ---------------------------------------------------------

clase_nominal(mitad, contraccion_del).

% ---------------------------------------------------------
% Nombres asociados a llaves musicales
% ---------------------------------------------------------
%
% Ejemplos:
%
%   llave de do
%   llave en cuarta linea
%
% =========================================================

clase_nominal(llave, clave_musical).
clase_nominal(llaves, clave_musical).

% ---------------------------------------------------------
% Nombres de elementos musicales localizables
% ---------------------------------------------------------
%
% Ejemplo:
%
%   notas en el pentagrama
%
% =========================================================

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

% ---------------------------------------------------------
% COMPATIBILIDADES DIRECTAS EXCEPCIONALES
% ---------------------------------------------------------
%
% Este predicado se deja preparado para casos futuros que no
% encajen bien en ninguna clase.
%
% Ejemplo posible:
%
%   admite_gp_nominal_directo(algun_nombre, alguna_prep).
%
% Actualmente no hay excepciones directas.
% =========================================================

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
%
% Ejemplos:
%
%   sirve para medir
%   se usa para los pasos agudos
%
% =========================================================

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
%
% Ejemplo:
%
%   corresponden a diversas notas
%
% =========================================================

clase_verbal(corresponden, correspondencia).

% ---------------------------------------------------------
% Verbos de union o enlace
% ---------------------------------------------------------
%
% Ejemplo:
%
%   une a dos notas
%
% =========================================================

clase_verbal(une, enlace).

% ---------------------------------------------------------
% Verbos de fijacion o ubicacion
% ---------------------------------------------------------
%
% Ejemplo:
%
%   fijar el nombre de las notas en el pentagrama
%
% =========================================================

clase_verbal(fijar, ubicacion).

% ---------------------------------------------------------
% Verbo "servir" con complemento "de"
% ---------------------------------------------------------
%
% Ejemplo:
%
%   sirve de base
%
% Esta clase se suma a la clase "finalidad", que permite:
%
%   sirve para ...
%
% =========================================================

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

% ---------------------------------------------------------
% COMPATIBILIDADES DIRECTAS EXCEPCIONALES
% ---------------------------------------------------------
%
% Este predicado se deja preparado para casos futuros que no
% encajen bien en ninguna clase.
%
% Ejemplo posible:
%
%   admite_gp_verbal_directo(algun_verbo, alguna_prep).
%
% Actualmente no hay excepciones directas.
% =========================================================

admite_gp_verbal_directo(_, _) :-
    fail.


% =========================================================
% EXTRACCION DE LEXEMAS
% =========================================================
%
% Convierte los terminos lexicos usados por la DCG en atomos
% simples para consultar las restricciones.
%
% Ejemplos:
%
%   n(nombre)      -> nombre
%   v(sirve)       -> sirve
%   vc(se, sirve)  -> sirve
%   prep(de)       -> de
%
% =========================================================

nombre_lexema(n(X), X).

verbo_lexema(v(X), X).
verbo_lexema(vc(_, v(X)), X).

prep_lexema(prep(X), X).