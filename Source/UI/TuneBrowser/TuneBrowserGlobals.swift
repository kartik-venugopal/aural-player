import Foundation

let tuneBrowserMusicFolderURL: URL = {
    
    if let volumeName = FileSystemUtils.primaryVolumeName {
        return URL(fileURLWithPath: "/Volumes/\(volumeName)\(NSHomeDirectory())/Music")
    } else {
        return AppConstants.FilesAndPaths.musicDir
    }
}()

let tuneBrowserPrimaryVolumeURL: URL = {
    
    if let volumeName = FileSystemUtils.primaryVolumeName {
        return URL(fileURLWithPath: "/Volumes/\(volumeName)")
    } else {
        return URL(fileURLWithPath: "/")
    }
}()

let tuneBrowserSidebarMusicFolder: TuneBrowserSidebarItem = TuneBrowserSidebarItem(url: tuneBrowserMusicFolderURL)
