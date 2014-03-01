require 'xcodeproj'

class ROADConfigurator
    @@road_attributes_code_generator_url = 'https://github.com/epam/road-ios-framework/raw/master/tools/binaries/ROADAttributesCodeGenerator'

    def self.set_github_credentials(username, password)
        @@github_username = username
        @@github_password = password
    end

    def self.post_install(installer_representation)
        config_path = './ROADConfigurator.yaml'
        if File.exists?(config_path)
          @@config = YAML::load(File.open(config_path))
        end

        road_framework_path = nil
        installer_representation.pods.each do |pod_representation|
            if pod_representation.name == 'ROADFramework'
                road_framework_path = pod_representation.root
            end
        end

        if road_framework_path.nil?
            puts 'ROADConfigurator.rb called without RoadFramework being defined in Podfile.'
            Process.exit!(true)
        end

        ROADConfigurator::download_binaries(installer_representation)
        ROADConfigurator::modify_user_project(installer_representation)
        ROADConfigurator::modify_pods_project(installer_representation)
    end

    def self.modify_user_project(installer_representation)
        installer_representation.installer.analysis_result.targets.each do |target|
            if target.user_project_path.exist? && target.user_target_uuids.any?
                user_project = Xcodeproj::Project.open(target.user_project_path)

                user_targets = Array.new
                target.user_target_uuids.each do |user_target_uuid|
                    user_target = get_target_from_project_by_uuid(user_project, user_target_uuid)
                    if not user_target.nil?
                        user_targets.push(user_target)

                        user_project_dir = File.dirname(user_project.path)
                        genereted_attributes_path = "#{user_project_dir}/#{user_target.name}/ROADGeneratedAttributes"
                        generated_attributes_file_path = ROADConfigurator::create_path_for_generated_attributes_file_for_folder_path(genereted_attributes_path)

                        if !File.exists?(generated_attributes_file_path)
                            ROADConfigurator::create_generated_attributes_folder_and_file_for_path(genereted_attributes_path, generated_attributes_file_path)
                            attributes_file_reference = user_project.new_file(generated_attributes_file_path)
                            user_target.source_build_phase.add_file_reference(attributes_file_reference)
                        end
                    end
                end

                run_script_user = "\"${SRCROOT}/#{target.xcconfig_relative_path.split('Pods/Pods')[0]}binaries/ROADAttributesCodeGenerator\""\
                " -src=\"${SRCROOT}/${PROJECT_NAME}\""\
                " -dst=\"${SRCROOT}/${PROJECT_NAME}/ROADGeneratedAttributes/\""
                ROADConfigurator::add_script_to_project_targets(run_script_user, 'ROAD - generate attributes', user_project, user_targets)
            end
        end
    end

    def self.modify_pods_project(installer_representation)
        installer_representation.project.targets.each do |pods_target|
            if pods_target.name.scan("ROADFramework").size > 0

                #======= Code for work around which works only for repeated command of "pod install" =======
                group_for_genrated_attributes = installer_representation.project.main_group['Pods/ROADFramework/ROADGeneratedAttributes']
                if group_for_genrated_attributes
                    installer_representation.project.main_group['Pods/ROADFramework/ROADGeneratedAttributes'].files.each do |file|
                        file.referrers.each do |referrer|
                            installer_representation.project.objects_by_uuid.delete(referrer.uuid)
                        end
                    end
                    installer_representation.project.objects_by_uuid.delete(installer_representation.project.main_group['Pods/ROADFramework/ROADGeneratedAttributes'].uuid)
                end
                #================================================================================

                path_proj_pods = installer_representation.config.project_pods_root
                genereted_attributes_path = "#{path_proj_pods}/ROADFramework/Framework/ROADGeneratedAttributes"
                generated_attributes_file_path = ROADConfigurator::create_generated_attributes_for_path(genereted_attributes_path)

                run_script_pods = "\"${SRCROOT}/../binaries/ROADAttributesCodeGenerator\""\
                " -src=\"${SRCROOT}/ROADFramework\""\
                " -dst=\"${SRCROOT}/ROADFramework/Framework/ROADGeneratedAttributes/\""
                ROADConfigurator::add_script_to_project_targets(run_script_pods, 'ROAD - generate attributes', installer_representation.project, [pods_target])

                attributes_file_reference = installer_representation.project.new_file(generated_attributes_file_path)
                tempPath = attributes_file_reference.real_path
                attributes_file_reference.move(installer_representation.project.main_group['Pods/ROADFramework/'])
                attributes_file_reference.set_path(tempPath)
                pods_target.source_build_phase.add_file_reference(attributes_file_reference)
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
            
            script_already_added = false
            target.build_phases.each do |build_phase|
                if build_phase.display_name == script_name
                    script_already_added = true
                    break
                end
            end

            next if script_already_added

            target.build_phases.insert(0, phase)
        end
        project.save
    end

    def self.download_binaries(installer_representation)
        binary_path =  "#{installer_representation.config.project_root}/binaries"

        if !File.directory?(binary_path)
            FileUtils.mkdir(binary_path)
        end

        attributes_code_generator_path = "#{binary_path}/ROADAttributesCodeGenerator"

        curl_call = "curl "
        if (defined? @@config)
            curl_call += "-u #{@@config['github_username']}:#{@@config['github_password']} "
        end
        curl_call += "-L -o \"#{attributes_code_generator_path}\" #{@@road_attributes_code_generator_url}"

        puts curl_call

        system curl_call
        system "chmod +x \"#{attributes_code_generator_path}\""
    end
end
