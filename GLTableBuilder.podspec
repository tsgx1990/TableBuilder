#
#  Be sure to run `pod spec lint TableBuilder.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "GLTableBuilder"
  spec.version      = "0.0.2"
  spec.summary      = "Build tableView quickly and easily"
  spec.description  = <<-DESC
  	A framework to build tableView easily
                   DESC
  spec.homepage     = "https://dabao.netlify.com/"
  spec.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  spec.author       = { "dabao" => "dabaotthao@163.com" }
  spec.platform     = :ios, "8.0"
  spec.source       = { :git => "https://github.com/tsgx1990/TableBuilder.git", :tag => "#{spec.version}" }
  spec.source_files  = "TableBuilder/Classes/**/*.{h,m}"
  spec.requires_arc = true

end
