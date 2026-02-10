To “pin” a submodule to a specific (e.g., 2022) commit **forever**, you don’t need anything fancy—just make sure your *superproject* records that exact submodule SHA, and optionally add guardrails so updates don’t accidentally move it.

## Pin it (the actual mechanism)

1. Go into the submodule and check out the exact commit you want:

```bash
cd path/to/libfranka
git fetch --all --tags
git checkout <2022_commit_sha_or_tag>
# (optional) verify you’re at the right commit
git rev-parse HEAD
cd ..
```

2. Record that pinned SHA in the parent repo:

```bash
git add path/to/libfranka
git commit -m "Pin libfranka submodule to <sha> (2022)"
```

From then on, **anyone** cloning your repo and running:

```bash
git submodule update --init --recursive
```

will get that exact pinned commit.

---

## Recommended guardrails (so it stays pinned)

### 1) Don’t track a moving branch in `.gitmodules`

If you have something like this in `.gitmodules`:

```ini
[submodule "libfranka"]
  path = path/to/libfranka
  url = https://github.com/frankarobotics/libfranka
  branch = main
```

…remove the `branch = ...` line, because it encourages `git submodule update --remote` to move it.

Remove it:

```bash
git config -f .gitmodules --unset submodule.libfranka.branch || true
git add .gitmodules
git commit -m "Stop tracking a branch for libfranka submodule"
```

### 2) Teach your workflow “don’t use `--remote`”

* `git submodule update --init` respects the pin.
* `git submodule update --remote` **tries to advance** to a branch head (not pinned).

So: avoid `--remote` in scripts/CI if your goal is strict pinning.

### 3) Add a simple CI check to enforce the pin (strongly recommended)

In your CI, fail if the submodule SHA isn’t the expected one:

```bash
EXPECTED="<pinned_sha>"
ACTUAL="$(git submodule status -- path/to/libfranka | awk '{print $1}' | sed 's/^-//')"

if [ "$ACTUAL" != "$EXPECTED" ]; then
  echo "libfranka submodule moved! expected $EXPECTED but got $ACTUAL"
  exit 1
fi
```

That prevents accidental bumps via PRs.

---

## Pinning to a tag (nice for readability)

If libfranka has a tag from 2022 you trust (e.g. `0.x.y`), you can pin to the commit behind that tag:

```bash
cd path/to/libfranka
git fetch --tags
git checkout tags/<tagname>
cd ..
git add path/to/libfranka
git commit -m "Pin libfranka to tag <tagname>"
```

Note: you’re still pinning a **commit**; the tag is just a convenient reference.

---

## Quick “future you” rule

**Pinning is just committing the submodule SHA in the parent repo.**
As long as you commit that state, it’s reproducible in the future.

If you tell me which exact libfranka version/commit from 2022 you want (SHA or tag), I can give you the exact commands using that reference.

