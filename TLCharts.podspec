#
# Be sure to run `pod lib lint TLCharts.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TLCharts'
  s.version          = '1.0.5'
  s.summary          = 'A short description of TLCharts.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/topjx/TLCharts'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'topjx' => '1178860884@qq.com' }
  s.source           = { :git => 'https://github.com/topjx/TLCharts.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  # s.source_files = 'TLCharts/Classes/**/*'
  
  s.subspec 'Util' do |su|
      su.ios.deployment_target = '8.0'
      su.source_files = 'TLCharts/Classes/ORChartUtilities/**/*.{h,m}'
  end
  s.subspec 'Ring' do |ss|
      ss.ios.deployment_target = '8.0'
      ss.source_files = 'TLCharts/Classes/ORRingChart/**/*.{h,m}'
      # ss.public_header_files = 'TLCharts/Classes/ORRingChart/ORRingChartView.h'
      ss.dependency 'TLCharts/Util'
  end
  s.subspec 'Line' do |sss|
      sss.ios.deployment_target = '8.0'
      sss.source_files = 'TLCharts/Classes/ORLineChart/**/*.{h,m}'
      # sss.public_header_files = 'TLCharts/Classes/ORLineChart/ORLineChartView.h'
      sss.dependency 'TLCharts/Util'
  end
  
  # s.resource_bundles = {
  #   'TLCharts' => ['TLCharts/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
