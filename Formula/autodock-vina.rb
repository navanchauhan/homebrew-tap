class AutodockVina < Formula
  desc "Open-source program for doing molecular docking"
  homepage "https://vina.scripps.edu"
  url "https://github.com/ccsb-scripps/AutoDock-Vina/archive/refs/tags/v1.2.5.tar.gz"
  sha256 "38aec306bff0e47522ca8f581095ace9303ae98f6a64031495a9ff1e4b2ff712"
  license "Apache-2.0"

  depends_on "swig" => :build
  depends_on "boost"

  def install
    if OS.mac?
      cd "build/mac/release" do
        inreplace "Makefile" do |s|
          s.gsub! "C_OPTIONS= -O3 -DNDEBUG -std=c++11 -fvisibility=hidden", "C_OPTIONS= -O3 -DNDEBUG \
          -std=c++14 -fvisibility=hidden -DBOOST_TIMER_ENABLE_DEPRECATED"
          s.gsub! "BASE=/usr/local", "BASE=#{HOMEBREW_PREFIX}"
        end
        system "make"
        system "make"
        bin.install "vina"
        bin.install "vina_split"
      end
    else
      cd "build/linux/release" do
        inreplace "Makefile" do |s|
          s.gsub! "C_OPTIONS= -O3 -DNDEBUG -std=c++11", "C_OPTIONS= -O3 -DNDEBUG \
          -std=c++14 -DBOOST_TIMER_ENABLE_DEPRECATED"
          s.gsub! "BASE=/usr/local", "BASE=#{HOMEBREW_PREFIX}"
        end
        system "make"
        system "make"
        bin.install "vina"
        bin.install "vina_split"
      end
    end
  end

  test do
    system "#{HOMEBREW_PREFIX}/bin/vina", "--version"
    system "#{HOMEBREW_PREFIX}/bin/vina_split", "--version"
  end
end
