require 'redmine'
require_dependency 'ponderation_hooks'

Redmine::Plugin.register :ponderation do
  name 'Ponderation plugin'
  author 'Damien GILLES'
  description "Customisable ticket's priority calcul (require qualification plugin)"
  version '0.1.1'
  settings partial: 'settings/ponderation', default: {}
end