class Dub < Formula
  desc "Build tool for D projects"
  homepage "https://code.dlang.org/getting_started"
  url "https://github.com/dlang/dub/archive/v1.9.0.tar.gz"
  sha256 "48f7387e93977d0ece686106c9725add2c4f5f36250da33eaa0dbb66900f9d57"
  version_scheme 1

  head "https://github.com/dlang/dub.git"

  devel do
    url "https://github.com/dlang/dub/archive/v1.6.0-beta.2.tar.gz"
    sha256 "da1877c7c39a4905bca78083784733bfae59d60c7b665169d87fe2d81651b38f"
  end

  bottle do
    sha256 "d2793e9348aa4acd0d9a5ce4497e8e5d8233809a2e7656e4f15f3bf3a6618d1d" => :high_sierra
    sha256 "a69c553d1148894029ee83a7a642b3774bd27860b49a07188b93e2ca7b58f7fd" => :sierra
    sha256 "e50dadec35b96a9ef9791ae670b482cb9ab3cc293c249aeab575ad4ce38db304" => :el_capitan
    sha256 "423e1f7fe43843d1755009420ea41acd1599e7e757f3857e63d92ad15296f11b" => :x86_64_linux
  end

  depends_on "pkg-config" => :recommended
  depends_on "dmd" => :build
  depends_on "curl" unless OS.mac?

  def install
    ENV["GITVER"] = version.to_s
    system "./build.sh"
    bin.install "bin/dub"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dub --version").split(/[ ,]/)[2]
  end
end
