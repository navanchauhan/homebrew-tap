class AutodockVina < Formula
  desc "Open-source program for doing molecular docking"
  homepage "http://vina.scripps.edu"
  url "https://github.com/navanchauhan/vina/archive/refs/tags/1.1.2.tar.gz"
  sha256 "6d79b7e3766075fc57bacc396829fab1ab3d3b966b4e6b5e1c7f838fe90fed77"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/navanchauhan/homebrew-tap/releases/download/autodock-vina-1.1.2"
    sha256 cellar: :any,                 catalina:     "d8d54542a7390d27cf892aa6f6109fc6c2db83ab0eeaa2dc4dd919ed42dc8ead"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c41cb8f8ddc50bc0cf964a0db8d094fa366cdd81a432ea6386d6c509120f5cba"
  end

  depends_on "makedepend" => :build
  depends_on "navanchauhan/homebrew-tap/boost-for-vina"

  def install
    ENV.deparallelize
    cd "build/mac/release" do
      system "make", "depend"
      system "make", "all"
      bin.install "vina"
      bin.install "vina_split"
    end
  end

  test do
    system "vina", "--version"
    system "vina_split", "--version"
  end
end
