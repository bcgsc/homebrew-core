class Ethereum < Formula
  desc "Official Go implementation of the Ethereum protocol"
  homepage "https://ethereum.github.io/go-ethereum/"
  url "https://github.com/ethereum/go-ethereum/archive/v1.8.6.tar.gz"
  sha256 "c208736b22c3d5610eb2900a622c358b7ce8e2b270cd85e7bcc6b5786ea74225"
  head "https://github.com/ethereum/go-ethereum.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "1fba318625a4615c6fd26fe736ad4c45091e83f4f5021592333fe5819a95a5b1" => :high_sierra
    sha256 "859d8b6a86c326b834c731301cb1881572772c47c5d04895b98f48d6afbbdabf" => :sierra
    sha256 "8a422299180075ed8bfee546b8b46a3548d380a36e367df60affdbd6b707d914" => :el_capitan
    sha256 "6c9bf6fe704e089ba4866d9a48944b0345ad4378a7da110fce014a8a624fbc9f" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    system "make", "all"
    bin.install Dir["build/bin/*"]
  end

  test do
    (testpath/"genesis.json").write <<~EOS
      {
        "config": {
          "homesteadBlock": 10
        },
        "nonce": "0",
        "difficulty": "0x20000",
        "mixhash": "0x00000000000000000000000000000000000000647572616c65787365646c6578",
        "coinbase": "0x0000000000000000000000000000000000000000",
        "timestamp": "0x00",
        "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
        "extraData": "0x",
        "gasLimit": "0x2FEFD8",
        "alloc": {}
      }
    EOS
    system "#{bin}/geth", "--datadir", "testchain", "init", "genesis.json"
    assert_predicate testpath/"testchain/geth/chaindata/000001.log", :exist?,
                     "Failed to create log file"
  end
end
