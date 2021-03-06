class Cryptopp < Formula
  desc "Free C++ class library of cryptographic schemes"
  homepage "https://www.cryptopp.com/"
  url "https://downloads.sourceforge.net/project/cryptopp/cryptopp/5.6.3/cryptopp563.zip"
  mirror "https://www.cryptopp.com/cryptopp563.zip"
  version "5.6.3"
  sha256 "9390670a14170dd0f48a6b6b06f74269ef4b056d4718a1a329f6f6069dc957c9"
  revision 1

  # https://cryptopp.com/wiki/Config.h#Options_and_Defines
  bottle :disable, "Library and clients must be built on the same microarchitecture"

  option :cxx11

  patch do
    # fix failing test
    # https://github.com/Homebrew/homebrew-core/issues/2783
    # http://comments.gmane.org/gmane.comp.encryption.cryptopp/8028
    url "https://github.com/weidai11/cryptopp/commit/0059f48.diff"
    sha256 "f75d6cf87f00dfa98839a89a3c0c57dc26c1739916d6d5c0abbd9228b0a01829"
  end

  def install
    ENV.cxx11 if build.cxx11?
    system "make", "shared", "all", "CXX=#{ENV.cxx}"
    system "./cryptest.exe", "v"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <cryptopp/sha.h>
      #include <string>
      using namespace CryptoPP;
      using namespace std;

      int main()
      {
        byte digest[SHA::DIGESTSIZE];
        string data = "Hello World!";
        SHA().CalculateDigest(digest, (byte*) data.c_str(), data.length());
        return 0;
      }
    EOS
    ENV.cxx11 if build.cxx11?
    system ENV.cxx, "test.cpp", "-L#{lib}", "-lcryptopp", "-o", "test"
    system "./test"
  end
end
