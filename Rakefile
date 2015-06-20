namespace :test do

  desc "Run the PubNub Integration Tests for iOS"
  task :ios do
    simulators = get_ios_simulators
    destinations = Array.new
    simulators.each {|version, available_simulators|
    destinations.push("platform=iOS Simulator,OS=#{available_simulators[:runtime]},name=#{available_simulators[:device_names][0]}")
    puts "Will run tests for iOS Simulator on iOS #{available_simulators[:runtime]} using #{available_simulators[:device_names][0]}"
    }

    run_tests('iOS Tests', 'iphonesimulator', destinations)
  end

end

desc "Run the PubNub Integration Tests for iOS"
task :test do
  Rake::Task['test:ios'].invoke
end

task :default => 'test'


private

def run_tests(scheme, sdk, destinations)
    destinations = destinations.map! { |destination| "-destination \'#{destination}\'" }.join(' ')
    sh("xcodebuild -workspace PubNub.xcworkspace -scheme '#{scheme}' -sdk '#{sdk}' #{destinations} -configuration 'Debug' clean test | xcpretty -c")
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