import DemoAppGeneratorContract
import Package
import Foundation

public struct DemoAppGenerator: DemoAppGeneratorProtocol {
    private let fileManager: FileManager
    private let packageNameProvider: PackageNameProviding
    
    public init(packageNameProvider: PackageNameProviding,
                fileManager: FileManager = .default) {
        self.packageNameProvider = packageNameProvider
        self.fileManager = fileManager
    }
    
    public func generateDemoApp(forComponent component: Component,
                                of family: Family,
                                at url: URL,
                                relativeURL: URL) throws {
        let name = packageNameProvider.packageName(forComponentName: component.name, of: family, packageConfiguration: .init(name: "", appendPackageName: false, hasTests: false))
        let finalURL = url
            .appendingPathComponent("\(name)DemoApp")
            .appendingPathComponent("\(name)DemoApp.xcodeproj")
        
        try fileManager.createDirectory(at: finalURL,
                                        withIntermediateDirectories: true)
        
        let pbxProbjectFileURL = finalURL
            .appendingPathComponent("project.pbxproj")
        fileManager.createFile(atPath: pbxProbjectFileURL.path,
                               contents: pbxProjectContent(forComponent: component).data(using: .utf8))
        
        let diffURL = URL(fileURLWithPath: url.path, isDirectory: true, relativeTo: relativeURL)
        print(diffURL)
    }
    
    func pbxProjectContent(forComponent component: Component) -> String {
"""
// !$*UTF8*$!
{
    archiveVersion = 1;
    classes = {
    };
    objectVersion = 55;
    objects = {

/* Begin PBXBuildFile section */
        B25E01A428B5009100C657EC /* Dependencies in Frameworks */ = {isa = PBXBuildFile; productRef = B25E01A328B5009100C657EC /* Dependencies */; };
        B2A0ED0B28B4FD7000DDB478 /* AppDelegate.swift in Sources */ = {isa = PBXBuildFile; fileRef = B2A0ED0A28B4FD7000DDB478 /* AppDelegate.swift */; };
        B2A0ED0D28B4FD7000DDB478 /* SceneDelegate.swift in Sources */ = {isa = PBXBuildFile; fileRef = B2A0ED0C28B4FD7000DDB478 /* SceneDelegate.swift */; };
        B2A0ED0F28B4FD7000DDB478 /* ViewController.swift in Sources */ = {isa = PBXBuildFile; fileRef = B2A0ED0E28B4FD7000DDB478 /* ViewController.swift */; };
        B2A0ED1428B4FD7100DDB478 /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = B2A0ED1328B4FD7100DDB478 /* Assets.xcassets */; };
        B2A0ED1728B4FD7100DDB478 /* LaunchScreen.storyboard in Resources */ = {isa = PBXBuildFile; fileRef = B2A0ED1528B4FD7100DDB478 /* LaunchScreen.storyboard */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
        B214226F28B7E0BA00FD7132 /* ActionSheetFeature */ = {isa = PBXFileReference; lastKnownFileType = wrapper; name = ActionSheetFeature; path = ../../../../HelloFresh/Modules/Features/ActionSheetFeature; sourceTree = "<group>"; };
        B214227028B7E0C200FD7132 /* ActionSheetFeatureContract */ = {isa = PBXFileReference; lastKnownFileType = wrapper; name = ActionSheetFeatureContract; path = ../../../../HelloFresh/Modules/Contracts/Features/ActionSheetFeatureContract; sourceTree = "<group>"; };
        B214227128B7E0C700FD7132 /* HFNavigator */ = {isa = PBXFileReference; lastKnownFileType = wrapper; name = HFNavigator; path = ../../../../HelloFresh/Modules/Support/HFNavigator; sourceTree = "<group>"; };
        B214227228B7E0CC00FD7132 /* HFNavigatorContract */ = {isa = PBXFileReference; lastKnownFileType = wrapper; name = HFNavigatorContract; path = ../../../../HelloFresh/Modules/Contracts/Support/HFNavigatorContract; sourceTree = "<group>"; };
        B214227328B7E0D100FD7132 /* HFNavigatorMock */ = {isa = PBXFileReference; lastKnownFileType = wrapper; name = HFNavigatorMock; path = ../../../../HelloFresh/Modules/Mocks/Support/HFNavigatorMock; sourceTree = "<group>"; };
        B214227428B7E0DA00FD7132 /* HxD */ = {isa = PBXFileReference; lastKnownFileType = wrapper; name = HxD; path = ../../../../HelloFresh/Modules/Support/HxD; sourceTree = "<group>"; };
        B25E01A128B5008A00C657EC /* Dependencies */ = {isa = PBXFileReference; lastKnownFileType = wrapper; path = Dependencies; sourceTree = "<group>"; };
        B2A0ED0728B4FD7000DDB478 /* ActionSheetFeatureDemoApp.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = ActionSheetFeatureDemoApp.app; sourceTree = BUILT_PRODUCTS_DIR; };
        B2A0ED0A28B4FD7000DDB478 /* AppDelegate.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppDelegate.swift; sourceTree = "<group>"; };
        B2A0ED0C28B4FD7000DDB478 /* SceneDelegate.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SceneDelegate.swift; sourceTree = "<group>"; };
        B2A0ED0E28B4FD7000DDB478 /* ViewController.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ViewController.swift; sourceTree = "<group>"; };
        B2A0ED1328B4FD7100DDB478 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
        B2A0ED1628B4FD7100DDB478 /* Base */ = {isa = PBXFileReference; lastKnownFileType = file.storyboard; name = Base; path = Base.lproj/LaunchScreen.storyboard; sourceTree = "<group>"; };
        B2A0ED1828B4FD7100DDB478 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
        B2A0ED0428B4FD7000DDB478 /* Frameworks */ = {
            isa = PBXFrameworksBuildPhase;
            buildActionMask = 2147483647;
            files = (
                B25E01A428B5009100C657EC /* Dependencies in Frameworks */,
            );
            runOnlyForDeploymentPostprocessing = 0;
        };
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
        B214226E28B7E0B200FD7132 /* Packages */ = {
            isa = PBXGroup;
            children = (
                B214227428B7E0DA00FD7132 /* HxD */,
                B214227328B7E0D100FD7132 /* HFNavigatorMock */,
                B214227228B7E0CC00FD7132 /* HFNavigatorContract */,
                B214227128B7E0C700FD7132 /* HFNavigator */,
                B214226F28B7E0BA00FD7132 /* ActionSheetFeature */,
                B214227028B7E0C200FD7132 /* ActionSheetFeatureContract */,
            );
            path = Packages;
            sourceTree = "<group>";
        };
        B25E01A228B5009100C657EC /* Frameworks */ = {
            isa = PBXGroup;
            children = (
            );
            name = Frameworks;
            sourceTree = "<group>";
        };
        B2A0ECFE28B4FD7000DDB478 = {
            isa = PBXGroup;
            children = (
                B214226E28B7E0B200FD7132 /* Packages */,
                B25E01A128B5008A00C657EC /* Dependencies */,
                B2A0ED0928B4FD7000DDB478 /* ActionSheetFeature */,
                B2A0ED0828B4FD7000DDB478 /* Products */,
                B25E01A228B5009100C657EC /* Frameworks */,
            );
            sourceTree = "<group>";
        };
        B2A0ED0828B4FD7000DDB478 /* Products */ = {
            isa = PBXGroup;
            children = (
                B2A0ED0728B4FD7000DDB478 /* ActionSheetFeatureDemoApp.app */,
            );
            name = Products;
            sourceTree = "<group>";
        };
        B2A0ED0928B4FD7000DDB478 /* ActionSheetFeature */ = {
            isa = PBXGroup;
            children = (
                B2A0ED0A28B4FD7000DDB478 /* AppDelegate.swift */,
                B2A0ED0C28B4FD7000DDB478 /* SceneDelegate.swift */,
                B2A0ED0E28B4FD7000DDB478 /* ViewController.swift */,
                B2A0ED1328B4FD7100DDB478 /* Assets.xcassets */,
                B2A0ED1528B4FD7100DDB478 /* LaunchScreen.storyboard */,
                B2A0ED1828B4FD7100DDB478 /* Info.plist */,
            );
            path = ActionSheetFeature;
            sourceTree = "<group>";
        };
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
        B2A0ED0628B4FD7000DDB478 /* ActionSheetFeatureDemoApp */ = {
            isa = PBXNativeTarget;
            buildConfigurationList = B2A0ED1B28B4FD7100DDB478 /* Build configuration list for PBXNativeTarget "ActionSheetFeatureDemoApp" */;
            buildPhases = (
                B2A0ED0328B4FD7000DDB478 /* Sources */,
                B2A0ED0428B4FD7000DDB478 /* Frameworks */,
                B2A0ED0528B4FD7000DDB478 /* Resources */,
            );
            buildRules = (
            );
            dependencies = (
            );
            name = ActionSheetFeatureDemoApp;
            packageProductDependencies = (
                B25E01A328B5009100C657EC /* Dependencies */,
            );
            productName = ActionSheetFeature;
            productReference = B2A0ED0728B4FD7000DDB478 /* ActionSheetFeatureDemoApp.app */;
            productType = "com.apple.product-type.application";
        };
/* End PBXNativeTarget section */

/* Begin PBXProject section */
        B2A0ECFF28B4FD7000DDB478 /* Project object */ = {
            isa = PBXProject;
            attributes = {
                BuildIndependentTargetsInParallel = 1;
                LastSwiftUpdateCheck = 1340;
                LastUpgradeCheck = 1340;
                TargetAttributes = {
                    B2A0ED0628B4FD7000DDB478 = {
                        CreatedOnToolsVersion = 13.4.1;
                    };
                };
            };
            buildConfigurationList = B2A0ED0228B4FD7000DDB478 /* Build configuration list for PBXProject "ActionSheetFeatureDemoApp" */;
            compatibilityVersion = "Xcode 13.0";
            developmentRegion = en;
            hasScannedForEncodings = 0;
            knownRegions = (
                en,
                Base,
            );
            mainGroup = B2A0ECFE28B4FD7000DDB478;
            productRefGroup = B2A0ED0828B4FD7000DDB478 /* Products */;
            projectDirPath = "";
            projectRoot = "";
            targets = (
                B2A0ED0628B4FD7000DDB478 /* ActionSheetFeatureDemoApp */,
            );
        };
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
        B2A0ED0528B4FD7000DDB478 /* Resources */ = {
            isa = PBXResourcesBuildPhase;
            buildActionMask = 2147483647;
            files = (
                B2A0ED1728B4FD7100DDB478 /* LaunchScreen.storyboard in Resources */,
                B2A0ED1428B4FD7100DDB478 /* Assets.xcassets in Resources */,
            );
            runOnlyForDeploymentPostprocessing = 0;
        };
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
        B2A0ED0328B4FD7000DDB478 /* Sources */ = {
            isa = PBXSourcesBuildPhase;
            buildActionMask = 2147483647;
            files = (
                B2A0ED0F28B4FD7000DDB478 /* ViewController.swift in Sources */,
                B2A0ED0B28B4FD7000DDB478 /* AppDelegate.swift in Sources */,
                B2A0ED0D28B4FD7000DDB478 /* SceneDelegate.swift in Sources */,
            );
            runOnlyForDeploymentPostprocessing = 0;
        };
/* End PBXSourcesBuildPhase section */

/* Begin PBXVariantGroup section */
        B2A0ED1528B4FD7100DDB478 /* LaunchScreen.storyboard */ = {
            isa = PBXVariantGroup;
            children = (
                B2A0ED1628B4FD7100DDB478 /* Base */,
            );
            name = LaunchScreen.storyboard;
            sourceTree = "<group>";
        };
/* End PBXVariantGroup section */

/* Begin XCBuildConfiguration section */
        B2A0ED1928B4FD7100DDB478 /* Debug */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ALWAYS_SEARCH_USER_PATHS = NO;
                CLANG_ANALYZER_NONNULL = YES;
                CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
                CLANG_CXX_LANGUAGE_STANDARD = "gnu++17";
                CLANG_ENABLE_MODULES = YES;
                CLANG_ENABLE_OBJC_ARC = YES;
                CLANG_ENABLE_OBJC_WEAK = YES;
                CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
                CLANG_WARN_BOOL_CONVERSION = YES;
                CLANG_WARN_COMMA = YES;
                CLANG_WARN_CONSTANT_CONVERSION = YES;
                CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
                CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
                CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
                CLANG_WARN_EMPTY_BODY = YES;
                CLANG_WARN_ENUM_CONVERSION = YES;
                CLANG_WARN_INFINITE_RECURSION = YES;
                CLANG_WARN_INT_CONVERSION = YES;
                CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
                CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
                CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
                CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
                CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
                CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
                CLANG_WARN_STRICT_PROTOTYPES = YES;
                CLANG_WARN_SUSPICIOUS_MOVE = YES;
                CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
                CLANG_WARN_UNREACHABLE_CODE = YES;
                CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
                COPY_PHASE_STRIP = NO;
                DEBUG_INFORMATION_FORMAT = dwarf;
                ENABLE_STRICT_OBJC_MSGSEND = YES;
                ENABLE_TESTABILITY = YES;
                GCC_C_LANGUAGE_STANDARD = gnu11;
                GCC_DYNAMIC_NO_PIC = NO;
                GCC_NO_COMMON_BLOCKS = YES;
                GCC_OPTIMIZATION_LEVEL = 0;
                GCC_PREPROCESSOR_DEFINITIONS = (
                    "DEBUG=1",
                    "$(inherited)",
                );
                GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
                GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
                GCC_WARN_UNDECLARED_SELECTOR = YES;
                GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
                GCC_WARN_UNUSED_FUNCTION = YES;
                GCC_WARN_UNUSED_VARIABLE = YES;
                IPHONEOS_DEPLOYMENT_TARGET = 15.5;
                MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
                MTL_FAST_MATH = YES;
                ONLY_ACTIVE_ARCH = YES;
                SDKROOT = iphoneos;
                SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
                SWIFT_OPTIMIZATION_LEVEL = "-Onone";
            };
            name = Debug;
        };
        B2A0ED1A28B4FD7100DDB478 /* Release */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ALWAYS_SEARCH_USER_PATHS = NO;
                CLANG_ANALYZER_NONNULL = YES;
                CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
                CLANG_CXX_LANGUAGE_STANDARD = "gnu++17";
                CLANG_ENABLE_MODULES = YES;
                CLANG_ENABLE_OBJC_ARC = YES;
                CLANG_ENABLE_OBJC_WEAK = YES;
                CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
                CLANG_WARN_BOOL_CONVERSION = YES;
                CLANG_WARN_COMMA = YES;
                CLANG_WARN_CONSTANT_CONVERSION = YES;
                CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
                CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
                CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
                CLANG_WARN_EMPTY_BODY = YES;
                CLANG_WARN_ENUM_CONVERSION = YES;
                CLANG_WARN_INFINITE_RECURSION = YES;
                CLANG_WARN_INT_CONVERSION = YES;
                CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
                CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
                CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
                CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
                CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
                CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
                CLANG_WARN_STRICT_PROTOTYPES = YES;
                CLANG_WARN_SUSPICIOUS_MOVE = YES;
                CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
                CLANG_WARN_UNREACHABLE_CODE = YES;
                CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
                COPY_PHASE_STRIP = NO;
                DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
                ENABLE_NS_ASSERTIONS = NO;
                ENABLE_STRICT_OBJC_MSGSEND = YES;
                GCC_C_LANGUAGE_STANDARD = gnu11;
                GCC_NO_COMMON_BLOCKS = YES;
                GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
                GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
                GCC_WARN_UNDECLARED_SELECTOR = YES;
                GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
                GCC_WARN_UNUSED_FUNCTION = YES;
                GCC_WARN_UNUSED_VARIABLE = YES;
                IPHONEOS_DEPLOYMENT_TARGET = 15.5;
                MTL_ENABLE_DEBUG_INFO = NO;
                MTL_FAST_MATH = YES;
                SDKROOT = iphoneos;
                SWIFT_COMPILATION_MODE = wholemodule;
                SWIFT_OPTIMIZATION_LEVEL = "-O";
                VALIDATE_PRODUCT = YES;
            };
            name = Release;
        };
        B2A0ED1C28B4FD7100DDB478 /* Debug */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 1;
                DEVELOPMENT_TEAM = 2A7X7KDSR2;
                GENERATE_INFOPLIST_FILE = YES;
                INFOPLIST_FILE = ActionSheetFeature/Info.plist;
                INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
                INFOPLIST_KEY_UILaunchStoryboardName = LaunchScreen;
                INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
                INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
                LD_RUNPATH_SEARCH_PATHS = (
                    "$(inherited)",
                    "@executable_path/Frameworks",
                );
                MARKETING_VERSION = 1.0;
                PRODUCT_BUNDLE_IDENTIFIER = com.hellofresh.iosdemos.ActionSheetFeature;
                PRODUCT_NAME = "$(TARGET_NAME)";
                SWIFT_EMIT_LOC_STRINGS = YES;
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = "1,2";
            };
            name = Debug;
        };
        B2A0ED1D28B4FD7100DDB478 /* Release */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 1;
                DEVELOPMENT_TEAM = 2A7X7KDSR2;
                GENERATE_INFOPLIST_FILE = YES;
                INFOPLIST_FILE = ActionSheetFeature/Info.plist;
                INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
                INFOPLIST_KEY_UILaunchStoryboardName = LaunchScreen;
                INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
                INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
                LD_RUNPATH_SEARCH_PATHS = (
                    "$(inherited)",
                    "@executable_path/Frameworks",
                );
                MARKETING_VERSION = 1.0;
                PRODUCT_BUNDLE_IDENTIFIER = com.hellofresh.iosdemos.ActionSheetFeature;
                PRODUCT_NAME = "$(TARGET_NAME)";
                SWIFT_EMIT_LOC_STRINGS = YES;
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = "1,2";
            };
            name = Release;
        };
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
        B2A0ED0228B4FD7000DDB478 /* Build configuration list for PBXProject "ActionSheetFeatureDemoApp" */ = {
            isa = XCConfigurationList;
            buildConfigurations = (
                B2A0ED1928B4FD7100DDB478 /* Debug */,
                B2A0ED1A28B4FD7100DDB478 /* Release */,
            );
            defaultConfigurationIsVisible = 0;
            defaultConfigurationName = Release;
        };
        B2A0ED1B28B4FD7100DDB478 /* Build configuration list for PBXNativeTarget "ActionSheetFeatureDemoApp" */ = {
            isa = XCConfigurationList;
            buildConfigurations = (
                B2A0ED1C28B4FD7100DDB478 /* Debug */,
                B2A0ED1D28B4FD7100DDB478 /* Release */,
            );
            defaultConfigurationIsVisible = 0;
            defaultConfigurationName = Release;
        };
/* End XCConfigurationList section */

/* Begin XCSwiftPackageProductDependency section */
        B25E01A328B5009100C657EC /* Dependencies */ = {
            isa = XCSwiftPackageProductDependency;
            productName = Dependencies;
        };
/* End XCSwiftPackageProductDependency section */
    };
    rootObject = B2A0ECFF28B4FD7000DDB478 /* Project object */;
}

"""
    }
}
