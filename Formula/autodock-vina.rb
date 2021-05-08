class AutodockVina < Formula
  desc "Open-source program for doing molecular docking"
  homepage "http://vina.scripps.edu"
  url "https://github.com/navanchauhan/vina/archive/refs/tags/1.1.2.tar.gz"
  sha256 "6d79b7e3766075fc57bacc396829fab1ab3d3b966b4e6b5e1c7f838fe90fed77"
  license "Apache-2.0"

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
