class BoostForVina < Formula
  desc "Collection of portable C++ source libraries"
  homepage "https://www.boost.org/"
  url "https://boostorg.jfrog.io/artifactory/main/release/1.75.0/source/boost_1_75_0.tar.bz2"
  sha256 "953db31e016db7bb207f11432bef7df100516eeb746843fa0486a222e3fd49cb"
  license "BSL-1.0"

  bottle do
    root_url "https://github.com/navanchauhan/homebrew-tap/releases/download/boost-for-vina-1.75.0"
    sha256 cellar: :any,                 catalina:     "d89416b4c696e0b730c9a2e6271b6343aeb14c1b7e441826ee8d0d50c4fe7c60"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "7708a5cca617e693167f4ca5e713c1d869b0ff09eea4601e6f60ce83a1ac7c02"
  end
  keg_only "it only builds a minimal version"

  # Base copied from https://github.com/Homebrew/homebrew-core/blob/7bee008fe6aa30fe1ebbaaa2f70e98f4b0565e3a/Formula/boost.rb

  depends_on "icu4c"

  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  # Reduce INTERFACE_LINK_LIBRARIES exposure for shared libraries. Remove with the next release.
  patch do
    url "https://github.com/boostorg/boost_install/commit/7b3fc734242eea9af734d6cd8ccb3d8f6b64c5b2.patch?full_index=1"
    sha256 "cd96f5c51fa510fa6cd194eb011c0a6f9beb377fa2e78821133372f76a3be349"
    directory "tools/boost_install"
  end

  # Fix build on 64-bit arm
  patch do
    url "https://github.com/boostorg/build/commit/456be0b7ecca065fbccf380c2f51e0985e608ba0.patch?full_index=1"
    sha256 "e7a78145452fc145ea5d6e5f61e72df7dcab3a6eebb2cade6b4cfae815687f3a"
    directory "tools/build"
  end

  def install
    # Force boost to compile with the desired compiler
    open("user-config.jam", "a") do |file|
      on_macos do
        file.write "using darwin : : #{ENV.cxx} ;\n"
      end
      on_linux do
        file.write "using gcc : : #{ENV.cxx} ;\n"
      end
    end

    # libdir should be set by --prefix but isn't
    icu4c_prefix = Formula["icu4c"].opt_prefix
    bootstrap_args = %W[
      --prefix=#{prefix}
      --libdir=#{lib}
      --with-icu=#{icu4c_prefix}
      --with-libraries=thread,date_time,system,filesystem,program_options,serialization
    ]

    # Handle libraries that will not be built.
    without_libraries = ["python", "mpi"]

    # Boost.Log cannot be built using Apple GCC at the moment. Disabled
    # on such systems.
    without_libraries << "log" if ENV.compiler == :gcc

    # layout should be synchronized with boost-python and boost-mpi
    args = %W[
      --prefix=#{prefix}
      --libdir=#{lib}
      -d2
      -j#{ENV.make_jobs}
      --layout=tagged-1.66
      --user-config=user-config.jam
      -sNO_LZMA=1
      -sNO_ZSTD=1
      install
      threading=multi,single
      link=shared,static
    ]

    # Boost is using "clang++ -x c" to select C compiler which breaks C++14
    # handling using ENV.cxx14. Using "cxxflags" and "linkflags" still works.
    args << "cxxflags=-std=c++14"
    args << "cxxflags=-stdlib=libc++" << "linkflags=-stdlib=libc++" if ENV.compiler == :clang

    system "./bootstrap.sh", *bootstrap_args
    system "./b2", *args
  end

  test do
    system "true"
  end
end
