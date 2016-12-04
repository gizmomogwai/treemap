FLAGS = ''
#FLAGS = '--verbose --vverbose'

desc 'build'
task :build do
  sh "dub #{FLAGS} build treemap:core"
  sh "dub #{FLAGS} build treemap:dlangui"
  sh "dub #{FLAGS} build treemap:file"
  sh "dub #{FLAGS} build treemap:nofile"
  sh "dub #{FLAGS} build treemap:zipfs"
end

task :test do
  sh "dub #{FLAGS} test treemap:core"
  sh "dub #{FLAGS} test treemap:dlangui"
  sh "dub #{FLAGS} test treemap:file"
  sh "dub #{FLAGS} test treemap:nofile"
  sh "dub #{FLAGS} test treemap:zipfs"
end

desc 'clean'
task :clean do
  Dir.glob('**/.dub').each do |f|
    sh "rm -rf #{f}"
  end
  Dir.glob('**/dub.selections.json').each do |f|
    sh "rm -rf #{f}"
  end
  sh "rm -rf ~/.dub/packages"
end

task :default => [:test, :build]
