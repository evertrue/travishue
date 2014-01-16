require 'keychain'
require 'travis/pro'

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

command :'travis:watch' do |c|
  c.syntax = 'travis:watch'
  c.summary = 'Watch Travis builds'

  c.action do |args, options|
	token = Keychain.generic_passwords.where(:service => 'travishue').where(:account => 'protoken').first

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

