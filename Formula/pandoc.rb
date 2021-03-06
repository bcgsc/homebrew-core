require "language/haskell"

class Pandoc < Formula
  include Language::Haskell::Cabal

  desc "Swiss-army knife of markup format conversion"
  homepage "https://pandoc.org/"
  url "https://hackage.haskell.org/package/pandoc-2.2/pandoc-2.2.tar.gz"
  sha256 "0f2984a6ea4948392154ecdcffcc21c561976c63f9c8aa648a56a677b80e8569"
  head "https://github.com/jgm/pandoc.git"

  bottle do
    sha256 "774554af79225ae040b25a87b9d762817d650e55c7016032f31f88076c69392f" => :high_sierra
    sha256 "01dc946af86b59324acd67e8448a5e582f4e23ef5a5ec24653b7868343864399" => :sierra
    sha256 "7c46b680f10275d25e48a53ccf5aa492fa7028397247403eb6ddfdd4abdc2554" => :el_capitan
    sha256 "fdde42d89c3cee9f74d66089c32bb2f71e7f57ef3e573dfe873a7c832581df8d" => :x86_64_linux
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  unless OS.mac?
    depends_on "unzip" => :build # for cabal install
    depends_on "zlib"
  end

  def install
    cabal_sandbox do
      args = []
      args << "--constraint=cryptonite -support_aesni" if MacOS.version <= :lion
      install_cabal_package *args
    end
    (bash_completion/"pandoc").write `#{bin}/pandoc --bash-completion`
  end

  test do
    input_markdown = <<~EOS
      # Homebrew

      A package manager for humans. Cats should take a look at Tigerbrew.
    EOS
    expected_html = <<~EOS
      <h1 id="homebrew">Homebrew</h1>
      <p>A package manager for humans. Cats should take a look at Tigerbrew.</p>
    EOS
    assert_equal expected_html, pipe_output("#{bin}/pandoc -f markdown -t html5", input_markdown)
  end
end
