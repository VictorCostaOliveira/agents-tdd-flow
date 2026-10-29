"""Gera a pasta cursor/ a partir de claude/.claude/.

claude/ é a fonte de verdade; cursor/ é todo gerado (agentes, skills, knowledge e rules).
"""
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "claude" / ".claude"
DST = ROOT / "cursor"

CLAUDE_ONLY_SKILLS = {"feature"}  # roteia modelos do Claude; sem equivalente no Cursor

REPLACEMENTS = [
    ("~/.claude/", "~/.cursor/"),
    (".claude/rules", ".cursor/rules"),
]


def convert_body(text):
    for old, new in REPLACEMENTS:
        text = text.replace(old, new)
    return text


def split_frontmatter(text):
    match = re.match(r"---\n(.*?)\n---\n", text, re.S)
    fields = dict(line.split(": ", 1) for line in match.group(1).split("\n") if ": " in line)
    return fields, text[match.end():]


def agent(src, dst):
    fields, body = split_frontmatter(src.read_text())
    out = [f"name: {fields['name']}", f"description: {fields['description']}"]
    out.append(f"model: {'fast' if fields.get('model') == 'haiku' else 'inherit'}")
    if "disallowedTools" in fields:
        out.append("readonly: true")
    dst.write_text("---\n" + "\n".join(out) + "\n---\n" + convert_body(body))


def skill(src_dir, dst_dir):
    for path in src_dir.rglob("*"):
        if path.is_dir():
            continue
        target = dst_dir / path.relative_to(src_dir)
        target.parent.mkdir(parents=True, exist_ok=True)
        if path.suffix == ".md":
            target.write_text(convert_body(path.read_text()))
        else:
            shutil.copy(path, target)


def rule(src, dst):
    text = src.read_text()
    title = text.splitlines()[0].lstrip("# ").strip()
    dst.write_text(f"---\ndescription: {title}\nalwaysApply: true\n---\n\n{convert_body(text)}")


def main():
    for folder in ("agents", "skills", "rules"):
        shutil.rmtree(DST / folder, ignore_errors=True)

    (DST / "agents" / "knowledge").mkdir(parents=True)
    for path in sorted((SRC / "agents").glob("*.md")):
        agent(path, DST / "agents" / path.name)
    for path in sorted((SRC / "agents" / "knowledge").glob("*.md")):
        shutil.copy(path, DST / "agents" / "knowledge" / path.name)

    for skill_dir in sorted(p for p in (SRC / "skills").iterdir() if p.is_dir()):
        if skill_dir.name in CLAUDE_ONLY_SKILLS:
            continue
        skill(skill_dir, DST / "skills" / skill_dir.name)

    (DST / "rules").mkdir()
    for path in sorted((SRC / "rules").glob("*.md")):
        rule(path, DST / "rules" / f"{path.stem}.mdc")


if __name__ == "__main__":
    main()
