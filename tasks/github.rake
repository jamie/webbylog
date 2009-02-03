namespace :git do
  desc 'Create a ghpages branch, mount in /output'
  task :setup_ghpages
  
  desc 'Commit and push /output'
  task :publish
end
