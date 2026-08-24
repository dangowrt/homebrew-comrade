class Libdht < Formula
  desc "Kademlia/mainline BitTorrent DHT library (jech/dht)"
  homepage "https://github.com/jech/dht"
  url "https://github.com/jech/dht/archive/0bbb8f4a5bd914b60de5e9fbb51573aa33a1cf18.tar.gz"
  version "2023.03.18"
  sha256 "5f126d158979d14bcc17ed0debf4d875d662e8fc3fb3e71b29a8835e4044fdeb"
  license "MIT"

  bottle do
    root_url "https://github.com/dangowrt/comrade/releases/download/v0.1.13"
    sha256 cellar: :any, arm64_tahoe: "f307ae5f45ba8a195bab10666f5a8bd0f1d9558d0c15eeb26a8461e0255c4760"
    sha256 cellar: :any, tahoe:       "54a971564fc855ff6c65170ea963392f00de234e2fee8e020b4cdd13a2e073b9"
  end

  # dht.c leaves four symbols (dht_hash, dht_random_bytes, dht_blacklisted,
  # dht_sendto) for the application to define; the consumer's executable
  # supplies them and the dynamic linker resolves them back at runtime. On
  # macOS that means the dylib must permit undefined symbols and the consumer
  # must export its own; comrade links with -export_dynamic to do so.
  def install
    soname = "libdht.dylib"
    system ENV.cc, "-O2", "-fPIC", "-Wall", "-c", "dht.c", "-o", "dht.o"
    if OS.mac?
      system ENV.cc, "-dynamiclib", "-undefined", "dynamic_lookup",
             "-install_name", "#{opt_lib}/#{soname}", "-o", soname, "dht.o"
    else
      soname = "libdht.so.0"
      system ENV.cc, "-shared", "-Wl,-soname,#{soname}", "-o", soname, "dht.o"
    end
    lib.install soname
    lib.install_symlink soname => "libdht.dylib" unless OS.mac?
    (include/"dht").install "dht.h"
    prefix.install "LICENCE"
  end

  test do
    (testpath/"t.c").write <<~C
      #include <dht/dht.h>
      /* the four callbacks jech/dht leaves to the application */
      int dht_blacklisted(const struct sockaddr *sa, int l){(void)sa;(void)l;return 0;}
      void dht_hash(void *d,int dl,const void *s1,int l1,const void *s2,int l2,
                    const void *s3,int l3){(void)d;(void)dl;(void)s1;(void)l1;
                    (void)s2;(void)l2;(void)s3;(void)l3;}
      int dht_random_bytes(void *b,size_t s){(void)b;(void)s;return 0;}
      int dht_sendto(int f,const void *b,int l,int fl,const struct sockaddr *sa,
                     int sl){(void)f;(void)b;(void)l;(void)fl;(void)sa;(void)sl;return 0;}
      int main(void){ return 0; }
    C
    system ENV.cc, "t.c", "-I#{include}", "-L#{lib}", "-ldht", "-o", "t"
    system "./t"
  end
end
