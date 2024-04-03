class AutodockVina < Formula
  desc "Open-source program for doing molecular docking"
  homepage "https://vina.scripps.edu"
  url "https://github.com/ccsb-scripps/AutoDock-Vina/archive/refs/tags/v1.2.5.tar.gz"
  sha256 "38aec306bff0e47522ca8f581095ace9303ae98f6a64031495a9ff1e4b2ff712"
  license "Apache-2.0"

  option "with-python-bindings", "Build with python bindings"

  depends_on "swig" => :build
  depends_on "boost"

  depends_on "numpy" => :optional if build.with? "python-bindings"
  depends_on "python" => :optional if build.with? "python-bindings"
  depends_on "python-setuptools" => :optional if build.with? "python-bindings"
  depends_on "python@3.11" => :optional if build.with? "python-bindings"
  depends_on "python@3.12" => :optional if build.with? "python-bindings"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.start_with?("python@") }
        .sort_by(&:version)
  end

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

    if build.with? "python-bindings"
      cd "build/python" do
        inreplace "setup.py" do |s|
          s.gsub! "self.boost_include_dir, self.boost_library_dir = locate_boost()", "self.boost_include_dir, \
          self.boost_library_dir = \"#{HOMEBREW_PREFIX}/include\", \"#{HOMEBREW_PREFIX}/lib\""
          s.gsub! "/usr/local/include", "#{HOMEBREW_PREFIX}/include"
        end
        pythons.each do |python|
          python3 = python.opt_libexec/"bin/python"
          ENV.append "CFLAGS", "-DBOOST_TIMER_ENABLE_DEPRECATED"
          system python3, "-m", "pip", "install", *std_pip_args(build_isolation: true), "."
        end
      end
      ohai "Python bindings installed for python@3.11 python@3.12 and latest version of python@3"
      ohai "You may have to link numpy by running brew link numpy"
    end
  end

  test do
    system "#{HOMEBREW_PREFIX}/bin/vina", "--version"
    system "#{HOMEBREW_PREFIX}/bin/vina_split", "--version"
  end
end
