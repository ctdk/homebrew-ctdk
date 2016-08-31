class JovianNoise < Formula
  desc "Forecasts Jupiter decameter radio storms."
  homepage "https://github.com/ctdk/jovian-noise"
  url "https://github.com/ctdk/jovian-noise/archive/v0.1.5.tar.gz"
  sha256 "72aaaf1360ecd072999e3164c5b45b1b7583467c68d69b0c9f786ca21bf2a4f1"

  head "https://github.com/ctdk/jovian-noise.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    jove_path = buildpath/"src/github.com/jove/jove"
    jove_path.install buildpath.children

    cd jove_path do
      system "go", "get", "github.com/ctdk/jovian-noise"
      system "go", "build", "-o", bin/"jovian-noise"
      system "git", "clone", "https://github.com/ctdk/vsop87.git"
      pkgshare.install "vsop87"
    end
  end

  def caveats
    "Make sure the VSOP87 environment variable is set before running jovian-noise. It can either be set in your .bashrc with 'export VSOP87=#{HOMEBREW_PREFIX}/share/jovian-noise/vsop87', or included on the command line like 'VSOP87=#{HOMEBREW_PREFIX}/share/jovian-noise/vsop87 jovian-noise <options>'."
  end

  test do
    require "open3"
    require "timeout"
    system "jovian-noise", "-version"
    ENV["VSOP87"] = pkgshare/"vsop87"
    stdin, stdout, stderr, wait_thr = Open3.popen3("jovian-noise")
    run_success = Timeout.timeout(5) do
      r = false
      stdout.each do |l|
        if l =~ /Jovian Decameter Radio Storm Forecast for:/
          r = true
          break
        end
      end
      r
    end
    stdin.close
    stderr.close
    stdout.close
    wait_thr.value
    run_success
  end
end
