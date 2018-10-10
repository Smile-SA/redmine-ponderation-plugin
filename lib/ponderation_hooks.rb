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

        if Setting.plugin_ponderation['weights']
            ponderation = 0

            Setting.plugin_ponderation['weights'].each do |key, value|
                if key.match(/\d+/) # is a custom field
                    if value.is_a?(Hash) # the field is a selector
                        Setting.plugin_ponderation['weights'][key].each do |skey, svalue|
                            if skey === context[:params][:issue][:custom_field_values][key]
                                ponderation += Setting.plugin_ponderation['weights'][key][skey].to_f
                            end
                        end
                    else
                        ponderation += Setting.plugin_ponderation['weights'][key].to_f * context[:params][:issue][:custom_field_values][key].to_f
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

            custom_field_values = context[:params][:issue][:custom_field_values]
            custom_field_values[Setting.plugin_ponderation['field_id']] = ponderation
            
            context[:issue].custom_field_values = custom_field_values
        end
    end
end
