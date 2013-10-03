Gem::Specification.new do |s|
  s.name        = 'pachinko'
  s.version     = '0.0.1'
  s.date        = '2013-10-03'
  s.summary     = "A Ruby monkeypatch manager."
  s.description = "Pachinko is a Ruby monkeypatch manager tool attempting to control the unpredictable and difficult-to-troubleshoot regressions possible when monkeypatches run amok and unchecked in a medium to large Ruby codebase."
  s.authors     = ["Peter Marreck"]
  s.email       = 'peter@marreck.com'
  s.files       = ["lib/pachinko.rb"]
  s.homepage    = 'http://rubygems.org/gems/pachinko'
  s.license     = 'BSD 3-Clause'
  s.add_runtime_dependency 'ansi'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'active_support'
end
