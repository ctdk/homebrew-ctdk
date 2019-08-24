# An update of the homebrew formula at
# https://gist.github.com/bartdorsey/908002f74f1870b3135a for bsdgames-osx,
# bringing it up to current homebrew standards. That formula in turn was an
# updated version of https://gist.github.com/ctdk/5938940, to make it work on
# Yosemite.

class BsdgamesOsx < Formula
  desc "The classic bsdgames of yore, for Mac OS X."
  homepage "https://github.com/ctdk/bsdgames-osx"
  url "https://github.com/ctdk/bsdgames-osx/archive/bsdgames-osx-2.19.4.tar.gz"
  sha256 "ae27651e709783e3f76038c85753d53ee36f86b4116802760c977595e284555d"

  head "https://github.com/ctdk/bsdgames-osx.git"

  depends_on "bsdmake" => :build

  def install
    # If, for whatever reason, ENV.deparallelize doesn't work for you, try
    # changing it to ENV.j1
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
