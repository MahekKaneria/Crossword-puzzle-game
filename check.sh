#!/usr/bin/bash
# Check script given for lab 14
#
# Written in Fall 2022 for CMPUT 201 @ University of Alberta
# by Akemi Izuko <akemi.izuko@ualberta.ca>
umask 077

declare -r TMP_DIR="$(mktemp -d --tmpdir=/dev/shm)"  # Shared mem is big enough?
declare -r REQUIRED_FILES=(\
  ex14q1.c
  lab14.h
  makefile
  dictionary.txt
  crossword.txt
  check.sh
)

print_help() {
  cat <<HELP
Check file for lab 14

USAGE:
    $0 submit.tar
    bash $0 submit.tar
HELP
}

# ===================================================================
# Solutions
# ===================================================================
cat <<SOLUTION_1 > "${TMP_DIR}/sol1.txt"
a r i s e *
f * * * * *
f i n a l *
e * * * i *
c * b u s y
t * * * t *
SOLUTION_1

cat <<SOLUTION_2 > "${TMP_DIR}/sol2.txt"
a p p l e *
f * * * * *
f i n a l *
e * * * i *
c * b a s h
t * * * t *
SOLUTION_2

cat <<SOLUTION_3 > "${TMP_DIR}/sol3.txt"
a p p l e *
f * * * * *
f i n a l *
e * * * i *
c * b u s y
t * * * t *
SOLUTION_3

cat <<SOLUTION_4 > "${TMP_DIR}/sol4.txt"
a r i s e *
f * * * * *
f i n a l *
e * * * i *
c * b a s h
t * * * t *
SOLUTION_4



# ===================================================================
# Helper functions
# ===================================================================
assert_lab_machine() {
  if [[ "$(hostname)" =~ ^ug[0-9]{2}$ || "$(hostname)" == ohaton ]]; then
    return 0
  else
    return 1
  fi
}

check_mem_leaks() {
  local -i valgrind_out=0
  local name="$1"
  local exe="${TMP_DIR}/${name}"
  local file="${TMP_DIR}/gamesales.csv"
  local input="$2"
  local out="${TMP_DIR}/valgrind_out"

  # Checks for heap memory leaks
  printf "\nChecking for memory leaks (this may appear to freeze for a second)\n"

  # Runs the program
  if [[ -z "$input" ]]; then
    valgrind "$exe" "$file" 2> "$out" >/dev/null
  else
    valgrind "$exe" "$file" <<<"$input" 2> "$out" >/dev/null
  fi

  # Parses out the "in use at exit" number
  awk 'match($0, /in use at exit/) {
    split($0, a, " ");
    printf "%d", a[6];
  }' "$out" | read -r valgrind_out

  if [[ "$valgrind_out" -ne 0 ]]; then
    echo "Memory leaks detected in ${name}!"
    return 1
  else
    printf "%s did not leak memory! Good stuff\n\n" "$name"
    return 0
  fi
}

# ===================================================================
# Main program starts here
# ===================================================================
if ! [[ -r "$1" ]]; then
  print_help
  exit 1
elif ! assert_lab_machine; then
    echo " \`$(hostname) \` is not a lab machine!"
    echo "Please scp your files to a lab machine and run this check script there"
    exit 1
else
  # =================================================================
  # Open tar and check all files are present
  # =================================================================
  if ! tar -C "$TMP_DIR" -xf "$1"; then
    echo "Something is wrong with the tar file \"${1}\""
    exit 1
  fi

  # Check to make sure all files are present
  for file in "${REQUIRED_FILES[@]}"; do
    if ! [[ -e "${TMP_DIR}/${file}" ]]; then
      echo "You're missing \"${file}\" in your submission"
      exit 1
    fi
  done

  echo "Opened $1 into \`${TMP_DIR}\`"

  # =================================================================
  # Make executable
  # =================================================================
  echo "==== MAKE OUTPUT START =========="
  if ! make -C "$TMP_DIR"; then
    echo "==== MAKE OUTPUT END ============"
    echo "\`make\` exited with nonzero exit code: $?. An error likely occured"
    exit 1
  elif ! [[ -x "${TMP_DIR}/ex14q1" ]]; then
    echo "==== MAKE OUTPUT END ============"
    echo "No \`ex14q1\` executable was built by the makefile run with \`make\`"
    echo "Please make sure running \`make\` alone creates the \`ex14q1\` executable"
    exit 1
  fi
  echo "==== MAKE OUTPUT END ============"

  # Test their solutions against ours
  cd "$TMP_DIR"

  if ! "${TMP_DIR}/ex14q1" "${TMP_DIR}/dictionary.txt" "${TMP_DIR}/crossword.txt" 100 9; then
    echo "\`ex14q1\` returned a nonzero code $? when run like:"
    echo "    ./ex14q1 dictionary.txt crossword.txt 100 9"
    exit 1
  elif ! [[ -d "${TMP_DIR}/Solutions" ]]; then
    echo "\`ex14q1\` did not create a directory named \`Solutions\`"
    exit 1
  fi

  # =================================================================
  # Check that all their solutions match [any] one of ours
  # =================================================================
  declare -i is_matched_all=1  # All 4 solutions found a match

  for i in {1..4}; do
    declare sol_name="sol${i}.txt"

    if ! [[ -r "${TMP_DIR}/${sol_name}" ]]; then
      echo "\`ex14q1\` did not produce \`Solutions/${sol_name}\`, which was expected"
      exit 1
    fi

    declare -i is_matched=0  # The ith solution found a match

    for j in {1..4}; do
      declare our_sol="sol${j}.txt"

      if diff --ignore-all-space "${TMP_DIR}/Solutions/${sol_name}" "${TMP_DIR}/${our_sol}" &>/dev/null
      then
        (( is_matched = 1 ))
      fi
    done

    if [[ $is_matched -eq 0 ]]; then
      echo "Your $sol_name is incorrect"
      (( is_matched_all = 0 ))
    else
      echo "Your $sol_name matches ours! (It's correct)"
    fi
  done

  # Check if all good ====
  if [[ $is_matched_all -eq 1 ]]; then
    echo "All checks passed!"
    echo "If you feel you've tested enough, you can submit. Good luck!"
  fi
fi
