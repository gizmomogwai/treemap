desc 'build'
task :build do
  sh "dub build treemap:file"
  sh "dub build treemap:nofile"
  sh "dub build treemap:zipfs"
end

task :test do
  sh "dub test treemap:file"
  sh "dub test treemap:nofile"
  sh "dub test treemap:zipfs"
end
desc 'clean'
task :clean do
  
end

task :default => [:test, :build]
