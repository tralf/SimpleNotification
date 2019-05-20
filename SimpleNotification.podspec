#
# Be sure to run `pod lib lint SimpleNotification.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SimpleNotification'
  s.version          = '0.5'
  s.summary          = 'A lightweight wrapper for native notifications with typed event observers.'

  s.description      = <<-DESC
                        A lightweight wrapper for native notifications.
                        Features:
                        1. Easy-to-use Swift-style replacement for Notification and NotificationCenter functionality
                        2. Closure-based - no need to deal with selectors anymore
                        3. Uses the power of Swift generics. Observers wait for a user data with specific type - they get it!
                       DESC

  s.homepage         = 'https://github.com/tralf/SimpleNotification'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Viktor Kalinchuk' => 'viktor.kalinchuk@gmail.com' }
  s.source           = { :git => 'https://github.com/tralf/SimpleNotification.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.source_files = 'SimpleNotification/Source/**/*.swift'
end
