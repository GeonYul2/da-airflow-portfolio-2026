#!/usr/bin/env python3
import fnmatch
import re
import subprocess
import sys
from pathlib import Path


FORBIDDEN_FILE_PATTERNS = [
    ".env",
    "*.pem",
    "*.key",
    "*id_rsa*",
    "*.p12",
    "*.pfx",
]

WARNING_REGEXES = [
    re.compile(r"(?i)(api[_-]?key|token|secret|password)\s*[:=]\s*['\"][^'\"]{8,}['\"]"),
    re.compile(r"(?i)[A-Z0-9_]*(SECRET|PASSWORD|TOKEN|API[_-]?KEY)[A-Z0-9_]*\s*:\s*[^\s#]+"),
    re.compile(r"AKIA[0-9A-Z]{16}"),
    re.compile(r"-----BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY-----"),
]

TEXT_EXTENSIONS = {".py", ".md", ".sql", ".yml", ".yaml", ".env", ".txt", ".sh", ".json", ".toml", ".ini"}


def run(cmd: list[str]) -> str:
    return subprocess.check_output(cmd, text=True).strip()


def is_text_file(path: Path) -> bool:
    return path.suffix.lower() in TEXT_EXTENSIONS


def main() -> int:
    repo_root = Path(run(["git", "rev-parse", "--show-toplevel"]))
    tracked = run(["git", "ls-files"]).splitlines()

    failures: list[str] = []
    warnings: list[str] = []

    for rel in tracked:
        rel_path = Path(rel)
        abs_path = repo_root / rel_path

        for pattern in FORBIDDEN_FILE_PATTERNS:
            if fnmatch.fnmatch(rel_path.name, pattern) or fnmatch.fnmatch(str(rel_path), pattern):
                failures.append(f"Forbidden tracked file matched pattern '{pattern}': {rel}")
                break

        if not abs_path.exists() or not abs_path.is_file():
            continue

        size_mb = abs_path.stat().st_size / (1024 * 1024)
        if size_mb > 5:
            warnings.append(f"Large tracked file (>5MB): {rel} ({size_mb:.2f}MB)")

        if not is_text_file(abs_path):
            continue

        try:
            content = abs_path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue

        for regex in WARNING_REGEXES:
            if regex.search(content):
                warnings.append(f"Potential sensitive pattern in {rel}: /{regex.pattern}/")
                break

    gitignore = (repo_root / ".gitignore").read_text(encoding="utf-8") if (repo_root / ".gitignore").exists() else ""
    for required in [".env", "logs/", "__pycache__/"]:
        if required not in gitignore:
            warnings.append(f".gitignore missing recommended entry: {required}")

    print("=== Public Release Audit ===")
    print(f"Tracked files: {len(tracked)}")
    print(f"Failures: {len(failures)}")
    print(f"Warnings: {len(warnings)}")

    if failures:
        print("\n[FAILURES]")
        for item in failures:
            print(f"- {item}")

    if warnings:
        print("\n[WARNINGS]")
        for item in warnings:
            print(f"- {item}")

    if failures:
        print("\nResult: FAIL (fix failures before public submission)")
        return 1

    print("\nResult: PASS (review warnings manually)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
