# The following are added to build with GCC (no Sun Studio)
export __GNUC=""
# Use GCC-4.4.4.
export __GNUC4=""
export GCC_ROOT=/opt/gcc/4.4.4
export CW_GCC_DIR=${GCC_ROOT}/bin
export CW_NO_SHADOW=1
export ONLY_LINT_DEFS=-I${SPRO_ROOT}/sunstudio12.1/prod/include/lint

# Use Perl 5.22 since OI hipster no longer ships 5.10
export PERL_VERSION="5.22"
export PERL_PKGVERS="-522"
