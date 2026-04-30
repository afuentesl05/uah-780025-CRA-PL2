import os
import re
import subprocess
import unicodedata
from shutil import get_terminal_size

SWIPL_CMD = "swipl"
BRIDGE_FILE = "cli_bridge.pl"

# ---------------------------------------------------------
# CORPUS TIPO
# Lo metemos aquí directamente para no crear otro archivo
# ---------------------------------------------------------

CORPUS = [
    (1, "La melodia es la acertada sucesion de varios sonidos."),
    (2, "La armonia es el conjunto de varios sonidos."),
    (3, "El pentagrama tiene cinco lineas y cuatro espacios."),
    (4, "Las notas musicales son siete."),
    (5, "Todas las figuras tienen silencio y valen igual a la figura que representa."),
    (6, "El puntillo aumenta la mitad del valor a la figura anterior."),
    (7, "El intervalo es la distancia de un sonido a otro."),
    (8, "Las llaves son tres: sol, fa y do."),
    (9, "Los instrumentos musicales se dividen en cuatro clases."),
    (10, "El compas es una pequena porcion de tiempo dividida en partes iguales."),
    (11, "El arte es el conjunto de reglas para hacer bien alguna cosa."),
    (12, "El tiempo es sinonimo de medida o compas y tambien es sinonimo de aire."),
    (13, "El compas sirve para medir el valor de las figuras y se compone de dos, tres o cuatro tiempos, etc."),
    (14, "El doble puntillo aumenta la mitad del valor al puntillo anterior."),
    (15, "Hay sincopas largas, breves y muy breves, escribiendose de tres modos."),
    (16, "Los accidentes musicales son cinco."),
    (17, "Los diferentes intervalos que resultan entre los signos toman los nombres numericos de unisono, segunda, tercera, etc."),
    (18, "Las llaves mas usuales en el dia son la llave de sol en segunda linea, la llave de fa en cuarta linea, la llave de do en tercera linea y la llave de do en cuarta linea."),
    (19, "Hay dos clases de compases: pares e impares."),
    (20, "La voz tonalidad se toma ordinariamente como segunda acepcion de tono.")
]

# ---------------------------------------------------------
# UTILIDADES DE TERMINAL
# ---------------------------------------------------------

def clear_screen():
    os.system("cls" if os.name == "nt" else "clear")


def terminal_width():
    return get_terminal_size((100, 30)).columns


def line(char="─"):
    return char * terminal_width()


def center(text):
    return text.center(terminal_width())


def pause():
    input("\nPulsa ENTER para continuar...")


# ---------------------------------------------------------
# TOKENIZACION MINIMA
# ---------------------------------------------------------

def strip_accents(text: str) -> str:
    text = unicodedata.normalize("NFD", text)
    return "".join(ch for ch in text if unicodedata.category(ch) != "Mn")


def normalize_text(text: str) -> str:
    text = text.strip().lower()
    text = strip_accents(text)
    return text


def tokenize(text: str):
    text = normalize_text(text)

    for sign in [":", ","]:
        text = text.replace(sign, f" {sign} ")

    for sign in [".", ";", "¿", "?", "¡", "!", "(", ")", '"', "«", "»"]:
        text = text.replace(sign, " ")

    parts = [p for p in text.split() if p]
    return parts


def atom_to_prolog(token: str) -> str:
    if token in [":", ","]:
        return f"'{token}'"

    if re.fullmatch(r"[a-z_][a-z0-9_]*", token):
        return token

    escaped = token.replace("'", "\\'")
    return f"'{escaped}'"


def tokens_to_prolog_list(tokens):
    return "[" + ",".join(atom_to_prolog(tok) for tok in tokens) + "]"


# ---------------------------------------------------------
# LLAMADAS A PROLOG
# ---------------------------------------------------------

def run_prolog_goal(goal: str):
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
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace"
        )
    except FileNotFoundError:
        return {
            "ok": False,
            "error": "No se ha encontrado SWI-Prolog. Revisa que 'swipl' este instalado y accesible desde terminal."
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
    arbol = None
    ascii_lines = []
    in_ascii = False

    for line in lines:
        if line.startswith("ESTADO:"):
            estado = line.replace("ESTADO:", "").strip()
        elif line.startswith("ID:"):
            id_line = line.replace("ID:", "").strip()
        elif line.startswith("TOKENS:"):
            tokens = line.replace("TOKENS:", "").strip()
        elif line.startswith("ARBOL:"):
            arbol = line.replace("ARBOL:", "").strip()
        elif line.strip() == "ASCII_INICIO":
            in_ascii = True
        elif line.strip() == "ASCII_FIN":
            in_ascii = False
        elif in_ascii:
            ascii_lines.append(line)

    return {
        "estado": estado,
        "id": id_line,
        "tokens": tokens,
        "arbol": arbol,
        "ascii": "\n".join(ascii_lines)
    }


def analyze_corpus_id(sentence_id: int):
    result = run_prolog_goal(f"analizar_id_terminal({sentence_id}),halt")

    if not result["ok"]:
        return result

    parsed = parse_bridge_output(result["stdout"])
    parsed["stderr"] = result["stderr"]
    parsed["returncode"] = result["returncode"]
    parsed["ok"] = True
    return parsed


def analyze_manual_text(text: str):
    tokens = tokenize(text)
    prolog_tokens = tokens_to_prolog_list(tokens)
    result = run_prolog_goal(f"analizar_tokens_terminal({prolog_tokens}),halt")

    if not result["ok"]:
        return result

    parsed = parse_bridge_output(result["stdout"])
    parsed["stderr"] = result["stderr"]
    parsed["returncode"] = result["returncode"]
    parsed["ok"] = True
    parsed["python_tokens"] = tokens
    return parsed


# ---------------------------------------------------------
# PRESENTACION
# ---------------------------------------------------------

def print_header(title: str):
    clear_screen()
    print(line("═"))
    print(center("ANALIZADOR SINTACTICO EN TERMINAL"))
    print(center(title))
    print(line("═"))


def print_menu():
    print_header("MENU PRINCIPAL")
    print("1. Ver oraciones tipo del corpus")
    print("2. Analizar una oracion del corpus por ID")
    print("3. Analizar una frase escrita a mano")
    print("4. Probar todo el corpus")
    print("5. Ayuda de tokenizacion")
    print("0. Salir")
    print(line())


def show_corpus():
    print_header("ORACIONES TIPO DEL CORPUS")
    for idx, text in CORPUS:
        print(f"{idx:>2}. {text}")
    pause()


def get_corpus_text(sentence_id: int):
    for idx, text in CORPUS:
        if idx == sentence_id:
            return text
    return None


def show_analysis_result(result, original_text=None):
    print(line())
    if original_text:
        print("FRASE:")
        print(original_text)
        print(line())

    estado = result.get("estado", "DESCONOCIDO")
    print(f"ESTADO: {estado}")

    if "python_tokens" in result:
        print("\nTOKENS (generados en Python):")
        print(result["python_tokens"])

    if result.get("tokens"):
        print("\nTOKENS (vistos por Prolog):")
        print(result["tokens"])

    if estado == "OK":
        print("\nARBOL (termino Prolog):")
        print(result.get("arbol", ""))

        print("\nARBOL ASCII:")
        print(result.get("ascii", ""))

    elif estado == "FALLO":
        print("\nLa frase no ha sido reconocida por la gramatica actual.")

    elif estado == "ID_NO_EXISTE":
        print("\nEse ID no existe en el corpus.")

    stderr = result.get("stderr", "").strip()
    if stderr:
        print("\nSTDERR:")
        print(stderr)

    print(line())


def analyze_corpus_sentence():
    print_header("ANALIZAR ORACION DEL CORPUS")
    raw = input("Introduce el ID de la oracion: ").strip()

    if not raw.isdigit():
        print("\nID no valido.")
        pause()
        return

    sentence_id = int(raw)
    original_text = get_corpus_text(sentence_id)

    result = analyze_corpus_id(sentence_id)
    if not result["ok"]:
        print("\nERROR:")
        print(result["error"])
        pause()
        return

    show_analysis_result(result, original_text=original_text)
    pause()


def analyze_manual_sentence():
    print_header("ANALIZAR FRASE MANUAL")
    text = input("Escribe la frase: ").strip()

    if not text:
        print("\nNo has escrito ninguna frase.")
        pause()
        return

    result = analyze_manual_text(text)
    if not result["ok"]:
        print("\nERROR:")
        print(result["error"])
        pause()
        return

    show_analysis_result(result, original_text=text)
    pause()


def test_all_corpus():
    print_header("PRUEBA COMPLETA DEL CORPUS")

    oks = []
    fails = []

    for sentence_id, text in CORPUS:
        result = analyze_corpus_id(sentence_id)
        if not result["ok"]:
            fails.append((sentence_id, text, "ERROR_PYTHON_O_SWIPL"))
            continue

        if result.get("estado") == "OK":
            oks.append((sentence_id, text))
            print(f"OK    -> {sentence_id:>2} | {text}")
        else:
            fails.append((sentence_id, text, result.get("estado", "FALLO")))
            print(f"FALLO -> {sentence_id:>2} | {text}")

    print("\n" + line())
    print(f"TOTAL OK: {len(oks)}")
    print(f"TOTAL FALLO: {len(fails)}")

    if fails:
        print("\nDETALLE DE FALLOS:")
        for sentence_id, text, motivo in fails:
            print(f"- {sentence_id}: {motivo} | {text}")

    pause()


def show_help():
    print_header("AYUDA DE TOKENIZACION")
    print("La interfaz hace una tokenizacion minima pensada para vuestro corpus.")
    print()
    print("Reglas actuales:")
    print("- pasa todo a minusculas")
    print("- quita tildes y enyes")
    print("- separa ':' y ',' como tokens propios")
    print("- elimina el punto final y otros signos generales")
    print("- mantiene 'al' y 'del' como tokens unicos")
    print()
    ejemplo = "Las llaves son tres: sol, fa y do."
    print("Ejemplo:")
    print("Texto :", ejemplo)
    print("Tokens:", tokenize(ejemplo))
    print()
    print("Si una frase falla, puede deberse a:")
    print("- palabra no registrada en el lexico")
    print("- estructura no cubierta por la gramatica")
    print("- tokenizacion distinta de la esperada")
    pause()


# ---------------------------------------------------------
# MAIN
# ---------------------------------------------------------

def main():
    while True:
        print_menu()
        option = input("Elige una opcion: ").strip()

        if option == "1":
            show_corpus()
        elif option == "2":
            analyze_corpus_sentence()
        elif option == "3":
            analyze_manual_sentence()
        elif option == "4":
            test_all_corpus()
        elif option == "5":
            show_help()
        elif option == "0":
            print("\nSaliendo...")
            break
        else:
            print("\nOpcion no valida.")
            pause()


if __name__ == "__main__":
    main()