# Maintainer: Radoslav Chobanov <rado.chobanov97@gmail.com>
# PlasmaNGenuity - NGenuity replacement for HyperX Pulsefire Dart on Linux
#
# Build from local source:
#   makepkg -si
#
# Build from Git:
#   Uncomment the git source below and comment out the local source

pkgname=plasmangenuity
pkgver=2.0.0
pkgrel=1
pkgdesc="Full configuration tool and battery monitor for HyperX Pulsefire Dart wireless mouse on Linux - NGenuity replacement"
arch=('any')
url="https://github.com/radoslavchobanov/plasmangenuity"
license=('MIT')
depends=(
    'python>=3.8'
    'python-hidapi'
    'python-pyqt5'
    'python-pyudev'
)
makedepends=(
    'python-build'
    'python-installer'
    'python-wheel'
    'python-setuptools'
)
backup=('etc/udev/rules.d/99-plasmangenuity.rules')
install=plasmangenuity.install

# For local builds (run makepkg in the repo directory)
source=()
sha256sums=()

# For release builds, uncomment:
# source=("$pkgname-$pkgver.tar.gz::$url/archive/v$pkgver.tar.gz")
# sha256sums=('SKIP')

build() {
    cd "${startdir}"
    python -m build --wheel --no-isolation
}

package() {
    cd "${startdir}"
    python -m installer --destdir="$pkgdir" dist/*.whl

    # Install udev rules
    install -Dm644 99-plasmangenuity.rules "$pkgdir/usr/lib/udev/rules.d/99-plasmangenuity.rules"

    # Install desktop file for autostart
    install -Dm644 plasmangenuity.desktop "$pkgdir/usr/share/applications/plasmangenuity.desktop"

    # Install autostart entry
    install -Dm644 plasmangenuity.desktop "$pkgdir/etc/xdg/autostart/plasmangenuity.desktop"

    # Install license
    install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"

    # Install documentation
    install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
    install -Dm644 CHANGELOG.md "$pkgdir/usr/share/doc/$pkgname/CHANGELOG.md"
}
