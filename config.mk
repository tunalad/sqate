MOD_NAME      = sqate

VERSION       = 2026.08

FTEQCC        = tools/fteqcc64
FTEQCC_FLAGS  = -src src/ -DSQ_VERSION=\"$(VERSION)\"

QCSTYLE       = tools/qcstyle
QCSTYLE_FLAGS = --style=quakec -n -s8

DIST          = dist
ARCHIVE       = bsdtar -a -cf
