class Goiardi < Formula
  desc "Chef server written in Go."
  homepage "http://goiardi.gl"
  url "https://github.com/ctdk/goiardi/archive/v0.11.7.tar.gz"
  sha256 "a74d81170068e5b138d46c9162b5df43e6e8c5969550cb9df2016f01555755fe"

  head "https://github.com/ctdk/goiardi.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    goiardi_path = buildpath/"src/github.com/ctdk/goiardi"
    goiardi_path.install buildpath.children
    cd goiardi_path do
      system "go", "get", "github.com/ctdk/goiardi"
      system "go", "build", "-o", bin/"goiardi"
      system "#{bin}/goiardi --print-man-page > goiardi.8"
      inreplace "goiardi.8", ".TH goiardi 1", ".TH goiardi 8"
      man8.install "goiardi.8"
      (etc/"goiardi").mkpath
      etc.install "etc/goiardi.conf-sample" => "goiardi/goiardi.conf"
    end
  end

  def post_install
    (var/"log/goiardi").mkpath
    (var/"lib/goiardi").mkpath
  end

  def caveats
    "Goiardi can use MySQL or PostgreSQL as its database backend. If you wish to do so, install your desired variant of either and edit #{HOMEBREW_PREFIX}/etc/goiardi/goiardi.conf accordingly. There is a webui available at https://github.com/ctdk/chef-server-webui for goiardi as well that is outside of the scope of this formula to install.\n\nAlso the sample config file is not suitable for actually running goiardi. Customize it before starting it up.\nNB: If you're upgrading from 0.10.4 or before to 0.11.0 and you're using the Postgres search, run 'knife index rebuild' after upgrading."
  end

  plist_options :manual => "goiardi -c #{HOMEBREW_PREFIX}/etc/goiardi/goiardi.conf"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/goiardi</string>
          <string>--config</string>
          <string>#{etc}/goiardi/goiardi.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}/share/grafana</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/goiardi/goiardi-stderr.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/goiardi/goiardi-stdout.log</string>
        <key>SoftResourceLimits</key>
        <dict>
          <key>NumberOfFiles</key>
          <integer>10240</integer>
        </dict>
      </dict>
    </plist>
    EOS
  end

  test do
    require "pty"
    require "timeout"

    system bin/"goiardi", "-v"

    res = PTY.spawn(bin/"goiardi", "-VVVVV", "-I", "127.0.0.1", "-P", "24545")
    r = res[0]
    w = res[1]
    pid = res[2]

    listening = Timeout.timeout(5) do
      li = false
      r.each do |l|
        if l =~ /Logging at debug level/
          li = true
          break
        end
      end
      li
    end

    Process.kill("TERM", pid)
    w.close
    r.close
    listening
  end
end
