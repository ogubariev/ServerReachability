Pod::Spec.new do |s|
	s.name = "ServerReachability"
	s.version = "0.0.2"
	s.summary = "ServerReachability - This class help you with checking of access to server by host and port."
	s.license = { :type => "MIT", :file => "LICENSE" }
	s.author = { "Alexey Gubarev" => "gubarev.lesha@gmail.com" }
	s.homepage     = "https://github.com/ogubariev/ServerReachability"
	s.platform = :ios, "6.0"
	s.source = { :git => "https://github.com/ogubariev/ServerReachability.git", :tag => "#{s.version}" }
	s.source_files = "*.{h,m}"
	s.public_header_files = "*.h"
	
	s.framework = "Foundation"
	s.requires_arc = true
end