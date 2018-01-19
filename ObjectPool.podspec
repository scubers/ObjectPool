

Pod::Spec.new do |s|
    s.name             = 'ObjectPool'
    s.version          = '2.0.0'
    s.summary          = 'A short description of ObjectPool.'

    s.description      = <<-DESC
    TODO: Add long description of the pod here.
                        DESC

    s.homepage         = 'https://github.com/scubers/ObjectPool'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'scubers' => 'jr-wong@qq.com' }

    s.source           = { :git => 'https://github.com/scubers/ObjectPool.git', :tag => s.version.to_s }

    s.ios.deployment_target = '8.0'


    s.source_files = "#{s.name}/Classes/**/*.{h,m}"
    s.public_header_files = "#{s.name}/Classes/**/*.h"


end
