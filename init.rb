require 'redmine'
require_dependency 'ponderation_hooks'

Redmine::Plugin.register :ponderation do
  name 'Ponderation plugin'
  author 'Smile R&D'
  description "Customisable ticket's priority calcul (require qualification plugin)"
  version '0.1.3'
  settings partial: 'settings/ponderation', default: {}
  project_module 'auto ponderation' do
    permission :ponderation, :public => true
  end
end