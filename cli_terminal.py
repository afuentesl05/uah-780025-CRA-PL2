import os
import re
import subprocess
import unicodedata
import textwrap
from shutil import get_terminal_size

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

SWIPL_CMD = "swipl"
BRIDGE_FILE = os.path.join(BASE_DIR, "cli_bridge.pl")

SHOW_PROLOG_WARNINGS = False
SHOW_INTERNAL_WARNINGS = False
SHOW_SEMANTIC_TREE = False


# =========================================================
# CORPUS ACTUAL DE 30 ORACIONES
# =========================================================

CORPUS = [
    (1, "La melodia es la acertada sucesion de varios sonidos."),
    (2, "La armonia es el conjunto de varios sonidos."),
    (3, "Las notas musicales son siete."),
    (4, "Los accidentes musicales son cinco."),
    (5, "El pentagrama tiene cinco lineas y cuatro espacios."),
    (6, "El intervalo es la distancia de un sonido a otro."),
    (7, "El puntillo aumenta la mitad del valor a la figura anterior."),
    (8, "El doble puntillo aumenta la mitad del valor al puntillo anterior."),
    (9, "Los instrumentos musicales se dividen en cuatro clases."),
    (10, "El compas es una pequena porcion de tiempo dividida en partes iguales."),
    (11, "El arte es el conjunto de reglas para hacer bien alguna cosa."),
    (12, "El tiempo es sinonimo de medida o compas y tambien es sinonimo de aire."),
    (13, "Las llaves son tres: sol, fa y do."),
    (14, "Hay dos clases de compases: pares e impares."),
    (15, "La voz tonalidad se toma ordinariamente como segunda acepcion de tono."),
    (16, "Los dobles sostenidos y dobles bemoles son tambien siete."),
    (17, "Los compases tienen tiempos fuertes y tiempos debiles."),
    (18, "Intervalo conjunto es la distancia entre dos notas inmediatas."),
    (19, "El intervalo conjunto mas pequeno es el semitono menor."),
    (20, "Estos valores irregulares corresponden a diversas notas de su figura."),
    (21, "Todas las figuras tienen silencio y valen igual a la figura que representa."),
    (22, "El compas sirve para medir el valor de las figuras y se compone de dos, tres o cuatro tiempos, etc."),
    (23, "Los diferentes intervalos que resultan entre los signos toman los nombres numericos de unisono, segunda, tercera, etc."),
    (24, "Silencio de redonda vale cuatro partes y se coloca debajo de las lineas."),
    (25, "Ligadura es una linea curva que une a dos notas del mismo nombre y posicion."),
    (26, "Llave es un signo o cifra que sirve para fijar el nombre de las notas en el pentagrama."),
    (27, "La llave de do en cuarta linea se usa para los pasos agudos del fagote y violoncello."),
    (28, "El tono toma el nombre de la primera nota de la escala que sirve de base."),
    (29, "Hay sincopas largas, breves y muy breves, escribiendose de tres modos."),
    (30, "Las llaves mas usuales en el dia son la llave de sol en segunda linea, la llave de fa en cuarta linea, la llave de do en tercera linea y la llave de do en cuarta linea.")
]


# =========================================================
# UTILIDADES DE TERMINAL
# =========================================================

def clear_screen():
    os.system("cls" if os.name == "nt" else "clear")


def terminal_width():
    return get_terminal_size((140, 30)).columns


def line(char="─"):
    return char * terminal_width()


def center(text):
    return text.center(terminal_width())


def pause():
    input("\nPulsa ENTER para continuar...")


def print_header(title: str):
    clear_screen()
    print(line("═"))
    print(center("ANALIZADOR SINTACTICO Y SEMANTICO EN TERMINAL"))
    print(center(title))
    print(line("═"))


def print_section(title: str):
    print("\n" + title)
    print(line())


def wrap_text(text, width=None, indent=""):
    if text is None:
        return ""

    if width is None:
        width = max(80, terminal_width() - 4)

    return textwrap.fill(
        str(text),
        width=width,
        initial_indent=indent,
        subsequent_indent=indent
    )


def compact(text, limit=100):
    if text is None:
        return ""

    text = str(text).replace("\n", " ").strip()

    if len(text) <= limit:
        return text

    return text[:limit - 3] + "..."


def clean_numbered_explanation(text):
    text = str(text).strip()
    return re.sub(r"^\d+\.\s*", "", text)


# =========================================================
# TOKENIZACION
# =========================================================

def strip_accents(text: str) -> str:
    text = unicodedata.normalize("NFD", text)
    return "".join(ch for ch in text if unicodedata.category(ch) != "Mn")


def normalize_text(text: str) -> str:
    return strip_accents(text.strip().lower())


def tokenize(text: str):
    text = normalize_text(text)

    for sign in [":", ","]:
        text = text.replace(sign, f" {sign} ")

    for sign in [".", ";", "¿", "?", "¡", "!", "(", ")", '"', "«", "»"]:
        text = text.replace(sign, " ")

    return [part for part in text.split() if part]


def atom_to_prolog(token: str) -> str:
    if token in [":", ","]:
        return f"'{token}'"

    if re.fullmatch(r"[a-z_][a-z0-9_]*", token):
        return token

    escaped = token.replace("'", "\\'")
    return f"'{escaped}'"


def tokens_to_prolog_list(tokens):
    return "[" + ",".join(atom_to_prolog(tok) for tok in tokens) + "]"


def prolog_atom_bool(value: bool) -> str:
    return "si" if value else "no"


# =========================================================
# LLAMADAS A PROLOG
# =========================================================

def run_prolog_goal(goal: str, timeout: int = 45):
    cmd = [
        SWIPL_CMD,
        "-q",
        "-s",
        BRIDGE_FILE,
        "-g",
        goal
    ]

    try:
        result = subprocess.run(
            cmd,
            cwd=BASE_DIR,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=timeout
        )
    except FileNotFoundError:
        return {
            "ok": False,
            "error": "No se ha encontrado SWI-Prolog. Revisa que 'swipl' este instalado y accesible desde terminal."
        }
    except subprocess.TimeoutExpired:
        return {
            "ok": False,
            "error": "La llamada a Prolog ha tardado demasiado y se ha cancelado. Puede haber demasiado backtracking o un bucle."
        }

    if result.returncode != 0:
        return {
            "ok": False,
            "error": "SWI-Prolog ha devuelto un error.",
            "stdout": result.stdout,
            "stderr": result.stderr,
            "returncode": result.returncode
        }

    return {
        "ok": True,
        "stdout": result.stdout,
        "stderr": result.stderr,
        "returncode": result.returncode
    }


def attach_process_data(parsed, result):
    parsed["stderr"] = result.get("stderr", "")
    parsed["returncode"] = result.get("returncode")
    parsed["ok"] = True
    return parsed


# =========================================================
# PARSER DE SALIDA DEL BRIDGE / GOALS SEMANTICOS
# =========================================================

def parse_bridge_output(output: str):
    data = {
        "estado": None,
        "id": None,
        "tokens": None,
        "tipo": None,
        "rasgos": None,
        "arbol": None,

        "funciones": None,
        "funciones_items": [],

        "descomposicion": "",

        "ambiguedad": None,
        "num_analisis": None,
        "arboles": None,
        "arboles_ascii": [],

        "estado_semantico": None,
        "clasificacion_semantica": None,
        "advertencias": None,
        "advertencias_items": [],
        "explicaciones": None,
        "explicaciones_items": [],
        "arbol_detector": None,

        "ascii": ""
    }

    ascii_lines = []
    descomp_lines = []
    explicacion_lines = []

    arboles_ascii = []
    ambig_index = None
    ambig_lines = []

    block = None

    for raw_line in output.splitlines():
        stripped = raw_line.strip()

        if stripped.startswith("ARBOL_AMBIGUEDAD_INICIO:"):
            block = "ambig_ascii"
            ambig_index = stripped.replace("ARBOL_AMBIGUEDAD_INICIO:", "", 1).strip()
            ambig_lines = []
            continue

        if stripped.startswith("ARBOL_AMBIGUEDAD_FIN:"):
            arboles_ascii.append({
                "indice": ambig_index,
                "ascii": "\n".join(ambig_lines)
            })
            block = None
            ambig_index = None
            ambig_lines = []
            continue

        if stripped == "DESCOMP_INICIO":
            block = "descomp"
            descomp_lines = []
            continue

        if stripped == "DESCOMP_FIN":
            block = None
            continue

        if stripped == "ASCII_INICIO":
            block = "ascii"
            ascii_lines = []
            continue

        if stripped == "ASCII_FIN":
            block = None
            continue

        if stripped == "EXPLICACIONES_INICIO":
            block = "explicaciones"
            explicacion_lines = []
            continue

        if stripped == "EXPLICACIONES_FIN":
            block = None
            continue

        if stripped == "FUNCIONES_INICIO":
            block = "funciones"
            continue

        if stripped == "FUNCIONES_FIN":
            block = None
            continue

        if block == "ambig_ascii":
            ambig_lines.append(raw_line)
            continue

        if block == "descomp":
            descomp_lines.append(raw_line)
            continue

        if block == "ascii":
            ascii_lines.append(raw_line)
            continue

        if block == "explicaciones":
            if stripped:
                explicacion_lines.append(stripped)
            continue

        if block == "funciones":
            if stripped:
                data["funciones_items"].append(stripped)
            continue

        if raw_line.startswith("ESTADO:"):
            data["estado"] = raw_line.replace("ESTADO:", "", 1).strip()

        elif raw_line.startswith("ID:"):
            data["id"] = raw_line.replace("ID:", "", 1).strip()

        elif raw_line.startswith("TOKENS:"):
            data["tokens"] = raw_line.replace("TOKENS:", "", 1).strip()

        elif raw_line.startswith("TIPO:"):
            data["tipo"] = raw_line.replace("TIPO:", "", 1).strip()

        elif raw_line.startswith("RASGOS:"):
            data["rasgos"] = raw_line.replace("RASGOS:", "", 1).strip()

        elif raw_line.startswith("ARBOL:"):
            data["arbol"] = raw_line.replace("ARBOL:", "", 1).strip()

        elif raw_line.startswith("FUNCIONES:"):
            data["funciones"] = raw_line.replace("FUNCIONES:", "", 1).strip()

        elif raw_line.startswith("AMBIGUEDAD:"):
            data["ambiguedad"] = raw_line.replace("AMBIGUEDAD:", "", 1).strip()

        elif raw_line.startswith("NUM_ANALISIS:"):
            data["num_analisis"] = raw_line.replace("NUM_ANALISIS:", "", 1).strip()

        elif raw_line.startswith("ARBOLES:"):
            data["arboles"] = raw_line.replace("ARBOLES:", "", 1).strip()

        elif raw_line.startswith("ESTADO_SEMANTICO:"):
            data["estado_semantico"] = raw_line.replace("ESTADO_SEMANTICO:", "", 1).strip()

        elif raw_line.startswith("CLASIFICACION_SEMANTICA:"):
            data["clasificacion_semantica"] = raw_line.replace("CLASIFICACION_SEMANTICA:", "", 1).strip()

        elif raw_line.startswith("ADVERTENCIAS:"):
            data["advertencias"] = raw_line.replace("ADVERTENCIAS:", "", 1).strip()

        elif raw_line.startswith("ADVERTENCIA:"):
            data["advertencias_items"].append(
                raw_line.replace("ADVERTENCIA:", "", 1).strip()
            )

        elif raw_line.startswith("EXPLICACIONES:"):
            data["explicaciones"] = raw_line.replace("EXPLICACIONES:", "", 1).strip()

        elif raw_line.startswith("EXPLICACION:"):
            data["explicaciones_items"].append(
                raw_line.replace("EXPLICACION:", "", 1).strip()
            )

        elif raw_line.startswith("ARBOL_ANALIZADO:"):
            data["arbol_detector"] = raw_line.replace("ARBOL_ANALIZADO:", "", 1).strip()

        elif raw_line.startswith("ARBOL_DETECCION:"):
            data["arbol_detector"] = raw_line.replace("ARBOL_DETECCION:", "", 1).strip()

        elif raw_line.startswith("ARBOL_DETECTOR:"):
            data["arbol_detector"] = raw_line.replace("ARBOL_DETECTOR:", "", 1).strip()

        elif raw_line.startswith("ARBOL_SEMANTICO:"):
            data["arbol_detector"] = raw_line.replace("ARBOL_SEMANTICO:", "", 1).strip()

    data["ascii"] = "\n".join(ascii_lines)
    data["descomposicion"] = "\n".join(descomp_lines)
    data["arboles_ascii"] = arboles_ascii

    if explicacion_lines:
        data["explicaciones_items"] = explicacion_lines

    return data


# =========================================================
# LLAMADAS SINTACTICAS
# =========================================================

def analyze_corpus_id(sentence_id: int, draw_tree: bool = False):
    draw_atom = prolog_atom_bool(draw_tree)
    result = run_prolog_goal(f"analizar_id_terminal({sentence_id},{draw_atom}),halt")

    if not result["ok"]:
        return result

    return attach_process_data(parse_bridge_output(result["stdout"]), result)


def analyze_manual_text(text: str, draw_tree: bool = False):
    tokens = tokenize(text)
    prolog_tokens = tokens_to_prolog_list(tokens)
    draw_atom = prolog_atom_bool(draw_tree)

    result = run_prolog_goal(f"analizar_tokens_terminal({prolog_tokens},{draw_atom}),halt")

    if not result["ok"]:
        return result

    parsed = attach_process_data(parse_bridge_output(result["stdout"]), result)
    parsed["python_tokens"] = tokens
    return parsed


# =========================================================
# LLAMADAS DE FUNCIONES SINTACTICAS
# =========================================================

def analyze_functions_corpus_id(sentence_id: int):
    result = run_prolog_goal(f"analizar_funciones_id_terminal({sentence_id}),halt")

    if not result["ok"]:
        return result

    return attach_process_data(parse_bridge_output(result["stdout"]), result)


def analyze_functions_manual_text(text: str):
    tokens = tokenize(text)
    prolog_tokens = tokens_to_prolog_list(tokens)

    result = run_prolog_goal(f"analizar_funciones_tokens_terminal({prolog_tokens}),halt")

    if not result["ok"]:
        return result

    parsed = attach_process_data(parse_bridge_output(result["stdout"]), result)
    parsed["python_tokens"] = tokens
    return parsed


# =========================================================
# LLAMADAS DE AMBIGUEDAD SINTACTICA
# =========================================================

def analyze_ambiguity_corpus_id(sentence_id: int):
    result = run_prolog_goal(f"analizar_ambiguedad_id_terminal({sentence_id}),halt")

    if not result["ok"]:
        return result

    return attach_process_data(parse_bridge_output(result["stdout"]), result)


def analyze_ambiguity_manual_text(text: str):
    tokens = tokenize(text)
    prolog_tokens = tokens_to_prolog_list(tokens)

    result = run_prolog_goal(f"analizar_ambiguedad_tokens_terminal({prolog_tokens}),halt")

    if not result["ok"]:
        return result

    parsed = attach_process_data(parse_bridge_output(result["stdout"]), result)
    parsed["python_tokens"] = tokens
    return parsed


# =========================================================
# LLAMADAS SEMANTICAS
# =========================================================

def semantic_id_goal(sentence_id: int):
    return (
        "ensure_loaded('deteccion.pl'),"
        "("
            f"oracion({sentence_id},Tokens)"
        "->"
            "("
                f"analizar_semantico_id_detallado({sentence_id},EstadoSem,Clas,Advs,Exps,Arbol),"
                "write('ESTADO:OK'),nl,"
                f"write('ID:'),write({sentence_id}),nl,"
                "write('TOKENS:'),write(Tokens),nl,"
                "write('ESTADO_SEMANTICO:'),write(EstadoSem),nl,"
                "write('CLASIFICACION_SEMANTICA:'),write(Clas),nl,"
                "write('ADVERTENCIAS:'),write(Advs),nl,"
                "forall(member(A,Advs),(write('ADVERTENCIA:'),write(A),nl)),"
                "write('EXPLICACIONES:'),write(Exps),nl,"
                "forall(member(E,Exps),(write('EXPLICACION:'),write(E),nl)),"
                "write('ARBOL_ANALIZADO:'),write(Arbol),nl"
            ")"
        ";"
            "("
                "write('ESTADO:ID_NO_EXISTE'),nl,"
                f"write('ID:'),write({sentence_id}),nl,"
                "write('ESTADO_SEMANTICO:fallo_id'),nl,"
                "write('CLASIFICACION_SEMANTICA:no_reconocida'),nl,"
                "write('ADVERTENCIAS:[]'),nl,"
                "write('EXPLICACIONES:[No existe una oracion con ese identificador.]'),nl,"
                "write('EXPLICACION:No existe una oracion con ese identificador.'),nl,"
                "write('ARBOL_ANALIZADO:none'),nl"
            ")"
        ")"
    )


def semantic_tokens_goal(prolog_tokens: str):
    return (
        "ensure_loaded('deteccion.pl'),"
        f"analizar_semantico_tokens_detallado({prolog_tokens},EstadoSem,Clas,Advs,Exps,Arbol),"
        "write('ESTADO:OK'),nl,"
        f"write('TOKENS:'),write({prolog_tokens}),nl,"
        "write('ESTADO_SEMANTICO:'),write(EstadoSem),nl,"
        "write('CLASIFICACION_SEMANTICA:'),write(Clas),nl,"
        "write('ADVERTENCIAS:'),write(Advs),nl,"
        "forall(member(A,Advs),(write('ADVERTENCIA:'),write(A),nl)),"
        "write('EXPLICACIONES:'),write(Exps),nl,"
        "forall(member(E,Exps),(write('EXPLICACION:'),write(E),nl)),"
        "write('ARBOL_ANALIZADO:'),write(Arbol),nl"
    )


def analyze_semantic_corpus_id(sentence_id: int):
    result = run_prolog_goal(semantic_id_goal(sentence_id) + ",halt")

    if not result["ok"]:
        return result

    return attach_process_data(parse_bridge_output(result["stdout"]), result)


def analyze_semantic_manual_text(text: str):
    tokens = tokenize(text)
    prolog_tokens = tokens_to_prolog_list(tokens)

    result = run_prolog_goal(semantic_tokens_goal(prolog_tokens) + ",halt")

    if not result["ok"]:
        return result

    parsed = attach_process_data(parse_bridge_output(result["stdout"]), result)
    parsed["python_tokens"] = tokens
    return parsed


# =========================================================
# CORPUS
# =========================================================

def get_corpus_text(sentence_id: int):
    for idx, text in CORPUS:
        if idx == sentence_id:
            return text
    return None


def show_corpus():
    print_header("ORACIONES DEL CORPUS")
    for idx, text in CORPUS:
        print(f"{idx:>2}. {text}")
    pause()


# =========================================================
# PRESENTACION GENERAL
# =========================================================

def print_menu():
    print_header("MENU PRINCIPAL")
    print("1.  Ver oraciones del corpus")
    print("2.  Analizar sintacticamente una oracion del corpus por ID")
    print("3.  Dibujar arbol sintactico de una oracion del corpus por ID")
    print("4.  Probar sintacticamente todo el corpus sin arboles")
    print("5.  Dibujar arboles sintacticos de todo el corpus")
    print("6.  Analizar sintacticamente una frase escrita a mano")
    print("7.  Dibujar arbol sintactico de una frase escrita a mano")
    print("8.  Detectar ambiguedad sintactica de una oracion por ID")
    print("9.  Detectar ambiguedad sintactica de todo el corpus")
    print("10. Detectar ambiguedad sintactica de una frase escrita a mano")
    print("11. Analizar semanticamente una oracion del corpus por ID")
    print("12. Analizar semanticamente todo el corpus")
    print("13. Analizar semanticamente una frase escrita a mano")
    print("14. Analisis completo por ID")
    print("15. Analizar funciones sintacticas de una oracion del corpus por ID")
    print("16. Analizar funciones sintacticas de una frase escrita a mano")
    print("0.  Salir")
    print(line())


def ask_sentence_id(title):
    print_header(title)
    raw = input("Introduce el ID de la oracion: ").strip()

    if not raw.isdigit():
        print("\nID no valido.")
        pause()
        return None

    return int(raw)


def ask_manual_sentence(title):
    print_header(title)
    text = input("Escribe la frase: ").strip()

    if not text:
        print("\nNo has escrito ninguna frase.")
        pause()
        return None

    return text


def show_error_result(result):
    print("\nERROR:")
    print(result.get("error", "Error desconocido."))

    stdout = result.get("stdout", "").strip()
    stderr = result.get("stderr", "").strip()

    if stdout:
        print("\nSTDOUT:")
        print(stdout)

    if stderr:
        print("\nSTDERR:")
        print(stderr)


def maybe_show_stderr(result):
    stderr = result.get("stderr", "").strip()
    if SHOW_PROLOG_WARNINGS and stderr:
        print("\nSTDERR:")
        print(stderr)


# =========================================================
# PRESENTACION SINTACTICA
# =========================================================

def show_analysis_result(result, original_text=None, show_ascii=False):
    print(line())

    if original_text:
        print("FRASE:")
        print(original_text)
        print(line())

    estado = result.get("estado", "DESCONOCIDO")
    print(f"ESTADO: {estado}")

    if "python_tokens" in result:
        print("\nTOKENS GENERADOS EN PYTHON:")
        print(result["python_tokens"])

    if result.get("tokens"):
        print("\nTOKENS EN PROLOG:")
        print(result["tokens"])

    if result.get("tipo"):
        print("\nTIPO PRINCIPAL:")
        print(result["tipo"])

    if result.get("rasgos"):
        print("\nRASGOS:")
        print(result["rasgos"])

    if result.get("descomposicion"):
        print("\nDESCOMPOSICION SINTACTICA:")
        print(result["descomposicion"])

    if estado == "OK":
        print("\nARBOL PROLOG:")
        print(result.get("arbol", ""))

        if show_ascii:
            print("\nARBOL ASCII:")
            ascii_tree = result.get("ascii", "")
            print(ascii_tree if ascii_tree else "(sin arbol ASCII recibido)")

    elif estado == "FALLO":
        print("\nLa frase no ha sido reconocida por la gramatica actual.")

    elif estado == "ID_NO_EXISTE":
        print("\nEse ID no existe en el corpus.")

    maybe_show_stderr(result)
    print(line())


# =========================================================
# PRESENTACION DE FUNCIONES SINTACTICAS
# =========================================================

def show_functions_result(result, original_text=None):
    print(line())

    if original_text:
        print("FRASE:")
        print(original_text)
        print(line())

    estado = result.get("estado", "DESCONOCIDO")
    print(f"ESTADO: {estado}")

    if "python_tokens" in result:
        print("\nTOKENS GENERADOS EN PYTHON:")
        print(result["python_tokens"])

    if result.get("tokens"):
        print("\nTOKENS EN PROLOG:")
        print(result["tokens"])

    if estado == "OK":
        print("\nARBOL PROLOG:")
        print(result.get("arbol", ""))

        funciones_items = result.get("funciones_items", [])

        print("\nFUNCIONES SINTACTICAS:")

        if funciones_items:
            for item in funciones_items:
                print("- " + item)
        else:
            print(result.get("funciones", "[]"))

    elif estado == "FALLO":
        print("\nLa frase no ha sido reconocida por la gramatica actual.")

    elif estado == "ID_NO_EXISTE":
        print("\nEse ID no existe en el corpus.")

    maybe_show_stderr(result)
    print(line())


# =========================================================
# PRESENTACION DE AMBIGUEDAD SINTACTICA
# =========================================================

def show_ambiguity_result(result, original_text=None, show_arboles=True):
    print(line())

    if original_text:
        print("FRASE:")
        print(original_text)
        print(line())

    estado = result.get("estado", "DESCONOCIDO")
    print(f"ESTADO: {estado}")

    if "python_tokens" in result:
        print("\nTOKENS GENERADOS EN PYTHON:")
        print(result["python_tokens"])

    if result.get("tokens"):
        print("\nTOKENS EN PROLOG:")
        print(result["tokens"])

    if result.get("ambiguedad"):
        print("\nAMBIGUEDAD:")
        print(result["ambiguedad"])

    if result.get("num_analisis"):
        print("\nNUMERO DE ANALISIS ENCONTRADOS:")
        print(result["num_analisis"])

    arboles_ascii = result.get("arboles_ascii", [])

    if show_arboles and arboles_ascii:
        print("\nARBOLES ASCII ENCONTRADOS:")
        for item in arboles_ascii:
            print("\n" + line("─"))
            print(f"ARBOL {item['indice']}")
            print(line("─"))
            print(item["ascii"])

    elif show_arboles and result.get("arboles"):
        print("\nARBOLES PROLOG ENCONTRADOS:")
        print(result["arboles"])

    maybe_show_stderr(result)
    print(line())


# =========================================================
# PRESENTACION SEMANTICA
# =========================================================

def semantic_status_message(result):
    clas = result.get("clasificacion_semantica")
    estado_sem = result.get("estado_semantico")

    if estado_sem == "fallo_sintactico" or clas == "no_reconocida":
        return "La frase no se ha podido interpretar semanticamente porque antes ha fallado el analisis sintactico."

    if clas == "correcta":
        return "La oracion es sintacticamente valida y no se han detectado advertencias semanticas relevantes."

    if clas == "ambigua":
        return "La oracion es sintacticamente valida, pero contiene una palabra o relacion que admite mas de una lectura semantica dentro del dominio musical."

    if clas == "problematica":
        return "La oracion es sintacticamente valida, pero contiene una posible incoherencia semantica o un uso no literal."

    return "No se ha podido determinar una interpretacion semantica clara."


def semantic_detail_for_table(result):
    explicaciones = result.get("explicaciones_items", [])

    if explicaciones:
        return clean_numbered_explanation(explicaciones[0])

    clas = result.get("clasificacion_semantica")

    if clas == "correcta":
        return "Sin advertencias semanticas."

    if clas == "no_reconocida":
        return "No reconocida por la gramatica sintactica."

    raw = result.get("advertencias")
    if raw and raw != "[]":
        return raw

    return ""


def should_print_explanations(result):
    clas = result.get("clasificacion_semantica")
    explicaciones = result.get("explicaciones_items", [])

    if not explicaciones:
        return False

    if clas == "correcta":
        return False

    return True


def show_semantic_result(result, original_text=None, show_tree=SHOW_SEMANTIC_TREE):
    print(line())

    if original_text:
        print("FRASE:")
        print(original_text)
        print(line())

    estado = result.get("estado", "DESCONOCIDO")
    print(f"ESTADO: {estado}")

    if "python_tokens" in result:
        print("\nTOKENS GENERADOS EN PYTHON:")
        print(result["python_tokens"])

    if result.get("tokens"):
        print("\nTOKENS EN PROLOG:")
        print(result["tokens"])

    if result.get("estado_semantico"):
        print("\nESTADO SEMANTICO:")
        print(result["estado_semantico"])

    if result.get("clasificacion_semantica"):
        print("\nCLASIFICACION SEMANTICA:")
        print(result["clasificacion_semantica"])

    print("\nINTERPRETACION:")
    print(wrap_text(semantic_status_message(result)))

    explicaciones = result.get("explicaciones_items", [])

    if should_print_explanations(result):
        print("\nEXPLICACIONES:")
        for exp in explicaciones:
            exp = clean_numbered_explanation(exp)
            print(wrap_text(f"- {exp}"))

    if SHOW_INTERNAL_WARNINGS:
        raw_advs = result.get("advertencias")
        adv_items = result.get("advertencias_items", [])

        if adv_items:
            print("\nADVERTENCIAS INTERNAS:")
            for adv in adv_items:
                print(wrap_text(f"- {adv}"))
        elif raw_advs:
            print("\nADVERTENCIAS INTERNAS:")
            print(wrap_text(raw_advs))

    if show_tree:
        print("\nARBOL ANALIZADO POR EL DETECTOR:")
        print(result.get("arbol_detector", ""))

    maybe_show_stderr(result)
    print(line())


# =========================================================
# ACCIONES SINTACTICAS
# =========================================================

def analyze_corpus_sentence(draw_tree=False):
    title = "DIBUJAR ARBOL SINTACTICO POR ID" if draw_tree else "ANALISIS SINTACTICO POR ID"
    sentence_id = ask_sentence_id(title)

    if sentence_id is None:
        return

    result = analyze_corpus_id(sentence_id, draw_tree=draw_tree)

    if not result["ok"]:
        show_error_result(result)
        pause()
        return

    show_analysis_result(
        result,
        original_text=get_corpus_text(sentence_id),
        show_ascii=draw_tree
    )
    pause()


def analyze_manual_sentence(draw_tree=False):
    title = "DIBUJAR ARBOL SINTACTICO DE FRASE MANUAL" if draw_tree else "ANALISIS SINTACTICO DE FRASE MANUAL"
    text = ask_manual_sentence(title)

    if text is None:
        return

    result = analyze_manual_text(text, draw_tree=draw_tree)

    if not result["ok"]:
        show_error_result(result)
        pause()
        return

    show_analysis_result(result, original_text=text, show_ascii=draw_tree)
    pause()


def test_all_corpus():
    print_header("PRUEBA SINTACTICA COMPLETA DEL CORPUS")

    oks = []
    fails = []

    for sentence_id, text in CORPUS:
        result = analyze_corpus_id(sentence_id, draw_tree=False)

        if not result["ok"]:
            fails.append((sentence_id, text, "ERROR_SWIPL"))
            print(f"ERROR -> {sentence_id:>2} | {text}")
            print("         ", result.get("error", "Error desconocido."))
            continue

        estado = result.get("estado", "DESCONOCIDO")

        if estado == "OK":
            tipo = result.get("tipo", "")
            rasgos = compact(result.get("rasgos", ""), 45)
            oks.append((sentence_id, text, tipo, rasgos))
            print(f"OK    -> {sentence_id:>2} | {tipo:<22} | {rasgos:<45} | {text}")
        else:
            fails.append((sentence_id, text, estado))
            print(f"FALLO -> {sentence_id:>2} | {estado:<22} | {text}")

    print("\n" + line())
    print(f"TOTAL OK: {len(oks)}")
    print(f"TOTAL FALLO: {len(fails)}")

    if fails:
        print("\nDETALLE DE FALLOS:")
        for sentence_id, text, motivo in fails:
            print(f"- {sentence_id}: {motivo} | {text}")

    pause()


def draw_all_corpus():
    print_header("DIBUJAR ARBOLES SINTACTICOS DE TODO EL CORPUS")

    print("Se mostrara un arbol por oracion.")
    print("Las oraciones no reconocidas apareceran como FALLO.")
    pause()

    for sentence_id, text in CORPUS:
        print_header(f"ARBOL SINTACTICO DE ORACION {sentence_id}")

        result = analyze_corpus_id(sentence_id, draw_tree=True)

        if not result["ok"]:
            show_error_result(result)
            pause()
            continue

        show_analysis_result(result, original_text=text, show_ascii=True)
        pause()


# =========================================================
# ACCIONES DE FUNCIONES SINTACTICAS
# =========================================================

def analyze_functions_corpus_sentence():
    sentence_id = ask_sentence_id("FUNCIONES SINTACTICAS POR ID")

    if sentence_id is None:
        return

    result = analyze_functions_corpus_id(sentence_id)

    if not result["ok"]:
        show_error_result(result)
        pause()
        return

    show_functions_result(
        result,
        original_text=get_corpus_text(sentence_id)
    )
    pause()


def analyze_functions_manual_sentence():
    text = ask_manual_sentence("FUNCIONES SINTACTICAS DE FRASE MANUAL")

    if text is None:
        return

    result = analyze_functions_manual_text(text)

    if not result["ok"]:
        show_error_result(result)
        pause()
        return

    show_functions_result(result, original_text=text)
    pause()


# =========================================================
# ACCIONES DE AMBIGUEDAD SINTACTICA
# =========================================================

def analyze_ambiguity_corpus_sentence():
    sentence_id = ask_sentence_id("DETECTAR AMBIGUEDAD SINTACTICA POR ID")

    if sentence_id is None:
        return

    result = analyze_ambiguity_corpus_id(sentence_id)

    if not result["ok"]:
        show_error_result(result)
        pause()
        return

    show_ambiguity_result(
        result,
        original_text=get_corpus_text(sentence_id),
        show_arboles=True
    )
    pause()


def analyze_ambiguity_manual_sentence():
    text = ask_manual_sentence("DETECTAR AMBIGUEDAD SINTACTICA DE FRASE MANUAL")

    if text is None:
        return

    result = analyze_ambiguity_manual_text(text)

    if not result["ok"]:
        show_error_result(result)
        pause()
        return

    show_ambiguity_result(result, original_text=text, show_arboles=True)
    pause()


def test_all_ambiguity():
    print_header("AMBIGUEDAD SINTACTICA EN TODO EL CORPUS")

    resumen = {
        "no_ambigua": 0,
        "ambigua": 0,
        "no_reconocida": 0,
        "otros": 0
    }

    for sentence_id, text in CORPUS:
        result = analyze_ambiguity_corpus_id(sentence_id)

        if not result["ok"]:
            resumen["otros"] += 1
            print(f"ERROR -> {sentence_id:>2} | {text}")
            print("         ", result.get("error", "Error desconocido."))
            continue

        amb = result.get("ambiguedad", "desconocida")
        num = result.get("num_analisis", "?")

        if amb in resumen:
            resumen[amb] += 1
        else:
            resumen["otros"] += 1

        print(f"{amb.upper():<15} -> {sentence_id:>2} | analisis={num:<3} | {text}")

    print("\n" + line())
    print("RESUMEN:")
    print(f"No ambiguas    : {resumen['no_ambigua']}")
    print(f"Ambiguas       : {resumen['ambigua']}")
    print(f"No reconocidas : {resumen['no_reconocida']}")
    print(f"Otros/errores  : {resumen['otros']}")

    pause()


# =========================================================
# ACCIONES SEMANTICAS
# =========================================================

def analyze_semantic_corpus_sentence():
    sentence_id = ask_sentence_id("ANALISIS SEMANTICO POR ID")

    if sentence_id is None:
        return

    result = analyze_semantic_corpus_id(sentence_id)

    if not result["ok"]:
        show_error_result(result)
        pause()
        return

    show_semantic_result(
        result,
        original_text=get_corpus_text(sentence_id),
        show_tree=SHOW_SEMANTIC_TREE
    )
    pause()


def analyze_semantic_manual_sentence():
    text = ask_manual_sentence("ANALISIS SEMANTICO DE FRASE MANUAL")

    if text is None:
        return

    result = analyze_semantic_manual_text(text)

    if not result["ok"]:
        show_error_result(result)
        pause()
        return

    show_semantic_result(result, original_text=text, show_tree=SHOW_SEMANTIC_TREE)
    pause()


def test_all_semantic():
    print_header("ANALISIS SEMANTICO DE TODO EL CORPUS")

    resumen = {
        "correcta": 0,
        "ambigua": 0,
        "problematica": 0,
        "no_reconocida": 0,
        "otros": 0
    }

    for sentence_id, text in CORPUS:
        result = analyze_semantic_corpus_id(sentence_id)

        if not result["ok"]:
            resumen["otros"] += 1
            print(f"ERROR -> {sentence_id:>2} | {text}")
            print("         ", result.get("error", "Error desconocido."))
            continue

        clas = result.get("clasificacion_semantica", "desconocida")

        if clas in resumen:
            resumen[clas] += 1
        else:
            resumen["otros"] += 1

        detalle = compact(semantic_detail_for_table(result), 90)
        print(f"{clas.upper():<15} -> {sentence_id:>2} | {detalle:<92} | {text}")

    print("\n" + line())
    print("RESUMEN:")
    print(f"Correctas      : {resumen['correcta']}")
    print(f"Ambiguas       : {resumen['ambigua']}")
    print(f"Problematicas  : {resumen['problematica']}")
    print(f"No reconocidas : {resumen['no_reconocida']}")
    print(f"Otros/errores  : {resumen['otros']}")

    pause()


# =========================================================
# ANALISIS COMPLETO
# =========================================================

def complete_analysis_by_id():
    sentence_id = ask_sentence_id("ANALISIS COMPLETO POR ID")

    if sentence_id is None:
        return

    original_text = get_corpus_text(sentence_id)

    print(line())
    if original_text:
        print("FRASE:")
        print(original_text)
        print(line())

    syntactic = analyze_corpus_id(sentence_id, draw_tree=True)
    ambiguity = analyze_ambiguity_corpus_id(sentence_id)
    semantic = analyze_semantic_corpus_id(sentence_id)
    functions = analyze_functions_corpus_id(sentence_id)

    print_section("[1] ANALISIS SINTACTICO")
    if syntactic["ok"]:
        show_analysis_result(syntactic, original_text=None, show_ascii=True)
    else:
        show_error_result(syntactic)

    print_section("[2] AMBIGUEDAD SINTACTICA")
    if ambiguity["ok"]:
        show_ambiguity_result(ambiguity, original_text=None, show_arboles=False)
    else:
        show_error_result(ambiguity)

    print_section("[3] ANALISIS SEMANTICO Y DETECCION")
    if semantic["ok"]:
        show_semantic_result(semantic, original_text=None, show_tree=False)
    else:
        show_error_result(semantic)

    print_section("[4] FUNCIONES SINTACTICAS")
    if functions["ok"]:
        show_functions_result(functions, original_text=None)
    else:
        show_error_result(functions)

    pause()


# =========================================================
# MAIN
# =========================================================

def main():
    actions = {
        "1": show_corpus,
        "2": lambda: analyze_corpus_sentence(draw_tree=False),
        "3": lambda: analyze_corpus_sentence(draw_tree=True),
        "4": test_all_corpus,
        "5": draw_all_corpus,
        "6": lambda: analyze_manual_sentence(draw_tree=False),
        "7": lambda: analyze_manual_sentence(draw_tree=True),
        "8": analyze_ambiguity_corpus_sentence,
        "9": test_all_ambiguity,
        "10": analyze_ambiguity_manual_sentence,
        "11": analyze_semantic_corpus_sentence,
        "12": test_all_semantic,
        "13": analyze_semantic_manual_sentence,
        "14": complete_analysis_by_id,
        "15": analyze_functions_corpus_sentence,
        "16": analyze_functions_manual_sentence,
    }

    while True:
        print_menu()
        option = input("Elige una opcion: ").strip()

        if option == "0":
            print("\nSaliendo...")
            break

        action = actions.get(option)

        if action is None:
            print("\nOpcion no valida.")
            pause()
        else:
            action()


if __name__ == "__main__":
    main()