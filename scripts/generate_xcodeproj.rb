require 'fileutils'
require 'xcodeproj'

PROJECT_NAME = 'Earnza'
PROJECT_PATH = "#{PROJECT_NAME}.xcodeproj"
BUNDLE_ID = 'com.earnza.app'

APP_SOURCE_DIRS = %w[App Core Data DesignSystem Features Share].freeze
TEST_SOURCE_DIRS = %w[EarnzaTests].freeze
UI_TEST_SOURCE_DIRS = %w[EarnzaUITests].freeze
RESOURCE_PATHS = [
  'Resources/Assets.xcassets',
  'Resources/MockData/cities.json',
  'Resources/MockData/objects.json',
  'Resources/MockData/fx_rates.json'
].freeze

def ensure_group(parent, path_components)
  current = parent
  path_components.each do |component|
    existing = current.groups.find { |group| group.path == component || group.display_name == component }
    current = existing || current.new_group(component, component)
  end
  current
end

def add_swift_files(project, target, directory)
  Dir.glob("#{directory}/**/*.swift").sort.each do |path|
    components = File.dirname(path).split('/')
    group = ensure_group(project.main_group, components)
    file_ref = group.files.find { |file| file.path == File.basename(path) } || group.new_file(File.basename(path))
    target.add_file_references([file_ref])
  end
end

def add_resource(project, target, relative_path)
  components = File.dirname(relative_path).split('/')
  group = ensure_group(project.main_group, components)
  existing = group.files.find { |file| file.path == File.basename(relative_path) } ||
             group.children.find { |file| file.path == File.basename(relative_path) }
  file_ref = existing || group.new_file(File.basename(relative_path))
  target.resources_build_phase.add_file_reference(file_ref, true)
  file_ref
end

FileUtils.rm_rf(PROJECT_PATH)
project = Xcodeproj::Project.new(PROJECT_PATH)
project.root_object.attributes['LastUpgradeCheck'] = '1640'
project.root_object.attributes['LastSwiftUpdateCheck'] = '1640'

app_target = project.new_target(:application, PROJECT_NAME, :ios, '17.0')
unit_target = project.new_target(:unit_test_bundle, "#{PROJECT_NAME}Tests", :ios, '17.0')
ui_target = project.new_target(:ui_test_bundle, "#{PROJECT_NAME}UITests", :ios, '17.0')

[app_target, unit_target, ui_target].each do |target|
  target.build_configurations.each do |config|
    config.build_settings['SWIFT_VERSION'] = '6.0'
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    config.build_settings['TARGETED_DEVICE_FAMILY'] = '1'
    config.build_settings['ENABLE_TESTABILITY'] = config.name == 'Debug' ? 'YES' : 'NO'
    config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
    config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
    config.build_settings['DEVELOPMENT_TEAM'] = ''
    config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
    config.build_settings['CURRENT_PROJECT_VERSION'] = '1'
    config.build_settings['MARKETING_VERSION'] = '1.0'
    config.build_settings['ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS'] = 'YES'
    config.build_settings['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
    config.build_settings['SUPPORTED_PLATFORMS'] = 'iphoneos iphonesimulator'
  end
end

app_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = BUNDLE_ID
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
  config.build_settings['INFOPLIST_KEY_CFBundleDisplayName'] = PROJECT_NAME
  config.build_settings['INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents'] = 'YES'
  config.build_settings['INFOPLIST_KEY_UILaunchScreen_Generation'] = 'YES'
  config.build_settings['INFOPLIST_KEY_UIRequiresFullScreen'] = 'YES'
  config.build_settings['INFOPLIST_KEY_LSApplicationCategoryType'] = 'public.app-category.finance'
  config.build_settings['DEVELOPMENT_ASSET_PATHS'] = 'Resources/PreviewContent'
  config.build_settings['ENABLE_PREVIEWS'] = 'YES'
end

unit_target.add_dependency(app_target)
ui_target.add_dependency(app_target)

unit_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "#{BUNDLE_ID}Tests"
  config.build_settings['TEST_TARGET_NAME'] = PROJECT_NAME
  config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
  config.build_settings['TEST_HOST'] = "$(BUILT_PRODUCTS_DIR)/#{PROJECT_NAME}.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/#{PROJECT_NAME}"
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks @loader_path/Frameworks'
end

ui_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "#{BUNDLE_ID}UITests"
  config.build_settings['TEST_TARGET_NAME'] = PROJECT_NAME
  config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks @loader_path/Frameworks'
end

APP_SOURCE_DIRS.each { |dir| add_swift_files(project, app_target, dir) }
TEST_SOURCE_DIRS.each { |dir| add_swift_files(project, unit_target, dir) }
UI_TEST_SOURCE_DIRS.each { |dir| add_swift_files(project, ui_target, dir) }
RESOURCE_PATHS.each do |resource|
  ref = add_resource(project, app_target, resource)
  unit_target.resources_build_phase.add_file_reference(ref, true) if resource.end_with?('.json')
end

scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app_target)
scheme.add_build_target(unit_target, false)
scheme.add_build_target(ui_target, false)
scheme.add_test_target(unit_target)
scheme.add_test_target(ui_target)
scheme.set_launch_target(app_target)
scheme.save_as(PROJECT_PATH, PROJECT_NAME, true)

project.sort
project.save
