#!/usr/bin/env bash

dl_base=https://download.elastic.co/beats
gh_base=https://github.com/elastic
ret=0

if [ $# -lt 1 ] ; then
    echo "Usage: $0 <version> [targets]"
    exit 1
else
    ver=$1
    shift
fi

if [ $# -gt 0 ] ; then
    targets=()
    for target in "$@" ; do
        targets+=("$target")
    done
else
    targets=('binary' 'source')
fi

pushd `dirname $0`/.. &>/dev/null

if [[ " ${targets[*]} " == *" binary "* ]] ; then
    # Update precompiled binary releases
    for bin_release in *beat-bin ; do
        beat=${bin_release%%-bin}
        artifact_32="$beat-$ver-i686.tar.gz"
        artifact_64="$beat-$ver-x86_64.tar.gz"
        checksums="$(mktemp /tmp/$(basename $0)-$beat.XXXXXX)"
        curl -s $dl_base/$beat/$artifact_32.sha1.txt >> $checksums
        curl -s $dl_base/$beat/$artifact_64.sha1.txt >> $checksums

        pushd /tmp/

        curl -s $dl_base/$beat/$artifact_32 -O
        curl -s $dl_base/$beat/$artifact_64 -O

        if gsha1sum -c "$checksums" ; then
            checksum_32="$(gsha256sum $artifact_32 | awk '{ print $1; }')"
            checksum_64="$(gsha256sum $artifact_64 | awk '{ print $1; }')"
            popd
            new_pkgbuild="$(sed -E \
                -e "s/(pkgver=).*/\1$ver/" \
                -e "s/(sha256sums_i686=).*/\1('$checksum_32')/" \
                -e "s/(sha256sums_x86_64=).*/\1('$checksum_64')/" \
                $bin_release/PKGBUILD)"
            echo "==> DIFF:"
            diff $bin_release/PKGBUILD <(echo "$new_pkgbuild")
            echo "==> FILES:"
            tar tzvf /tmp/$artifact_32
            echo -n "Write new PKGBUILD? (y/N): "
            read want_creds

            if [ $want_creds == 'y' ] ; then
                echo "$new_pkgbuild" > $bin_release/PKGBUILD
            fi
            pushd /tmp/
        else
            ret=1
            echo "Checksum for $beat failed, skipping..."
        fi

        rm $checksums $artifact_32 $artifact_64
        popd

    done
fi

if [[ " ${targets[*]} " == *" source "* ]] ; then
    # Update from-source tarballs
    artifact="v$ver.tar.gz"
    tag="$gh_base/beats/archive/$artifact"
    pushd /tmp/
    curl -L -s $tag -O
    checksum="$(gsha256sum $artifact | awk '{ print $1; }')"
    popd
    for src_release in *beat ; do
        new_pkgbuild="$(sed -E \
            -e "s/(pkgver=).*/\1$ver/" \
            -e "s/(sha256sums=).*/\1('$checksum'/" \
            -e "s/^pkgrel=.*/pkgrel=1/" \
            $src_release/PKGBUILD)"
        echo "==> $src_release DIFF:"
        diff $src_release/PKGBUILD <(echo "$new_pkgbuild")
        echo -n "Write new PKGBUILD? (y/N): "
        read want_creds

        if [ $want_creds == 'y' ] ; then
            echo "$new_pkgbuild" > $src_release/PKGBUILD
        fi
    done
    pushd /tmp/
    rm $artifact
    popd
fi

popd
exit $ret
