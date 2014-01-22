require 'keychain'
require 'travis/pro'
require 'date'

command :'travis:token' do |c|
  c.syntax = 'travis:token TOKEN [...]'
  c.summary = 'Set Travis pro token '

  c.action do |args, options|
    say_error "Missing arguments, expected [TOKEN] (travis token --pro)" and abort if args.nil? or args.empty? or args.count < 1

	Keychain.generic_passwords.create(
		:service => 'travishue', 
		:password => args[0], 
		:account => "protoken")

	puts "Added Token"

  end
end

def seconds_to_temp(current_seconds)
	six_am_temperature = 10000
	six_pm_temperature = 1000

	six_am_seconds = (DateTime.parse("06:00").hour * 3600 + DateTime.parse("06:00").min * 60) + DateTime.parse("06:00").sec
	six_pm_seconds = (DateTime.parse("18:00").hour * 3600 + DateTime.parse("18:00").min * 60) + DateTime.parse("18:00").sec

	seconds_per_degree = (six_pm_seconds - six_am_seconds).to_f / (six_am_temperature - six_pm_temperature).to_f

	current_temperature = (six_am_temperature - ((current_seconds - six_am_seconds) / seconds_per_degree)).to_i

	current_temperature
end

def set_to_temperature_by_current_time(light)
	seconds = (DateTime.now.hour * 3600 + DateTime.now.min * 60) + DateTime.now.sec

	temp = seconds_to_temp(seconds)

	%x(hue #{light} color #{temp})
	puts "Set Light #{light} to color #{temp}"
end

command :'flux:now' do |c|
  c.syntax = 'hue:flux'
  c.summary = 'Do flux cycle'

  c.action do |args, options|

    say_error "Missing arguments, expected [LIGHT NUMBER]" and abort if args.nil? or args.empty? or args.count < 1

	trap("INT") { exit }

	light = args[0]

	set_to_temperature_by_current_time(light)
  end

end

command :'flux:cycle' do |c|
  c.syntax = 'hue:flux'
  c.summary = 'Do flux cycle'

  c.action do |args, options|

    say_error "Missing arguments, expected [LIGHT NUMBER]" and abort if args.nil? or args.empty? or args.count < 1

	trap("INT") { exit }

	light = args[0]

	while true
		set_to_temperature_by_current_time(light)
		sleep(60)
	end
  end

end


command :'travis:watch' do |c|
  c.syntax = 'travis:watch'
  c.summary = 'Watch Travis builds'

  c.action do |args, options|
	token = Keychain.generic_passwords.where(:service => 'travishue').where(:account => 'protoken').first

	trap("INT") { exit }

	say_error "Travis Pro token not stored in keychain.  (Login with the Travis gem first)" and abort if !token

	Travis::Pro.access_token = token.password
	user = Travis::Pro::User.current

	puts "Hello #{user.name}: watching your builds."

	Travis::Pro.listen do |stream|
	  stream.on('build:started', 'build:finished') do |event|
	    puts "#{event.repository.slug} just #{event.build.state}"
	    if event.build.state == 'failed'
	    	%x(hue 1 failed)
	    	%x(hue 2 failed)
	    end

	    if event.build.state == 'errored'
	    	%x(hue 1 failed)
	        %x(hue 2 failed)
	    end

	    if event.build.state == 'passed'
	    	%x(hue 1 passed)
	    	%x(hue 2 passed)
	    end

	    if event.build.state == 'started'
	    	%x(hue 1 started)
	    	%x(hue 2 started)
	    end
	  end
	end
  end

end

