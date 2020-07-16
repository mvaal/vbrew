DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR" || exit
if [ ! -d "homebrew-core" ]; then
  git clone git@github.com:Homebrew/homebrew-core.git homebrew-core
  printf 'Please add vbrew.sh to your profile.\nalias vbrew="%s"\n' "$DIR/vbrew.sh"
fi

COMMAND=$1
FORMULA=$2
VERSION=$3

if [ "$COMMAND" != "install" ] || [ -z "$VERSION" ] ; then
  echo "Proxying call to brew..."
  brew "$@"
  exit 0
fi
if [ -z "$FORMULA" ]; then
  echo Please provide formula
  exit 1
fi

cd homebrew-core || exit

git fetch && git switch -C master origin/master

REVISION=$(git log --all --grep="$FORMULA $VERSION" --pretty=fuller --no-abbrev-commit | grep commit | sed 's/^.* //')
if [ -z "$REVISION" ]; then
  echo "$FORMULA-$VERSION not found in homebrew-core"
  exit 1
fi
git checkout "${FORMULA}-${VERSION}" 2>/dev/null || git checkout -B "${FORMULA}-${VERSION}" "$REVISION"

FORMULA_PATH="Formula/$FORMULA.rb"

brew unlink "$FORMULA"

INSTALL_RESULT=$(brew install "$FORMULA_PATH" 2>&1)
SIGINT=$?
if [ $SIGINT -ne 0 ]; then
  ERROR=$(echo "$INSTALL_RESULT" | awk -F': ' '/[Ee]rror/ {print $2}')
  if [ "$ERROR" == "SHA256 mismatch" ]; then
    echo "SHA256 mismatch, correcting..."
    EXPECTED=$(echo "$INSTALL_RESULT" | awk -F': ' '/[Ee]xpected/ {print $2}')
    ACTUAL=$(echo "$INSTALL_RESULT" | awk -F': ' '/[Aa]ctual/ {print $2}')
    sed -i -e "s/$EXPECTED/$ACTUAL/g" "$FORMULA_PATH"
    git add "$FORMULA_PATH"
    git commit -m "Updating sha256 to $ACTUAL"
    brew install "$FORMULA_PATH"
  else
    echo "$INSTALL_RESULT"
    exit $SIGINT
  fi
else
  WARNING=$(echo "$INSTALL_RESULT" | awk -F': ' '/[Ww]arning/ {print $2}')
  if [ "$WARNING" == "$FORMULA $VERSION is already installed, it's just not linked" ]; then
    brew switch "$FORMULA" "$VERSION"
  else
    echo "$INSTALL_RESULT"
    exit $SIGINT
  fi
fi
