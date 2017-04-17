Pod::Spec.new do |s|
    # 基本信息
    s.name = 'ObjectPool' 
    s.version="1.0.0"
    s.summary = 'summary'
    s.homepage = 'http://www.jrwong.com'
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.author = { 'author' => 'Jrwong' }
    s.ios.deployment_target = '8.0'

    s.source = { :git => 'https://github.com/scubers/ObjectPool.git', :tag => s.version }


    s.source_files = 'Classes/**/*.{h,m}'
    s.public_header_files = 'Classes/**/*.{h}'
    
    # s.dependency 'MJExtension', :exclusive => true        # 类似这样添加自己的内部需要的pod, exclusive表示这个pod自己独有，如果大家都需要的pod，去LYCommon里面加入


 end
