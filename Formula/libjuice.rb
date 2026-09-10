class Libjuice < Formula
  desc "UDP Interactive Connectivity Establishment (ICE) library"
  homepage "https://github.com/paullouisageneau/libjuice"
  url "https://github.com/paullouisageneau/libjuice/archive/refs/tags/v1.7.3.tar.gz"
  sha256 "86e075ca4732882746b6d5733ff1b6090f942e5750df58630b191b5f00f30010"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/dangowrt/comrade/releases/download/v0.2.1"
    sha256 cellar: :any, arm64_tahoe: "ebed72c9770a08d2a6db58654d1a5ef18ec54e956c821153177eacd354b9b2c4"
    sha256 cellar: :any, tahoe:       "d626a195b750bfb44224dc51e863a0a4972929f2755f275ac00cf9b7237d20ae"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *std_cmake_args,
           "-DCMAKE_BUILD_TYPE=Release", "-DBUILD_SHARED_LIBS=ON",
           "-DNO_TESTS=ON", "-DUSE_NETTLE=OFF"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"t.c").write <<~C
      #include <juice/juice.h>
      int main(void) { juice_set_log_level(JUICE_LOG_LEVEL_NONE); return 0; }
    C
    system ENV.cc, "t.c", "-I#{include}", "-L#{lib}", "-ljuice", "-o", "t"
    system "./t"
  end
end
