import os
import re
import subprocess
import unicodedata
from shutil import get_terminal_size

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

SWIPL_CMD = "swipl"
BRIDGE_FILE = os.path.join(BASE_DIR, "cli_bridge.pl")


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
    return get_terminal_size((120, 30)).columns


def line(char="─"):
    return char * terminal_width()


def center(text):
    return text.center(terminal_width())


def pause():
    input("\nPulsa ENTER para continuar...")


def print_header(title: str):
    clear_screen()
    print(line("═"))
    print(center("ANALIZADOR SINTACTICO EN TERMINAL"))
    print(center(title))
    print(line("═"))


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

    return [p for p in text.split() if p]


def atom_to_prolog(token: str) -> str:
    if token in [":", ","]:
        return f"'{token}'"

    if re.fullmatch(r"[a-z_][a-z0-9_]*", token):
        return token

    escaped = token.replace("'", "\\'")
    return f"'{escaped}'"


def tokens_to_prolog_list(tokens):
    return "[" + ",".join(atom_to_prolog(tok) for tok in tokens) + "]"


# =========================================================
# LLAMADAS A PROLOG
# =========================================================

def prolog_atom_bool(value: bool) -> str:
    return "si" if value else "no"


def run_prolog_goal(goal: str, timeout: int = 30):
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


def parse_bridge_output(output: str):
    lines = output.splitlines()

    estado = None
    id_line = None
    tokens = None
    tipo = None
    rasgos = None
    arbol = None
    ambiguedad = None
    num_analisis = None
    arboles = None

    ascii_lines = []
    in_ascii = False

    descomp_lines = []
    in_descomp = False

    arboles_ascii = []
    in_ambig_ascii = False
    ambig_index = None
    ambig_lines = []

    for line_text in lines:
        stripped = line_text.strip()

        # -------------------------------------------------
        # Bloque de arboles ASCII de ambiguedad
        # -------------------------------------------------

        if stripped.startswith("ARBOL_AMBIGUEDAD_INICIO:"):
            in_ambig_ascii = True
            ambig_index = stripped.replace("ARBOL_AMBIGUEDAD_INICIO:", "", 1).strip()
            ambig_lines = []
            continue

        if stripped.startswith("ARBOL_AMBIGUEDAD_FIN:"):
            arboles_ascii.append({
                "indice": ambig_index,
                "ascii": "\n".join(ambig_lines)
            })
            in_ambig_ascii = False
            ambig_index = None
            ambig_lines = []
            continue

        if in_ambig_ascii:
            ambig_lines.append(line_text)
            continue

        # -------------------------------------------------
        # Bloque de descomposicion sintactica
        # -------------------------------------------------

        if stripped == "DESCOMP_INICIO":
            in_descomp = True
            descomp_lines = []
            continue

        if stripped == "DESCOMP_FIN":
            in_descomp = False
            continue

        if in_descomp:
            descomp_lines.append(line_text)
            continue

        # -------------------------------------------------
        # Bloque de arbol ASCII normal
        # -------------------------------------------------

        if stripped == "ASCII_INICIO":
            in_ascii = True
            ascii_lines = []
            continue

        if stripped == "ASCII_FIN":
            in_ascii = False
            continue

        if in_ascii:
            ascii_lines.append(line_text)
            continue

        # -------------------------------------------------
        # Campos normales del bridge
        # -------------------------------------------------

        if line_text.startswith("ESTADO:"):
            estado = line_text.replace("ESTADO:", "", 1).strip()
        elif line_text.startswith("ID:"):
            id_line = line_text.replace("ID:", "", 1).strip()
        elif line_text.startswith("TOKENS:"):
            tokens = line_text.replace("TOKENS:", "", 1).strip()
        elif line_text.startswith("TIPO:"):
            tipo = line_text.replace("TIPO:", "", 1).strip()
        elif line_text.startswith("RASGOS:"):
            rasgos = line_text.replace("RASGOS:", "", 1).strip()
        elif line_text.startswith("ARBOL:"):
            arbol = line_text.replace("ARBOL:", "", 1).strip()
        elif line_text.startswith("AMBIGUEDAD:"):
            ambiguedad = line_text.replace("AMBIGUEDAD:", "", 1).strip()
        elif line_text.startswith("NUM_ANALISIS:"):
            num_analisis = line_text.replace("NUM_ANALISIS:", "", 1).strip()
        elif line_text.startswith("ARBOLES:"):
            arboles = line_text.replace("ARBOLES:", "", 1).strip()

    return {
        "estado": estado,
        "id": id_line,
        "tokens": tokens,
        "tipo": tipo,
        "rasgos": rasgos,
        "arbol": arbol,
        "descomposicion": "\n".join(descomp_lines),
        "ambiguedad": ambiguedad,
        "num_analisis": num_analisis,
        "arboles": arboles,
        "arboles_ascii": arboles_ascii,
        "ascii": "\n".join(ascii_lines)
    }


def analyze_corpus_id(sentence_id: int, draw_tree: bool = False):
    draw_atom = prolog_atom_bool(draw_tree)
    result = run_prolog_goal(f"analizar_id_terminal({sentence_id},{draw_atom}),halt")

    if not result["ok"]:
        return result

    parsed = parse_bridge_output(result["stdout"])
    parsed["stderr"] = result["stderr"]
    parsed["returncode"] = result["returncode"]
    parsed["ok"] = True
    return parsed


def analyze_manual_text(text: str, draw_tree: bool = False):
    tokens = tokenize(text)
    prolog_tokens = tokens_to_prolog_list(tokens)
    draw_atom = prolog_atom_bool(draw_tree)

    result = run_prolog_goal(f"analizar_tokens_terminal({prolog_tokens},{draw_atom}),halt")

    if not result["ok"]:
        return result

    parsed = parse_bridge_output(result["stdout"])
    parsed["stderr"] = result["stderr"]
    parsed["returncode"] = result["returncode"]
    parsed["ok"] = True
    parsed["python_tokens"] = tokens
    return parsed


def analyze_ambiguity_corpus_id(sentence_id: int):
    result = run_prolog_goal(f"analizar_ambiguedad_id_terminal({sentence_id}),halt")

    if not result["ok"]:
        return result

    parsed = parse_bridge_output(result["stdout"])
    parsed["stderr"] = result["stderr"]
    parsed["returncode"] = result["returncode"]
    parsed["ok"] = True
    return parsed


def analyze_ambiguity_manual_text(text: str):
    tokens = tokenize(text)
    prolog_tokens = tokens_to_prolog_list(tokens)

    result = run_prolog_goal(f"analizar_ambiguedad_tokens_terminal({prolog_tokens}),halt")

    if not result["ok"]:
        return result

    parsed = parse_bridge_output(result["stdout"])
    parsed["stderr"] = result["stderr"]
    parsed["returncode"] = result["returncode"]
    parsed["ok"] = True
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
# PRESENTACION
# =========================================================

def print_menu():
    print_header("MENU PRINCIPAL")
    print("1. Ver oraciones del corpus")
    print("2. Analizar una oracion del corpus por ID")
    print("3. Dibujar arbol de una oracion del corpus por ID")
    print("4. Probar todo el corpus sin arboles")
    print("5. Dibujar arboles de todo el corpus")
    print("6. Analizar una frase escrita a mano")
    print("7. Dibujar arbol de una frase escrita a mano")
    print("8. Detectar ambiguedad de una oracion por ID")
    print("9. Detectar ambiguedad de todo el corpus")
    print("10. Detectar ambiguedad de una frase escrita a mano")
    print("0. Salir")
    print(line())


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

    stderr = result.get("stderr", "").strip()
    if stderr:
        print("\nSTDERR:")
        print(stderr)

    print(line())


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

    stderr = result.get("stderr", "").strip()
    if stderr:
        print("\nSTDERR:")
        print(stderr)

    print(line())


def analyze_corpus_sentence(draw_tree=False):
    title = "DIBUJAR ARBOL DE ORACION DEL CORPUS" if draw_tree else "ANALIZAR ORACION DEL CORPUS"
    print_header(title)

    raw = input("Introduce el ID de la oracion: ").strip()

    if not raw.isdigit():
        print("\nID no valido.")
        pause()
        return

    sentence_id = int(raw)
    original_text = get_corpus_text(sentence_id)

    result = analyze_corpus_id(sentence_id, draw_tree=draw_tree)

    if not result["ok"]:
        show_error_result(result)
        pause()
        return

    show_analysis_result(result, original_text=original_text, show_ascii=draw_tree)
    pause()


def analyze_manual_sentence(draw_tree=False):
    title = "DIBUJAR ARBOL DE FRASE MANUAL" if draw_tree else "ANALIZAR FRASE MANUAL"
    print_header(title)

    text = input("Escribe la frase: ").strip()

    if not text:
        print("\nNo has escrito ninguna frase.")
        pause()
        return

    result = analyze_manual_text(text, draw_tree=draw_tree)

    if not result["ok"]:
        show_error_result(result)
        pause()
        return

    show_analysis_result(result, original_text=text, show_ascii=draw_tree)
    pause()


def analyze_ambiguity_corpus_sentence():
    print_header("DETECTAR AMBIGUEDAD POR ID")

    raw = input("Introduce el ID de la oracion: ").strip()

    if not raw.isdigit():
        print("\nID no valido.")
        pause()
        return

    sentence_id = int(raw)
    original_text = get_corpus_text(sentence_id)

    result = analyze_ambiguity_corpus_id(sentence_id)

    if not result["ok"]:
        show_error_result(result)
        pause()
        return

    show_ambiguity_result(result, original_text=original_text, show_arboles=True)
    pause()


def analyze_ambiguity_manual_sentence():
    print_header("DETECTAR AMBIGUEDAD DE FRASE MANUAL")

    text = input("Escribe la frase: ").strip()

    if not text:
        print("\nNo has escrito ninguna frase.")
        pause()
        return

    result = analyze_ambiguity_manual_text(text)

    if not result["ok"]:
        show_error_result(result)
        pause()
        return

    show_ambiguity_result(result, original_text=text, show_arboles=True)
    pause()


def test_all_corpus():
    print_header("PRUEBA COMPLETA DEL CORPUS")

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
            rasgos = result.get("rasgos", "")
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


def test_all_ambiguity():
    print_header("AMBIGUEDAD EN TODO EL CORPUS")

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


def draw_all_corpus():
    print_header("DIBUJAR ARBOLES DE TODO EL CORPUS")

    print("Se mostrara un arbol por oracion.")
    print("Las oraciones no reconocidas apareceran como FALLO.")
    pause()

    for sentence_id, text in CORPUS:
        print_header(f"ARBOL DE ORACION {sentence_id}")

        result = analyze_corpus_id(sentence_id, draw_tree=True)

        if not result["ok"]:
            show_error_result(result)
            pause()
            continue

        show_analysis_result(result, original_text=text, show_ascii=True)
        pause()


# =========================================================
# MAIN
# =========================================================

def main():
    while True:
        print_menu()
        option = input("Elige una opcion: ").strip()

        if option == "1":
            show_corpus()
        elif option == "2":
            analyze_corpus_sentence(draw_tree=False)
        elif option == "3":
            analyze_corpus_sentence(draw_tree=True)
        elif option == "4":
            test_all_corpus()
        elif option == "5":
            draw_all_corpus()
        elif option == "6":
            analyze_manual_sentence(draw_tree=False)
        elif option == "7":
            analyze_manual_sentence(draw_tree=True)
        elif option == "8":
            analyze_ambiguity_corpus_sentence()
        elif option == "9":
            test_all_ambiguity()
        elif option == "10":
            analyze_ambiguity_manual_sentence()
        elif option == "0":
            print("\nSaliendo...")
            break
        else:
            print("\nOpcion no valida.")
            pause()


if __name__ == "__main__":
    main()