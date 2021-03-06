class Skaffold < Formula
  desc "Easy and Repeatable Kubernetes Development"
  homepage "https://github.com/GoogleContainerTools/skaffold"
  url "https://github.com/GoogleContainerTools/skaffold.git",
      :tag => "v0.5.0",
      :revision => "a9b7884039ae50fbada04e5bdcaf9e43ddf0a3e4"

  bottle do
    cellar :any_skip_relocation
    sha256 "076e488c0a121978a65b2bb0a12152296d41de9a931c4c73d804d51ccf974c82" => :high_sierra
    sha256 "b0f7fd7a1193b2d48e296f8b76154919e1c5b486f41902e05902dd5722c13f4c" => :sierra
    sha256 "0c7b565298d4c346f3c2d92e3f716e488fceb009f2559572f6379fbb08379006" => :el_capitan
    sha256 "691f533266bdb3efe7192211c93bd40dda1718efc1a257c30272b20e2e761df7" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    dir = buildpath/"src/github.com/GoogleContainerTools/skaffold"
    dir.install buildpath.children - [buildpath/".brew_home"]
    cd dir do
      system "make"
      bin.install "out/skaffold"
      prefix.install_metafiles
    end
  end

  test do
    output = shell_output("#{bin}/skaffold version --output {{.GitTreeState}}")
    assert_match "clean", output
  end
end
