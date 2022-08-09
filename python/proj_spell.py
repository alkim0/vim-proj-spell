import hashlib
import pathlib

SYS_ROOT = pathlib.Path("/")
SYS_TMP = pathlib.Path("/tmp")


def _gather_spell_words(spell_dir: pathlib.Path) -> list[str]:
    """Gathers all project-specific words specified by spell_dir and returns a single word list

    :spell_dir: path to spell directory we wish to look at
    :returns: list of all spell words allowed for the project
    """
    words = []
    try:
        for child in spell_dir.iterdir():
            try:
                with open(child) as f:
                    words.extend(
                        [line.strip() for line in f.readlines() if line.strip()]
                    )
            except:
                pass
    except:
        pass

    return words


def _write_spell_words(words: list[str], output_path: pathlib.Path) -> None:
    """Writes all the words into one file to the location specified by output_path"""
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w") as f:
        f.write("\n".join(words))


def _lookup_spell_dir(current_dir: pathlib.Path, spell_dir: str) -> pathlib.Path | None:
    current_dir = current_dir.resolve()

    while True:
        if (current_dir / spell_dir).exists():
            return current_dir / spell_dir

        if current_dir == SYS_ROOT:
            break

        current_dir = current_dir.parent

    return None


def compile_proj_spell(current_dir: str, spell_dir: str) -> str:
    spell_dir_path = _lookup_spell_dir(pathlib.Path(current_dir), spell_dir)
    if spell_dir_path is None:
        return ""

    output_fname = f"{hashlib.sha1(bytes(spell_dir_path)).hexdigest()}.utf-8.add"
    output_path = SYS_TMP / "vim-proj-spell" / output_fname
    words = _gather_spell_words(spell_dir_path)
    _write_spell_words(words, output_path)

    return str(output_path)


def lookup_spell_dir(current_dir: str, spell_dir: str) -> str:
    result = _lookup_spell_dir(pathlib.Path(current_dir), spell_dir)
    if result is None:
        return ""
    else:
        return str(result)
