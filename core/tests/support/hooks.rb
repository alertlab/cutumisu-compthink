Before('@fakefs') do
   begin
      FakeFS.activate!
      FakeFS::FileSystem.clear
   rescue StandardError => e
      Kernel.abort(([e.message] + e.backtrace).join("\n"))
   end
end

After('@fakefs') do
   FakeFS.deactivate!
end
