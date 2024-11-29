from goad.command.windows import WindowsCommand
from goad.command.linux import LinuxCommand
from goad.command.wsl import WslCommand
from goad.utils import Utils


class CommandFactory:

    @staticmethod
    def get_command():
        if Utils.is_wsl():
            return WslCommand()
        elif Utils.is_windows():
            return WindowsCommand()
        return LinuxCommand()
