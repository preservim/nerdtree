desc "Copy the vim/doc files into ~/.vim"
task :deploy_local do
  run "cp plugin/NERD_tree.vim ~/.vim/plugin"
  run "cp doc/NERD_tree.txt ~/.vim/doc"
end


desc "Create a zip archive for release to vim.org"
task :zip do
  abort "NERD_tree.zip already exists, aborting" if File.exist?("NERD_tree.zip")
  run "zip NERD_tree.zip plugin/NERD_tree.vim doc/NERD_tree.txt"
end

def run(cmd)
  puts "Executing: #{cmd}"
  system cmd
end

