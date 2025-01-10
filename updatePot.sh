#! /usr/bin/env bash
# SPDX-FileCopyrightText: 2024 Evan Maddock <maddock.evan@vivaldi.net>
# SPDX-License-Identifier: CC0-1.0

projectRoot=$(git rev-parse --show-toplevel)
podir="${projectRoot}/po"

xgettextOpts=(
    "--c++"
    "--kde"
    "--from-code=UTF-8"
    "-c i18n"
    "-ki18n:1"
    "-ki18nc:1c,2"
    "-ki18np:1,2"
    "-ki18ncp:1c,2,3"
    "-kki18n:1"
    "-kki18nc:1c,2"
    "-kki18np:1,2"
    "-kki18ncp:1c,2,3"
    "-kkli18n:1"
    "-kkli18nc:1c,2"
    "-kkli18np:1,2"
    "-kkli18ncp:1c,2,3"
    "-kI18N_NOOP:1"
    "-kI18NC_NOOP:1c,2"
    "--copyright-holder=\"Evan Maddock\""
    "--msgid-bugs-address=https://github.com/EbonJaeger/bluejay/issues"
)

# xgettext $(find -name \*.cpp -o -name \*.qml -o -name \*.js) -o "$podir/bluejay.pot"

find -name "*.cpp" -o -name "*.h" -o -name "*.qml" | sort | xargs xgettext "${xgettextOpts[@]}" -o "${podir}/bluejay.pot"
