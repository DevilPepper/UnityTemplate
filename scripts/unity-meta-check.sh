#!/bin/bash

get_unpaired() {
  # comm complains about these not being sorted so we sort them...
  assets=$(echo "$1" | grep ".*\.meta" -v | sort)
  meta=$(echo "$1" | grep ".*\.meta" | sed -e "s/.meta$//" | sort)
  unpaired_assets=$(comm <(echo "$assets") <(echo "$meta") -23)
  unpaired_meta=$(comm <(echo "$assets") <(echo "$meta") -13 | sed -e "s/$/.meta/")
  results=$(echo "$unpaired_assets" && echo "$unpaired_meta")

  echo "$results" | sed "/^$/d"
}

staged=
abort=false
if [ $# -ne 2 ]; then
  staged="--staged"
fi

added=$(git diff $staged --name-only --diff-filter=A --no-renames $1 $2 -- */Assets/* Assets/)
deleted=$(git diff $staged --name-only --diff-filter=D --no-renames $1 $2 -- */Assets/* Assets/)
modified=$(git diff $staged --name-only --diff-filter=MR $1 $2 -- *.meta)

unpaired_files=$(get_unpaired "$added" && get_unpaired "$deleted")

for unpaired in $unpaired_files; do
  asset=${unpaired%.meta}
  meta=$asset.meta

  if [ -e "$asset" -a ! -e "$meta" ]; then
    echo "[Error] Can't find $meta"
    git reset -- "$asset"
    abort=true
  elif  [ ! -e "$asset" -a -e "$meta" ]; then
    echo "[Error] Can't find $asset"
    git reset -- "$meta"
    abort=true
  elif [ -d "$asset" -a -z "$(ls -A $asset)" ]; then
    echo "[Warning] Unstaging meta file for empty directory $asset"
    git reset -- "$meta"
  else
    echo "[Warning] Staging both $asset and $meta"
    git stage "$asset" "$meta"
  fi
done

# TODO: check parent directories of added/removed files for matching meta file (either staged or tracked (or not))
# Parked because it sounds like folder meta files are worthless and nothing will break if omitted.
# This may be a job for .gitignore
# If there exists a valid reason to push folder metas, here's some inspiration:
# [ ! $(git ls-files --error-unmatch $dir[.meta] 2> /dev/null ) ] && echo "not tracked" || echo "tracked"

for change in $modified; do
  diffs=$(git diff $staged $1 $2 -- $change | grep "^[\+|\-]guid:" | wc -l)
  if [ $diffs -eq 2 ]
  then
    echo "[Error] Found GUID change in $change"
    git reset -- "$change"
    abort=true
  fi
done

if [ "$abort" = true ]; then
  echo "There are errors that need to be fixed. Aborting commit!"
  exit 1
fi
