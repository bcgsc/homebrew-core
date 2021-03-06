class Groovy < Formula
  desc "Java-based scripting language"
  homepage "http://www.groovy-lang.org"
  url "https://dl.bintray.com/groovy/maven/apache-groovy-binary-2.4.14.zip"
  sha256 "f9c846e21d9220bac464ffc00eae8f4146f4c26777b61f62e3123da95c6bc52a"

  bottle :unneeded

  option "with-invokedynamic", "Install the InvokeDynamic version of Groovy (only works with Java 1.7+)"

  deprecated_option "invokedynamic" => "with-invokedynamic"

  conflicts_with "groovysdk", :because => "both install the same binaries"

  def install
    # Don't need Windows files.
    rm_f Dir["bin/*.bat"]

    if build.with? "invokedynamic"
      Dir.glob("indy/*.jar") do |src_path|
        dst_file = File.basename(src_path, "-indy.jar") + ".jar"
        dst_path = File.join("lib", dst_file)
        mv src_path, dst_path
      end
    end

    libexec.install %w[bin conf lib embeddable]
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  def caveats
    <<~EOS
      You should set GROOVY_HOME:
        export GROOVY_HOME=#{opt_libexec}
    EOS
  end

  test do
    system "#{bin}/grape", "install", "org.activiti", "activiti-engine", "5.16.4"
  end
end
