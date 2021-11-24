class AutodockVina < Formula
  desc "Open-source program for doing molecular docking"
  homepage "https://vina.scripps.edu"
  url "https://github.com/ccsb-scripps/AutoDock-Vina/archive/refs/tags/v1.2.3.tar.gz"
  sha256 "22f85b2e770b6acc363429153b9551f56e0a0d88d25f747a40d2f55a263608e0"
  license "Apache-2.0"

  depends_on "swig" => :build
  depends_on "boost"

  def install
    if OS.mac?
      cd "build/mac/release" do
        system "make"
        system "make"
        bin.install "vina"
        bin.install "vina_split"
      end
    else
      cd "build/linux/release" do
        system "make"
        system "make"
        bin.install "vina"
        bin.install "vina_split"
      end
    end
  end

  test do
    system "vina", "--version"
    system "vina_split", "--version"
  end
end
