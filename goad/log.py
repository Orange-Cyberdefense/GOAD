from rich import print

from goad.utils import *

log_level = INFO


class Log:

    @staticmethod
    def error(message, level=INFO):
        if level >= log_level:
            print(f'[red][-] {message} [/red]')

    @staticmethod
    def warning(message, level=INFO):
        if level >= log_level:
            print(f'[yellow][-] {message} [/yellow]')

    @staticmethod
    def success(message, level=INFO):
        if level >= log_level:
            print(f'[green][+] {message} [/green]')

    @staticmethod
    def info(message, level=INFO):
        if level >= log_level:
            print(f'[cyan][*] [/cyan]{message}')

    @staticmethod
    def basic(message, level=INFO):
        if level >= log_level:
            print(f'{message}')

    @staticmethod
    def cmd(message, level=INFO):
        if level >= log_level:
            print(f'[cyan][*] [/cyan]Running command : [yellow]{message}[/yellow]')
