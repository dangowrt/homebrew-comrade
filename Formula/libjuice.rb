class Libjuice < Formula
  desc "UDP Interactive Connectivity Establishment (ICE) library"
  homepage "https://github.com/paullouisageneau/libjuice"
  url "https://github.com/paullouisageneau/libjuice/archive/refs/tags/v1.7.3.tar.gz"
  sha256 "86e075ca4732882746b6d5733ff1b6090f942e5750df58630b191b5f00f30010"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/dangowrt/comrade/releases/download/v0.1.16"
    sha256 cellar: :any, arm64_tahoe: "b6227525bcf043fddc8b8642e408b47045246aa5cf82543de302f0c73350c04a"
    sha256 cellar: :any, tahoe:       "6ea0f5c31005f0b90b5f9f568e70f9e25b2790181087d6920685162003053a8a"
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
