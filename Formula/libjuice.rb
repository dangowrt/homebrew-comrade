class Libjuice < Formula
  desc "UDP Interactive Connectivity Establishment (ICE) library"
  homepage "https://github.com/paullouisageneau/libjuice"
  url "https://github.com/paullouisageneau/libjuice/archive/refs/tags/v1.7.3.tar.gz"
  sha256 "86e075ca4732882746b6d5733ff1b6090f942e5750df58630b191b5f00f30010"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/dangowrt/comrade/releases/download/v0.2.2"
    sha256 cellar: :any, arm64_tahoe: "edd65c92cb876f03924a6a4c88e2a13547b8d2570cae144b9706610bb1e6c1cf"
    sha256 cellar: :any, tahoe:       "4d63c15a79fb1a3f5f6bbd0b19249970cf8ab0f294cf04bdeff3098f6afc1c1a"
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
