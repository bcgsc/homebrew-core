class Exempi < Formula
  desc "Library to parse XMP metadata"
  homepage "https://wiki.freedesktop.org/libopenraw/Exempi/"
  url "https://libopenraw.freedesktop.org/download/exempi-2.4.5.tar.bz2"
  sha256 "406185feb88e84ea1d4b4251370be2991205790d7113a7e28e192ff46a4f221e"

  bottle do
    cellar :any
    sha256 "cb8963597a18110d41181ef79296a7f649330dbd21581f3bbc02209ad478d1bc" => :high_sierra
    sha256 "61b309245e23f723bdea631694de9809cc9ff9551abc87386eb063cef351c172" => :sierra
    sha256 "b1214df8ff8d55b48940e13e27cb7a0fcce0d423a8a791de876974622add734e" => :el_capitan
    sha256 "603524512314d1acccb7a0ee2e6e91ee25032cb495f81636ca9195e1843ce1bc" => :x86_64_linux
  end

  depends_on "boost"
  depends_on "expat" unless OS.mac?

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-boost=#{HOMEBREW_PREFIX}"
    system "make", "install"
  end
end
