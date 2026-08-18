class Comrade < Formula
  desc "Serverless peer-to-peer terminal sharing over a punched p2p link"
  homepage "https://github.com/dangowrt/comrade"
  url "https://github.com/dangowrt/comrade.git",
      tag:      "v0.1.1",
      revision: "5d8e01000afa7c4c0d05ee04bd67e81f17b9bff5"
  # The release CI stamps a stable `url` (the tagged commit) and a bottle block
  # into this formula when it pushes the tap, so `brew install comrade` fetches a
  # prebuilt bottle. `head` stays for `brew install --HEAD comrade`, which builds
  # the current tip of main; the build date is taken from the checked-out commit
  # (SOURCE_DATE_EPOCH, honoured by the CMake build) so the result is reproducible.
  head "https://github.com/dangowrt/comrade.git", branch: "main"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/dangowrt/comrade/releases/download/v0.1.1"
    sha256 cellar: :any, arm64_tahoe: "fb5fde85dd32f0b82db7e29a918b445c760761a52376640e709f5529ecc937a9"
    sha256 cellar: :any, tahoe:       "9d56651f55c10314a2e725ccd8e50615cd6cd35630477e83698fd4593f2d8247"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "dangowrt/comrade/libjuice"
  depends_on "dangowrt/comrade/kcp"
  depends_on "dangowrt/comrade/libdht"
  depends_on "libssh"
  depends_on "openssl@3"

  def install
    # Reproducible build date from the commit being built, not the clock. Both
    # the tagged (git url + revision) and --HEAD sources are git checkouts with a
    # .git to read, so this applies to a release build too.
    if File.directory?(".git")
      epoch = Utils.safe_popen_read("git", "log", "-1", "--format=%ct").strip
      ENV["SOURCE_DATE_EPOCH"] = epoch unless epoch.empty?
    end

    # comrade follows libssh's crypto backend; brew's libssh links OpenSSL, so
    # this resolves to the OpenSSL backend. libjuice, kcp and libdht are the
    # shared libraries from their own formulae, linked dynamically like on every
    # other distribution. libdht leaves four symbols for the application, so the
    # binary is linked with -export_dynamic to let the dylib resolve them back.
    prefixes = %w[libjuice kcp libdht openssl@3 libssh]
                 .map { |f| Formula[f].opt_prefix }.join(";")
    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *std_cmake_args,
           "-DCMAKE_BUILD_TYPE=Release",
           "-DCMAKE_PREFIX_PATH=#{prefixes}",
           "-DCOMRADE_CRYPTO=auto",
           "-DBUILD_TESTING=OFF",
           "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-export_dynamic"
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def caveats
    <<~EOS
      Hosting a session needs tmux (joining one does not):
        brew install tmux
    EOS
  end

  test do
    # comrade prints its usage banner on stderr.
    assert_match "start a shared session", shell_output("#{bin}/comrade --help 2>&1")
    assert_match "no running session", shell_output("#{bin}/comrade show 2>&1", 1)
  end
end
