class Kcp < Formula
  desc "Fast and reliable ARQ protocol over UDP"
  homepage "https://github.com/skywind3000/kcp"
  url "https://github.com/skywind3000/kcp/archive/refs/tags/2.1.1.tar.gz"
  sha256 "54d3c80928d206529f67cba6f96f2c98007182b46e3112819b200d914f96e425"
  license "MIT"

  bottle do
    root_url "https://github.com/dangowrt/comrade/releases/download/v0.1.16"
    sha256 cellar: :any, arm64_tahoe: "9c320af7b48934b70c05539913d5ee3b59eb68d1d30dc50296997acef516b414"
    sha256 cellar: :any, tahoe:       "d940a7b813e0228ff09a9f4dc38bd9731e4baf773aaf97fdf840070de2e346dd"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build

  # Upstream honours BUILD_SHARED_LIBS but sets no VERSION/SOVERSION, so a bare
  # libkcp.dylib is installed. The dylib carries its own install_name, so
  # consumers resolve it regardless; 0 is treated as the packaged ABI epoch.
  def install
    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *std_cmake_args,
           "-DCMAKE_BUILD_TYPE=Release", "-DBUILD_SHARED_LIBS=ON"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"t.c").write <<~C
      #include <ikcp.h>
      int main(void) { ikcpcb *k = ikcp_create(1, 0); ikcp_release(k); return 0; }
    C
    system ENV.cc, "t.c", "-I#{include}", "-L#{lib}", "-lkcp", "-o", "t"
    system "./t"
  end
end
