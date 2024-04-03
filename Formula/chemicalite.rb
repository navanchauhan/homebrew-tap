class Chemicalite < Formula
  desc "SQLite extension for chemoinformatics applications"
  homepage "https://chemicalite.readthedocs.io/en/latest/"
  url "https://github.com/rvianello/chemicalite/archive/refs/tags/2024.02.1.tar.gz"
  sha256 "fa254bb9a9b15b8fb4befefc28ff12225fdf99ddcf3ee0a5bd749be72283c9e7"
  license "BSD-3-Clause"

  depends_on "catch2" => [:build, :test]
  depends_on "cmake" => :build
  depends_on "sqlite" => [:build, :test]
  depends_on "python3" => [:test]
  depends_on "boost"
  depends_on "rdkit"

  def install
    system "cmake", "-S", ".", "-B", "build", "-DCHEMICALITE_ENABLE_TESTS=OFF", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system "python3", "-c", "import sqlite3; \
    con = sqlite3.connect('chembldb.sql'); \
    con.enable_load_extension(True); \
    con.load_extension('chemicalite'); \
    con.execute( \
    'CREATE TABLE chembl(id INTEGER PRIMARY KEY, chembl_id TEXT, molecule MOL)')"
  end
end
