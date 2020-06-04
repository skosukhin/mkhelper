noinst_LTLIBRARIES =       \
    libthreaded_hello.la   \
    libthreaded_hello_f.la

noinst_PROGRAMS = print_hello

libthreaded_hello_la_SOURCES = \
    threaded_hello.c \
    threaded_hello.h

libthreaded_hello_f_la_SOURCES = threaded_hello_f.f90

libthreaded_hello_f_la_LIBADD = libthreaded_hello.la

print_hello_SOURCES = print_hello.c

# Check that Libtool can link a C program to the Fortran library too:
print_hello_LDADD = libthreaded_hello_f.la

mostlyclean-local:
	rm -f *.mod

ACLOCAL_AMFLAGS = -I m4
