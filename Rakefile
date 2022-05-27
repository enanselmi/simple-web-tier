require 'yaml'
require 'fileutils'

# You may want to change this.
def modules_path(environment)
  File.join('environments', environment, 'modules')
end

def terrafile_path(environment)
  File.join('environments', environment, 'Terrafile')
end

def read_terrafile(path)
  if File.exist? path
    YAML.load_file path
  else
    puts "[*] Terrafile does not exist at '#{path}', dependency download will not take place."
    false
  end
end

def create_modules_directory(dir_path)
  unless Dir.exist? dir_path
    puts "[*] Creating Terraform modules directory at '#{dir_path}'"
    FileUtils.makedirs dir_path
  end
end

def delete_cached_terraform_modules(environment)
  puts "[*] Deleting cached Terraform modules at '#{modules_path(environment)}'"
  FileUtils.rm_rf modules_path(environment)
end

desc 'Fetch the Terraform modules listed in the Terrafile'
task :get_modules, :environment do |t, args|
  
  # read the environment's Terrafile
  terrafile =   read_terrafile(terrafile_path(args[:environment]))
  if(terrafile)
    # Try to create the base modules dir if it doesn't exist already
    create_modules_directory(modules_path(args[:environment]))
    # Delete any existing (old) modules
    delete_cached_terraform_modules(args[:environment])
    
    # Keep track of every thread
    threads = {}
    
    # Get dependencies recursively
    terrafile.each do |module_name, repository_details|
      threads[module_name] = Thread.new do
        resolve_terrafile_dependencies(module_name, repository_details, modules_path(args[:environment]))
      end
    end
    # Waint until every thead finish its work
    threads.values.each { |t| t.join }
  end
end

def resolve_terrafile_dependencies(module_name, repository_details, base_destination)
  
      source      = repository_details['source']
      version     = repository_details['version']
      destination = File.join(base_destination, module_name)
      msg         = "Checking out #{version} of #{source} into #{destination}"
      
      clone_was_ok = system("git clone -b #{version} #{source} #{destination} > /dev/null 2>&1")
      if clone_was_ok
        puts "[*] #{msg}"
        # Check if the current module has a Terrafile
        module_terrafile_path = File.join(destination, "Terrafile")
        if File.exist? (module_terrafile_path)
          module_terrafile = read_terrafile(module_terrafile_path)
          module_terrafile.each do |module_dependency_name, module_repository_details|
            module_dependencies_path = File.join(destination, "modules")
            create_modules_directory(module_dependencies_path)
            resolve_terrafile_dependencies(module_dependency_name, module_repository_details, module_dependencies_path)
          end
        end
      else
        puts "[ERROR] #{msg}"
        exit 1
      end
    
end

desc 'Remove Terraform modules path'
task :remove_modules, :environment do |t, args|
  delete_cached_terraform_modules(args[:environment])
end
