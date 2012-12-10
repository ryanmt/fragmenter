spec = Gem::Specification.new do |s|
  s.name = 'fragmenter'
  s.version = '0.0.2'
  s.summary = "ryanmt's peptide fragmenter"
  s.description = "A peptide sequence fragmenter which will handle graphing and mgf output, as well as command line fragmentation with options"
  s.files = Dir['lib/**/*.rb'] + Dir['test/**/*.rb']
  s.require_path = 'lib'
  s.autorequire = 'fragmenter'
  s.has_rdoc = false
  s.author = "Ryan Taylor"
  s.email = 'ryanmt@byu.net'
  s.homepage = "https://github.com/ryanmt/fragmenter"
end
