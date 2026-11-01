#!/bin/sh
# Bumps one formula of the tap to a published release of its project.
#
#   scripts/bump.sh [--dry-run] FORMULA VERSION
#
# FORMULA is lox, lea, locksql, lockmq, lockfile, lockhttp or locklog;
# VERSION is the release, X.Y.Z or vX.Y.Z.
#
# It downloads the release's checksums.txt and its Sigstore bundle, checks
# with cosign that checksums.txt was signed by the project's release
# workflow run for that very tag, then rewrites Formula/FORMULA.rb: the
# version, the sha256 of every archive the formula names (the URLs hold
# #{version}, so they follow), and, for a formula that pins its images, the
# image digests, each verified with cosign against the same workflow.
# An archive the formula names but the release lacks is an error.
#
# --dry-run prints the diff and leaves the formula as it is. Without it, the
# formula is rewritten in place and the diff is printed too; committing is
# left to the caller (.github/workflows/bump.yml commits and pushes).
#
# Needs: curl, cosign (v2 or later), awk, diff.
#
# Environment:
#   BUMP_RELEASE_BASE  base URL of the releases (default
#                      https://github.com/DavidGodefroid), for tests
set -eu

say() { printf 'bump: %s\n' "$*" >&2; }
die() { say "$*"; exit 1; }
usage() {
	printf 'usage: scripts/bump.sh [--dry-run] FORMULA VERSION\n' >&2
	exit 2
}

dry_run=0
while [ $# -gt 0 ]; do
	case "$1" in
	--dry-run) dry_run=1; shift ;;
	-h | --help) usage ;;
	--) shift; break ;;
	-*) say "unknown option $1"; usage ;;
	*) break ;;
	esac
done
[ $# -eq 2 ] || usage
formula=$1
version=${2#v}

# The formula's project, and whether it pins images (none, image, or image
# and vault image). Only these names: the value goes into paths and URLs.
case "$formula" in
lox) repo=lockhub images=none ;;
lea) repo=lea images=none ;;
locksql | lockmq | lockfile) repo=$formula images=vault ;;
lockhttp) repo=$formula images=image ;;
locklog) repo=$formula images=image ;;
*) die "unknown formula '$formula': lox, lea, locksql, lockmq, lockfile, lockhttp or locklog" ;;
esac
# Only a release version: it goes into URLs and into the formula's text.
printf '%s\n' "$version" | grep -Eqx '[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?' ||
	die "invalid version '$2': a release version, X.Y.Z or vX.Y.Z"
tag="v$version"

root=$(cd "$(dirname "$0")/.." && pwd -P)
file="$root/Formula/$formula.rb"
[ -f "$file" ] || die "$file does not exist: write the formula first (see README.md)"
command -v cosign >/dev/null 2>&1 || die "cosign is required (https://docs.sigstore.dev/cosign/system_config/installation/)"

base="${BUMP_RELEASE_BASE:-https://github.com/DavidGodefroid}"
identity="https://github.com/DavidGodefroid/$repo/.github/workflows/release.yml@refs/tags/$tag"
issuer="https://token.actions.githubusercontent.com"
registry="ghcr.io/davidgodefroid/$repo"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

fetch() { curl -fsSL --proto '=https' --tlsv1.2 --retry 3 -o "$2" "$1"; }

say "$formula: $repo $tag"
fetch "$base/$repo/releases/download/$tag/checksums.txt" "$tmp/checksums.txt" ||
	die "no checksums.txt in the $repo release $tag: is it published?"
fetch "$base/$repo/releases/download/$tag/checksums.txt.sigstore.json" "$tmp/checksums.txt.sigstore.json" ||
	die "no checksums.txt.sigstore.json in the $repo release $tag"
cosign verify-blob --bundle "$tmp/checksums.txt.sigstore.json" \
	--certificate-identity "$identity" --certificate-oidc-issuer "$issuer" \
	"$tmp/checksums.txt" >"$tmp/cosign.log" 2>&1 || {
	cat "$tmp/cosign.log" >&2
	die "cosign: checksums.txt of $repo $tag is not signed by $identity"
}
say "cosign: checksums.txt signed by the $repo release workflow for $tag"

# verified_digest TAG: the digest of registry:TAG whose signature verifies.
verified_digest() {
	cosign verify --certificate-identity "$identity" --certificate-oidc-issuer "$issuer" \
		"$registry:$1" 2>"$tmp/cosign.log" |
		sed -n 's/.*"docker-manifest-digest":"\(sha256:[0-9a-f]\{64\}\)".*/\1/p' | sed -n 1p
}
digest='' vdigest=''
if [ "$images" != none ]; then
	digest=$(verified_digest "$version")
	[ -n "$digest" ] || { cat "$tmp/cosign.log" >&2; die "cosign: $registry:$version does not verify, or is not published"; }
	say "cosign: $registry:$version is $digest"
fi
if [ "$images" = vault ]; then
	vdigest=$(verified_digest "$version-vault")
	[ -n "$vdigest" ] || { cat "$tmp/cosign.log" >&2; die "cosign: $registry:$version-vault does not verify, or is not published"; }
	[ "$vdigest" != "$digest" ] || die "$registry:$version and :$version-vault have the same digest"
	say "cosign: $registry:$version-vault is $vdigest"
fi

# The rewrite: the version line; after each url line, its sha256 line gets
# the checksum of that archive (the url's last segment, #{version} expanded);
# the image_digest and vault_image_digest assignments get the digests.
awk -v version="$version" -v digest="$digest" -v vdigest="$vdigest" -v sums="$tmp/checksums.txt" '
BEGIN {
	while ((getline line < sums) > 0) {
		n = split(line, f, /[ \t]+/)
		name = f[2]
		sub(/^\*/, "", name)
		if (n >= 2) sum[name] = f[1]
	}
	err = 0
}
function fail(msg) { printf "bump: %s\n", msg > "/dev/stderr"; err = 1 }
/^  version "[^"]*"$/ { sub(/"[^"]*"/, "\"" version "\""); seen_version = 1 }
/^ *url "/ {
	u = $0
	sub(/^ *url "/, "", u)
	sub(/".*$/, "", u)
	asset = u
	sub(/.*\//, "", asset)
	gsub(/#\{version\}/, version, asset)
	pending = asset
}
/^ *sha256 "[0-9a-f]+"$/ {
	if (pending == "") fail("line " NR ": a sha256 without a url before it")
	else if (!(pending in sum)) fail(pending " is not in the release checksums.txt")
	else { sub(/"[0-9a-f]+"/, "\"" sum[pending] "\""); urls++ }
	pending = ""
}
/^ *image_digest = "sha256:[0-9a-f]+"$/ {
	if (digest == "") fail("line " NR ": an image digest, but no image to verify")
	else sub(/"sha256:[0-9a-f]+"/, "\"" digest "\"")
	digests++
}
/^ *vault_image_digest = "sha256:[0-9a-f]+"$/ {
	if (vdigest == "") fail("line " NR ": a vault image digest, but no vault image to verify")
	else sub(/"sha256:[0-9a-f]+"/, "\"" vdigest "\"")
	digests++
}
{ print }
END {
	if (!seen_version) fail("no version line (  version \"X.Y.Z\")")
	if (urls == 0) fail("no url/sha256 pair")
	if (digest != "" && digests == 0) fail("the formula pins no image digest, but its project publishes images")
	exit err
}' "$file" >"$tmp/formula.rb" || die "could not rewrite $file; nothing changed"

if diff -u "$file" "$tmp/formula.rb" >"$tmp/diff"; then
	say "$formula is already at $version with these checksums"
	exit 0
fi
sed -e "s|^--- $file|--- a/Formula/$formula.rb|" -e "s|^+++ $tmp/formula.rb|+++ b/Formula/$formula.rb|" "$tmp/diff"
if [ "$dry_run" = 1 ]; then
	say "dry run: $file left as it is"
else
	cat "$tmp/formula.rb" >"$file"
	say "$file bumped to $version"
fi
