#!/usr/bin/env python3

import argparse
import difflib
import hashlib
import os
import re
import subprocess
import sys
import tempfile
import urllib.parse
import urllib.request
from dataclasses import dataclass
from pathlib import Path


REF_PATTERN = re.compile(
    r"^(?P<prefix>[ \t]*REF[ \t]+)(?P<value>\S+)(?P<suffix>[ \t]*)(?=\r?$)",
    re.MULTILINE,
)
SHA_PATTERN = re.compile(
    r"^(?P<prefix>[ \t]*SHA512[ \t]+)(?P<value>[0-9A-Fa-f]+)(?P<suffix>[ \t]*)(?=\r?$)",
    re.MULTILINE,
)


@dataclass(frozen=True)
class PortUpdate:
    name: str
    portfile: Path
    old_ref: str
    new_ref: str
    sha512: str
    original_text: str
    updated_text: str


class ArchiveProvider:
    hosts: tuple[str, ...] = ()

    def archive_url(self, repository_url: str, commit: str) -> str:
        raise NotImplementedError


class GitHubProvider(ArchiveProvider):
    hosts = ("github.com",)

    def archive_url(self, repository_url: str, commit: str) -> str:
        return f"{repository_url}/archive/{commit}.tar.gz"


class GitLabProvider(ArchiveProvider):
    hosts = ("gitlab.com",)

    def archive_url(self, repository_url: str, commit: str) -> str:
        repository_name = urllib.parse.urlsplit(repository_url).path.rstrip("/").rsplit("/", 1)[-1]
        archive_name = urllib.parse.quote(f"{repository_name}-{commit}.tar.gz")
        return f"{repository_url}/-/archive/{commit}/{archive_name}"


ARCHIVE_PROVIDERS = (GitHubProvider(), GitLabProvider())
COMMIT_SUBJECT_LIMIT = 80


def run_git(repo_dir: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(repo_dir), *args],
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    return result.stdout.strip()


def git_repository_dir(ports_dir: Path, repo_arg: Path | None) -> Path:
    if repo_arg is not None:
        repo_dir = repo_arg.resolve()
        if not repo_dir.is_dir():
            raise ValueError(f"Git repository directory does not exist: {repo_dir}")
    else:
        repo_dir = Path(run_git(ports_dir, "rev-parse", "--show-toplevel"))

    detected_dir = Path(run_git(repo_dir, "rev-parse", "--show-toplevel")).resolve()
    if detected_dir != repo_dir:
        raise ValueError(f"not a Git working tree root: {repo_dir} (detected {detected_dir})")
    return repo_dir


def repository_path(repo_dir: Path, path: Path) -> Path:
    try:
        return path.resolve().relative_to(repo_dir)
    except ValueError as error:
        raise ValueError(f"{path}: file is outside Git repository {repo_dir}") from error


def repository_url(remote_url: str) -> str:
    if remote_url.startswith("ssh://"):
        parsed = urllib.parse.urlsplit(remote_url)
        host = parsed.hostname
        if not host:
            raise ValueError(f"invalid origin URL: {remote_url}")
        url = urllib.parse.urlunsplit(("https", host, parsed.path, "", ""))
    elif remote_url.startswith("http://") or remote_url.startswith("https://"):
        url = remote_url
    else:
        scp_match = re.fullmatch(r"(?:[^@]+@)?([^:]+):(.+)", remote_url)
        if not scp_match:
            raise ValueError(f"unsupported origin URL: {remote_url}")
        url = f"https://{scp_match.group(1)}/{scp_match.group(2)}"

    return url.removesuffix(".git").rstrip("/")


def archive_url(remote_url: str, commit: str) -> tuple[str, str]:
    url = repository_url(remote_url)
    host = urllib.parse.urlsplit(url).hostname
    for provider in ARCHIVE_PROVIDERS:
        if host and host.lower() in provider.hosts:
            return provider.archive_url(url, commit), type(provider).__name__.removesuffix("Provider")
    raise ValueError(f"unsupported Git hosting provider: {host or remote_url}")


def read_preserving_newlines(path: Path) -> str:
    with path.open("r", encoding="utf-8", newline="") as stream:
        return stream.read()


def unique_match(pattern: re.Pattern[str], text: str, field: str, portfile: Path) -> re.Match[str]:
    matches = list(pattern.finditer(text))
    if len(matches) != 1:
        raise ValueError(f"{portfile}: expected exactly one {field}, found {len(matches)}")
    return matches[0]


def archive_sha512(url: str, timeout: float, verbose: bool) -> str:
    digest = hashlib.sha512()
    total_size = 0
    request = urllib.request.Request(url, headers={"User-Agent": "update-ports/1.0"})
    with urllib.request.urlopen(request, timeout=timeout) as response:
        while chunk := response.read(1024 * 1024):
            digest.update(chunk)
            total_size += len(chunk)
    if verbose:
        print(f"[verbose] downloaded {total_size} bytes")
    return digest.hexdigest()


def updated_portfile_text(text: str, portfile: Path, new_ref: str, sha512: str) -> str:
    ref_match = unique_match(REF_PATTERN, text, "REF field", portfile)
    text = text[: ref_match.start("value")] + new_ref + text[ref_match.end("value") :]
    sha_match = unique_match(SHA_PATTERN, text, "SHA512 field", portfile)
    return text[: sha_match.start("value")] + sha512 + text[sha_match.end("value") :]


def prepare_update(
    name: str, repo_dir: Path, ports_dir: Path, timeout: float, verbose: bool
) -> PortUpdate | None:
    if not repo_dir.is_dir():
        raise ValueError(f"repository directory does not exist: {repo_dir}")
    run_git(repo_dir, "rev-parse", "--git-dir")

    portfile = ports_dir / name / "portfile.cmake"
    if not portfile.is_file():
        raise ValueError(f"portfile does not exist: {portfile}")

    text = read_preserving_newlines(portfile)
    ref_match = unique_match(REF_PATTERN, text, "REF field", portfile)
    unique_match(SHA_PATTERN, text, "SHA512 field", portfile)

    commit = run_git(repo_dir, "rev-parse", "HEAD")
    old_ref = ref_match.group("value")
    if old_ref.lower() == commit.lower():
        print(f"[unchanged] {name}: {commit}")
        return None

    if run_git(repo_dir, "status", "--porcelain"):
        print(
            f"[warning] {name}: {repo_dir} has uncommitted changes; the archive contains HEAD only",
            file=sys.stderr,
        )

    origin = run_git(repo_dir, "config", "--get", "remote.origin.url")
    url, provider = archive_url(origin, commit)
    if verbose:
        print(f"[verbose] {name}: provider={provider}, repository={repository_url(origin)}")
        print(f"[verbose] {name}: {old_ref} -> {commit}")
    print(f"[download] {name}: {url}")
    sha512 = archive_sha512(url, timeout, verbose)
    updated_text = updated_portfile_text(text, portfile, commit, sha512)
    return PortUpdate(name, portfile, old_ref, commit, sha512, text, updated_text)


def stage_text(path: Path, text: str) -> Path:
    with tempfile.NamedTemporaryFile(
        mode="w", encoding="utf-8", newline="", dir=path.parent, delete=False
    ) as stream:
        stream.write(text)
        stream.flush()
        os.fsync(stream.fileno())
        temporary_path = Path(stream.name)
    temporary_path.chmod(path.stat().st_mode)
    return temporary_path


def apply_updates(updates: list[PortUpdate]) -> None:
    for update in updates:
        if read_preserving_newlines(update.portfile) != update.original_text:
            raise ValueError(f"{update.portfile}: file changed while updates were being prepared")

    staged: list[tuple[PortUpdate, Path]] = []
    replaced: list[PortUpdate] = []
    try:
        for update in updates:
            staged.append((update, stage_text(update.portfile, update.updated_text)))
        for update, temporary_path in staged:
            temporary_path.replace(update.portfile)
            replaced.append(update)
        for update in updates:
            print(f"[updated] {update.name}: {update.old_ref} -> {update.new_ref}")
    except OSError:
        for update in reversed(replaced):
            rollback_path = stage_text(update.portfile, update.original_text)
            rollback_path.replace(update.portfile)
        raise
    finally:
        for _, temporary_path in staged:
            temporary_path.unlink(missing_ok=True)


def print_diff(update: PortUpdate) -> None:
    diff = difflib.unified_diff(
        update.original_text.splitlines(keepends=True),
        update.updated_text.splitlines(keepends=True),
        fromfile=str(update.portfile),
        tofile=str(update.portfile),
    )
    sys.stdout.writelines(diff)


def commit_message(updates: list[PortUpdate]) -> str:
    names = [update.name for update in updates]
    if len(names) == 1:
        subject = f"Update {names[0]} port"
    elif len(names) == 2:
        ports = f"{names[0]} and {names[1]}"
        subject = f"Update {ports} ports"
    else:
        ports = f"{', '.join(names[:-1])}, and {names[-1]}"
        subject = f"Update {ports} ports"

    if len(subject) <= COMMIT_SUBJECT_LIMIT:
        return subject

    summary = "Update a vcpkg port" if len(names) == 1 else f"Update {len(names)} vcpkg ports"
    details = "\n".join(f"- {name}" for name in names)
    return f"{summary}\n\n{details}"


def commit_updates(repo_dir: Path, updates: list[PortUpdate]) -> None:
    paths = [repository_path(repo_dir, update.portfile) for update in updates]
    staged_paths = run_git(repo_dir, "diff", "--cached", "--name-only")
    if staged_paths:
        raise ValueError(f"{repo_dir}: index already contains staged changes")

    for path in paths:
        status = run_git(repo_dir, "status", "--porcelain", "--", str(path))
        if status:
            raise ValueError(f"{repo_dir / path}: target file already has uncommitted changes")

    apply_updates(updates)
    run_git(repo_dir, "add", "--", *(str(path) for path in paths))
    message = commit_message(updates)
    run_git(repo_dir, "commit", "-m", message)
    print(f"[committed] {message.splitlines()[0]}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Update vcpkg port REF and SHA512 fields from local Git repositories."
    )
    parser.add_argument(
        "--port",
        action="append",
        nargs=2,
        required=True,
        metavar=("PORT_NAME", "REPO_DIR"),
        help="add a vcpkg port name and its local Git repository",
    )
    parser.add_argument(
        "vcpkg_ports_dir",
        nargs="?",
        default=Path(__file__).resolve().parent.parent / "ports",
        metavar="VCPKG_PORTS_DIR",
        type=Path,
        help="vcpkg ports directory (default: ../ports relative to this script)",
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="prepare updates without modifying portfiles"
    )
    parser.add_argument("--diff", action="store_true", help="show the proposed portfile changes")
    parser.add_argument(
        "--timeout",
        type=float,
        default=30.0,
        metavar="SECONDS",
        help="set the timeout for each archive request (default: 30)",
    )
    parser.add_argument("--verbose", action="store_true", help="show additional update details")
    parser.add_argument(
        "--commit", action="store_true", help="stage and commit the updated portfiles"
    )
    parser.add_argument(
        "--repo",
        type=Path,
        metavar="REPO_DIR",
        help="overlay Git repository (default: detect from VCPKG_PORTS_DIR)",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.timeout <= 0:
        raise ValueError("--timeout must be greater than zero")
    if args.commit and args.dry_run:
        raise ValueError("--commit cannot be used with --dry-run")
    if args.repo is not None and not args.commit:
        raise ValueError("--repo requires --commit")
    ports_dir = args.vcpkg_ports_dir.resolve()
    if not ports_dir.is_dir():
        raise ValueError(f"vcpkg ports directory does not exist: {ports_dir}")

    names: set[str] = set()
    updates: list[PortUpdate] = []
    for name, repo_text in args.port:
        if name in names:
            raise ValueError(f"duplicate --port name: {name}")
        names.add(name)
        update = prepare_update(
            name, Path(repo_text).resolve(), ports_dir, args.timeout, args.verbose
        )
        if update:
            updates.append(update)

    if args.diff:
        for update in updates:
            print_diff(update)

    if args.dry_run:
        print(f"Done. Would update {len(updates)} of {len(args.port)} ports.")
        return 0

    if args.commit and updates:
        repo_dir = git_repository_dir(ports_dir, args.repo)
        commit_updates(repo_dir, updates)
    else:
        apply_updates(updates)
    print(f"Done. Updated {len(updates)} of {len(args.port)} ports.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        print(f"error: {error}", file=sys.stderr)
        raise SystemExit(1)
