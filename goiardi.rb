class Goiardi < Formula
  desc "Chef server written in Go."
  homepage "http://goiardi.gl"
  url "https://github.com/ctdk/goiardi/archive/v0.11.5.tar.gz"
  sha256 "26ef9170e0e503a17816f4cca5ef7e2a3fdd7ebdd4bd9091a34d4491db4c23f9"

  head "https://github.com/ctdk/goiardi.git"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    goiardi_path = buildpath/"src/github.com/ctdk/goiardi"
    goiardi_path.install buildpath.children
    cd goiardi_path do
      system "go", "get", "github.com/ctdk/goiardi"
      system "go", "build", "-o", bin/"goiardi"
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

  def plist; <<-EOS.undent
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
