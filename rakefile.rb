desc 'build'
task :build do
  sh "dub build treemap:file"
  sh "dub build treemap:nofile"
end

desc 'run test'
task :test do
  sh "dub test treemap:core"
end

desc 'run app'
task :run do
  sh "dub run"
end

task :default => :test
