class Octave < Formula
  desc "High-level interpreted language for numerical computing"
  homepage "https://www.gnu.org/software/octave/index.html"
  url "https://ftp.gnu.org/gnu/octave/octave-4.2.2.tar.gz"
  mirror "https://ftpmirror.gnu.org/octave/octave-4.2.2.tar.gz"
  sha256 "77b84395d8e7728a1ab223058fe5e92dc38c03bc13f7358e6533aab36f76726e"
  revision 2

  bottle do
    sha256 "a7f5ad466f6f4af7ff0c2dbf361a524361378521f4530cf448258db579b69c24" => :high_sierra
    sha256 "6e48de076c248387c14a31156fcc19aaffde248e5a0239f1c2e3b05809ddb657" => :sierra
    sha256 "b7863bc195691632f3d2dc3359bcee21fda4549b061a76cbded236517ec5bcd9" => :el_capitan
    sha256 "ab8c2cd962bc6e34f59506b304689fdb990486d2580f8225bef4183941d16fdf" => :x86_64_linux
  end

  head do
    url "https://hg.savannah.gnu.org/hgweb/octave", :branch => "default", :using => :hg
    depends_on "mercurial" => :build
    depends_on "bison" => :build
    depends_on "icoutils" => :build
    depends_on "librsvg" => :build
    depends_on "sundials"
  end

  # Complete list of dependencies at https://wiki.octave.org/Building
  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "gnu-sed" => :build # https://lists.gnu.org/archive/html/octave-maintainers/2016-09/msg00193.html
  depends_on "pkg-config" => :build
  depends_on "arpack"
  depends_on "epstool"
  depends_on "fftw"
  depends_on "fig2dev"
  depends_on "fltk"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gcc" # for gfortran
  depends_on "ghostscript"
  depends_on "gl2ps"
  depends_on "glpk"
  depends_on "gnuplot"
  depends_on "graphicsmagick"
  depends_on "hdf5"
  depends_on "libsndfile"
  depends_on "libtool"
  depends_on "pcre"
  depends_on "portaudio"
  depends_on "pstoedit"
  depends_on "qhull"
  depends_on "qrupdate"
  depends_on "readline"
  depends_on "suite-sparse"
  depends_on :java => ["1.6+", :optional]
  if OS.mac?
    depends_on "openblas" => :optional
    depends_on "veclibfort" if build.without?("openblas")
  else
    depends_on "curl"
    depends_on "openblas" => :recommended
  end

  # Dependencies use Fortran, leading to spurious messages about GCC
  cxxstdlib_check :skip

  # If GraphicsMagick was built from source, it is possible that it was
  # done to change quantum depth. If so, our Octave bottles are no good.
  # https://github.com/Homebrew/homebrew-science/issues/2737
  def pour_bottle?
    Tab.for_name("graphicsmagick").without?("quantum-depth-32") &&
      Tab.for_name("graphicsmagick").without?("quantum-depth-8")
  end

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j8" if ENV["CIRCLECI"]

    # Default configuration passes all linker flags to mkoctfile, to be
    # inserted into every oct/mex build. This is unnecessary and can cause
    # cause linking problems.
    inreplace "src/mkoctfile.in.cc", /%OCTAVE_CONF_OCT(AVE)?_LINK_(DEPS|OPTS)%/, '""'

    blas_args = []
    if build.with? "openblas"
      blas_args << "--with-blas=-L#{Formula["openblas"].opt_lib} -lopenblas"
    elsif build.with? "veclibfort"
      blas_args << "--with-blas=-L#{Formula["veclibfort"].opt_lib} -lvecLibFort"
    else
      blas_args << "--with-blas=-lblas -llapack"
    end

    # allow for recent Oracle Java (>=1.8) without requiring the old Apple Java 1.6
    # this is more or less the same as in https://savannah.gnu.org/patch/index.php?9439
    inreplace "libinterp/octave-value/ov-java.cc",
      "#if ! defined (__APPLE__) && ! defined (__MACH__)", "#if 1" # treat mac's java like others
    inreplace "configure.ac",
      "-framework JavaVM", "" # remove framework JavaVM as it requires Java 1.6 after build

    inreplace "scripts/java/module.mk",
      "-source 1.3 -target 1.3", "" # necessary for Java >1.8

    args = *blas_args + %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-link-all-dependencies
      --enable-shared
      --disable-static
      --disable-docs
      --without-OSMesa
      --without-qt
      --with-hdf5-includedir=#{Formula["hdf5"].opt_include}
      --with-hdf5-libdir=#{Formula["hdf5"].opt_lib}
      --with-x=no
      --with-portaudio
      --with-sndfile
    ]

    args << "--disable-java" if build.without? "java"

    if build.head?
      system "./bootstrap"
    else
      system "autoreconf", "-fiv"
    end

    system "./configure", *args
    system "make", "all"

    # Avoid revision bumps whenever fftw's or gcc's Cellar paths change
    inreplace "src/mkoctfile.cc" do |s|
      s.gsub! Formula["fftw"].prefix.realpath, Formula["fftw"].opt_prefix
      s.gsub! Formula["gcc"].prefix.realpath, Formula["gcc"].opt_prefix
    end

    system "make", "install"
  end

  test do
    system bin/"octave", "--eval", "(22/7 - pi)/pi"
    # This is supposed to crash octave if there is a problem with veclibfort
    system bin/"octave", "--eval", "single ([1+i 2+i 3+i]) * single ([ 4+i ; 5+i ; 6+i])"
    # Test java bindings: check if javaclasspath is working, return error if not
    system bin/"octave", "--eval", "try; javaclasspath; catch; quit(1); end;" if build.with? "java"
  end
end
