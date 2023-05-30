Pod::Spec.new do |spec|

  spec.name         = "WYYSDK"
  spec.version      = "0.0.2"
  spec.summary      = "WYYSDK "
  spec.homepage     = "https://github.com/wangyongyue/WYYSDK"
  spec.license      = "MIT"
  spec.author       = "wangyongyue"
  spec.platform     = :ios, "8.0"
  spec.ios.deployment_target = "8.0"
  spec.swift_version = '4.2'
  spec.source       = { :git => "https://github.com/wangyongyue/WYYSDK.git", :tag => "#{spec.version}" }
  spec.source_files = "WYYSDK/Resources/**/*.swift"
  spec.requires_arc = true
  
end
