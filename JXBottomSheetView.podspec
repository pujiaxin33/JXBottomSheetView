
Pod::Spec.new do |s|
  s.name         = "JXBottomSheetView"
  s.version      = "0.0.3"
  s.summary      = "可以手势交互的底部列表视图"
  s.homepage     = "https://github.com/pujiaxin33/JXBottomSheetView"
  s.license      = "MIT"
  s.author       = { "pujiaxin33" => "317437084@qq.com" }
  s.platform     = :ios, "9.0"
  s.swift_version = "4.0"
  s.source       = { :git => "https://github.com/pujiaxin33/JXBottomSheetView.git", :tag => "#{s.version}" }
  s.framework    = "UIKit"
  s.source_files  = "Sources", "Sources/*.{swift}"
  s.requires_arc = true
end
