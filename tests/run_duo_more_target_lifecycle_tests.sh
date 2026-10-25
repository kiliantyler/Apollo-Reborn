#!/bin/sh
set -eu
test_repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_build_dir=$(mktemp -d "${TMPDIR:-/tmp}/apollo-more-lifecycle.XXXXXX")
trap 'rm -rf -- "$test_build_dir"' EXIT HUP INT TERM
python3 - "$test_repo_root" "$test_build_dir" <<'PY'
from pathlib import Path
import sys
root, output = map(Path, sys.argv[1:])
source = (root / 'src/ApolloNavigationActions.xm').read_text()
begin = source.index('static void ApolloActionsArmFoldedModerator(')
end = source.index('\n}', begin) + 2
test = (root / 'tests/duo_more_target_lifecycle_tests.m').read_text()
(output / 'test.m').write_text(test.replace('// INCLUDE_PRODUCTION_MORE_WRAPPER', source[begin:end]))
PY
xcrun --sdk macosx clang -fobjc-arc -fblocks -Wall -Wextra -Werror \
    -fsanitize=address,undefined -framework Foundation "$test_build_dir/test.m" -o "$test_build_dir/tests"
"$test_build_dir/tests"
