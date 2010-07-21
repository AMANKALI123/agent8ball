require File.expand_path('../../../config/application', __FILE__)
require 'rake'
require 'util'

module JsCompile
  def self.work
    dir = 'box2d'
    tmp_file = Util.create_temp_file('js_concat')

    prototype_lite_path = File.join(Rails.root, 'public','javascripts','prototype_lite.js')

    concat(dir, tmp_file)
    compile([tmp_file.path], [prototype_lite_path])
  end

  def self.concat(dir, temp_file)
    js_dir = File.join(Rails.root, 'public','javascripts')
    files = Util.get_js_dir(dir)
    files.collect!{ |file_name| File.join(js_dir, file_name)}

    files.each do |file_name|
      File.open(file_name) do |file|
        temp_file << file.read
        temp_file.flush
      end
    end

    temp_file.rewind
  end

  def self.compile(js_file_paths, dependencies = [])
    compiler_jar_path = File.join(Rails.root, 'vendor/jars/closure_compiler/compiler.jar')
    compiled_output_path = js_file_paths[0] + '_compiled.js'

    sys_command = "java -jar #{compiler_jar_path}"

    js_file_paths.each do |file|
      sys_command << " --js #{file}"
    end

    dependencies.each do |file|
      sys_command << " --externs #{file}"
    end

    sys_command << " --js_output_file #{compiled_output_path} --compilation_level ADVANCED_OPTIMIZATIONS --summary_detail_level 3 --debug 1 --warning_level VERBOSE --manage_closure_dependencies 1"

    #sys_command = "java -jar #{compiler_jar_path} --help"

    puts sys_command.inspect
    `#{sys_command}`
  end

end

namespace :js do
  desc 'Concat and compile the local javascript'
  task :compile do
    JsCompile.work
  end
end

if(__FILE__ == $0)
  JsCompile.work
  #([File.join(Rails.root, 'public','javascripts','eightball', 'PoolTable.js'),File.join(Rails.root, 'public/javascripts/closure-library/closure/goog/base.js')])
end