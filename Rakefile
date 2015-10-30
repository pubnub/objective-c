include FileUtils::Verbose

namespace :test do

  task :prepare do
    puts 'Start'
  end

  desc "Run the PubNub Tests for iOS"
  task :ios => :prepare do
    destinations = get_sims_for_run
    final_exit_status = 0
    destinations.each { |destination|
      puts '**********************************'
      puts destination
      puts '**********************************'
      sleep(5)
      run_tests('iOS Tests (ObjC)', 'iphonesimulator', destination)
      tests_failed('iOS') unless $?.success?
    }
  end

  desc "Run the PubNub Tests for Mac OS X"
  task :osx => :prepare do
    run_tests('OSX Tests (ObjC)', 'macosx', 'platform=OS X,arch=x86_64')
    tests_failed('OSX') unless $?.success?
  end
end

desc "Run the PubNub Tests for iOS & Mac OS X"
task :test do
  Rake::Task['test:ios'].invoke
  Rake::Task['test:osx'].invoke if is_mavericks_or_above
end

task :default => 'test'


private

def run_tests(scheme, sdk, destination)
  sim_destination = "-destination \'#{destination}\'"
  sh("xcodebuild -workspace PubNub.xcworkspace -scheme '#{scheme}' -sdk '#{sdk}' #{sim_destination} -configuration 'Debug' clean test | xcpretty -c ; exit ${PIPESTATUS[0]}") rescue nil
end

def is_mavericks_or_above
  osx_version = `sw_vers -productVersion`.chomp
  Gem::Version.new(osx_version) >= Gem::Version.new('10.8')
end

def tests_failed(platform)
  puts red("#{platform} unit tests failed")
  exit $?.exitstatus
end

def red(string)
 "\033[0;31m! #{string}"
end

def get_sims_for_run
  simulators = get_ios_simulators
  destinations = Array.new
  # collect all sims except for "Resizable sims"
  simulators.each { |version, available_simulators|
    # sims for 7.0.3 exist on Travis CI but not on local machines, so remove
    # because we can't reproduce results locally
    if available_simulators[:runtime] != '7.1' && available_simulators[:runtime] != '7.1.0'
      available_simulators[:device_names].each { |device|
        if !device.match(/^Resizable/)
          destinations.push("platform=iOS Simulator,OS=#{available_simulators[:runtime]},name=#{device}")
          puts "Will run tests for iOS Simulator on iOS #{available_simulators[:runtime]} using #{device}"
        end
      }
    end
  }
  return destinations
end

def get_ios_simulators
  device_section_regex = /== Devices ==(.*?)(?=(?===)|\z)/m
  runtime_section_regex = /== Runtimes ==(.*?)(?=(?===)|\z)/m
  runtime_version_regex  = /iOS (.*) \((.*) - .*?\)/
  xcrun_output = `xcrun simctl list`
  puts "Available iOS Simulators: \n#{xcrun_output}"
  
  simulators = Hash.new
  runtimes_section = xcrun_output.scan(runtime_section_regex)[0]
  runtimes_section[0].scan(runtime_version_regex) {|result|
    simulators[result[0]] = Hash.new
    simulators[result[0]][:runtime] = result[1]
  }
  
  device_section = xcrun_output.scan(device_section_regex)[0]
  version_regex = /-- iOS (.*?) --(.*?)(?=(?=-- .*? --)|\z)/m
  simulator_name_regex = /(.*) \([A-F0-9-]*\) \(.*\)/
  device_section[0].scan(version_regex) {|result| 
    simulators[result[0]][:device_names] = Array.new
    result[1].scan(simulator_name_regex) { |device_name_result| 
      device_name = device_name_result[0].strip
      simulators[result[0]][:device_names].push(device_name)
    }
   }
   return simulators
end
