#!/bin/sh
set -eu
kernel=$1
rootfs=$2
output=$3
test "$(wc -c < "$kernel")" -le 3174400 || { echo "V-MS3000K kernel exceeds 25 LEBs" >&2; exit 1; }
test "$(wc -c < "$rootfs")" -le 4190208 || { echo "V-MS3000K rootfs exceeds 33 LEBs" >&2; exit 1; }
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp "$kernel" "$work/kernel"
fdtput=${4:?missing host fdtput}
size=$(wc -c < "$rootfs")
"$fdtput" -p -t x "$work/kernel" /rootfs size "$(printf '%x' "$size")"
"$fdtput" -p -t s "$work/kernel" /rootfs/hash-1 algo crc32
"$fdtput" -p -t x "$work/kernel" /rootfs/hash-1 value "$(python3 -c 'import pathlib,sys,zlib; print(format(zlib.crc32(pathlib.Path(sys.argv[1]).read_bytes()), "08x"))' "$rootfs")"
"$fdtput" -p -t s "$work/kernel" /rootfs/hash-2 algo sha1
digest=$(sha1sum "$rootfs" | cut -d " " -f 1)
# fdtput expects one numeric argument per 32-bit cell.
"$fdtput" -p -t x "$work/kernel" /rootfs/hash-2 value $(echo "$digest" | sed 's/\(........\)/\1 /g')
test "$(wc -c < "$work/kernel")" -le 3174400
cp "$rootfs" "$work/rootfs"
printf '%s\n' tenbay,v-ms3000k:ubi1:v1 > "$work/format"
(cd "$work" && sha256sum kernel rootfs > sha256)
tar --format=ustar --numeric-owner --owner=0 --group=0 --mtime="@${SOURCE_DATE_EPOCH:-0}" \
    -cf "$output" -C "$work" format kernel rootfs sha256
