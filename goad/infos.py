from goad.log import *
from rich.table import Table


def show_labs_providers_list(labs):
    for lab in labs:
        Log.success(f'*** {lab.lab_name} ***')
        for provider in lab.providers.keys():
            Log.info(f' {provider}')


def show_labs_providers_table(labs):
    table = Table(title="Labs providers")
    table.add_column('Lab')
    headers = []
    for lab in labs:
        for provider in lab.providers.keys():
            if provider not in headers:
                headers.append(provider)

    for header in headers:
        table.add_column(header)

    for lab in labs:
        row_value = [lab.lab_name]
        for header in headers:
            if header in lab.providers.keys():
                row_value.append('[green]✓[/green]')
            else:
                row_value.append('[red]X[/red]')
        table.add_row(*row_value)

    print(table)
