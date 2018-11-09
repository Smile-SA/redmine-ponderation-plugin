require 'uri'
require 'net/http'
require 'json'

class PonderationHooks < Redmine::Hook::ViewListener
    def controller_issues_new_before_save(context)
        setPonderation(context)
    end

    def controller_issues_new_before_save_after_qualification(context)
        setPonderation(context)
    end

    def controller_issues_edit_before_save(context)
        setPonderation(context)
    end

    def setPonderation(context)
        if !Project.find(context[:issue][:project_id]).enabled_module('auto ponderation') || !context[:params][:issue][:custom_field_values]
            return nil
        end

        if Setting.plugin_ponderation['weights']
            ponderation = 0

            Setting.plugin_ponderation['weights'].each do |key, value|
                
                # is a custom field
                if key.match(/\d+/)
                    if context[:params][:issue][:custom_field_values][key]
                        if value.is_a?(Hash) # the field is a selector
                            Setting.plugin_ponderation['weights'][key].each do |skey, svalue|
                                if skey === context[:params][:issue][:custom_field_values][key]
                                    ponderation += Setting.plugin_ponderation['weights'][key][skey].to_f
                                end
                            end
                        else
                            ponderation += Setting.plugin_ponderation['weights'][key].to_f * context[:params][:issue][:custom_field_values][key].to_f
                        end
                    end
                else # is a default field
                    if value.is_a?(Hash) # the field is a selector
                        Setting.plugin_ponderation['weights'][key].each do |skey, svalue|
                            if skey.to_i === context[:issue][key].to_i
                                ponderation += Setting.plugin_ponderation['weights'][key][skey].to_f
                            end
                        end
                    else
                        if (key === 'created_on' && !context[:issue]['created_on']) || key === 'updated_on'
                            ponderation += Setting.plugin_ponderation['weights'][key].to_f * Time.now.to_i
                        else
                            ponderation += Setting.plugin_ponderation['weights'][key].to_f * context[:issue][key].to_f
                        end
                    end
                end
                
            end
            print(ponderation)
            context[:params][:issue][:custom_field_values][Setting.plugin_ponderation['field_id']] = ponderation
        end
    end
end
