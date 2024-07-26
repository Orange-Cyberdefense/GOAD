from rich.table import Table
from rich import print


def show_labs_providers(labs):
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
                row_value.append('[green]X[/green]')
            else:
                row_value.append('[red]-[/red]')
        table.add_row(*row_value)

    print(table)
