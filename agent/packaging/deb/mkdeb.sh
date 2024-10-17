#!/bin/bash -eux
# use CLEAN=0 to avoid the final teardown tidoudou dou

TOP_SRCDIR=$(readlink -m "$0/../../..")
UID_GID=$(stat -c %u:%g "$0")
cd "$TOP_SRCDIR"
test -f setup.py

BUILDDIR=$(readlink -m packaging/deb/build)
DESTDIR=$BUILDDIR/destdir

teardown () {
    set +x
    if [ "0" = "${CLEAN-1}" ] ; then
        return
    fi

    rm -rf "$BUILDDIR"

    if type -p temboard-agent &>/dev/null ; then
        echo "Cleaning previous installation." >&2
        apt-get -qq purge -y temboard-agent
    fi
    set -x
}
trap teardown EXIT INT TERM
CLEAN=1 teardown

mkdir -p "$DESTDIR"

#       V E R S I O N S

if [ -z "${VERSION-}" ] ; then
	VERSION=$(python3 setup.py --version)
fi
mapfile -t versions < <(pep440deb --echo "$VERSION" | tr ' ' '\n')
pep440v=${versions[0]}
debianv=${versions[1]}
codename=$(grep -Po 'VERSION_CODENAME=\K(.+)' /etc/os-release)
release=0dlb1${codename}1

#       I N S T A L L

whl="dist/temboard_agent-$pep440v-py3-none-any.whl"
if ! [ -f "$whl" ] ; then
	pip download --only-binary :all: --no-deps --pre --dest "dist/" "temboard-agent==$pep440v"
fi

# Install from sources
pip3 install --pre --root "$DESTDIR" --prefix /usr --no-deps "$whl"
# Fake --install-layout=deb, when using wheel.
pythonv=$(python3 --version |& grep -Po 'Python \K(3\.[0-9]{1,2})')
if [ -d "$DESTDIR/usr/local" ] ; then
    mv "$DESTDIR"/usr/local/* "$DESTDIR/usr/"
    rmdir "$DESTDIR/usr/local"
fi
if [ -d "$DESTDIR/usr/lib/python${pythonv}/site-packages" ] ; then
    mv "$DESTDIR/usr/lib/python${pythonv}/site-packages" "$DESTDIR/usr/lib/python$pythonv/dist-packages"
fi
mkdir -p "${DESTDIR}/usr/lib/python3/dist-packages/"
mv "$DESTDIR/usr/lib/python${pythonv}/dist-packages"/* "$DESTDIR/usr/lib/python3/dist-packages/"
rm -rf "$DESTDIR/usr/lib/python$pythonv"
rm -vf $(find "$DESTDIR/usr/lib" -name "*cpython-*.pyc" | grep -v "cpython-${pythonv/\.}.pyc")

#       B U I L D

PYTHON="$(readlink -e "$(type -p python3)")"
python_pkg="$(dpkg -S "$PYTHON")"
python_pkg="${python_pkg%:*}"
python_pkg="${python_pkg/-minimal}"


(
	export DEBIANV=$debianv
	export RELEASE=$release
	export PYTHON_PKG=$python_pkg
	nfpm pkg --config packaging/deb/nfpm.yaml --packager deb
)

#       T E S T

deb="temboard-agent_${debianv}-${release}_all.deb"
mv "$deb" dist/
dpkg-deb --info "dist/$deb"
dpkg-deb --show --showformat '$''{Depends}\n' "dist/$deb"
dpkg-deb --contents "dist/$deb"
retry apt-get update --quiet
apt-get install --yes "./dist/$deb"
(
	cd /
	temboard-agent --version
)

#       S A V E

# Point deb as latest build for changes generation.
ln -fs "$deb" "dist/temboard-agent_last.deb"
chown -R "${UID_GID}" "dist/"
