require 'xcodeproj'

class ROADConfigurator
    def self.post_install(installer, config_path = './ROADConfigurator.yml')
        if File.exists?(config_path)
          @@config = YAML::load(File.open(config_path))
        end

        ROADConfigurator::modify_user_project(installer)
    end

    def self.modify_user_project(installer)
        ROADConfigurator::remove_configurator_from_project(installer.pods_project)
        ROADConfigurator::remove_generator_from_project(installer.pods_project)

        installer.analysis_result.targets.each do |target|

            libObjCAttrPod = false
            target.pod_targets.each do |pod_target|
                if pod_target.pod_name == 'libObjCAttr'
                    libObjCAttrPod = true
                end
            end

            if !libObjCAttrPod
                next
            end

            if target.user_project_path.exist? && target.user_target_uuids.any?
                user_project = Xcodeproj::Project.open(target.user_project_path)
                user_project_dir = File.dirname(user_project.path)

                user_targets = Array.new
                target.user_target_uuids.each do |user_target_uuid|
                    user_target = get_target_from_project_by_uuid(user_project, user_target_uuid)
                    if not user_target.nil?
                        user_targets.push(user_target)

                        genereted_attributes_path = "#{user_project_dir}/#{user_target.name}/ROADGeneratedAttributes"
                        generated_attributes_file_path = ROADConfigurator::create_path_for_generated_attributes_file_for_folder_path(genereted_attributes_path)

                        # if 'ROADGeneratedAttribute.m' does not exist
                        if !File.exists?(generated_attributes_file_path)
                            ROADConfigurator::create_generated_attributes_folder_and_file_for_path(genereted_attributes_path, generated_attributes_file_path)
                        end
                        gen_attr_absolute_path = Pathname.new(user_project_dir + create_path_for_generated_attributes_file_for_folder_path("/#{user_target.name}/ROADGeneratedAttributes"))
                        # file have not been added to project
                        attributes_file_reference = user_project.reference_for_path(gen_attr_absolute_path)
                        if !attributes_file_reference
                            attributes_file_reference = user_project.new_file(generated_attributes_file_path)
                            user_target.source_build_phase.add_file_reference(attributes_file_reference)
                        else
                            # if not added to compile build phase
                            if !user_target.source_build_phase.include?(attributes_file_reference)
                                user_target.source_build_phase.add_file_reference(attributes_file_reference)
                            end
                        end
                    end
                end

                run_script_user = "\"${PODS_ROOT}/libObjCAttr/tools/binaries/ROADAttributesCodeGenerator\""\
                " -src=\"${SRCROOT}/${TARGET_NAME}\" -src=\"${PODS_ROOT}\""
                if defined? @@config
                    if @@config['source']
                        attr_source = @@config['source']
                        if attr_source.respond_to?("each")
                            attr_source.each do |attr_source_dir|
                                run_script_user += " -src=#{attr_source_dir}"
                            end
                        else
                            run_script_user += " -src=#{attr_source}"
                        end
                    end
                    if @@config['define_file']
                        attr_def_file = @@config['define_file']
                        if attr_def_file.respond_to?("each")
                            attr_def_file.each do |attr_def_file_path|
                                run_script_user += " -def_file=#{attr_def_file_path}"
                            end
                        else
                            run_script_user += " -def_file=#{attr_def_file}"
                        end
                    end
                    if @@config['exclude']
                        exclude_arg = @@config['exclude']
                        if exclude_arg.respond_to?("each")
                            exclude_arg.each do |exclude_pattern|
                                run_script_user += " -e=#{exclude_pattern}"
                            end
                        else
                            run_script_user += " -e=#{exclude_arg}"
                        end
                    end
                end
                run_script_user += " -dst=\"${SRCROOT}/${TARGET_NAME}/ROADGeneratedAttributes/\""
                ROADConfigurator::add_script_to_project_targets(run_script_user, 'libObjCAttr - generate attributes', user_project, user_targets)
            end
        end
    end

    def self.get_target_from_project_by_uuid(project, uuid)
        project.targets.each do |project_target|
            if project_target.uuid.eql? uuid
                return project_target
            end
        end
        return nil
    end

    def self.create_path_for_generated_attributes_file_for_folder_path(path)
        generated_attributes_file_path = "#{path}/ROADGeneratedAttribute.m"
        generated_attributes_file_path
    end

    def self.create_generated_attributes_folder_and_file_for_path(path, generated_attributes_file_path)
        if !File.exists?(generated_attributes_file_path)
            FileUtils.mkdir_p(path)
            puts "create: #{generated_attributes_file_path}"
            File.new(generated_attributes_file_path, 'w+').close
        end
    end

    def self.create_generated_attributes_for_path(path)
        generated_attributes_file_path = ROADConfigurator::create_path_for_generated_attributes_file_for_folder_path(path)
        ROADConfigurator::create_generated_attributes_folder_and_file_for_path(path, generated_attributes_file_path)
        generated_attributes_file_path
    end

    def self.add_script_to_project_targets(script, script_name, project, targets)
        targets.each do |target|
            phase = project.new(Xcodeproj::Project::PBXShellScriptBuildPhase)
            phase.name = script_name
            phase.shell_script = script

            target.build_phases.each do |build_phase|
                # Removing old version phase too
                if build_phase.display_name == script_name || build_phase.display_name == 'ROAD - generate attributes'
                    build_phase.remove_from_project
                    break
                end
            end

            target.build_phases.insert(0, phase)
        end
        project.save
    end

    def self.remove_configurator_from_project(project)
        path = project.path
        pod_path = File.dirname(path)
        configurator_path = "#{pod_path}/libObjCAttr/libObjCAttr/Resources/ROADConfigurator.rb"
        reference_for_path = project.reference_for_path(configurator_path)
        if !reference_for_path.nil?
            reference_for_path.remove_from_project()
        end
        project.save;
    end

    def self.remove_generator_from_project(project)
        path = project.path
        pod_path = File.dirname(path)
        generator_path = "#{pod_path}/libObjCAttr/tools/binaries/ROADAttributesCodeGenerator"
        reference_for_path = project.reference_for_path(generator_path)
        if !reference_for_path.nil?
            reference_for_path.remove_from_project()
        end
        project.save;
    end

end
