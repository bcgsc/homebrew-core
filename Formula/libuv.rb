class Libuv < Formula
  desc "Multi-platform support library with a focus on asynchronous I/O"
  homepage "https://github.com/libuv/libuv"
  url "https://github.com/libuv/libuv/archive/v1.20.2.tar.gz"
  sha256 "a5e62a6ed3c25a712477b55ce923e7f49af95b80319f88b9c950200d65427793"
  head "https://github.com/libuv/libuv.git", :branch => "v1.x"

  bottle do
    cellar :any
    sha256 "e9acf9c1902153a9b60d384487bb56ccaea005f863af1c19e2ffa83894c6a098" => :high_sierra
    sha256 "cff97140f289482643cea3d1160b04ac41c69b80b83fc35b4dc14a87fa01bf50" => :sierra
    sha256 "e5480274a5fd9793f7f910778db8d18af4b859634319e7856025c82a8f4b77ef" => :el_capitan
    sha256 "c4e5c6e90008e258aafa1976ffde0468a11a11e4beea3005eaccbe8e983e1bd9" => :x86_64_linux
  end

  option "with-test", "Execute compile time checks (Requires Internet connection)"

  deprecated_option "with-check" => "with-test"

  depends_on "pkg-config" => :build
  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build
  depends_on "sphinx-doc" => :build

  def install
    # This isn't yet handled by the make install process sadly.
    cd "docs" do
      system "make", "man"
      system "make", "singlehtml"
      man1.install "build/man/libuv.1"
      doc.install Dir["build/singlehtml/*"]
    end

    system "./autogen.sh"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "check" if build.with? "test"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <uv.h>
      #include <stdlib.h>

      int main()
      {
        uv_loop_t* loop = malloc(sizeof *loop);
        uv_loop_init(loop);
        uv_loop_close(loop);
        free(loop);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-luv", "-o", "test"
    system "./test"
  end
end
