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
        project = Project.find(context[:issue][:project_id])
        custom_field_values = context[:params][:issue][:custom_field_values]
        weights = Setting.plugin_ponderation['weights']
        field_id = Setting.plugin_ponderation['field_id']

        if !project.enabled_module('auto ponderation') || !custom_field_values || !weights || !field_id
            return nil
        end

        ponderation = 0

        weights.each do |key, value|
            # is a custom field
            if key.match(/\d+/)
                if custom_field_values[key]
                    if value.is_a?(Hash) # the field is a selector
                        weights[key].each do |skey, svalue|
                            if skey === custom_field_values[key]
                                # add the value mapped to the current selector option
                                ponderation += weights[key][skey].to_f
                            end
                        end
                    else
                        ponderation += weights[key].to_f * custom_field_values[key].to_f
                    end
                end
            else # is a default field
                if value.is_a?(Hash) # the field is a selector
                    weights[key].each do |skey, svalue|
                        if skey.to_i === context[:issue][key].to_i
                            # add the value mapped to the current selector option
                            ponderation += weights[key][skey].to_f
                        end
                    end
                else
                    if (key === 'created_on' && !context[:issue]['created_on']) || key === 'updated_on'
                        ponderation += weights[key].to_f * Time.now.to_i
                    else
                        ponderation += weights[key].to_f * context[:issue][key].to_f
                    end
                end
            end
        end
        
        custom_field_values[field_id] = ponderation
    end
end
