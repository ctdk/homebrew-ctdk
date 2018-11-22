# An update of the homebrew formula at
# https://gist.github.com/bartdorsey/908002f74f1870b3135a for bsdgames-osx,
# bringing it up to current homebrew standards. That formula in turn was an
# updated version of https://gist.github.com/ctdk/5938940, to make it work on
# Yosemite.

class BsdgamesOsx < Formula
  desc "The classic bsdgames of yore, for Mac OS X."
  homepage "https://github.com/ctdk/bsdgames-osx"
  url "https://github.com/ctdk/bsdgames-osx/archive/bsdgames-osx-2.19.3.tar.gz"
  sha256 "699bb294f2c431b9729320f73c7fcd9dcf4226216c15137bb81f7da157bed2a9"
  head "https://github.com/ctdk/bsdgames-osx.git"
  depends_on "bsdmake" => :build

  def install
    ENV.deparallelize
    # This replicates the behavior of wargames calling games from /usr/games
    inreplace "wargames/wargames.sh", "/usr/games", bin
    system "CFLAGS=\"-std=c11\" bsdmake PREFIX=#{prefix} VARDIR=#{HOMEBREW_PREFIX}/var/games"
    user = ENV["USER"]
    ENV["BINOWN"] = user
    ENV["LIBOWN"] = user
    ENV["MANOWN"] = user
    ENV["SHAREOWN"] = user
    system "bsdmake", "install", "PREFIX=#{prefix}", "VARDIR=#{var}/games"
  end

  test do
    %w[pom].each do |game|
      system game
    end
  end
end
