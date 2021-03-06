class CIRequirement < Requirement
  fatal true
  satisfy { ENV["CIRCLECI"].nil? && ENV["TRAVIS"].nil? }
end

class AwsSdkCpp < Formula
  desc "AWS SDK for C++"
  homepage "https://github.com/aws/aws-sdk-cpp"
  # aws-sdk-cpp should only be updated every 10 releases on multiples of 10
  url "https://github.com/aws/aws-sdk-cpp/archive/1.4.40.tar.gz"
  sha256 "bcb510eb9c9c61b0a417246537e48175f64fac92c12408d13390a8922c4ae7a1"
  head "https://github.com/aws/aws-sdk-cpp.git"

  bottle do
    cellar :any
    sha256 "e13c7805787af269eedc96d7e85f0a097105d908445ed3e3b61d71bdea0932a9" => :high_sierra
    sha256 "e7e5759e102698efa8b89deb1f5399c3a8fa8c5326f4476204508ac4914e82a4" => :sierra
    sha256 "6c227c852904d30fcf9bd089fe64c79871bad4a23c0a60d18dd3a02b84bea01f" => :el_capitan
  end

  option "with-static", "Build with static linking"
  option "without-http-client", "Don't include the libcurl HTTP client"

  depends_on "cmake" => :build
  depends_on "curl" unless OS.mac?
  depends_on CIRequirement

  def install
    args = std_cmake_args
    args << "-DSTATIC_LINKING=1" if build.with? "static"
    args << "-DNO_HTTP_CLIENT=1" if build.without? "http-client"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end

    lib.install Dir[lib/"mac/Release/*"].select { |f| File.file? f }
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <aws/core/Version.h>
      #include <iostream>

      int main() {
          std::cout << Aws::Version::GetVersionString() << std::endl;
          return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-o", "test", "-L#{lib}", "-laws-cpp-sdk-core"
    system "./test"
  end
end
